//@dart=2.9
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'dart:developer';
import 'package:milton/basedat.dart';
import 'package:milton/userdat.dart';


class map extends StatefulWidget {
  final GeoPoint endLoc;
  final String address;
  map({this.address, this.endLoc});

  @override
  State<map> createState() => _mapState();
}

class _mapState extends State<map> {
  MapController controller;
  List<usuario> verbdusuario;
  List novedades;
  RoadInfo _roadInfo = RoadInfo();
  String address = "unknown";
  bool mapaok = false;
  var distance = 0.0;
  var time = 0.0;

  @override
  void initState() {
    controller = MapController(
      initMapWithUserPosition: true,
      initPosition: GeoPoint(
        latitude: 0,
        longitude: 0,
      ),
    );
    //  localizacion();

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future localizacion() async {
    verbdusuario = await datab.getusertable();
    for (int i = 0; i < verbdusuario.length; i++) {
      if (verbdusuario[i].cordenadax != "vacio") {
        await controller.addMarker(
          GeoPoint(
            latitude: double.parse(verbdusuario[i].cordenadax),
            longitude: double.parse(verbdusuario[i].cordenaday),
          ),
          markerIcon: MarkerIcon(
            icon: Icon(
              Icons.location_on,
              color: Colors.green,
              size: 40,
            ),
          ),
        );
      }
    }
    novedades = await datab.getnovedadtable();
    for (int i = 0; i < novedades.length; i++) {
      if (novedades[i].latitud != "") {
        // no eliminar iconos antiguos
        await controller.addMarker(
          GeoPoint(
            latitude: double.parse(novedades[i].latitud),
            longitude: double.parse(novedades[i].longitud),
          ),
          markerIcon: MarkerIcon(
            icon: Icon(
              Icons.wrong_location,
              color: Colors.red,
              size: 40,
            ),
          ),
        );
      }
    }
  }

  void showinfogeopoint(GeoPoint point, BuildContext context) {
    //mostrar datos de verbduusuario que se encuentra en la posicion del geopoint
    for (int i = 0; i < verbdusuario.length; i++) {
      if (verbdusuario[i].cordenadax == point.latitude.toString() &&
          verbdusuario[i].cordenaday == point.longitude.toString()) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Informacion"),
                content: Text("Nombre: " +
                    verbdusuario[i].nombre +
                    "\n" +
                    "Numero de cuenta: " +
                    verbdusuario[i].numcuenta +
                    "\n" +
                    "Ruta: " +
                    verbdusuario[i].ruta +
                    "\n" +
                    "Numero de medidor: " +
                    verbdusuario[i].nummedidor +
                    "\n"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Cerrar"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
      }
    }
    // mostrar datos de las novedades que coincidan con la posicion
    novedades.forEach((element) {
      if (element.latitud == point.latitude.toString() &&
          element.longitud == point.longitude.toString()) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "Novedad: " + element.descripcion,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Image.memory(base64.decode(element.imagen)),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cerrar"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await controller.currentLocation();
          log(controller.initPosition.latitude.toString());
          log(controller.initPosition.longitude.toString());
        },
        child: Icon(Icons.place),
      ),
      body: Stack(
        children: [
          OSMFlutter(
            controller: controller,
            trackMyPosition: true,
            initZoom: 16, // zoom inicial aplicacion
            minZoomLevel: 2,
            maxZoomLevel: 18,
            stepZoom: 5.0,
            onGeoPointClicked: (GeoPoint point) {
              showinfogeopoint(point, context);
            },

            userLocationMarker: UserLocationMaker(
              personMarker: MarkerIcon(
                icon: Icon(
                  Icons.my_location_rounded,
                  color: Colors.blue,
                  size: 60,
                ),
              ),
              directionArrowMarker: MarkerIcon(
                icon: Icon(
                  Icons.double_arrow,
                  size: 48,
                ),
              ),
            ),

            markerOption: MarkerOption(
              defaultMarker: MarkerIcon(
                icon: Icon(
                  Icons.location_history,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
            ),
          ),
          FutureBuilder(
              future: localizacion(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Container(
                      child: Text(""),
                    ),
                  );
                }
              })
        ],
      ),
    );
  }
}
