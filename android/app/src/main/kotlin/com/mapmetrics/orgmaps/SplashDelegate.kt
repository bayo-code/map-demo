package com.mapmetrics.orgmaps

import android.Manifest.permission
import android.app.Activity
import android.content.Intent
import android.util.Log
import androidx.core.app.ActivityCompat
import app.organicmaps.MwmApplication
import app.organicmaps.SplashActivity
import app.organicmaps.downloader.CountryItem
import app.organicmaps.downloader.MapManager
import app.organicmaps.location.LocationHelper
import app.organicmaps.util.Config
import app.organicmaps.util.Counters
import app.organicmaps.util.LocationUtils
import com.google.gson.Gson
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.IOException

class SplashDelegate private constructor(private val channel: MethodChannel, private val activity: Activity) : MethodChannel.MethodCallHandler {

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init" -> {
                init(result)
            }
        }
    }

    private fun init(result: MethodChannel.Result) {
        val app = MwmApplication.from(activity)
        try {
            app.init()
        } catch (e: IOException) {
            result.error("100", e.message, null)
            channel.invokeMethod("onError", mapOf(
                "title" to activity.getString(R.string.dialog_error_storage_title),
                "message" to activity.getString(R.string.dialog_error_storage_message),
            ))
            return
        }
        if (Counters.isFirstLaunch(activity) && LocationUtils.isLocationGranted(
                activity
            )
        ) {
            LocationHelper.INSTANCE.onEnteredIntoFirstRun()
            if (!LocationHelper.INSTANCE.isActive) LocationHelper.INSTANCE.start()
        }

        Counters.setFirstStartDialogSeen(activity)

        result.success(true)
    }

    fun resume() {
        if (!Config.isLocationRequested() && !LocationUtils.isLocationGranted(activity)) {
            ActivityCompat.requestPermissions(
                activity, arrayOf(
                    permission.ACCESS_COARSE_LOCATION,
                    permission.ACCESS_FINE_LOCATION
                ), SplashActivity.REQUEST_PERMISSIONS
            )
            return
        }
    }

    fun release() {
        channel.setMethodCallHandler(null)
    }

    fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<out String>,
        grantResults: IntArray
    ) {
        if (requestCode == SplashActivity.REQUEST_PERMISSIONS) {
            Config.setLocationRequested()
        }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
//        if (requestCode == SplashActivity.REQ_CODE_API_RESULT) {
//            setResult(resultCode, data)
//            finish()
//        }
    }

    companion object {
        const val TAG = "SplashDelegate"

        fun make(engine: FlutterEngine, activity: Activity): SplashDelegate {
            val channel =
                MethodChannel(engine.dartExecutor.binaryMessenger, "com.mapmetrics.orgmaps/splash")
            return SplashDelegate(channel, activity)
        }
    }
}