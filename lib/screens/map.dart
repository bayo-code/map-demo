import 'package:flutter/material.dart';
import 'package:orgmaps/components/map_widget.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();

  static void launch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return const Map();
      }),
    );
  }
}

class _MapState extends State<Map> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: MapWidget()),
    );
  }
}
