//@dart=2.9
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:milton/map.dart';
//import 'package:medidor/camara.dart';
import 'package:milton/capdat.dart';
//import 'package:medidor/datmanual.dart';
//import 'package:/gpdf.dart';
//import 'package:medidor/pruebadat.dart';
import 'package:milton/basedat.dart';
import 'package:milton/novedadesGenerales.dart';
//import 'package:medidor/reconocimiento.dart';
import 'package:milton/userdat.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
//import 'package:ext_storage/ext_storage.dart';

class dats extends StatelessWidget {
  // final bool prueba = false;
  final bool btnabilitarbase;
  final String rutaresp;

  dats(this.btnabilitarbase, this.rutaresp);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: datos(btnabilitarbase, rutaresp),
    );
  }
}

class datos extends StatefulWidget {
  final bool btnbase;
  final String rutaserpuesta;
  datos(this.btnbase, this.rutaserpuesta);
  @override
  State<datos> createState() => _datosState();
}

class _datosState extends State<datos> {
  bool table = false;
  // bool btnbase = false;
  List<usuario> verbdusuario;
  List<usuario> cargaruserpdf;
  usuario user;
  bool funciones = true;
  bool medidor;
  bool cargarbase = false;
  bool entconsumo = false;
  BuildContext dialogcontex;
  BuildContext progressContext;
  String ruta = '';
  String rutaSelect = '';
  List<String> rutas = [];
  bool confirmacion = false;

  @override
  void initState() {
    super.initState();
  }

  Future progreso() async {
    // if()
    showDialog(
        context: context,
        builder: (BuildContext progcontext) {
          dialogcontex = progcontext;
          progressContext = progcontext;
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.all(2),
              child: Column(
                // height: MediaQuery.of(context).size.height,
                // width: MediaQuery.of(context).size.width,
                //mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Container(
                    //color: Colors.transparent,
                    //  mainAxisSize: MainAxisSize.min,
                    // mainAxisAlignment: MainAxisAlignment.center,
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

  getCurrentDate() {
    String finalfecha = '';
    String mes = '';
    var fecha = new DateTime.now().toString();
    var dateParse = DateTime.parse(fecha);
    //var formatofecha = "${dateParse.day}-${dateParse.month}-${dateParse.year}";
    mes = "${dateParse.month}";

    int nummes = int.parse(mes);
    if (nummes < 10) {
      mes = "0" + nummes.toString();
    } else {
      mes = nummes.toString();
    }

    var formatofecha = "${dateParse.year}-$mes-${dateParse.day}";
    return finalfecha = formatofecha.toString();
  }

  Future enviardatos() async {
    String path = (await getExternalStorageDirectory()).path;

    progreso();

    String nombre = '';
    String identificacion = '';
    String numcuenta = '';
    String nummedidor = '';
    String marcamedidor = '';
    String direccion = '';
    String ruta = '';
    String ordruta = '';
    String ultconsumo = '';
    String fechaultconsumo = '';
    String promedio = '';
    String idlector = '';
    String tiempo = '';
    String sensor = '';
    String consumo = '';
    String novedad = '';
    String cordenadax = '';
    String cordenaday = '';
    String img = '';
    String lecturainicial = '';
    String aclaracion = '';
    verbdusuario = await datab.getusertable();
    String idlectorNovedad = verbdusuario[0].idlector;
    verbdusuario.forEach((element) {
      nombre = nombre + element.nombre + ',';
      identificacion = identificacion + element.identificacion + ',';
      numcuenta = numcuenta + element.numcuenta + ',';
      nummedidor = nummedidor + element.nummedidor + ',';
      marcamedidor = marcamedidor + element.marcamedidor + ',';
      direccion = direccion + element.direccion + ',';
      ruta = ruta + element.ruta + ',';
      ordruta = ordruta + element.ordruta + ',';
      ultconsumo = ultconsumo + element.ultconsumo + ',';
      fechaultconsumo = fechaultconsumo + element.fechaultconsumo + ',';
      promedio = promedio + element.promedio + ',';
      idlector = idlector + element.idlector + ',';
      tiempo = tiempo + element.tiempo + ',';
      sensor = sensor + element.sensor + ',';
      consumo = consumo + element.consumo + ',';
      novedad = novedad + element.novedad + ',';
      cordenadax = cordenadax + element.cordenadax + ',';
      cordenaday = cordenaday + element.cordenaday + ',';
      img = img + element.img + ',';
      lecturainicial = lecturainicial + element.lecturainicial + ',';
      aclaracion = aclaracion + element.aclaracion + ',';
    });
    var status = await Permission.storage.status;
    print(nombre);
    print(identificacion);
    print(ordruta);
    //if (status..) {
    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      // Permission.camera,
    ].request();

    if (await hayInternet()) {
      List<dynamic> associateList = [
        {
          "nombre": verbdusuario[0].nombre,
          "lat": verbdusuario[0].cordenadax,
          "lon": verbdusuario[0].cordenaday
        },
      ];

      List<List<dynamic>> rows = [];

      List<dynamic> row = [];
      row.add("Numero Cuenta");
      row.add("Numero Medidor");
      row.add("Tiempo");
      row.add("Consumo");
      row.add("Observaciones");
      rows.add(row);

      for (int i = 0; i < verbdusuario.length; i++) {
        List<dynamic> row = [];
        row.add(verbdusuario[i].numcuenta);
        row.add(verbdusuario[i].nummedidor);
        row.add(verbdusuario[i].tiempo);
        row.add(verbdusuario[i].consumo);
        row.add(verbdusuario[i].novedad);
        rows.add(row);
      }
      //Mostrar que se esta generando el archivo
      showDialog(
        context: context,
        builder: (BuildContext context) {
          dialogcontex = context;
          return AlertDialog(
            title: Text("Generando archivo"),
            content: Text("Por favor espere..."),
            // agregar tiempo de duracion de la carga
          );
        },
      );

      // eliminar el dialogo de espera
      // ignore: use_build_context_synchronously

      String csv = const ListToCsvConverter(fieldDelimiter: ";").convert(rows);

      String filenombre = '';
      String fecha = '';
      fecha = getCurrentDate();

      filenombre = fecha +
          "_lect_" +
          verbdusuario[0].idlector +
          "_ruta_" +
          verbdusuario[0].ruta.replaceAll(" ", "").replaceAll('"', "") +
          ".csv";

      File f = File(path + "/" + filenombre);

      await f.writeAsString(csv);
      await Future.delayed(Duration(seconds: 1));
      Navigator.pop(dialogcontex);

      Uri url = Uri.https('m2mlight.com', '/elchaco/recibir_lecturas.php');

      var req = http.MultipartRequest('POST', url);
      req.files.add(
          await http.MultipartFile.fromPath('file', path + "/" + filenombre));

      var resp = await req.send();
      // mostrar que se ha enviado el archivo

      showDialog(
          context: context,
          builder: (BuildContext context) {
            dialogcontex = context;
            return AlertDialog(
              title: Text("Archivo enviado"),
            );
          });

      await Future.delayed(Duration(seconds: 1));
      // eliminar el dialogo de espera
      Navigator.pop(dialogcontex);

      // Mostrar que se estan cargando los datos a la base de datos
      showDialog(
          context: context,
          builder: (BuildContext context) {
            dialogcontex = context;
            return AlertDialog(
              title: Text("Cargando datos"),
            );
          });
      // eliminar el dialogo de espera

      Uri url1 = Uri.https('m2mlight.com', '/elchaco/procesar_lecturas.php');
      var response = await http.post(url1, body: {
        "sensor_id": sensor,
        "latitud": cordenadax,
        "longitud": cordenaday,
        "tiempo": tiempo,
        "codigo_novedad": novedad,
        "foto_novedad": img,
        "cuenta": numcuenta,
        "medidor": nummedidor,
        "consumo_medi": consumo,
        "ruta": ruta,
        "idlector": idlector,
        "aclaracion": aclaracion,
        "orden": ordruta,
      });
      List novedades = await datab.getnovedadtable();

      Uri url2 =
          Uri.https('m2mlight.com', '/elchaco/leer_novedades_generales.php');
      // enviar datos de id_lector, tiempo, latitud, longitud, foto_novedad y observacion
      novedades.forEach((element) async {
        var response = await http.post(url2, body: {
          "id_lector": idlectorNovedad,
          "tiempo": element.tiempo,
          "latitud": element.latitud,
          "longitud": element.longitud,
          "foto_novedad": element.imagen,
          "observacion": element.descripcion,
        });
      });
      await datab.cleannovedadtable();

      await Future.delayed(Duration(seconds: 1));
      Navigator.pop(dialogcontex);
      await aviconsumo(3);
      Navigator.pop(progressContext);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            dialogcontex = context;
            return AlertDialog(
              title: Text("No hay internet"),
              content: Text("Por favor verifique su conexion a internet"),
            );
          });
      await Future.delayed(Duration(seconds: 2));
      Navigator.pop(progressContext);
      Navigator.pop(dialogcontex);
    }
  }

  bool hayConsumo() {
    bool isconsumo = true;
    verbdusuario.forEach((element) {
      if (element.consumo == '0' && element.img == 'vacio') {
        isconsumo = false;
      }
    });
    return isconsumo;
  }

  Future<bool> hayInternet() async {
    // Check if there is Internet
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  Future leertabla(int ejecutar) async {
    try {
      verbdusuario = await datab.getusertable();

      //setState(() {
      funciones = true;
      // mapear rutas de verbdusuario sin repetir

      verbdusuario.forEach((element) {
        if (!rutas.contains(element.ruta)) {
          rutas.add(element.ruta);
        }
      });
      // });

    } catch (e) {
      if (ejecutar != 1 && widget.btnbase != true) {
        aviconsumo(1);
      }
      funciones = false;
      return;
    }

    if (ejecutar == 1) {
      await confirmarGuardado("Cargar los datos",
          "Si existen datos cargados se actualizaran ¿Desea cargar los datos?");
      if (!confirmacion) return;
      if (widget.btnbase == true) {
        //if (funciones == false) {
        tablaconect();
        //}
      } else {
        aviconsumo(2);
      }
    }

    if (ejecutar == 2) {
      if (funciones == true) {
        _createPDF();
      }
    }
    if (ejecutar == 3) {
      if (funciones == true) {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return map();
        }));
      }
    }
    if (ejecutar == 4) {
      if (verbdusuario.length > 0) {
        if (funciones == true) {
          // showDialog(
          //     context: context,
          //     builder: (BuildContext context) {
          //       return AlertDialog(
          //         title: const Text('Elejir ruta'),
          //         content: DropdownButton<String>(
          //           hint: const Text('Seleccione una ruta'),
          //           value: rutas[0],
          //           onChanged: (String newValue) {
          //             setState(() {
          //               rutaSelect = newValue;
          //             });
          //           },
          //           items: rutas.isEmpty
          //               ? DropdownMenuItem<String>(
          //                   value: '0',
          //                   child: Text("No hay rutas"),
          //                 )
          //               : rutas.map<DropdownMenuItem<String>>((String value) {
          //                   return DropdownMenuItem<String>(
          //                     value: value,
          //                     child: Text(value),
          //                   );
          //                 }).toList(),
          //         ),
          //         actions: <Widget>[
          //           FlatButton(
          //             child: Text('Aceptar'),
          //             onPressed: () async {
          //               // guardar ruta seleccionada en la memoria interna del celular
          //               final prefs = await SharedPreferences.getInstance();

          Navigator.of(context).pop();
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return capdat();
          }));
          //  },
          // ),
          //       FlatButton(
          //         child: Text('Cancelar'),
          //         onPressed: () {
          //           Navigator.of(context).pop();
          //         },
          //       ),
          //     ],
          //   );
          // });
        }
      } else {
        aviconsumo(1);
      }
    }
    if (ejecutar == 5) {
      if (funciones == true) {
        // mostrar alerta de que no hay lecturas
        // verificar si existe usuarios sin consumo
        // si existe usuarios sin consumo mostrar alerta de que no hay lecturas
        if (!hayConsumo()) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Datos sin consumo"),
                  content: Text(
                      "Algunos datos no tienen consumo asignado.¿Enviar datos?"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Aceptar"),
                      onPressed: () {
                        enviardatos();
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text("Cancelar"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Enviar Datos"),
                  content: Text("¿Enviar los datos?"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Aceptar"),
                      onPressed: () {
                        enviardatos();
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text("Cancelar"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
        }
      }
    }
    if (ejecutar == 6) {
      if (funciones == true) {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return NovedadesGenerales();
        }));
      }
    }
  }

  Future aviconsumo(int numnovedades) async {
    if (numnovedades == 1) {
      showDialog(
          context: context,
          builder: (BuildContext progcontext) {
            dialogcontex = progcontext;
            return const CupertinoAlertDialog(
              title: Text('cargar primero datos ruta'),
              content: Text('no se puede acceder a las funciones'),
            );
          });
    }
    if (numnovedades == 2) {
      showDialog(
          context: context,
          builder: (BuildContext progcontext) {
            dialogcontex = progcontext;
            return const CupertinoAlertDialog(
              title: Text('Ingrese un usuario para cargar datos de ruta'),
              // content: Text('no se puede acceder a las funciones'),
            );
          });
    }
    if (numnovedades == 3) {
      showDialog(
          context: context,
          builder: (BuildContext progcontext) {
            dialogcontex = progcontext;
            return const CupertinoAlertDialog(
              title: Text('Datos enviados'),
              // content: Text('no se puede acceder a las funciones'),
            );
          });
    }
    if (numnovedades == 4) {
      showDialog(
          context: context,
          builder: (BuildContext progcontext) {
            dialogcontex = progcontext;
            return const CupertinoAlertDialog(
              title: Text('Error carga datos de ruta'),
              // content: Text('no se puede acceder a las funciones'),
            );
          });
    }
    if (numnovedades == 5) {
      showDialog(
          context: context,
          builder: (BuildContext progcontext) {
            dialogcontex = progcontext;
            return const CupertinoAlertDialog(
              title: Text('Datos de ruta cargado'),
              // content: Text('no se puede acceder a las funciones'),
            );
          });
    }

    await Future.delayed(Duration(seconds: 2));
    Navigator.pop(dialogcontex);
  }

  Future tablaconect() async {
    ruta = widget.rutaserpuesta;
    var status = await Permission.storage.status;

    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    progreso();
    Dio dio = Dio();
    String path = (await getExternalStorageDirectory()).path;

    String direccion = path + "/" + "archivo.csv";
    await dio.download(
        //'http://192.168.31.84/2022-06-23_lect_24_ruta_1010SIMONBOLIVAR.csv',
        //2022-06-23_lect_22_ruta_0101REVOLUCION-CENTRAL.csv
        // 'http://192.168.31.84/2022-06-23_lect_22_ruta_0101REVOLUCION-CENTRAL.csv',
        ruta,
        direccion);
    final input = new File(direccion).openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(new CsvToListConverter())
        .toList();

    List<String> filascsv = fields.toString().split("\n");
    List<String> itemscsv;

    try {
      try {
        verbdusuario = await datab.getusertable();
        cargarbase = true;
      } catch (e) {
        print(e);
        print("no hay elementos cargados "); //si existiera algun error
        cargarbase = false;
      }
      if (cargarbase == true) {
        if (verbdusuario.length == 0) {
          for (int i = 1; i < filascsv.length; i++) {
            if (filascsv[i].contains(";")) {
              itemscsv = filascsv[i].toString().split(";");
              await datab.insert(usuario(
                nombre: itemscsv[0],
                identificacion: itemscsv[1],
                numcuenta: itemscsv[2],
                nummedidor: itemscsv[3],
                marcamedidor: itemscsv[4],
                direccion: itemscsv[5],
                ruta: itemscsv[6],
                ordruta: itemscsv[7],
                ultconsumo: itemscsv[8],
                fechaultconsumo: itemscsv[9],
                promedio: itemscsv[10],
                idlector: itemscsv[11],
                tiempo: itemscsv[12],
                sensor: itemscsv[13],
                cordenadax: 'vacio',
                cordenaday: 'vacio',
                consumo: '0',
                novedad: 'Sin registro de lectura',
                img: 'vacio',
                lecturainicial: itemscsv[14],
                aclaracion: '',
              ));
            }
          }
        } else {
          int borrar = verbdusuario.length;
          for (int i = 0; i < verbdusuario.length; i++) {
            await datab.delete(borrar);
            borrar = borrar - 1;
            if (borrar == 0) {
              for (int i = 1; i < filascsv.length; i++) {
                if (filascsv[i].contains(";")) {
                  itemscsv = filascsv[i].toString().split(";");
                  await datab.insert(usuario(
                      nombre: itemscsv[0],
                      identificacion: itemscsv[1],
                      numcuenta: itemscsv[2],
                      nummedidor: itemscsv[3],
                      marcamedidor: itemscsv[4],
                      direccion: itemscsv[5],
                      ruta: itemscsv[6],
                      ordruta: itemscsv[7],
                      ultconsumo: itemscsv[8],
                      fechaultconsumo: itemscsv[9],
                      promedio: itemscsv[10],
                      idlector: itemscsv[11],
                      tiempo: itemscsv[12],
                      sensor: itemscsv[13],
                      cordenadax: 'vacio',
                      cordenaday: 'vacio',
                      consumo: '0',
                      novedad: 'Sin registro de lectura',
                      img: 'vacio',
                      lecturainicial: itemscsv[14],
                      aclaracion: ''));
                }
              }
            }
          }
        }
      }
      Navigator.pop(dialogcontex);
      aviconsumo(5);
    } catch (e) {
      print(e);
      Navigator.pop(dialogcontex);
      aviconsumo(4);
    }
  }

  Future confirmarGuardado(String novedad, String content) async {
    await showDialog(
        context: context,
        builder: (BuildContext progcontext) {
          dialogcontex = progcontext;
          return CupertinoAlertDialog(
            title: Text(novedad),
            content: Text(content),
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

  List<listitems> litems = [
    listitems(Icons.cloud_download_outlined, 'Cargar datos de ruta', true, 1),
    listitems(Icons.bookmark_border, 'Reporte de lecturas', false, 2),
    listitems(Icons.map_outlined, 'Mapa de lecturas', false, 3),
    listitems(Icons.book_online_outlined, 'Toma de lecturas', false, 4),
    listitems(Icons.report, 'Enviar reporte', false, 5),
    listitems(
        Icons.notification_important_sharp, 'Novedades Generales', false, 6)
  ];

  Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
    final path = (await getExternalStorageDirectory()).path;
    final file = File('$path/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open('$path/$fileName');
  }

  Future<void> _createPDF() async {
    PdfDocument document = PdfDocument();
    cargaruserpdf = await datab.getusertable();
    //final page = document.pages.add(); //añade una hoja en el pdf

    //page.graphics.drawString('Reporte', PdfStandardFont(PdfFontFamily.helvetica, 30));

    /* page.graphics.drawImage(
        PdfBitmap(await _readImageData('Pdf_Succinctly.jpg')),
        Rect.fromLTWH(0, 100, 440, 550));*/

    PdfGrid grid = PdfGrid();
    grid.style = PdfGridStyle(
        font: PdfStandardFont(PdfFontFamily.helvetica, 10),
        cellPadding: PdfPaddings(left: 5, right: 2, top: 2, bottom: 2));

    /*PdfGrid gridpaint = PdfGrid();
    grid.style = PdfGridStyle(
        font: PdfStandardFont(PdfFontFamily.helvetica, 20),
        cellPadding: PdfPaddings(left: 5, right: 2, top: 2, bottom: 2),
        backgroundBrush: PdfBrushes.seaGreen);*/

    grid.columns.add(count: 10);
    grid.headers.add(1);

    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'Orden';
    header.cells[1].value = 'Nombre';
    header.cells[2].value = 'N. Medidor';
    header.cells[3].value = 'Lectura Inicial';
    header.cells[4].value = 'Consumo';
    header.cells[5].value = 'Novedad';
    header.cells[6].value = 'Latitud';
    header.cells[7].value = 'Longitud';
    header.cells[8].value = 'Foto';
    header.cells[9].value = 'Aclaración';

    for (int i = 0; i < cargaruserpdf.length; i++) {
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = cargaruserpdf[i].ordruta;
      row.cells[1].value = cargaruserpdf[i].nombre;
      row.cells[2].value = cargaruserpdf[i].nummedidor;
      row.cells[3].value = "${cargaruserpdf[i].lecturainicial} m^3";
      row.cells[4].value = cargaruserpdf[i].consumo;
      row.cells[5].value = cargaruserpdf[i].novedad;
      row.cells[6].value = cargaruserpdf[i].cordenadax;
      row.cells[7].value = cargaruserpdf[i].cordenaday;
      if (cargaruserpdf[i].img != "vacio") {
        row.cells[8].value = "ok";
      } else {
        row.cells[8].value = cargaruserpdf[i].img;
      }
      if (cargaruserpdf[i].aclaracion != '') {
        row.cells[9].value = 'ok';
      } else {
        row.cells[9].value = 'vacio';
      }
    }

    grid.draw(
        page: document.pages.add(), bounds: const Rect.fromLTWH(0, 0, 0, 0));

    List<int> bytes = await document.save();
    document.dispose();

    saveAndLaunchFile(bytes, 'Reporte.pdf');
  }

  /*Future<Uint8List> _readImageData(String name) async {
    final data = await rootBundle.load('assets/$name');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }*/

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Color.fromARGB(255, 187, 198, 219),
          appBar: AppBar(
            title: Text('Medir'),
          ),
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(""),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: litems
                        .map((e) => Card(
                              elevation: 5,
                              child: InkWell(
                                onTap: () {
                                  leertabla(e.num);
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    /*    Image.asset(
                                      'assets/team.jpg',
                                    ),*/
                                    Icon(
                                      e.icon,
                                      size: 40,
                                      color: Colors.blueAccent,
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      e.title,
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              )
            ],
          )),
    );
  }
}

class listitems {
  final icon;
  final title;
  bool bactive = false;
  final num;
  listitems(this.icon, this.title, this.bactive, this.num);
}
