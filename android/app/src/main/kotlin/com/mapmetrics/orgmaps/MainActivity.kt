package com.mapmetrics.orgmaps

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class MainActivity: FlutterActivity() {
    var downloadResourcesDelegate: DownloadResourcesDelegate? = null
    var splashDelegate: SplashDelegate? = null

    var mapDelegate: MapDelegate? = null

    val mapViewFactory: PlatformViewFactory = object: PlatformViewFactory(StandardMessageCodec.INSTANCE) {
        override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
            mapDelegate = MapDelegate.make(flutterEngine!!, this@MainActivity).apply {
                onDisposeListener = {
                    mapDelegate = null
                    onDisposeListener = null
                }
            }

            return mapDelegate!!
        }

    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        flutterEngine.platformViewsController
            .registry
            .registerViewFactory("map-ui", mapViewFactory)

        splashDelegate = SplashDelegate.make(flutterEngine, this)
        downloadResourcesDelegate = DownloadResourcesDelegate.make(flutterEngine, this)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)

        splashDelegate?.release()
        splashDelegate = null

        downloadResourcesDelegate?.release()
        downloadResourcesDelegate = null
    }

    override fun onStart() {
        super.onStart()
        mapDelegate?.onStart()
    }

    override fun onStop() {
        mapDelegate?.onStop()
        super.onStop()
    }

    override fun onPause() {
        mapDelegate?.onPause()
        super.onPause()
    }

    override fun onResume() {
        mapDelegate?.onResume()
        super.onResume()
        splashDelegate?.resume()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        splashDelegate?.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }
}
