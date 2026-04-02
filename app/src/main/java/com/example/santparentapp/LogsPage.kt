package com.example.santparentapp

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun ChatHistoryPage(modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .background(Color(0xFFF8F9FA))
            .padding(16.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Chat History",
                style = MaterialTheme.typography.headlineSmall.copy(fontWeight = FontWeight.Bold),
                modifier = Modifier.weight(1f)
            )
            TextButton(onClick = { ChatHistoryManager.clearHistory() }) {
                Text("Clear", color = Color.Red)
            }
        }
        
        Text(
            text = "Conversation logs from your AI assistant sessions.",
            style = MaterialTheme.typography.bodySmall,
            color = Color.Gray
        )
        
        Spacer(modifier = Modifier.height(16.dp))
        
        if (ChatHistoryManager.history.isEmpty()) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Text("No chat history available.", color = Color.LightGray)
            }
        } else {
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                items(ChatHistoryManager.history) { entry ->
                    ChatHistoryCard(entry)
                }
            }
        }
    }
}

@Composable
fun ChatHistoryCard(entry: ChatHistoryEntry) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
    ) {
        Column(modifier = Modifier.padding(12.dp)) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                val isUser = entry.message.startsWith("User:")
                val isSystem = entry.message.startsWith("System Error:")
                
                val label = when {
                    isUser -> "YOU"
                    isSystem -> "SYSTEM"
                    else -> "FINAI"
                }
                
                val labelColor = when {
                    isUser -> Color(0xFF1976D2)
                    isSystem -> Color.Red
                    else -> Color(0xFF388E3C)
                }

                Text(
                    text = label,
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold,
                    color = labelColor
                )
                Text(
                    text = entry.timestamp,
                    fontSize = 10.sp,
                    color = Color.Gray
                )
            }
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = entry.message.removePrefix("User: ").removePrefix("FinAI: "),
                style = MaterialTheme.typography.bodyMedium
            )
        }
    }
}
