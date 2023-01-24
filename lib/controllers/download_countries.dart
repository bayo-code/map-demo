import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:orgmaps/models/country.dart';
import 'package:orgmaps/models/storage_callback_data.dart';

extension ThisExt<T> on T? {
  void let(void Function(T) c) {
    if (this != null) {
      c(this as T);
    }
  }
}

class DownloadCountries {
  DownloadCountries._();

  static DownloadCountries instance = DownloadCountries._();

  jsonParser(String data) => json.decode(data);

  late final _channel =
      const MethodChannel('com.mapmetrics.orgmaps/map_download')
        ..setMethodCallHandler(_callHandler);

  Future<List<Country>> get countries async {
    final String result = await _channel.invokeMethod('getCountries');

    final data = await compute(jsonParser, result);
    final countries = <Country>[];

    for (final item in data) {
      countries.add(Country.fromJson(item));
    }

    return countries;
  }

  void Function(List<StorageCallbackData> data)? onStatusChanged;
  void Function(String countryId, int localSize, int remoteSize)? onProgress;

  Future<void> _callHandler(MethodCall call) async {
    switch (call.method) {
      case 'onStatusChanged':
        await _handleStatusChange(call.arguments);
        break;
      case 'onProgress':
        await _handleProgress(call.arguments);
        break;
    }
  }

  Future<void> _handleStatusChange(String jsonData) async {
    onStatusChanged.let((it) async {
      final result = await compute(jsonParser, jsonData);

      final data = <StorageCallbackData>[];
      for (final item in result) {
        data.add(StorageCallbackData.fromJson(item));
      }

      it(data);
    });
  }

  Future<void> _handleProgress(Map data) async {
    onProgress.let(
      (it) => it(
        data['countryId'],
        data['localSize'],
        data['remoteSize'],
      ),
    );
  }

  Future<void> init() async {
    await _channel.invokeMethod('init');
  }

  Future<void> dispose() async {
    await _channel.invokeMethod('dispose');
  }

  Future<void> downloadCountry(String countryId) async {
    await _channel.invokeMethod(
      'downloadCountry',
      {'countryId': countryId},
    );
  }

  Future<void> cancelCountryDownload(String countryId) async {
    await _channel.invokeMethod(
      'cancelCountryDownload',
      {'countryId': countryId},
    );
  }

  Future<void> deleteCountryDownload(String countryId) async {
    await _channel.invokeMethod(
      'deleteCountryDownload',
      {'countryId': countryId},
    );
  }
}
