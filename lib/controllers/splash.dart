import 'package:flutter/services.dart';

class SplashController {
  static SplashController instance = SplashController._();

  final _channel = const MethodChannel('com.mapmetrics.orgmaps/splash');
  void Function(String title, String message)? errorListener;

  SplashController._() {
    _channel.setMethodCallHandler(_callHandler);
  }

  Future<void> init() {
    return _channel.invokeMethod('init');
  }

  Future<dynamic> _callHandler(MethodCall call) async {
    switch (call.method) {
      case 'onError':
        final String title = call.arguments['title'];
        final String message = call.arguments['message'];

        onError(title, message);
        break;
    }
  }

  void onError(String title, String message) {
    if (errorListener != null) {
      errorListener!(title, message);
    }
  }
}
