package com.vakitli.vakitli

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "vakitli/dnd"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasAccess" -> result.success(nm.isNotificationPolicyAccessGranted)
                    "openSettings" -> {
                        val intent = Intent(
                            Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS
                        ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(true)
                    }
                    "setSilent" -> {
                        if (!nm.isNotificationPolicyAccessGranted) {
                            result.success(false)
                            return@setMethodCallHandler
                        }
                        val silent = call.argument<Boolean>("silent") ?: false
                        nm.setInterruptionFilter(
                            if (silent) NotificationManager.INTERRUPTION_FILTER_NONE
                            else NotificationManager.INTERRUPTION_FILTER_ALL
                        )
                        result.success(true)
                    }
                    "isIgnoringBatteryOptimizations" -> {
                        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                        result.success(pm.isIgnoringBatteryOptimizations(packageName))
                    }
                    "requestIgnoreBatteryOptimizations" -> {
                        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                        if (pm.isIgnoringBatteryOptimizations(packageName)) {
                            result.success(true)
                        } else {
                            val intent = Intent(
                                Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                                Uri.parse("package:$packageName")
                            ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(intent)
                            result.success(true)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
