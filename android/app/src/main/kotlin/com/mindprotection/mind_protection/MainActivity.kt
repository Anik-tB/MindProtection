package com.mindprotection.mind_protection

import android.app.AppOpsManager
import android.app.admin.DevicePolicyManager
import android.app.usage.UsageStatsManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Process
import android.provider.Settings
import android.text.TextUtils
import com.mindprotection.mind_protection.services.AntiUninstallDeviceAdminReceiver
import com.mindprotection.mind_protection.services.WellbeingForegroundService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.Manifest
import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.mindprotection.mind_protection.services.NotificationAlarmReceiver
import java.util.Calendar

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.mindprotection.blocking"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkUsageStatsPermission" -> {
                    result.success(hasUsageStatsPermission())
                }
                "requestUsageStatsPermission" -> {
                    val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "checkAccessibilityPermission" -> {
                    result.success(isAccessibilityServiceEnabled())
                }
                "requestAccessibilityPermission" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "checkNotificationListenerPermission" -> {
                    result.success(isNotificationListenerEnabled())
                }
                "requestNotificationListenerPermission" -> {
                    val intent = Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS").apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "checkDeviceAdminActive" -> {
                    result.success(isDeviceAdminActive())
                }
                "requestDeviceAdminPermission" -> {
                    val componentName = ComponentName(this, AntiUninstallDeviceAdminReceiver::class.java)
                    val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
                        putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, componentName)
                        putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION, "Secures your study sessions, prevents uninstallation during Deep Focus, and allows emergency device locking.")
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "updateBlockedApps" -> {
                    val packages = call.argument<List<String>>("packages")?.toSet() ?: emptySet()
                    val prefs = getSharedPreferences("com.mindprotection.blocking", Context.MODE_PRIVATE)
                    prefs.edit().putStringSet("blocked_apps", packages).apply()
                    result.success(true)
                }
                "setFocusActive" -> {
                    val active = call.argument<Boolean>("active") ?: false
                    val prefs = getSharedPreferences("com.mindprotection.blocking", Context.MODE_PRIVATE)
                    prefs.edit().putBoolean("focus_active", active).apply()
                    result.success(true)
                }
                "triggerEmergencyLock" -> {
                    val devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
                    val componentName = ComponentName(this, AntiUninstallDeviceAdminReceiver::class.java)
                    if (devicePolicyManager.isAdminActive(componentName)) {
                        devicePolicyManager.lockNow()
                        result.success(true)
                    } else {
                        result.error("ADMIN_INACTIVE", "Device Admin is not active", null)
                    }
                }
                "startForegroundService" -> {
                    val intent = Intent(this, WellbeingForegroundService::class.java)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    } else {
                        startService(intent)
                    }
                    result.success(true)
                }
                "stopForegroundService" -> {
                    val intent = Intent(this, WellbeingForegroundService::class.java)
                    stopService(intent)
                    result.success(true)
                }
                "getBlockedApps" -> {
                    val prefs = getSharedPreferences("com.mindprotection.blocking", Context.MODE_PRIVATE)
                    val blocked = prefs.getStringSet("blocked_apps", emptySet()) ?: emptySet()
                    result.success(blocked.toList())
                }
                "getUsageStats" -> {
                    if (!hasUsageStatsPermission()) {
                        result.error("PERMISSION_DENIED", "Usage Stats permission not granted", null)
                    } else {
                        result.success(getAppUsageStats())
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.mindprotection.notifications").setMethodCallHandler { call, result ->
            when (call.method) {
                "checkPermission" -> {
                    val granted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
                    } else {
                        true
                    }
                    result.success(granted)
                }
                "requestPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.POST_NOTIFICATIONS), 101)
                    }
                    result.success(true)
                }
                "showInstantNotification" -> {
                    val id = call.argument<Int>("id") ?: 1000
                    val title = call.argument<String>("title") ?: "MindProtection Reminder"
                    val body = call.argument<String>("body") ?: "Time to lock in and focus!"
                    showInstantNotification(id, title, body)
                    result.success(true)
                }
                "scheduleDailyReminder" -> {
                    val id = call.argument<Int>("id") ?: 1001
                    val title = call.argument<String>("title") ?: "Focus Reminder"
                    val body = call.argument<String>("body") ?: "Ready for a high-focus session?"
                    val hour = call.argument<Int>("hour") ?: 8
                    val minute = call.argument<Int>("minute") ?: 0
                    scheduleDailyAlarm(id, title, body, hour, minute)
                    result.success(true)
                }
                "cancelReminder" -> {
                    val id = call.argument<Int>("id") ?: 1001
                    cancelDailyAlarm(id)
                    result.success(true)
                }
                "getVaultNotifications" -> {
                    val prefs = getSharedPreferences("com.mindprotection.blocking", Context.MODE_PRIVATE)
                    val vaultItems = prefs.getStringSet("vault_notifications", emptySet()) ?: emptySet()
                    result.success(vaultItems.toList())
                }
                "clearVaultNotifications" -> {
                    val prefs = getSharedPreferences("com.mindprotection.blocking", Context.MODE_PRIVATE)
                    prefs.edit().remove("vault_notifications").apply()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
        } else {
            appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val accessibilityEnabled = Settings.Secure.getInt(
            contentResolver,
            Settings.Secure.ACCESSIBILITY_ENABLED,
            0
        )
        if (accessibilityEnabled == 1) {
            val service = "$packageName/com.mindprotection.mind_protection.services.AppBlockingAccessibilityService"
            val settingValue = Settings.Secure.getString(
                contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
            )
            if (settingValue != null) {
                val splitter = TextUtils.SimpleStringSplitter(':')
                splitter.setString(settingValue)
                while (splitter.hasNext()) {
                    val accessibilityService = splitter.next()
                    if (accessibilityService.equals(service, ignoreCase = true)) {
                        return true
                    }
                }
            }
        }
        return false
    }

    private fun isNotificationListenerEnabled(): Boolean {
        val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
        return flat != null && flat.contains(packageName)
    }

    private fun isDeviceAdminActive(): Boolean {
        val devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val componentName = ComponentName(this, AntiUninstallDeviceAdminReceiver::class.java)
        return devicePolicyManager.isAdminActive(componentName)
    }

    private fun getAppUsageStats(): List<Map<String, Any>> {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val calendar = Calendar.getInstance()
        // End: now
        val endTime = calendar.timeInMillis
        // Start: midnight today
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val startTime = calendar.timeInMillis

        val usageStatsList = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY, startTime, endTime
        )

        val pm: PackageManager = packageManager
        val result = mutableListOf<Map<String, Any>>()

        if (usageStatsList != null) {
            for (usageStats in usageStatsList) {
                val pkg = usageStats.packageName
                // Skip our own app
                if (pkg == packageName) continue
                val totalMs = usageStats.totalTimeInForeground
                if (totalMs <= 0L) continue
                val minutes = (totalMs / 1000 / 60).toInt()
                if (minutes <= 0) continue

                // Resolve human-readable app name
                val appName: String = try {
                    pm.getApplicationLabel(pm.getApplicationInfo(pkg, 0)).toString()
                } catch (e: PackageManager.NameNotFoundException) {
                    pkg
                }

                result.add(
                    mapOf(
                        "packageName" to pkg,
                        "appName" to appName,
                        "usageMinutes" to minutes
                    )
                )
            }
        }

        // Sort by usage descending
        return result.sortedByDescending { it["usageMinutes"] as Int }
    }

    private fun showInstantNotification(id: Int, title: String, body: String) {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channelId = "mindprotection_reminders"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "MindProtection Reminders & Nudges",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Daily focus kickoff, evening reflection, and streak reminders"
                enableVibration(true)
            }
            nm.createNotificationChannel(channel)
        }

        val tapIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingTap = PendingIntent.getActivity(
            this,
            id,
            tapIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingTap)
            .build()

        nm.notify(id, notification)
    }

    private fun scheduleDailyAlarm(id: Int, title: String, body: String, hour: Int, minute: Int) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, NotificationAlarmReceiver::class.java).apply {
            putExtra("id", id)
            putExtra("title", title)
            putExtra("body", body)
            putExtra("isDaily", true)
            putExtra("hour", hour)
            putExtra("minute", minute)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val calendar = Calendar.getInstance().apply {
            timeInMillis = System.currentTimeMillis()
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }

        if (calendar.timeInMillis <= System.currentTimeMillis()) {
            calendar.add(Calendar.DAY_OF_YEAR, 1)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, pendingIntent)
        }
    }

    private fun cancelDailyAlarm(id: Int) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, NotificationAlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        alarmManager.cancel(pendingIntent)
    }
}
