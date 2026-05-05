package com.example.mangnet_connect
import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.IBinder
import android.util.Log

class PlutusSmartService : Service() {
    private val binder = LocalBinder()

    inner class LocalBinder : Binder() {
        fun getService(): PlutusSmartService = this@PlutusSmartService
    }

    override fun onBind(intent: Intent?): IBinder {
        return binder
    }

    override fun onCreate() {
        super.onCreate()
        Log.d("PlutusSmartService", "Service created")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d("PlutusSmartService", "Service destroyed")
    }

    fun processTransaction(payload: String): String {
        Log.d("PlutusSmartService", "Processing transaction with payload: $payload")
        return """{
            "ResponseCode": "00",
            "ResponseMsg": "Transaction successful",
            "TransactionId": "TX12345678"
        }"""
    }
}
