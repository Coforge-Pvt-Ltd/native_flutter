import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart'; // ✅ correct import
import 'package:flutter/foundation.dart';

import 'embedding_service.dart';
import 'financial_entities.dart';

/// ─────────────────────────────────────────────
/// Service
/// ─────────────────────────────────────────────
class FinancialSyncService {
  FinancialSyncService({
    FirebaseFirestore? firestore,
    required EmbeddingService embeddingService,
    int writesPerEntity = 2, // raw doc + vector doc
    int firestoreWriteLimit = 500,
    this.vectorDim = 736,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _embeddingService = embeddingService {
    // Safe chunk size: 500 writes ÷ 2 writes-per-entity = 250
    _chunkSize = max(1, firestoreWriteLimit ~/ writesPerEntity);
  }

  final FirebaseFirestore _db;
  final EmbeddingService _embeddingService;
  final int vectorDim;
  late final int _chunkSize;

  // ─────────────────────────────────────────────
  // PUBLIC: Sync bulk records
  // ─────────────────────────────────────────────
  Future<void> syncBulkRecords({
    required String userId,
    required List<FinancialEntity> entities,
    required String collectionName,
  }) async {
    if (userId.isEmpty) throw ArgumentError('userId must not be empty');
    if (collectionName.isEmpty) {
      throw ArgumentError('collectionName must not be empty');
    }
    if (entities.isEmpty) {
      debugPrint('[FinancialSync] No entities to sync.');
      return;
    }

    final totalChunks = (entities.length / _chunkSize).ceil();
    debugPrint(
      '[FinancialSync] Syncing ${entities.length} entities → '
      '$totalChunks chunk(s) (chunkSize=$_chunkSize)',
    );

    for (var i = 0; i < entities.length; i += _chunkSize) {
      final chunk = entities.sublist(i, min(i + _chunkSize, entities.length));
      final chunkIndex = (i ~/ _chunkSize) + 1;
      debugPrint(
        '[FinancialSync] Processing chunk $chunkIndex / $totalChunks '
        '(${chunk.length} records)',
      );
      await _processChunk(userId, chunk, collectionName);
    }

    debugPrint('[FinancialSync] Sync complete.');
  }

  // ─────────────────────────────────────────────
  // PUBLIC: Vector search — via Cloud Function
  // ─────────────────────────────────────────────
  /// Calls a deployed Cloud Function (`findNearestVectors`) which performs
  /// server-side Firestore vector search using the Admin SDK.
  ///
  /// Returns a list of matching documents (each as a Map).
  Future<List<Map<String, dynamic>>> searchUserContext({
    required String userId,
    required List<double> queryVector,
    int limit = 20,

    /// Optional: restrict search to one entity type
    /// e.g. "transactions", "loans", "investments"
    String? collectionFilter,
  }) async {
    if (userId.isEmpty) {
      throw ArgumentError('userId must not be empty');
    }

    if (queryVector.length != vectorDim) {
      throw ArgumentError(
        'queryVector must have dimension=$vectorDim '
            '(got ${queryVector.length})',
      );
    }

    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'findNearestVectors',
        options: HttpsCallableOptions(
          timeout: Duration(seconds: 30),
        ),
      );

      final response = await callable.call({
        'userId': userId,
        'vector': queryVector,
        'k': limit,
        if (collectionFilter != null)
          'collectionFilter': collectionFilter,
      });

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        debugPrint('[FinancialSearch] Invalid response payload');
        return const [];
      }

      final rawResults = data['results'];
      if (rawResults is! List) {
        debugPrint('[FinancialSearch] No vector results returned');
        return const [];
      }

      final results = rawResults
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      if (kDebugMode) {
        debugPrint('[FinancialSearch] Found ${results.length} chunk(s)');
        for (final r in results) {
          debugPrint(
            ' → chunkId=${r['id']} '
                'collection=${r['collection']} '
                'count=${r['count']}',
          );
        }
      }

      return results;
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint(
        '[FinancialSearch] Cloud Function error: '
            'code=${e.code}, message=${e.message}',
      );
      debugPrintStack(stackTrace: st);
      rethrow;
    } catch (e, st) {
      debugPrint('[FinancialSearch] Unexpected error: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // PRIVATE: Process a single chunk
  // ─────────────────────────────────────────────
  Future<void> _processChunk(
    String userId,
    List<FinancialEntity> chunk,
    String collectionName,
  ) async {
    if (chunk.isEmpty) return;

    // 1. Build combined semantic text for the chunk
    final combinedText = chunk
        .map((e) => e.toSemanticText().trim())
        .where((t) => t.isNotEmpty)
        .join('\n\n---\n\n');

    if (combinedText.isEmpty) {
      throw StateError('Empty semantic text for chunk ($collectionName)');
    }

    // 2. Fetch SINGLE embedding for the whole chunk
    final vector = await _embeddingService.embed(combinedText);

    if (vector.length != vectorDim) {
      throw StateError(
        'Embedding dimension mismatch '
        '(expected $vectorDim, got ${vector.length})',
      );
    }

    // 3. Firestore batch
    final batch = _db.batch();

    // 3a. Write raw entities (normal docs)
    for (final entity in chunk) {
      final rawRef = _db
          .collection('users')
          .doc(userId)
          .collection(collectionName)
          .doc(entity.id);

      batch.set(rawRef, entity.toJson(), SetOptions(merge: true));
    }

    // 3b. Write SINGLE vector document for the chunk
    final chunkId = '${collectionName}_${chunk.first.id}_${chunk.last.id}';

    final vectorRef = _db
        .collection('users')
        .doc(userId)
        .collection('vector_chunks')
        .doc(chunkId);

    batch.set(
      vectorRef,
      {
        'text': combinedText,
        'embedding': VectorValue(vector),
        'userId': userId,
        'collection': collectionName,
        'entityIds': chunk.map((e) => e.id).toList(),
        'entityTypes': chunk.map((e) => e.type).toSet().toList(),
        'count': chunk.length,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // 4. Commit with retry
    await _commitWithRetry(batch);
  }

  // ─────────────────────────────────────────────
  // PRIVATE: Retry helper
  // ─────────────────────────────────────────────
  Future<void> _commitWithRetry(WriteBatch batch) async {
    const maxAttempts = 5;
    var attempt = 0;
    var delayMs = 250;

    while (true) {
      attempt++;
      try {
        await batch.commit();
        return;
      } on FirebaseException catch (e, st) {
        if (!_isRetryable(e) || attempt >= maxAttempts) {
          debugPrint(
            '[FinancialSync] Batch commit failed (attempt $attempt): '
            '${e.code} — ${e.message}',
          );
          debugPrintStack(stackTrace: st);
          rethrow;
        }
        debugPrint(
          '[FinancialSync] Transient error "${e.code}". '
          'Retrying in ${delayMs}ms (attempt $attempt)...',
        );
        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs = min(delayMs * 2, 5000);
      }
    }
  }

  bool _isRetryable(FirebaseException e) => const {
    'aborted',
    'unavailable',
    'deadline-exceeded',
    'internal',
    'resource-exhausted',
  }.contains(e.code.toLowerCase());
}


