package com.example.santparentapp

import androidx.compose.runtime.mutableStateListOf
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object LogManager {
    private val _logs = mutableStateListOf<LogEntry>()
    val logs: List<LogEntry> get() = _logs

    fun addLog(message: String) {
        val timestamp = SimpleDateFormat("HH:mm:ss.SSS", Locale.getDefault()).format(Date())
        _logs.add(0, LogEntry(timestamp, message)) // Add at top
    }

    fun clearLogs() {
        _logs.clear()
    }
}

data class LogEntry(val timestamp: String, val message: String)
