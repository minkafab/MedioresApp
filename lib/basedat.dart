// @dart=2.9
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:milton/userdat.dart';
import 'package:location/location.dart';

bool seractivo = false;
Location location = Location();
PermissionStatus permiso;
LocationData datolocal;

class datab {
  static Future<Database> _openDB() async {
    return openDatabase(join(await getDatabasesPath(), 'mesa.db'),
        onCreate: (db, version) async {
      await db.execute(
        "CREATE TABLE mesa (id INTEGER PRIMARY KEY, nombre TEXT, identificacion TEXT, numcuenta TEXT, nummedidor TEXT, marcamedidor TEXT, direccion TEXT, ruta TEXT, ordruta TEXT, ultconsumo TEXT, fechaultconsumo TEXT, promedio TEXT, idlector TEXT, tiempo TEXT, sensor TEXT, consumo TEXT NOT NULL, novedad TEXT, cordenadax TEXT, cordenaday TEXT, img TEXT, lecturainicial TEXT, aclaracion TEXT)",
      );
      await db.execute(
        "CREATE TABLE novedades(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,descripcion TEXT, imagen TEXT, tiempo TEXT, latitud TEXT, longitud TEXT)",
      );
    }, version: 1);
  }

  static Future<void> insert(usuario _usuario) async {
    Database database = await _openDB();

    return database.insert("mesa", _usuario.toMap());
  }

  // obtener datos de la base de datos de la tabla novedades
  static Future<List<novedad>> getnovedadtable() async {
    Database database = await _openDB();
    final List<Map<String, dynamic>> novedadMap =
        await database.query("novedades");

    return List.generate(
        novedadMap.length,
        (i) => novedad(
              novedadMap[i]['id'],
              novedadMap[i]['descripcion'],
              novedadMap[i]['imagen'],
              novedadMap[i]['tiempo'],
              novedadMap[i]['latitud'],
              novedadMap[i]['longitud'],
            ));
  }

  // limpiar la tabla novedades
  static Future<void> cleannovedadtable() async {
    Database database = await _openDB();
    return database.delete("novedades");
  }

  static Future insertNovedad(novedad _novedad) async {
    Database database = await _openDB();

    return database.insert("novedades", _novedad.toMap2());
  }

  // eliminar datos de la base de datos
  static Future deleteNovedad(int id) async {
    Database database = await _openDB();

    return database.delete("novedades", where: "id = ?", whereArgs: [id]);
  }

  // actualizar datos en la base de datos
  static Future updateNovedad(novedad _novedad) async {
    Database database = await _openDB();

    return database.update("novedades", _novedad.toMap(),
        where: "id = ?", whereArgs: [_novedad.id]);
  }

  /*static Future<void> delete(usuario _usuario) async {
    Database database = await _openDB();

    return database.delete("prueba", where: "id = ?", whereArgs: [_usuario.id]);
  }*/
  static Future<void> delete(int id) async {
    Database database = await _openDB();

    return database.delete("mesa", where: "id = ?", whereArgs: [id]);
  }



  static Future<void> update(usuario _usuario) async {
    Database database = await _openDB();

    return database.update("mesa", _usuario.toMap(),
        where: "id = ?", whereArgs: [_usuario.id]);
  }

  // static Future<List<String>> getRutas() async {
  //   Database database = await _openDB();
  //   final List<Map<String, dynamic>> rutaMap =
  //       await database.query("mesa", distinct: true, columns: ['ruta']);
  //   return List.generate(rutaMap.length, (i) => rutaMap[i]['ruta']);
  // }

  static Future<List<usuario>> getusertable() async {
    Database database = await _openDB();
    final List<Map<String, dynamic>> userMap = await database.query("mesa");

    return List.generate(
        userMap.length,
        (i) => usuario(
              id: userMap[i]['id'],
              nombre: userMap[i]['nombre'],
              identificacion: userMap[i]['identificacion'],
              numcuenta: userMap[i]['numcuenta'],
              nummedidor: userMap[i]['nummedidor'],
              marcamedidor: userMap[i]['marcamedidor'],
              direccion: userMap[i]['direccion'],
              ruta: userMap[i]['ruta'],
              ordruta: userMap[i]['ordruta'],
              ultconsumo: userMap[i]['ultconsumo'],
              fechaultconsumo: userMap[i]['fechaultconsumo'],
              promedio: userMap[i]['promedio'],
              idlector: userMap[i]['idlector'],
              tiempo: userMap[i]['tiempo'],
              sensor: userMap[i]['sensor'],
              consumo: userMap[i]['consumo'],
              novedad: userMap[i]['novedad'],
              cordenadax: userMap[i]['cordenadax'],
              cordenaday: userMap[i]['cordenaday'],
              img: userMap[i]['img'],
              lecturainicial: userMap[i]['lecturainicial'],
              aclaracion: userMap[i]['aclaracion'],
            ));
  }

  // static Future verificardatos(String etiqueta) async {
  //   List<usuario> veretiqueta;
  //   //  bool encontrardatos = false;
  //   //List cargar = [];
  //   // int identificador = 0;
  //   veretiqueta = await datab.getusertable();

  //   for (int i = 0; i < veretiqueta.length; i++) {
  //     if (veretiqueta[i].nummedidor == etiqueta) {
  //       List cargar = [
  //         true,
  //         veretiqueta[i].id,
  //         veretiqueta[i].nombre,
  //         veretiqueta[i].identificacion,
  //         veretiqueta[i].numcuenta,
  //         veretiqueta[i].nummedidor,
  //         veretiqueta[i].marcamedidor,
  //         veretiqueta[i].direccion,
  //         veretiqueta[i].ruta,
  //         veretiqueta[i].ordruta,
  //         veretiqueta[i].ultconsumo,
  //         veretiqueta[i].fechaultconsumo,
  //         veretiqueta[i].promedio,
  //         veretiqueta[i].idlector,
  //         veretiqueta[i].tiempo,
  //         veretiqueta[i].sensor,
  //         veretiqueta[i].consumo,
  //         veretiqueta[i].novedad,
  //         veretiqueta[i].cordenadax,
  //         veretiqueta[i].cordenaday,
  //         veretiqueta[i].img,
  //         veretiqueta[i].lecturainicial,
  //         veretiqueta[i].aclaracion
  //       ];
  //       return cargar;
  //       // identificador = veretiqueta[i].id;
  //     }
  //   }
  //   List cargar = [false];
  //   return cargar;
  // }

  static Future localizacion() async {
    List coordenadas = ["", ""];
    seractivo = await location.serviceEnabled();
    if (!seractivo) {
      seractivo = await location.requestService();
      if (seractivo) {
        return;
      }
    }
    permiso = await location.hasPermission();
    if (permiso == PermissionStatus.denied) {
      permiso = await location.requestPermission();
      if (permiso != PermissionStatus.granted) {
        return;
      }
    }
    datolocal = await location.getLocation();

    coordenadas[0] = datolocal.latitude.toString();
    coordenadas[1] = datolocal.longitude.toString();
    coordenadas = await verificarCordenadas(coordenadas);
    return (coordenadas);
  }

  static Future verificarCordenadas(List coordenadas) async {
    // verificar que las coordenadas no se repiten en verbusuario
    List<usuario> veretiqueta;
    bool encontrardatos = false;
    veretiqueta = await datab.getusertable();
    // rango +- 0.000036
    String rangoArriba = (double.parse(coordenadas[1]) + 0.000036).toString();
    String rangoAbajo = (double.parse(coordenadas[1]) - 0.000036).toString();
    for (int i = 0; i < veretiqueta.length && !encontrardatos; i++) {
      if (veretiqueta[i].cordenadax != 'vacio') {
        if ((veretiqueta[i].cordenadax == coordenadas[0] &&
                veretiqueta[i].cordenaday == coordenadas[1]) ||
            (double.parse(veretiqueta[i].cordenaday) >=
                    double.parse(rangoAbajo) &&
                double.parse(veretiqueta[i].cordenaday) <=
                    double.parse(rangoArriba))) {
          print("encontrado");
          encontrardatos = true;
          // salir del for
          i = veretiqueta.length;
        } else {
          print("no encontrado");
        }
      }
    }
    if (encontrardatos) {
      coordenadas[1] = (double.parse(coordenadas[1]) + 0.000036).toString();
      return await verificarCordenadas(coordenadas);
    } else {
      return coordenadas;
    }
  }


}

class novedad {
  int id;
  String descripcion;
  String imagen;
  String tiempo;
  String latitud;
  String longitud;

  novedad(this.id, this.descripcion, this.imagen, this.tiempo, this.latitud,
      this.longitud);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descripcion': descripcion,
      'imagen': imagen,
      'tiempo': tiempo,
      'latitud': latitud,
      'longitud': longitud,
    };
  }

  Map<String, dynamic> toMap2() {
    return {
      'descripcion': descripcion,
      'imagen': imagen,
      'tiempo': tiempo,
      'latitud': latitud,
      'longitud': longitud,
    };
  }
}
