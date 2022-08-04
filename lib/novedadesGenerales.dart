import 'dart:convert';
import 'dart:ffi';

import 'package:camera/camera.dart';
import 'package:flutter/rendering.dart';
import 'package:milton/dats.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:milton/main.dart';

import 'basedat.dart';

class NovedadesGenerales extends StatefulWidget {
  NovedadesGenerales();
  @override
  _NovedadesGeneralesState createState() => _NovedadesGeneralesState();
}

class _NovedadesGeneralesState extends State<NovedadesGenerales> {
  // insertar datos en la base de datos

  // consultar datos de la base de datos
  void confirmDelete(int id, BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Eliminar"),
            content: Text("¿Desea eliminar la novedad?"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Eliminar"),
                onPressed: () {
                  datab.deleteNovedad(id);
                  setState(() {});
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void showNovedad(novedad _novedad, BuildContext context) async {
    // mostrar descripcion de la novedad y la imagen si existe
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(_novedad.descripcion),
            content: _novedad.imagen != ''
                ? Image.memory(base64Decode(_novedad.imagen))
                : Text("No hay imagen"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cerrar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Future novedadesGeneralesForm(BuildContext context) async {
    CameraController cameraController;
    Future<void> initcamara;
    cameraController = CameraController(cameras[0], ResolutionPreset.high);
    initcamara = cameraController.initialize();
    novedad _novedad = new novedad(0, '', '', '', '', '');
    showDialog(
      // agregar una novedad
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Agregar Novedad"),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
                child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextField(
                    maxLength: 40,
                    decoration: InputDecoration(
                      labelText: "Descripcion",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _novedad.descripcion = value;
                    },
                  ),
                  Container(
                      margin: EdgeInsets.all(0),
                      height: MediaQuery.of(context).size.height * 0.5,
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: _novedad.imagen == ''
                          ? FutureBuilder(
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
                              })
                          : Image.memory(base64Decode(_novedad.imagen))),
                  //boton de tomar foto
                  RaisedButton(
                    child: Text("Tomar Foto"),
                    onPressed: () async {
                      try {
                        await initcamara;
                        final foto = await cameraController.takePicture();

                        var imagePath = foto.path;
                        String codimg =
                            base64Encode(File(imagePath).readAsBytesSync());

                        setState(() {
                          _novedad.imagen = codimg;
                        });
                      } catch (e) {
                        print(e);
                      }
                    },
                  ), //boton de seleccionar foto
                ],
              ),
            ));
          }),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Agregar"),
              onPressed: () async {
                // fecha y hora en numero de segundos
                _novedad.tiempo =
                    ((DateTime.now().millisecondsSinceEpoch / 1000).floor())
                        .toString();

                List coordenadas = await datab.localizacion();
                _novedad.latitud = coordenadas[0];
                _novedad.longitud = coordenadas[1];
                datab.insertNovedad(_novedad);

                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novedades Generales'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              novedadesGeneralesForm(context);
            },
          ),
        ],
      ),
      body: Container(
        child: FutureBuilder(
          future: datab.getnovedadtable(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  // convertir snapshot[index].tiempo a fecha y hora
                  var date = DateTime.fromMillisecondsSinceEpoch(
                      int.parse(snapshot.data[index].tiempo) * 1000);
                  return Card(
                    child: ListTile(
                      title: Text(snapshot.data[index].descripcion),
                      subtitle: Text(date.toString()),
                      leading: Image.memory(
                        base64Decode(snapshot.data[index].imagen),
                        height: 100,
                        width: 100,
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          confirmDelete(snapshot.data[index].id, context);
                          setState(() {});
                        },
                      ),
                      onTap: () {
                        showNovedad(snapshot.data[index], context);
                      },
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}

// ListTile(
//               leading: Icon(Icons.person),
//               title: Text('Nombre'),
//               subtitle: Text('Identificacion'),
//             )


