package com.mindprotection.mind_protection.services

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent
import android.widget.Toast

class AntiUninstallDeviceAdminReceiver : DeviceAdminReceiver() {

    override fun onEnabled(context: Context, intent: Intent) {
        super.onEnabled(context, intent)
        Toast.makeText(context, "MindProtection: Device Admin Enabled", Toast.LENGTH_SHORT).show()
    }

    override fun onDisabled(context: Context, intent: Intent) {
        super.onDisabled(context, intent)
        Toast.makeText(context, "MindProtection: Device Admin Disabled", Toast.LENGTH_SHORT).show()
    }

    override fun onDisableRequested(context: Context, intent: Intent): CharSequence? {
        val prefs = context.getSharedPreferences("com.mindprotection.blocking", Context.MODE_PRIVATE)
        val isFocusActive = prefs.getBoolean("focus_active", false)

        if (isFocusActive) {
            // Retain device admin status and show warning popup
            return "MindProtection: You are in an active Deep Focus session. Admin deactivation is blocked until your timer ends!"
        }
        return null
    }
}
