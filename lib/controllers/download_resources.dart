import 'package:flutter/services.dart';

enum ResultCode {
  downloadSuccess(0),
  diskError(-1),
  notEnoughFreeSpace(-2),
  storageDisconnected(-3),
  downloadError(-4),
  noMoreFiles(-5),
  fileInProgress(-6);

  final int code;

  const ResultCode(this.code);

  static ResultCode? from(int code) {
    try {
      return ResultCode.values.firstWhere((element) => element.code == code);
    } catch (e) {
      return null;
    }
  }
}

enum Action {
  download,
  pause,
  resume,
  tryAgain,
  proceedToMap;

  String get textValue {
    switch (this) {
      case Action.download:
        return 'Download';
      case Action.pause:
        return 'Pause';
      case Action.resume:
        return 'Resume';
      case Action.tryAgain:
        return 'Try Again';
      case Action.proceedToMap:
        return 'Proceed To Map';
    }
  }
}

class DownloadResourcesController {
  static DownloadResourcesController instance = DownloadResourcesController._();

  final _channel =
      const MethodChannel('com.mapmetrics.orgmaps/download_resources');

  Future<int> get bytesToDownload async =>
      await _channel.invokeMethod('getBytesToDownload');

  late final List<VoidCallback> _btnListeners = [
    handleDownloadClick,
    handlePauseClick,
    handleResumeClick,
    handleTryAgainClick,
    handleProceedToMapClick,
  ];

  bool downloadedResources = false;
  Action _action = Action.download;
  Future<String> get downloadSizeString async =>
      (await _channel.invokeMethod('downloadSizeString'));

  Action get action => _action;
  set action(Action act) {
    _action = act;

    if (onActionChange != null) {
      onActionChange!(_btnListeners[act.index], act.textValue);
    }
  }

  void Function(String title, String message)? errorListener;
  void Function(VoidCallback listener, String text)? onActionChange;
  void Function(int progress)? onProgress;
  void Function(int errorCode)? onFinish;
  VoidCallback? onProceedToMap;
  void Function(int bytes)? onBytesToDownload;

  DownloadResourcesController._() {
    _channel.setMethodCallHandler(_callHandler);
  }

  Future<void> init() async {
    if (await prepareFilesDownload()) {
      await keepScreenOn(true);
      action = Action.download;
    } else {
      handleProceedToMapClick();
    }
  }

  Future<void> destroy() async {
    await keepScreenOn(false);
  }

  Future<void> _callHandler(MethodCall call) async {
    switch (call.method) {
      case 'onProgress':
        int percent = call.arguments;
        if (onProgress != null) {
          onProgress!(percent);
        }
        break;
      case 'onFinish':
        final errorCode = call.arguments;
        final code = ResultCode.from(errorCode)!;

        if (code == ResultCode.downloadSuccess) {
          final res = await startNextFileDownload();
          if (res == ResultCode.noMoreFiles.code) {
            await _finishFilesDownload(ResultCode.noMoreFiles);
          }
        } else {
          await _finishFilesDownload(code);
        }

        if (onFinish != null) {
          onFinish!(errorCode);
        }
        break;
    }
  }

  Future<void> handleDownloadClick() async {
    action = Action.pause;
    await _doDownload();
  }

  Future<void> _doDownload() async {
    final res = await startNextFileDownload();
    if (res == ResultCode.noMoreFiles.code) {
      await _finishFilesDownload(ResultCode.noMoreFiles);
    }
  }

  Future<void> handlePauseClick() async {
    action = Action.resume;
    await _cancelCurrentFile();
  }

  Future<void> handleResumeClick() async {
    action = Action.pause;
    _doDownload();
  }

  Future<void> handleTryAgainClick() async {
    if (await prepareFilesDownload()) {
      action = Action.pause;
      _doDownload();
    }
  }

  Future<void> handleProceedToMapClick() async {
    downloadedResources = true;
    if (onProceedToMap != null) {
      onProceedToMap!();
    }
  }

  Future<bool> prepareFilesDownload() async {
    final bytes = await bytesToDownload;

    if (bytes == 0) {
      downloadedResources = true;
      return false;
    }

    if (bytes < 0) {
      await _finishFilesDownload(ResultCode.from(bytes)!);
    } else {
      if (onBytesToDownload != null) {
        onBytesToDownload!(bytes);
      }
    }

    return true;
  }

  Future<void> _finishFilesDownload(ResultCode code) async {
    if (code == ResultCode.noMoreFiles) {
      await _reloadWorldMaps();
      downloadedResources = true;
      action = Action.proceedToMap;
    } else if (errorListener != null) {
      errorListener!('Error Occurred', code.name);
    }
  }

  Future<void> _reloadWorldMaps() {
    return _channel.invokeMethod('reloadWorldMaps');
  }

  Future<void> keepScreenOn(bool ison) async {
    return _channel.invokeMethod('keepScreenOn', ison);
  }

  Future<bool> canShowMap() async {
    if (!downloadedResources) {
      return false;
    }

    return true;
  }

  Future<int> startNextFileDownload() async {
    return (await _channel.invokeMethod('startNextFileDownload'));
  }

  Future<void> _cancelCurrentFile() async {
    return await _channel.invokeMethod('cancelCurrentFile');
  }
}
