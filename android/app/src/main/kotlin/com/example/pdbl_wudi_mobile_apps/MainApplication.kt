// android/app/src/main/kotlin/com/example/pdbl_wudi_mobile_apps/MainApplication.kt
package com.example.pdbl_wudi_mobile_apps

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import io.flutter.app.FlutterApplication

class MainApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        createJarvisNotificationChannel()
    }

    private fun createJarvisNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "jarvis_voice_channel",
                "Jarvis Voice Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Used for Jarvis background voice assistant"
                setShowBadge(false)
            }

            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }
}
