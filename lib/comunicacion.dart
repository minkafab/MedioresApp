// @dart=2.9
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:milton/dats.dart';
import 'package:milton/userdat.dart';
import 'package:milton/basedat.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class comunicacion extends StatefulWidget {
  final String imgpath;
  final usuario idetiqueta;

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
  bool confirmacion = false;

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

  
  Future confirmarGuardado(String novedad) async {
    await showDialog(
        context: context,
        builder: (BuildContext progcontext) {
          dialogcontex = progcontext;
          return CupertinoAlertDialog(
            title: Text(novedad),
            content: Text('¿Guardar Consumo?'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('Si'),
                onPressed: () {
                  Navigator.pop(dialogcontex);
                  setState(() {
                    confirmacion = true;
                  });
                },
              ),
              CupertinoDialogAction(
                child: Text('No'),
                onPressed: () {
                  Navigator.pop(dialogcontex);
                  setState(() {
                    confirmacion = false;
                  });
                },
              ),
            ],
          );
        });
  }

  Future verificaretiqueta() async {
    _consumo = resserver;
    List coordenadas = await datab.localizacion();

    String novedadcons = 'Sin registro de lectura';
    int numnovedades = 0;
    try {
      int promedio = int.parse(widget.idetiqueta.promedio);
      int consumoant = int.parse(widget.idetiqueta.lecturainicial);
      int consumoact = int.parse(_consumo);

      int valpromediosup = 0;
      int valpromediobaj = 0;

      if (consumoact >= consumoant) {
        valpromediosup = consumoant + promedio * 2;
        valpromediobaj = consumoant + (promedio * 0.3).toInt();
        String rango =
            "    Rango estimado: ${valpromediobaj} - ${valpromediosup}";
        // consumoant != 0 y promedio != 0 y
        if (consumoant == 0 || promedio == 0) {
          novedadcons = 'No hay como validar el consumo';
          numnovedades = 6;
        } else if (consumoact > valpromediosup) {
          novedadcons = 'Consumo sobre rango estimado';
          numnovedades = 1;
        } else if (consumoact < valpromediobaj) {
          novedadcons = 'Consumo bajo rango estimado';
          numnovedades = 2;
        } else if (consumoact >= valpromediobaj &&
            consumoact <= valpromediosup) {
          novedadcons = 'Sin novedad';
          numnovedades = 3;
        }
        await confirmarGuardado(novedadcons + rango);
        if (!confirmacion) {
          regresar();
          return;
        }
      } else {
        numnovedades = 4;
        aviconsumo(numnovedades);
        return;
      }
    } catch (e) {
      numnovedades = 5;
    }
    DateTime now = DateTime.now();
    var epochTime = (now.millisecondsSinceEpoch / 1000).floor();

    String fecha = epochTime.toString();

    await datab.update(usuario(
        id: widget.idetiqueta.id,
        nombre: widget.idetiqueta.nombre,
        identificacion: widget.idetiqueta.identificacion,
        numcuenta: widget.idetiqueta.numcuenta,
        nummedidor: widget.idetiqueta.nummedidor,
        marcamedidor: widget.idetiqueta.marcamedidor,
        direccion: widget.idetiqueta.direccion,
        ruta: widget.idetiqueta.ruta,
        ordruta: widget.idetiqueta.ordruta,
        ultconsumo: widget.idetiqueta.ultconsumo,
        fechaultconsumo: widget.idetiqueta.fechaultconsumo,
        promedio: widget.idetiqueta.promedio,
        idlector: widget.idetiqueta.idlector,
        tiempo: fecha,
        sensor: widget.idetiqueta.sensor,
        consumo: _consumo == '' ? '0' : _consumo,
        novedad: novedadcons,
        cordenadax: coordenadas[0], //latitud
        cordenaday: coordenadas[1], //longitud
        img: widget.idetiqueta.img,
        lecturainicial: widget.idetiqueta.lecturainicial,
        aclaracion: widget.idetiqueta.aclaracion));

    aviconsumo(numnovedades);
    _consumo = '';
    setState(() {});
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

    setState(() {});
  }

  Future imgcortar(String direc) async {
    img.Image image = img.decodeJpg(File(direc).readAsBytesSync());

    int offsetY = (image.height * 0.4618).toInt();
    int offsetX = (image.width * 0.2917).toInt();
    int ancho = (image.width * 0.4166).toInt();
    int alto = (image.height * 0.0764).toInt();
    img.Image destImage = img.copyCrop(image, offsetX, offsetY, ancho, alto);


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
                                      verificaretiqueta();
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
