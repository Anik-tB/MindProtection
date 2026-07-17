package com.mindprotection.mind_protection

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.Gravity
import android.view.WindowManager
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView

/**
 * Full-screen blocker overlay shown when user opens a blocked app.
 * Launched by AppBlockingAccessibilityService instead of bouncing to home.
 * Cannot be swiped away — only the "Go Back" button dismisses it.
 */
class BlockerOverlayActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Make it look full-screen and on top
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
        )

        val blockedApp   = intent.getStringExtra("app_name") ?: "This app"
        val blockedPkg   = intent.getStringExtra("package_name") ?: ""
        val initialLetter = if (blockedApp.isNotEmpty()) blockedApp[0].toString().uppercase() else "?"

        // ── Root background ──────────────────────────────────────────────────
        val root = FrameLayout(this).apply {
            setBackgroundColor(0xFF070A14.toInt())
        }

        // ── Center column ───────────────────────────────────────────────────
        val column = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setPadding(80, 0, 80, 0)
        }

        // Shield emoji
        val emoji = TextView(this).apply {
            text = "\uD83D\uDEE1\uFE0F"
            textSize = 64f
            gravity = Gravity.CENTER
        }

        // App initial avatar circle (drawn via background tint + text)
        val avatarText = TextView(this).apply {
            text = initialLetter
            textSize = 36f
            gravity = Gravity.CENTER
            setTextColor(0xFF070A14.toInt())
            val bgDrawable = android.graphics.drawable.GradientDrawable().apply {
                shape = android.graphics.drawable.GradientDrawable.OVAL
                setColor(0xFF00F5A0.toInt())
                setSize(160, 160)
            }
            background = bgDrawable
            layoutParams = LinearLayout.LayoutParams(160, 160).apply {
                topMargin = 32
                bottomMargin = 32
                gravity = Gravity.CENTER_HORIZONTAL
            }
        }

        // Title
        val title = TextView(this).apply {
            text = "App Blocked"
            textSize = 28f
            setTextColor(0xFFFFFFFF.toInt())
            gravity = Gravity.CENTER
            typeface = android.graphics.Typeface.DEFAULT_BOLD
        }

        // App name
        val appNameView = TextView(this).apply {
            text = blockedApp
            textSize = 16f
            setTextColor(0xFF00F5A0.toInt())
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply { topMargin = 8 }
        }

        // Motivational message
        val message = TextView(this).apply {
            text = "You're in Deep Focus mode.\nStay locked in. You've got this. \uD83D\uDCAA"
            textSize = 14f
            setTextColor(0xFFAAAAAA.toInt())
            gravity = Gravity.CENTER
            setLineSpacing(0f, 1.4f)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply { topMargin = 20; bottomMargin = 48 }
        }

        // Go Back button
        val backBtn = Button(this).apply {
            text = "Go Back to Focus"
            textSize = 15f
            setTextColor(0xFF070A14.toInt())
            setBackgroundColor(0xFF00F5A0.toInt())
            val btnBackground = android.graphics.drawable.GradientDrawable().apply {
                cornerRadius = 40f
                setColor(0xFF00F5A0.toInt())
            }
            background = btnBackground
            setPadding(60, 30, 60, 30)
            setOnClickListener { finish() }
        }

        column.addView(emoji)
        column.addView(avatarText)
        column.addView(title)
        column.addView(appNameView)
        column.addView(message)
        column.addView(backBtn)

        val centerParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.WRAP_CONTENT,
            Gravity.CENTER
        )
        root.addView(column, centerParams)
        setContentView(root)
    }

    // Prevent back button from exiting to blocked app
    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        // Intentionally blocked — user must tap "Go Back to Focus"
    }
}
