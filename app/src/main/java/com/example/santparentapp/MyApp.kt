package com.example.santparentapp

import android.app.Application
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugins.GeneratedPluginRegistrant

class MyApp : Application() {

    lateinit var flutterEngine: FlutterEngine

    override fun onCreate() {
        super.onCreate()

        // 1. Create and pre-warm Flutter engine
        flutterEngine = FlutterEngine(this)

        // 2. Register plugins (CRITICAL for Firebase, TTS, etc.)
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        // 3. Start executing Dart code
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )

        // 4. Cache it
        FlutterEngineCache.getInstance()
            .put("my_engine_id", flutterEngine)
    }
}
