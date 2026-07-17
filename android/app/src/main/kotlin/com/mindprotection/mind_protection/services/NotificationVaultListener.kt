package com.mindprotection.mind_protection.services

import android.content.Context
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class NotificationVaultListener : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val packageName = sbn.packageName ?: return

        // Do not intercept notifications from the host app
        if (packageName == "com.mindprotection.mind_protection") {
            return
        }

        val prefs = getSharedPreferences("com.mindprotection.blocking", Context.MODE_PRIVATE)
        val blockedApps = prefs.getStringSet("blocked_apps", null) ?: emptySet()
        val isFocusActive = prefs.getBoolean("focus_active", false)

        // Intercept if focus is active or app is on the blocklist
        if (isFocusActive || blockedApps.contains(packageName)) {
            cancelNotification(sbn.key)
            saveToVault(packageName, sbn)
        }
    }

    private fun saveToVault(packageName: String, sbn: StatusBarNotification) {
        val extras = sbn.notification.extras
        val title = extras.getString("android.title") ?: "Notification"
        val text = extras.getCharSequence("android.text")?.toString() ?: ""

        val prefs = getSharedPreferences("com.mindprotection.blocking", Context.MODE_PRIVATE)
        val vaultItems = prefs.getStringSet("vault_notifications", null)?.toMutableSet() ?: mutableSetOf()
        
        // Save format payload: packageName|title|text|timestamp
        val timestamp = System.currentTimeMillis()
        val entry = "$packageName|$title|$text|$timestamp"
        vaultItems.add(entry)
        
        prefs.edit().putStringSet("vault_notifications", vaultItems).apply()
    }
}
