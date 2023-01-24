package com.mapmetrics.orgmaps

import android.app.Activity
import android.util.Log
import app.organicmaps.DownloadResourcesLegacyActivity
import app.organicmaps.Framework
import app.organicmaps.util.StringUtils
import app.organicmaps.util.Utils
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class DownloadResourcesDelegate private constructor(private val channel: MethodChannel, private val activity: Activity) : MethodChannel.MethodCallHandler, DownloadResourcesLegacyActivity.Listener {
    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getBytesToDownload" -> {
                getBytesToDownload(result)
            }
            "reloadWorldMaps" -> {
                reloadWorldMaps(result)
            }
            "keepScreenOn" -> {
                val isOn: Boolean = call.arguments as Boolean
                Utils.keepScreenOn(isOn, activity.window)
                result.success(null)
            }
            "startNextFileDownload" -> {
                startNextFileDownload(result)
            }
            "cancelCurrentFile" -> {
                cancelCurrentFile(result)
            }
            "downloadSizeString" -> {
                downloadSizeString(result)
            }
        }
    }

    private fun getBytesToDownload(result: MethodChannel.Result) {
        val bytes = DownloadResourcesLegacyActivity.nativeGetBytesToDownload()
        Log.d(TAG, "Bytes To Download: $bytes")
        result.success(bytes)
    }

    private fun reloadWorldMaps(result: MethodChannel.Result) {
        Log.d(TAG, "Reloading world maps...")
        // World and WorldCoasts has been downloaded, we should register maps again to correctly add them to the model.
        Framework.nativeReloadWorldMaps()

        result.success(null)
    }

    private fun startNextFileDownload(result: MethodChannel.Result) {
        Log.d(TAG, "Starting next file download...")
        result.success(
            DownloadResourcesLegacyActivity.nativeStartNextFileDownload(
                this
            ))
    }

    private fun cancelCurrentFile(result: MethodChannel.Result) {
        Log.d(TAG, "Cancelling current file...")
        DownloadResourcesLegacyActivity.nativeCancelCurrentFile()
        result.success(null)
    }

    private fun downloadSizeString(result: MethodChannel.Result) {
        Log.d(TAG, "Getting download size string...")
        var bytes = DownloadResourcesLegacyActivity.nativeGetBytesToDownload()
        if (bytes < 0) {
            bytes = 0
        }

        if (bytes == 0) {
            result.success("0 B")
            return
        }

        result.success(StringUtils.getFileSizeString(activity, bytes.toLong()))
    }

    fun release() {
        channel.setMethodCallHandler(null)
    }

    companion object {
        const val TAG = "DownloadResources"

        fun make(engine: FlutterEngine, activity: Activity): DownloadResourcesDelegate {
            val channel = MethodChannel(
                engine.dartExecutor.binaryMessenger,
                "com.mapmetrics.orgmaps/download_resources"
            )

            return DownloadResourcesDelegate(channel, activity)
        }
    }

    override fun onProgress(percent: Int) {
        channel.invokeMethod("onProgress", percent)
    }

    override fun onFinish(errorCode: Int) {
        channel.invokeMethod("onFinish", errorCode)
    }
}