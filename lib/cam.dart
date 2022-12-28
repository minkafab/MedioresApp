// @dart=2.9

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:water_meter/dats.dart';
import 'package:milton/main.dart';
import 'package:milton/comunicacion.dart';
//import 'package:milton/src/controller/class/model.dart';

import 'userdat.dart';

class cam extends StatefulWidget {
  final usuario idetiqueta;
  cam(this.idetiqueta);
  // const cam({ Key? key }) : super(key: key);

  @override
  State<cam> createState() => _camState();
}

class _camState extends State<cam> {
  CameraController cameraController;
  CameraImage imgCamera;
  Future<void> initcamara;
  bool isWorking = false;
  XFile pictureFile;
  Future<void> ver;
  @override
  void initState() {
    super.initState();

    //cameras = availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.high);
    initcamara = cameraController.initialize();
   
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
    cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String imagePath = '';
    String imgdir = '';

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('Reconocimiento'),
        ),
        body: Container(
          /*  decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/jarvis.jpg")),
          ),*/
          child: Column(
            children: [
              Stack(
                children: [
                  Center(
                    child: Container(
                        margin: EdgeInsets.all(0),
                        //color: Colors.red,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height - 100,
                        child: FutureBuilder(
                            future: initcamara,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return CameraPreview(cameraController);

                                /*AspectRatio(
                                  aspectRatio:
                                      cameraController.value.aspectRatio,
                                  child: CameraPreview(cameraController),
                                );*/
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: Container(
                                    child: Text("error"),
                                  ),
                                );
                              }
                              return Center(
                                child: Container(
                                  child: Text("cargando"),
                                ),
                              );
                            })),
                  ),
                  Positioned(
                    bottom: 50,
                    left: (MediaQuery.of(context).size.width) * 0.42,
                    child: FloatingActionButton(
                      onPressed: () async {
                        try {
                          await initcamara;
                          final foto = await cameraController.takePicture();

                          imagePath = foto.path;
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  comunicacion(imagePath, widget.idetiqueta),
                            ),
                          );
                        } catch (e) {
                          print(e);
                        }
                      },
                      child: Icon(Icons.camera_alt),
                      /*child: habilitarcam == true
                          ? Container(child: Image.file(File(imagePath)))
                          : Container(
                              child: Text('maldicion'),
                            )*/
                    ),
                  ),
                  Positioned(
                    /*  top: (((MediaQuery.of(context).size.height) * 0.41).toInt())
                        .toDouble(),
                    left: ((((MediaQuery.of(context).size.width) * 0.5) - 100)
                            .toInt())
                        .toDouble(),*/
                    top:
                        ((((MediaQuery.of(context).size.height) - 100) * 0.4618)
                                .toInt())
                            .toDouble(),
                    left: ((((MediaQuery.of(context).size.width) * 0.2917))
                            .toInt())
                        .toDouble(),
                    child: Container(
                      height: ((((MediaQuery.of(context).size.height) - 100) *
                                  0.0764)
                              .toInt())
                          .toDouble(),
                      width: ((((MediaQuery.of(context).size.width) * 0.4166))
                              .toInt())
                          .toDouble(),
                      child: Placeholder(
                        color: Colors.purple,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
    //),
    // );
  }
}
