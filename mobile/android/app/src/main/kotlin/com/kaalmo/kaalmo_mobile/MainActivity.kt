package com.kaalmo.kaalmo_mobile

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Create the default FCM notification channel referenced by the
        // `default_notification_channel_id` manifest meta-data. Without this an
        // Android 8+ device falls back to an unnamed "Miscellaneous" channel.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (manager.getNotificationChannel("kaalmo_default") == null) {
                manager.createNotificationChannel(
                    NotificationChannel(
                        "kaalmo_default",
                        getString(R.string.notif_channel_default_name),
                        NotificationManager.IMPORTANCE_HIGH,
                    ).apply {
                        description = getString(R.string.notif_channel_default_desc)
                    }
                )
            }
        }
    }
}
