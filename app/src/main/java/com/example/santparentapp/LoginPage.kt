package com.example.santparentapp

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch


@Composable
fun LoginPage(modifier: Modifier = Modifier) {


    var isLoading by remember { mutableStateOf(false) }

    val scope = rememberCoroutineScope()
    val sHostState = remember { SnackbarHostState() }


    Box(modifier = Modifier.fillMaxSize()) {
        Column(
            modifier = modifier
                .fillMaxSize()
                .padding(16.dp),
            verticalArrangement = Arrangement.Center
        ) {

            Box(
                modifier = Modifier.fillMaxWidth(),
                contentAlignment = Alignment.Center
            ) {
                Image(
                    painter = painterResource(id = R.drawable.bank),
                    contentDescription = "App Logo",
                    modifier = Modifier
                        .size(120.dp)
                )
            }

            Spacer(modifier = Modifier.height(24.dp))

            Button(
                onClick = {
                    scope.launch {
                        isLoading = true
                        delay(5000L)
                        isLoading = false
                        generateUUidAndShow(sHostState)
                    }

                },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Move to chat screen")
            }

            Spacer(modifier = Modifier.height(24.dp))

        }
        if (isLoading) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color.Black.copy(alpha = 0.3f))
                    .clickable(enabled = false) { },
                contentAlignment = Alignment.Center
            ) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    CircularProgressIndicator(color = Color.White)
                    Spacer(modifier = Modifier.height(8.dp))
                    Text("Please Wait", color = Color.White)
                }
            }
        }
        SnackbarHost(
            hostState = sHostState,
            modifier = Modifier.align(Alignment.BottomCenter)
        )
    }
}

suspend fun generateUUidAndShow(sHostState: SnackbarHostState) {
    val randomUUID = java.util.UUID.randomUUID().toString()
    sHostState.showSnackbar("Generated ID: $randomUUID")
//    FlutterActivity
//        .withCachedEngine("bank_engine")
//        .initialRoute("/home")
//        .build(this)
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun LoginPagePreview() {
    LoginPage(modifier = Modifier)
}