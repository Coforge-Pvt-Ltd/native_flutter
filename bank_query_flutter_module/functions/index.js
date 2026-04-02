const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

initializeApp();
const db = getFirestore();

exports.findNearestVectors = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 60,
    memory: "1GiB",
  },
  async (request) => {
    try {
      const {
        userId,
        vector,
        k = 20,
        collectionFilter, // optional
      } = request.data;

      // ─────────────────────────
      // Validation
      // ─────────────────────────
      if (!userId || typeof userId !== "string") {
        throw new HttpsError("invalid-argument", "userId is required");
      }

      if (!Array.isArray(vector) || vector.length !== 736) {
        throw new HttpsError(
          "invalid-argument",
          "Vector must be an array of 1536 numbers"
        );
      }

      if (typeof k !== "number" || k <= 0 || k > 100) {
        throw new HttpsError(
          "invalid-argument",
          "k must be between 1 and 100"
        );
      }

      // ─────────────────────────
      // Base query (collectionGroup ✅)
      // ─────────────────────────
      let query = db
        .collectionGroup("vector_chunks")
        .where("userId", "==", userId);

      if (collectionFilter) {
        query = query.where("collection", "==", collectionFilter);
      }

      // ─────────────────────────
      // Vector search
      // ─────────────────────────
      const snapshot = await query.findNearest({
        vectorField: "embedding",
        queryVector: FieldValue.vector(vector),
        distanceMeasure: "COSINE",
        limit: k,
      }).get();

      return {
        results: snapshot.docs.map((doc) => ({
          id: doc.id,
          path: doc.ref.path,
          collection: doc.data().collection,
          entityIds: doc.data().entityIds ?? [],
          entityTypes: doc.data().entityTypes ?? [],
          count: doc.data().count ?? 0,
          text: doc.data().text,
          updatedAt: doc.data().updatedAt ?? null,
          score: doc.data().score ?? null,
          embedding: null, // never return vectors
        })),
      };
    } catch (error) {
      console.error("Vector search failed:", error);

      if (error instanceof HttpsError) {
        throw error;
      }

      throw new HttpsError(
        "internal",
        error.message || "Vector search failed"
      );
    }
  }
);