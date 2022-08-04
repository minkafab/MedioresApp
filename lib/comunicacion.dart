// @dart=2.9
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
//import 'dart:math';
//import 'package:flutter/rendering.dart';
//import 'package:google_ml_kit/google_ml_kit.dart';
//*import 'package:camera/camera.dart';
//import 'package:medidor/camara.dart';
import 'package:milton/dats.dart';
import 'package:milton/userdat.dart';
import 'package:milton/basedat.dart';
import 'package:flutter/cupertino.dart';
//import 'package:opencv/opencv.dart';
import 'package:http/http.dart' as http;

class comunicacion extends StatefulWidget {
  // const comunicacion({ Key? key }) : super(key: key);
  final String imgpath;
  final String idetiqueta;

  comunicacion(this.imgpath, this.idetiqueta);

  @override
  State<comunicacion> createState() => _comunicacionState();
}

class _comunicacionState extends State<comunicacion> {
  File cortado;
  String codimg = '';
  String tipo = 'Consumo';
  String btipo = 'Guardar Consumo';
  List cargar = [];
  String etiquetamed = '';
  String _consumo = '';
  String resserver = '';
  BuildContext dialogcontex;
  bool correr = true;

  Future reconocer() async {
    //
    if (correr == true) {
      await imgcortar(widget.imgpath);
      startupload();
    }
  }

  Future aviconsumo(int numnovedades) async {
    if (numnovedades == 1) {
      showDialog(
          context: context,
          builder: (BuildContext progcontext) {
            dialogcontex = progcontext;
            return const CupertinoAlertDialog(
              title: Text('consumo guardado'),
              content: Text('consumo promedio sobre rango estimado'),
            );
          });
    }
    if (numnovedades == 2) {
      showDialog(
          context: context,
          builder: (BuildContext progcontext) {
            dialogcontex = progcontext;
            return const CupertinoAlertDialog(
              title: Text('consumo guardado'),
              content: Text('consumo promedio bajo el rango estimado'),
            );
          });
    }
    if (numnovedades == 3) {
      showDialog(
          context: context,
          builder: (BuildContext progcontext) {
            dialogcontex = progcontext;
            return const CupertinoAlertDialog(
              title: Text('consumo guardado'),
              content: Text('sin novedad'),
            );
          });
    }
    if (numnovedades == 4) {
      showDialog(
          context: context,
          builder: (BuildContext progcontext) {
            dialogcontex = progcontext;
            return const CupertinoAlertDialog(
              title: Text('consumo guardado'),
              content: Text('consumo acumulado menor o igual al anterior'),
            );
          });
    }
    if (numnovedades == 5) {
      showDialog(
          context: context,
          builder: (BuildContext progcontext) {
            dialogcontex = progcontext;
            return const CupertinoAlertDialog(
              title: Text('consumo guardado'),
              content: Text('error valores promedio'),
            );
          });
    }

    await Future.delayed(Duration(seconds: 2));
    Navigator.pop(dialogcontex);
  }

  Future progreso() async {
    showDialog(
        context: context,
        builder: (BuildContext progcontext) {
          dialogcontex = progcontext;
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.all(2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: CircularProgressIndicator(),
                  ),
                  Text(""),
                  Text("Procesando"),
                ],
              ),
            ),
          );
        });
  }

  regresar() {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return dats(false, null);
    }));
  }

  Future avimconsumo() async {
    //String prueba = '';
    showDialog(
        context: context,
        builder: (BuildContext progcontext) {
          dialogcontex = progcontext;
          return const CupertinoAlertDialog(
            title: Text('el consumo ingresado debe ser un numero'),
          );
        });
    await Future.delayed(Duration(seconds: 2));
    Navigator.pop(dialogcontex);
  }

  Future verificaretiqueta() async {
    cargar = await datab.verificardatos(widget.idetiqueta); //7428
    if (_consumo == '') {
      _consumo = resserver;
    }
    List coordenadas = await datab.localizacion();
    String novedadcons = '';
    int numnovedades = 0;
    try {
      int promedio = int.parse(cargar[12]);
      int consumoant = int.parse(cargar[10]);
      int consumoact = int.parse(_consumo);
      int valpromediosup = 0;
      int valpromediobaj = 0;

      if (consumoact > consumoant) {
        consumoact = consumoact - consumoant;
        valpromediosup = promedio * 2;
        valpromediobaj = (promedio * 0.3).toInt();
        
        if (consumoact >= valpromediosup) {
          novedadcons = 'consumo promedio sobre rango estimado';
          numnovedades = 1;
        }
       
        if (consumoact <= valpromediobaj) {
          novedadcons = 'consumo promedio bajo el rango estimado';
          numnovedades = 2;
        }
        if (consumoact > valpromediobaj && consumoact < valpromediosup) {
          novedadcons = 'sin novedad';
          numnovedades = 3;
        }
      } else {
        novedadcons = 'consumo acumulado menor o igual al anterior';
        numnovedades = 4;
      }
    } catch (e) {
      novedadcons = 'error valores promedio';
      numnovedades = 5;
    }
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
      consumo: _consumo,
      novedad: novedadcons,
      cordenadax: coordenadas[0], //latitud
      cordenaday: coordenadas[1], //longitud
      img: cargar[20],
      lecturainicial: cargar[21],
      aclaracion: cargar[22],
    ));
    await aviconsumo(numnovedades);
    regresar();
  }

  Future startupload() async {
    progreso();
    
    //String fileName = widget.imgpath.split('/').last;
    codimg = base64Encode(File(widget.imgpath).readAsBytesSync());
    String fileName = "nombre.jpg";
    
    upload(fileName);
  }

  Future upload(String fileName) async {
    //String url = "http://192.168.100.107/prueba.php";
    Uri url = Uri.https('service.minkafab.com', '/opencv/comunicacion.php');

    var response = await http.post(url, body: {
      "image": codimg,
      "name": fileName,
    });
    

    resserver = response.body;
    Navigator.pop(dialogcontex);

    correr = false;

    setState(() {
      resserver;
    });

  }

  Future imgcortar(String direc) async {
    img.Image image = img.decodeJpg(File(direc).readAsBytesSync());
   

    //int offsetY = ((MediaQuery.of(context).size.height) * 0.48).toInt();
    //int offsetX = (((MediaQuery.of(context).size.width) * 0.5) - 75).toInt();
    int offsetY = (image.height * 0.4618).toInt();
    int offsetX = (image.width * 0.2917).toInt();
    int ancho = (image.width * 0.4166).toInt();
    int alto = (image.height * 0.0764).toInt();
    img.Image destImage = img.copyCrop(image, offsetX, offsetY, ancho, alto);

    //img.grayscale(destImage);
    //img.Image imggray = img.grayscale(destImage);

    //resimg = await ImgProc.colorRGB2GRAY;

    var jpg = img.encodeJpg(destImage);
    // InputImage pruebaimg = destImage;
    await File(direc).writeAsBytes(jpg);
    
    return;
  }

  @override
  Widget build(BuildContext context) {
   
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(30),
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(100))),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    Center(
                                      child: Text(
                                        tipo,
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              45,
                                        ),
                                      ),
                                    ),
                                    FutureBuilder(
                                        future: reconocer(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return Image.file(
                                                File(widget.imgpath));
                                          }
                                          return Text("cargando");
                                        })
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.all(8),
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      _consumo = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.admin_panel_settings,
                                        color: Colors.blue,
                                      ),
                                      labelText: resserver),
                                )),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 1.4 *
                                      (MediaQuery.of(context).size.height / 20),
                                  width: 5 *
                                      (MediaQuery.of(context).size.width / 10),
                                  margin: EdgeInsets.all(20),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      //int valcon = 0;
                                      //try {
                                      //  valcon = int.parse(_consumo);
                                      verificaretiqueta();
                                      // } catch (e) {
                                      //  avimconsumo();
                                      //}
                                      // verificaretiqueta();
                                    },
                                    child: Text(btipo),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ],
          )
        ],
      ),
    ));
  }
}
