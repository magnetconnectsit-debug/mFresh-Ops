package com.example.mangnet_connect

import android.content.pm.PackageManager
import android.util.Base64
import android.util.Log
import java.security.MessageDigest
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
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
