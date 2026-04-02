package com.example.santparentapp

import androidx.compose.runtime.mutableStateListOf
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object ChatHistoryManager {
    private val _history = mutableStateListOf<ChatHistoryEntry>()
    val history: List<ChatHistoryEntry> get() = _history

    fun addEntry(message: String) {
        val timestamp = SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date())
        _history.add(0, ChatHistoryEntry(timestamp, message)) // Add at top (latest first)
    }

    fun clearHistory() {
        _history.clear()
    }
}

data class ChatHistoryEntry(val timestamp: String, val message: String)
