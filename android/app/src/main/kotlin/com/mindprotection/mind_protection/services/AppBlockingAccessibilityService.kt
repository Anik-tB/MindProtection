package com.mindprotection.mind_protection.services

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.widget.Toast

class AppBlockingAccessibilityService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString() ?: return
            
            // Prevent blocking the host app to avoid infinite loops
            if (packageName == "com.mindprotection.mind_protection") {
                return
            }

            val prefs = getSharedPreferences("com.mindprotection.blocking", Context.MODE_PRIVATE)
            val blockedApps = prefs.getStringSet("blocked_apps", null) ?: emptySet()
            
            if (blockedApps.contains(packageName)) {
                blockAppRedirect()
            }
        }
    }

    private fun blockAppRedirect() {
        // Redirect user to device launcher home screen
        val startMain = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(startMain)

        Toast.makeText(
            applicationContext, 
            "MindProtection: Focus Active. This app is blocked!", 
            Toast.LENGTH_LONG
        ).show()
    }

    override fun onInterrupt() {
        // Interrupt event handler no-op
    }
}
