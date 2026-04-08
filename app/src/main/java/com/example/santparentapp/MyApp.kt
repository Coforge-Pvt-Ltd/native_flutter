package com.example.santparentapp

import android.app.Application
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugins.GeneratedPluginRegistrant

class MyApp : Application(), NativeApi {

    companion object {
        var flutterToken: String? = null
    }

    lateinit var flutterEngine: FlutterEngine

    override fun onCreate() {
        super.onCreate()

        flutterEngine = FlutterEngine(this)

        NativeApi.setUp(flutterEngine.dartExecutor.binaryMessenger, this)


        GeneratedPluginRegistrant.registerWith(flutterEngine)

        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )

        FlutterEngineCache.getInstance().put("my_engine_id", flutterEngine)
    }

    override fun getToken(): String? {
        return flutterToken
    }

    override fun sendAppLog(message: String) {
        ChatHistoryManager.addEntry(message)
    }
}
