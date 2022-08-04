// @dart=2.9
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:milton/basedat.dart';
import 'package:milton/capdat.dart';
import 'package:flutter/cupertino.dart';
import 'package:milton/userdat.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:milton/main.dart';
import 'package:milton/comunicacion.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';

class picture extends StatefulWidget {
  final String idetiqueta;
  picture(this.idetiqueta);
  @override
  State<picture> createState() => _pictureState();
}

class _pictureState extends State<picture> {
  CameraController cameraController;
  CameraImage imgCamera;
  Future<void> initcamara;
  bool isWorking = false;
  XFile pictureFile;
  List cargar = [];
  BuildContext dialogcontex;

  @override
  void initState() {
    super.initState();

    cameraController = CameraController(cameras[0], ResolutionPreset.high);
    initcamara = cameraController.initialize();
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
    cameraController.dispose();
  }

  Future aviconsumo(int numnovedades) async {
    if (numnovedades == 1) {
      showDialog(
          context: context,
          builder: (BuildContext progcontext) {
            dialogcontex = progcontext;
            return const CupertinoAlertDialog(
              title: Text('foto guardada'),
              //content: Text('consumo promedio sobre rango estimado'),
            );
          });
    }

    await Future.delayed(Duration(seconds: 1));
    Navigator.pop(dialogcontex);
  }

  Future<void> peticion(String lat, String lon, String nummed) async {
    //entro = 'si';
    try {
      Uri url = Uri.http('m2mlight.com', '/iot/send_sensor_location.php',
          // uHZg1njcsr
          {
            'api_key': 'uHZg1njcsr',
            'latitude': lat,
            'longitude': lon,
            'meter_number': nummed
          });

      var respuesta = await http.get(url);
      //var respserv = await http.get(url1);
      //_respserv = respserv.body;
      String response = '';
      response = respuesta.body;

      //if()
    } catch (e) {
      print('no funciona');
    }
  }

  Future verificaretiqueta(String nummed, String code) async {
    cargar = await datab.verificardatos(nummed); //7428
    List coordenadas = await datab.localizacion();
    await peticion(coordenadas[0], coordenadas[1], nummed);
    DateTime now = DateTime.now();
    var epochTime = (now.millisecondsSinceEpoch / 1000).floor();

    String fecha = epochTime.toString();

    await datab.update(usuario(
      id: cargar[1],
      nombre: cargar[2],
      identificacion: cargar[3],
      numcuenta: cargar[4],
      nummedidor: cargar[5],
      marcamedidor: cargar[6],
      direccion: cargar[7],
      ruta: cargar[8],
      ordruta: cargar[9],
      ultconsumo: cargar[10],
      fechaultconsumo: cargar[11],
      promedio: cargar[12],
      idlector: cargar[13],
      tiempo: fecha,
      sensor: cargar[15],
      consumo: cargar[16],
      novedad: cargar[17],
      cordenadax: coordenadas[0], //latitud
      cordenaday: coordenadas[1], //longitud
      img: code,
      lecturainicial: cargar[21],
      aclaracion: cargar[22],

      //consumo: _consumo,
      //variacion: difvariacion
    ));
    await aviconsumo(1);
  }

  @override
  Widget build(BuildContext context) {
    String imagePath = '';
    String imgdir = '';

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('Foto medidor'),
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
                          String codimg =
                              base64Encode(File(imagePath).readAsBytesSync());
                          await verificaretiqueta(widget.idetiqueta, codimg);

                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => capdat(),
                            ),
                          );
                        } catch (e) {
                          print(e);
                        }
                      },
                      child: Icon(Icons.camera_alt),
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
