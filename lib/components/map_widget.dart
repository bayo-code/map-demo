import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MapWidget extends StatelessWidget {
  const MapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const AndroidView(
      viewType: 'map-ui',
      layoutDirection: TextDirection.ltr,
      creationParams: {},
      creationParamsCodec: StandardMessageCodec(),
    );
  }
}
