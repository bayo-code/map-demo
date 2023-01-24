import 'package:flutter/material.dart';
import 'package:orgmaps/controllers/download_resources.dart';
import 'package:orgmaps/screens/map.dart';

class DownloadResources extends StatefulWidget {
  const DownloadResources({super.key});

  @override
  State<DownloadResources> createState() => _DownloadResourcesState();
}

class _DownloadResourcesState extends State<DownloadResources> {
  bool _initialized = false;
  String _buttonText = '';
  VoidCallback? _listener;
  double _progress = 0;
  double _max = 1;
  String _downloadSize = '';

  DownloadResourcesController get controller =>
      DownloadResourcesController.instance;

  @override
  void initState() {
    super.initState();

    debugPrint('Download Resources: InitState');

    controller.errorListener = (title, message) {
      debugPrint('Error! Title: $title, Msg: $message');
    };
    controller.onActionChange = ((listener, text) {
      if (mounted) {
        setState(() {
          _listener = listener;
          _buttonText = text;
        });
      }
    });

    controller.onBytesToDownload = (bytes) {
      _max = bytes.toDouble();
      _progress = 0;
      setState(() {});
    };

    controller.onProceedToMap = (() {
      debugPrint('Proceeding to map!');
      Map.launch(context);
    });

    controller.onProgress = ((progress) {
      _progress = progress.toDouble();
      if (mounted) setState(() {});
    });

    controller.onFinish = ((errorCode) {});

    controller.init().then((value) async {
      debugPrint('Initialization done!');
      _downloadSize = await controller.downloadSizeString;
      _initialized = true;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _initialized = false;
    controller.errorListener = null;
    controller.onActionChange = null;
    controller.onProceedToMap = null;
    controller.onProgress = null;
    controller.onFinish = null;
    controller.onBytesToDownload = null;

    controller.destroy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: !_initialized
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Map Download Required',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    'We need to download some map data to proceed.\nThe download is $_downloadSize',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12.0),
                  ElevatedButton(
                    onPressed: _listener,
                    child: Text(_buttonText),
                  ),
                  const SizedBox(height: 12.0),
                  LinearProgressIndicator(
                    value: _progress / _max,
                  ),
                ],
              ),
      ),
    );
  }
}
