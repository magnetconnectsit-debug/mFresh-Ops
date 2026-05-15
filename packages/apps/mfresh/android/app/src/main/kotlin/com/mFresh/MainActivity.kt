package com.mFresh

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log
import android.content.pm.PackageManager
import android.util.Base64
import java.security.MessageDigest
import org.json.JSONObject

class MainActivity: FlutterActivity() {
    private val CHANNEL = "PLUTUS-API"
    private val PINELABS_REQUEST_CODE = 2001 // Unique code to avoid conflict with PhonePe (1001)
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
                    // Simple acknowledgement for compatibility
                    result.success("BINDING SUCCESS.")
                }
                "startPrintJob" -> {
                    val printData = call.argument<String>("printData")
                    if (printData != null) {
                        startPineLabsActivity(printData, result, isPrint = true)
                    } else {
                        result.error("INVALID_ARGUMENT", "Print data is null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun startPineLabsActivity(data: String, result: MethodChannel.Result, isPrint: Boolean = false) {
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

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        printPackageSignature()
    }

    private fun printPackageSignature() {
        try {
            val packageName = packageName
            val packageInfo = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
                packageManager.getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(PackageManager.GET_SIGNATURES.toLong()))
            } else {
                @Suppress("DEPRECATION")
                packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
            }

            val signatures = packageInfo.signatures
            if (signatures != null) {
                for (signature in signatures) {
                    val md = MessageDigest.getInstance("SHA-256")
                    md.update(signature.toByteArray())
                    val signatureBase64 = Base64.encodeToString(md.digest(), Base64.NO_WRAP)
                    Log.e("PHONEPE_SIGNATURE", "################################################")
                    Log.e("PHONEPE_SIGNATURE", "YOUR PACKAGE SIGNATURE: $signatureBase64")
                    Log.e("PHONEPE_SIGNATURE", "################################################")
                }
            }
        } catch (e: Exception) {
            Log.e("PHONEPE_SIGNATURE", "Error getting signature: ${e.message}")
        }
    }
}
