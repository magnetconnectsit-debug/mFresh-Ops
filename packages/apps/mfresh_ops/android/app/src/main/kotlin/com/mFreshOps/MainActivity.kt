package com.mFreshOps

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "PLUTUS-API"
    private val PINELABS_REQUEST_CODE = 2001
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getCameraCount" -> {
                    try {
                        val manager = getSystemService(android.content.Context.CAMERA_SERVICE) as android.hardware.camera2.CameraManager
                        result.success(manager.cameraIdList.size)
                    } catch (e: Exception) {
                        result.success(0)
                    }
                }
                "startTransaction" -> {
                    val transactionData = call.argument<String>("transactionData")
                    if (transactionData != null) {
                        startPineLabsActivity(transactionData, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Transaction data is null", null)
                    }
                }
                "bindToService" -> {
                    result.success("BINDING SUCCESS.")
                }
                "startPrintJob" -> {
                    val printData = call.argument<String>("printData")
                    if (printData != null) {
                        startPineLabsActivity(printData, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Print data is null", null)
                    }
                }
                "startScanner" -> {
                    val scannerData = call.argument<String>("scannerData")
                    if (scannerData != null) {
                        startPineLabsActivity(scannerData, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Scanner data is null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun startPineLabsActivity(data: String, result: MethodChannel.Result) {
        try {
            pendingResult = result
            val intent = Intent("com.pinelabs.masterapp.HYBRID_REQUEST")
            intent.setPackage("com.pinelabs.masterapp")
            intent.putExtra("p_request_data", data)
            
            Log.d("PLUTUS-BRIDGE", "Starting PineLabs Intent with data: $data")
            startActivityForResult(intent, PINELABS_REQUEST_CODE)
        } catch (e: Exception) {
            Log.e("PLUTUS-BRIDGE", "Error starting PineLabs activity: ${e.message}")
            result.error("INTENT_ERROR", e.message, null)
            pendingResult = null
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == PINELABS_REQUEST_CODE) {
            val response = data?.getStringExtra("p_response_data")
            Log.d("PLUTUS-BRIDGE", "Received PineLabs Response: $response")
            
            if (pendingResult != null) {
                if (response != null) {
                    pendingResult?.success(response)
                } else {
                    pendingResult?.error("NULL_RESPONSE", "No response received from PineLabs", null)
                }
                pendingResult = null
            }
        }
    }
}
