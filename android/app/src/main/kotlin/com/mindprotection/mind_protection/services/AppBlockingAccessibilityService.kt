package com.mindprotection.mind_protection.services

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import com.mindprotection.mind_protection.BlockerOverlayActivity

class AppBlockingAccessibilityService : AccessibilityService() {

    // Track last blocked package to avoid relaunching overlay repeatedly
    private var lastBlockedPackage: String = ""
    private var lastBlockedTime: Long = 0L

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString() ?: return

            // Never block our own app
            if (packageName == "com.mindprotection.mind_protection") {
                lastBlockedPackage = ""
                return
            }

            // If already showing the overlay for this package, skip
            if (packageName == "com.mindprotection.mind_protection" ||
                packageName == lastBlockedPackage &&
                System.currentTimeMillis() - lastBlockedTime < 3000L
            ) return

            val prefs = getSharedPreferences("com.mindprotection.blocking", Context.MODE_PRIVATE)
            val blockedApps = prefs.getStringSet("blocked_apps", null) ?: emptySet()

            if (blockedApps.contains(packageName)) {
                lastBlockedPackage = packageName
                lastBlockedTime = System.currentTimeMillis()
                launchBlockerOverlay(packageName)
            }
        }
    }

    private fun launchBlockerOverlay(blockedPackageName: String) {
        // Resolve human-readable app name
        val appName: String = try {
            val pm = applicationContext.packageManager
            pm.getApplicationLabel(pm.getApplicationInfo(blockedPackageName, 0)).toString()
        } catch (e: Exception) {
            blockedPackageName
        }

        val intent = Intent(applicationContext, BlockerOverlayActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("package_name", blockedPackageName)
            putExtra("app_name", appName)
        }
        startActivity(intent)
    }

    override fun onInterrupt() {
        // No-op
    }
}
