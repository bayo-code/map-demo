import 'package:flutter/services.dart';

class MapController {
  static MapController instance = MapController._();

  MapController._();

  late final _channel = const MethodChannel('com.mapmetrics.orgmaps/map')
    ..setMethodCallHandler(onMethodCall);

  Future<void> onMethodCall(MethodCall call) async {}
}
