package com.example.aia_project

import android.app.Service
import android.content.Intent
import android.os.IBinder

class AIAForegroundService : Service() {

    override fun onBind(intent: Intent): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // This is where we will start the hotword detection
        return START_STICKY
    }
}
