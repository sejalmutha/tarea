import 'package:flutter/material.dart';
import 'package:task_manager/root_page.dart';
import 'package:task_manager/authentication.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:task_manager/locales/locale.dart';
import 'package:camera/camera.dart';

Future<void> main() async {
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;
  MyApp({this.camera});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        DemoLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
    const Locale.fromSubtags(languageCode: 'en'), // English
    const Locale.fromSubtags(languageCode: 'mr'), // Marathi
      ],
      title: 'Flutter Demo',
      home: RootPage(
        auth: new Auth(),
        camera: camera
      ),
    );
  }
}
