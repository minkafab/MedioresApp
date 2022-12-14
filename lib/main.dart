// @dart=2.9
import 'package:flutter/material.dart';
import 'package:milton/login.dart';
import 'package:camera/camera.dart';

/*void main() {
  runApp(app());
}*/
List<CameraDescription> cameras;
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    //WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
  runApp(app());
}

class app extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: login(),
    );
  }
}
