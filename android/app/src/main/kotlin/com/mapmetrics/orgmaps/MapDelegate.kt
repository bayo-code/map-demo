package com.mapmetrics.orgmaps

import android.annotation.SuppressLint
import android.app.Activity
import android.os.Build
import android.util.DisplayMetrics
import android.util.Log
import android.view.MotionEvent
import android.view.SurfaceHolder
import android.view.SurfaceView
import android.view.View
import androidx.core.content.res.ConfigurationHelper
import app.organicmaps.Map
import app.organicmaps.MapRenderingListener
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class MapDelegate private constructor(channel: MethodChannel, private val activity: Activity) : PlatformView, MethodChannel.MethodCallHandler, SurfaceHolder.Callback, View.OnTouchListener, MapRenderingListener
{

    var onDisposeListener: (() -> Unit)? = null
    private val map = Map()

    init {
        channel.setMethodCallHandler(this)

        map.setMapRenderingListener(this)
        map.setCallbackUnsupported {  }
        map.onCreate(false)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    }

    override fun surfaceCreated(holder: SurfaceHolder) {

        val densityDpi: Int = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) ConfigurationHelper.getDensityDpi(
            activity.resources
        ) else getDensityDpiOld()

        map.onSurfaceCreated(
            activity,
            holder.surface,
            holder.surfaceFrame,
            densityDpi
        )
    }

    override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        map.onSurfaceChanged(
            activity,
            holder.surface,
            holder.surfaceFrame,
            holder.isCreating
        )
    }

    override fun surfaceDestroyed(holder: SurfaceHolder) {
        destroySurface()
    }

    fun onStart() {
        map.onStart()
    }

    fun onStop() {
        map.onStop()
    }

    fun onPause() {
        map.onPause(activity)
    }

    fun onResume() {
        map.onResume()
    }

    @SuppressLint("ClickableViewAccessibility")
    override fun onTouch(v: View?, event: MotionEvent?): Boolean {
        var action = event!!.actionMasked
        var pointerIndex = event.actionIndex
        when (action) {
            MotionEvent.ACTION_POINTER_UP -> action = Map.NATIVE_ACTION_UP
            MotionEvent.ACTION_UP -> {
                action = Map.NATIVE_ACTION_UP
                pointerIndex = 0
            }
            MotionEvent.ACTION_POINTER_DOWN -> action = Map.NATIVE_ACTION_DOWN
            MotionEvent.ACTION_DOWN -> {
                action = Map.NATIVE_ACTION_DOWN
                pointerIndex = 0
            }
            MotionEvent.ACTION_MOVE -> {
                action = Map.NATIVE_ACTION_MOVE
                pointerIndex = Map.INVALID_POINTER_MASK
            }
            MotionEvent.ACTION_CANCEL -> action = Map.NATIVE_ACTION_CANCEL
        }
        Map.onTouch(action, event, pointerIndex)
        return true
    }

    private fun getDensityDpiOld(): Int {
        val metrics = DisplayMetrics()
        activity.windowManager.defaultDisplay.getMetrics(metrics)
        return metrics.densityDpi
    }

    override fun getView(): View? {
        val inflater = activity.layoutInflater
        val view = inflater.inflate(R.layout.fragment_map, null)

        val surfaceView = view.findViewById<SurfaceView>(R.id.map_surfaceview)
        surfaceView.holder.addCallback(this)

        view.setOnTouchListener(this)

        return view
    }

    override fun dispose() {
        map.setMapRenderingListener(null)
        map.setCallbackUnsupported(null)

        onDisposeListener?.let { it() }
    }

    companion object {
        const val TAG = "MapDelegate"

        fun make(engine: FlutterEngine, activity: Activity): MapDelegate {
            val channel = MethodChannel(engine.dartExecutor.binaryMessenger, "com.mapmetrics.orgmaps/map")
            return MapDelegate(channel, activity)
        }
    }

    fun adjustCompass(offsetX: Int, offsetY: Int) {
        map.setupCompass(activity, offsetX, offsetY, true)
    }

    fun adjustBottomWidgets(offsetX: Int, offsetY: Int) {
        map.setupBottomWidgetsOffset(activity, offsetX, offsetY)
    }

    private fun destroySurface() {
        map.onSurfaceDestroyed(activity.isChangingConfigurations, true)
    }

    fun isContextCreated(): Boolean {
        return map.isContextCreated
    }

    override fun onRenderingCreated() {
        Log.d(TAG, "Rendering created")
    }

    override fun onRenderingRestored() {
        Log.d(TAG, "Rendering restored")
    }

    override fun onRenderingInitializationFinished() {
        Log.d(TAG, "Rendering initialization finished")
    }

}