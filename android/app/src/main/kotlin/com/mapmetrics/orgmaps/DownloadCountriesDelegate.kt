package com.mapmetrics.orgmaps

import android.app.Activity
import app.organicmaps.downloader.CountryItem
import app.organicmaps.downloader.MapManager
import com.google.gson.Gson
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class DownloadCountriesDelegate private constructor(
        private val channel: MethodChannel,
        private val activity: Activity) : MethodChannel.MethodCallHandler,
MapManager.StorageCallback {

    private var subscriberSlot = 0

    init {
        channel.setMethodCallHandler(this)
    }

    private fun init(result: MethodChannel.Result) {
        subscriberSlot = MapManager.nativeSubscribe(this)
        result.success(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init" -> {
                init(result)
            }
            "dispose" -> {
                dispose(result)
            }
            "getCountries" -> {
                getCountries(result)
            }
            "downloadCountry" -> {
                val countryId = call.argument<String>("countryId")
                downloadCountry(result, countryId!!)
            }
            "cancelCountryDownload" -> {
                val countryId = call.argument<String>("countryId")
                cancelCountryDownload(result, countryId!!)
            }
            "deleteCountryDownload" -> {
                val countryId = call.argument<String>("countryId")
                deleteCountryDownload(result, countryId!!)
            }
        }
    }

    private fun fetchCountries(): List<CountryItem> {
        val countries = mutableListOf<CountryItem>()

        MapManager.nativeListItems(
            CountryItem.getRootId(),
            0.0,
            0.0,
            false,
            false,
            countries
        )

        return countries
    }

    private fun getCountries(result: MethodChannel.Result) {
        val countries = fetchCountries()

        result.success(Gson().toJson(countries))
    }

    private fun downloadCountry(result: MethodChannel.Result, countryId: String) {
        MapManager.warn3gAndDownload(activity, countryId, null)
        result.success(null)
    }

    private fun cancelCountryDownload(result: MethodChannel.Result, countryId: String) {
        val country = fetchCountries().first { countryId == it.id }
        MapManager.nativeCancel(country.id)
        result.success(null)
    }

    private fun deleteCountryDownload(result: MethodChannel.Result, countryId: String) {
        MapManager.nativeDelete(countryId)
        result.success(Gson().toJson(fetchCountries()))
    }

    override fun onStatusChanged(data: MutableList<MapManager.StorageCallbackData>?) {
        channel.invokeMethod("onStatusChanged", Gson().toJson(data))
    }

    override fun onProgress(countryId: String?, localSize: Long, remoteSize: Long) {
        channel.invokeMethod("onProgress", mapOf(
            "countryId" to countryId,
            "localSize" to localSize,
            "remoteSize" to remoteSize
        ))
    }

    private fun dispose(result: MethodChannel.Result) {
        MapManager.nativeUnsubscribe(subscriberSlot)
        subscriberSlot = 0

        result.success(null)
    }

    companion object {
        fun make(activity: Activity, engine: FlutterEngine): DownloadCountriesDelegate {
            val channel = MethodChannel(
                engine.dartExecutor.binaryMessenger,
                "com.mapmetrics.orgmaps/map_download"
            )

            return DownloadCountriesDelegate(channel, activity)
        }
    }

}