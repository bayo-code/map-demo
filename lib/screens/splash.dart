import 'package:flutter/material.dart';
import 'package:orgmaps/controllers/splash.dart';
import 'package:orgmaps/screens/download_resources.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final controller = SplashController.instance;

  @override
  void initState() {
    super.initState();

    controller.errorListener = onError;
    controller.init().then((value) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return const DownloadResources();
            },
          ),
        );
      }
    });
  }

  void onError(String title, String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Okay'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    SplashController.instance.errorListener = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Loading map data...',
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
    );
  }
}
