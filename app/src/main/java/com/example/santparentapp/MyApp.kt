package com.example.santparentapp

import android.app.Application



class MyApp : Application() {

    lateinit var flutterEngine: FlutterEngine

    override fun onCreate() {
        super.onCreate()

        // Create and pre-warm Flutter engine
        flutterEngine = FlutterEngine(this)
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )

        // Cache it
        FlutterEngineCache.getInstance()
            .put("my_engine_id", flutterEngine)
    }


}