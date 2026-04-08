package com.example.santparentapp

import android.content.Context
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
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngineCache
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch


@Composable
fun LoginPage(modifier: Modifier = Modifier) {
    val context = LocalContext.current
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
                        LogManager.addLog("Login button clicked. Starting UUID generation...")
                        // Delay is necessary to let Compose render the loader
                        delay(1000L) 
                        launchFlutterWithToken(context, onComplete = { 
                            isLoading = false 
                        })
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

fun launchFlutterWithToken(context: Context, onComplete: () -> Unit) {
    val randomUUID = java.util.UUID.randomUUID().toString()
    LogManager.addLog("Generated Token: $randomUUID")

    // 1. Update the companion object variable in MyApp
    MyApp.flutterToken = randomUUID
    LogManager.addLog("Updated MyApp.flutterToken")

    // 2. Push the new token to the Flutter engine via Pigeon
    val engine = FlutterEngineCache.getInstance().get("my_engine_id")
    if (engine != null) {
        LogManager.addLog("Cached Flutter Engine found. Pushing token via Pigeon...")
        val flutterApi = FlutterTokenApi(engine.dartExecutor.binaryMessenger)
        flutterApi.onTokenReceived(TokenPayload(token = randomUUID, route = "/chat")) {}
    } else {
        LogManager.addLog("WARNING: Cached Flutter Engine NOT FOUND!")
    }

    // 3. Launch the activity
    LogManager.addLog("Launching FlutterActivity...")
    context.startActivity(
        FlutterActivity
            .withCachedEngine("my_engine_id")
            .build(context)
    )
    
    // Callback to stop loading
    onComplete()
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun LoginPagePreview() {
    LoginPage(modifier = Modifier)
}
