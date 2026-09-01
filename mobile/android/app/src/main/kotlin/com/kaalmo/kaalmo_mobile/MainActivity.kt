package com.kaalmo.kaalmo_mobile

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
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

        // Android 13+ requires the POST_NOTIFICATIONS runtime permission before
        // the system will display ANY notification (foreground system, background
        // or terminated). firebase_messaging's requestPermission() usually asks,
        // but this native request is a reliable fallback so the OS dialog is
        // shown once on a real device. Denied is fine — the app keeps working
        // with in-app notifications only.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val granted = ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) ==
                PackageManager.PERMISSION_GRANTED
            if (!granted) {
                ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.POST_NOTIFICATIONS), 1001)
            }
        }
    }
}
