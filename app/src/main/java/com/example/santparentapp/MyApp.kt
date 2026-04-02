package com.example.santparentapp

import android.app.Application
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MyApp : Application() {

    companion object {
        var flutterToken: String? = null
    }

    lateinit var flutterEngine: FlutterEngine

    override fun onCreate() {
        super.onCreate()

        flutterEngine = FlutterEngine(this)

        // Updated MethodChannel to handle both Token requests and incoming Chat History
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.bank_query/token")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getToken" -> {
                        result.success(MyApp.flutterToken)
                    }
                    "sendAppLog" -> {
                        val message = call.argument<String>("message") ?: ""
                        ChatHistoryManager.addEntry(message) // Adds chat entry to History Page
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        GeneratedPluginRegistrant.registerWith(flutterEngine)
        
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )

        FlutterEngineCache.getInstance().put("my_engine_id", flutterEngine)
    }
}
