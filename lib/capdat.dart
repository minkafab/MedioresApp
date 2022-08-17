//@dart=2.9
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:milton/dats.dart';
import 'package:flutter/material.dart';
import 'package:milton/picture.dart';
import 'package:milton/userdat.dart';
import 'package:milton/basedat.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' as lib_pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:native_pdf_renderer/native_pdf_renderer.dart' as render_pdf;

import 'cam.dart';

class capdat extends StatefulWidget {
  @override
  State<capdat> createState() => _capdatState();
}

class _capdatState extends State<capdat> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  bool _connected = false;
  BluetoothDevice _device;
  String tips = 'No hay impresora conectada';

  int cont = 0;
  bool refrescar = true;
  BuildContext dialogcontex;
  BuildContext progresocontext;
  List cargar = [];
  String _consumo = '';
  String ultimaBusqueda = '';
  List<usuario> verbdusuario;
  List<usuario> verbdusuario2;
  bool _isSearching = false;
  bool confirmacion = false;
  bool isCharging = false;

  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));

    bool isConnected = await bluetoothPrint.isConnected;

    bluetoothPrint.state.listen((state) {
      print('cur device status: $state');

      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'Conectado';
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'Desconectado';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

// Mostrar dispositives Bluetooth
  void showPrintDialog(usuario usuario) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Selecciona un dispositivo'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return RefreshIndicator(
              onRefresh: () =>
                  bluetoothPrint.startScan(timeout: Duration(seconds: 4)),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Text(tips),
                        ),
                      ],
                    ),
                    Divider(),
                    StreamBuilder<List<BluetoothDevice>>(
                      stream: bluetoothPrint.scanResults,
                      initialData: [],
                      builder: (c, snapshot) => Column(
                        children: snapshot.data
                            .map((d) => ListTile(
                                  title: Text(d.name ?? ''),
                                  subtitle: Text(d.address),
                                  onTap: () async {
                                    setState(() {
                                      _device = d;
                                    });
                                  },
                                  trailing: _device != null &&
                                          _device.address == d.address
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        )
                                      : null,
                                ))
                            .toList(),
                      ),
                    ),
                    Divider(),
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              OutlinedButton(
                                child: Text('Conectar'),
                                onPressed: _connected
                                    ? null
                                    : () async {
                                        if (_device != null &&
                                            _device.address != null) {
                                          await bluetoothPrint.connect(_device);
                                          setState(() {
                                            _connected = true;
                                            tips = 'Conectado';
                                          });
                                        } else {
                                          setState(() {
                                            tips = 'Seleccione un dispositivo';
                                          });
                                          print('Seleccione un dispositivo');
                                        }
                                      },
                              ),
                              SizedBox(width: 10.0),
                              OutlinedButton(
                                child: Text('Desconectar'),
                                onPressed: _connected
                                    ? () async {
                                        await bluetoothPrint.disconnect();
                                        setState(() {
                                          _connected = false;
                                          tips = 'Desconectado';
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                          OutlinedButton(
                            child: Text('Imprimir Recibo'),
                            onPressed: _connected
                                ? () async {
                                    Map<String, dynamic> config = Map();
                                    config['width'] = 57;
                                    config['height'] = -100;
                                    config['gap'] = 2;
                                    // fecha sin hora
                                    String fecha = DateTime.now().toString();
                                    fecha = fecha.substring(0, 10);
                                    List<LineText> list = [];
                                    // crear pdf
                                    final pdf = pw.Document();
                                    pdf.addPage(pw.MultiPage(
                                      pageFormat: lib_pdf.PdfPageFormat(
                                          8.5 * 72.0, 5 * 72.0),
                                      margin:
                                          pw.EdgeInsets.fromLTRB(0, 40, 155, 0),
                                      build: (pw.Context context) {
                                        return <pw.Widget>[
                                          pw.Text(
                                            'Recibo de Consumo',
                                            textAlign: pw.TextAlign.center,
                                            style: pw.TextStyle(
                                                fontSize: 30,
                                                fontWeight: pw.FontWeight.bold),
                                          ),
                                          pw.Text(
                                            'GAD Municipal LORETO',
                                            textAlign: pw.TextAlign.center,
                                            style: pw.TextStyle(
                                                fontSize: 25,
                                                fontWeight: pw.FontWeight.bold),
                                          ),
                                          pw.Text(
                                            'Cuenta: ${usuario.numcuenta}',
                                            style: pw.TextStyle(
                                                fontSize: 25,
                                                fontWeight:
                                                    pw.FontWeight.normal),
                                          ),
                                          pw.Text(
                                            'Medidor:${usuario.nummedidor}',
                                            style: pw.TextStyle(
                                                fontSize: 25,
                                                fontWeight:
                                                    pw.FontWeight.normal),
                                          ),
                                          pw.Text(
                                            'Nombre: ${usuario.nombre}',
                                            style: pw.TextStyle(
                                                fontSize: 25,
                                                fontWeight:
                                                    pw.FontWeight.normal),
                                          ),
                                          pw.Text(
                                            'Consumo anterior: ${usuario.lecturainicial} m³',
                                            style: pw.TextStyle(
                                                fontSize: 25,
                                                fontWeight:
                                                    pw.FontWeight.normal),
                                          ),
                                          pw.Text(
                                            'Fecha:$fecha',
                                            style: pw.TextStyle(
                                                fontSize: 25,
                                                fontWeight:
                                                    pw.FontWeight.normal),
                                          ),
                                          pw.Text(
                                            'Consumo actual :${usuario.consumo} m³',
                                            style: pw.TextStyle(
                                                fontSize: 25,
                                                fontWeight:
                                                    pw.FontWeight.normal),
                                          ),
                                          pw.Text(
                                            '-----------------------------------------',
                                            style: pw.TextStyle(
                                                fontSize: 25,
                                                fontWeight: pw.FontWeight.bold),
                                          ),
                                        ];
                                      },
                                    ));

                                    // guardar pdf
                                    final filePdf = await File(
                                        '${(await getExternalStorageDirectory()).path}/recibo.pdf');
                                    await filePdf
                                        .writeAsBytes(await pdf.save());

                                    // convert pdf to image
                                    Uint8List image =
                                        await convertPdfToImage(filePdf.path);
                                    // recortar alto de la image para que no se vea el encabezado

                                    Uint8List image2 =
                                        await Uint8List.sublistView(
                                            image, 0, image.length - 3000);

                                    final ByteData data =
                                        ByteData.view(image2.buffer);

                                    List<int> imageBytes = await data.buffer
                                        .asUint8List(data.offsetInBytes,
                                            data.lengthInBytes);
                                    String base64 = base64Encode(imageBytes);

                                    list.add(LineText(
                                      type: LineText.TYPE_IMAGE,
                                      content: base64,
                                      x: 40,
                                      y: 40,
                                    ));
                                    await bluetoothPrint.printLabel(
                                        config, list);
                                  }
                                : null,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  final TextEditingController _searchQuery = TextEditingController();
  List<listitems> litems = [
    listitems(Icons.cloud_download_outlined, 'Base de datos', true, 1),
    listitems(Icons.camera_alt, 'Medir', false, 2),
    listitems(Icons.bookmark_border, 'Reporte', false, 3),
    listitems(Icons.map_outlined, 'Mapa', false, 4),
    listitems(Icons.book_online_outlined, 'Medir Manual', false, 5),
  ];

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

      String response = '';
      response = respuesta.body;
    } catch (e) {
      print('error');
    }
  }

  Future aviconsumo(int numnovedades) async {
    if (numnovedades == 1) {
      showDialog(
          context: context,
          builder: (BuildContext progcontext) {
            dialogcontex = progcontext;
            return const CupertinoAlertDialog(
              title: Text('Consumo guardado'),
              content: Text('Consumo sobre rango estimado'),
            );
          });
    }
    if (numnovedades == 2) {
      showDialog(
          context: context,
          builder: (BuildContext progcontext) {
            dialogcontex = progcontext;
            return const CupertinoAlertDialog(
              title: Text('Consumo guardado'),
              content: Text('Consumo bajo el rango estimado'),
            );
          });
    }
    if (numnovedades == 3) {
      showDialog(
          context: context,
          builder: (BuildContext progcontext) {
            dialogcontex = progcontext;
            return const CupertinoAlertDialog(
              title: Text('Consumo guardado'),
              content: Text('Sin novedad'),
            );
          });
    }
    if (numnovedades == 4) {
      showDialog(
          context: context,
          builder: (BuildContext progcontext) {
            dialogcontex = progcontext;
            return const CupertinoAlertDialog(
              title: Text('Consumo no guardado'),
              content: Text('Consumo acumulado menor que el anterior'),
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
    if (numnovedades == 6) {
      showDialog(
          context: context,
          builder: (BuildContext progcontext) {
            dialogcontex = progcontext;
            return const CupertinoAlertDialog(
              title: Text('Consumo Guardado'),
              content: Text('No hay como validar rango'),
            );
          });
    }

    await Future.delayed(Duration(seconds: 2));
    Navigator.pop(dialogcontex);
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

  Future progreso() async {
    // if()
    showDialog(
        context: context,
        builder: (BuildContext progcontext) {
          progresocontext = progcontext;
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

  Future confirmarEliminado(String novedad) async {
    await showDialog(
        context: context,
        builder: (BuildContext progcontext) {
          dialogcontex = progcontext;
          return CupertinoAlertDialog(
            title: Text(novedad),
            content: Text('¿Eliminar Foto?'),
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

  Future verificaretiqueta(usuario user) async {
    //7428

    List coordenadas = await datab.localizacion();
    //await peticion(coordenadas[0], coordenadas[1], user.nummedidor);

    String novedadcons = 'Sin registro de lectura';
    int numnovedades = 0;
    try {
      int promedio = int.parse(user.promedio);
      int consumoant = int.parse(user.lecturainicial);
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
        id: user.id,
        nombre: user.nombre,
        identificacion: user.identificacion,
        numcuenta: user.numcuenta,
        nummedidor: user.nummedidor,
        marcamedidor: user.marcamedidor,
        direccion: user.direccion,
        ruta: user.ruta,
        ordruta: user.ordruta,
        ultconsumo: user.ultconsumo,
        fechaultconsumo: user.fechaultconsumo,
        promedio: user.promedio,
        idlector: user.idlector,
        tiempo: fecha,
        sensor: user.sensor,
        consumo: _consumo == '' ? '0' : _consumo,
        novedad: novedadcons,
        cordenadax: coordenadas[0], //latitud
        cordenaday: coordenadas[1], //longitud
        img: user.img,
        lecturainicial: user.lecturainicial,
        aclaracion: user.aclaracion));

    aviconsumo(numnovedades);
    _consumo = '';
    setState(() {});
    refrescarUsuario();
  }

  Future leertabla() async {
    // el id de usuario empieza en 1

    // tablaconect().then((value) {
    if (refrescar == true) {
      verbdusuario = await datab.getusertable();

      verbdusuario2 = verbdusuario;
      if (_isSearching) {
        buscarElemento(ultimaBusqueda);
      }
      isCharging = true;
      setState(() {});
      refrescar = false;
    }

    return verbdusuario;
  }

  @override
  void initState() {
    super.initState();
    leertabla();
    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  void buscarElemento(String buscar) {
    if (buscar.isNotEmpty) {
      setState(() {
        _isSearching = true;
        verbdusuario = verbdusuario2.where((element) {
          return element.nummedidor
              .toLowerCase()
              .contains(buscar.toLowerCase());
        }).toList();
        if (verbdusuario.length == 0) {
          verbdusuario.add(usuario(
              id: 0,
              nombre: 'No se encontraron resultados',
              identificacion: '',
              numcuenta: '',
              nummedidor: '',
              marcamedidor: '',
              direccion: '',
              ruta: verbdusuario2[0].ruta,
              ordruta: '',
              ultconsumo: '',
              fechaultconsumo: '',
              promedio: '',
              idlector: '',
              tiempo: '',
              sensor: '',
              consumo: '',
              novedad: '',
              cordenadax: '',
              cordenaday: '',
              img: '',
              lecturainicial: '',
              aclaracion: ''));
        }
        //setear gridview a la cantidad de elementos encontrados
      });
    } else {
      verbdusuario = verbdusuario2;
      setState(() {});
    }
  }

  void refrescarUsuario() async {
    refrescar = true;
    _consumo = '';
    await leertabla();
    verbdusuario = verbdusuario2;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var buscar;
    var _descripcion;
    return SafeArea(
      child: Scaffold(
          backgroundColor: Color.fromARGB(255, 187, 198, 219),
          appBar: AppBar(
            leading: GestureDetector(
                child: Icon(Icons.arrow_back),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return dats(null, null);
                  }));
                }),
            title: Text('  RUTA  ${isCharging ? verbdusuario[0].ruta : ''}'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: '',
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Buscar medidor'),
                          content: TextField(
                            onChanged: (value) {
                              setState(() {
                                ultimaBusqueda = value;
                              });
                              buscar = value;
                              buscarElemento(buscar);
                            },
                            // buscar mientras se escribe
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Cancelar'),
                              onPressed: () {
                                // eliminar el dialogo
                                Navigator.of(context).pop();
                                setState(() {
                                  verbdusuario = verbdusuario2;
                                });
                              },
                            ),
                            FlatButton(
                              child: Text('Buscar'),
                              onPressed: () {
                                buscarElemento(buscar);
                                Navigator.of(context).pop();
                                // buscar elemento en gridview
                              },
                            ),
                          ],
                        );
                      });
                },
              ),
              IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Show Snackbar',
                  onPressed: () {
                    // eliminar el filtro de busqueda
                    _isSearching = false;
                    setState(() {});
                    refrescarUsuario();
                  })
            ],
          ),
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              Expanded(
                child: Padding(
                    // height: ((MediaQuery.of(context).size.height) * 0.4),

                    padding: const EdgeInsets.all(9.0),
                    child: FutureBuilder(
                        future: leertabla(),
                        builder: (context, snapshot) {
                          return OrientationBuilder(
                            builder: (context, orientation) {
                              if (!snapshot.hasData) {
                                return Text('cargando');
                              }

                              return GridView.count(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                crossAxisCount:
                                    orientation == Orientation.portrait ? 1 : 2,

                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                //childAspectRatio 1.2 si es vertical, 2.9 si es horizontal
                                childAspectRatio: orientation !=
                                        Orientation.portrait
                                    ? MediaQuery.of(context).size.width < 1000
                                        ? 1.4
                                        : MediaQuery.of(context).size.width /
                                            (MediaQuery.of(context).size.height)
                                    : MediaQuery.of(context).size.height < 1000
                                        ? 1
                                        : MediaQuery.of(context).size.height /
                                            (MediaQuery.of(context).size.width),

                                children:
                                    verbdusuario[0].nombre ==
                                            'No se encontraron resultados'
                                        ? ([
                                            const Text(
                                              'No se encontraron resultados',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ])
                                        : verbdusuario
                                            .map((e) => Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      border: Border.all(
                                                        color: Colors.black,
                                                        width: 1,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black45,
                                                          blurRadius: 1,
                                                          offset: Offset(10, 5),
                                                        )
                                                      ]),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                25, 0, 25, 0),
                                                        margin:
                                                            EdgeInsets.fromLTRB(
                                                                0, 0, 0, 20),
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: orientation ==
                                                                Orientation
                                                                    .portrait
                                                            ? ((((MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height)) *
                                                                0.2))
                                                            : ((((MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height)) *
                                                                0.25)),
                                                        decoration:
                                                            BoxDecoration(
                                                                color: e.consumo ==
                                                                            '0' &&
                                                                        e.img ==
                                                                            'vacio'
                                                                    ? const Color.fromRGBO(
                                                                        171,
                                                                        222,
                                                                        250,
                                                                        1)
                                                                    : const Color
                                                                            .fromRGBO(
                                                                        165,
                                                                        238,
                                                                        160,
                                                                        1),
                                                                borderRadius:
                                                                    BorderRadius.all(
                                                                        Radius.circular(
                                                                            10)),
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .black,
                                                                  width: 1,
                                                                ),
                                                                boxShadow: const [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black45,
                                                                blurRadius: 2,
                                                                offset: Offset(
                                                                    2, 2),
                                                              )
                                                            ]),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              textDirection:
                                                                  TextDirection
                                                                      .rtl,
                                                              children: [
                                                                Text(
                                                                  // e.title,
                                                                  'Orden: ${e.ordruta}',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          13),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                ),
                                                              ],
                                                            ),
                                                            Text(
                                                              e.nombre,
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Text(
                                                              '     Cuenta: ${e.numcuenta}',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                            Text(
                                                              'Número de medidor: ${e.nummedidor}',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                            Row(
                                                                textDirection:
                                                                    TextDirection
                                                                        .ltr,
                                                                children: [
                                                                  Column(
                                                                      children: [
                                                                        Text(
                                                                          'Última Lectura: ${e.lecturainicial}   Promedio: ${e.promedio}',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize:
                                                                                16,
                                                                          ),
                                                                        ),
                                                                      ])
                                                                ])
                                                          ],
                                                        ),
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              Column(children: [
                                                                Container(
                                                                  margin: EdgeInsets
                                                                      .fromLTRB(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          10),
                                                                  height: 50,
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.2,
                                                                  child:
                                                                      TextFormField(
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    initialValue:
                                                                        e.consumo !=
                                                                                '0'
                                                                            ? e.consumo
                                                                            : '',
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        _consumo =
                                                                            value;
                                                                      });
                                                                    },
                                                                    decoration: InputDecoration(
                                                                        labelText:
                                                                            'Lectura'),
                                                                  ),
                                                                ),
                                                              ]),
                                                              Column(
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                    child:
                                                                        ElevatedButton(
                                                                      onPressed:
                                                                          () async {
                                                                        int valcon =
                                                                            0;
                                                                        try {
                                                                          valcon =
                                                                              int.parse(_consumo);
                                                                          await verificaretiqueta(
                                                                              e);
                                                                        } catch (e) {
                                                                          avimconsumo();
                                                                        }
                                                                        //cerrar el teclado
                                                                        FocusScope.of(context)
                                                                            .requestFocus(FocusNode());
                                                                      },
                                                                      child: Text(
                                                                          'Grabar consumo'),
                                                                    ),
                                                                  )
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceEvenly,
                                                                children: [
                                                                  ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        // ventana modal con campo de texto para descripcion
                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder: (context) =>
                                                                              AlertDialog(
                                                                            title:
                                                                                Text('Descripción'),
                                                                            content:
                                                                                TextField(
                                                                              maxLength: 40,
                                                                              onChanged: (value) {
                                                                                setState(() {
                                                                                  _descripcion = value;
                                                                                });
                                                                              },
                                                                            ),
                                                                            actions: <Widget>[
                                                                              FlatButton(
                                                                                child: Text('Cancelar'),
                                                                                onPressed: () {
                                                                                  _descripcion = '';
                                                                                  print(e.aclaracion);
                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                              ),
                                                                              FlatButton(
                                                                                  child: Text('Aceptar'),
                                                                                  onPressed: () {
                                                                                    print(_descripcion);
                                                                                    guardarAclaracion(e, _descripcion);
                                                                                    Navigator.of(context).pop();
                                                                                  })
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                      child: Text(
                                                                          'Aclaración'))
                                                                ],
                                                              ),
                                                              Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    ElevatedButton(
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          primary: e.img == 'vacio'
                                                                              ? Colors.blue
                                                                              : Colors.red,
                                                                        ),
                                                                        // cambiar de color

                                                                        onPressed: e.img ==
                                                                                'vacio'
                                                                            ? () {
                                                                                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                                                                                  return picture(e);
                                                                                }));
                                                                              }
                                                                            : () async {
                                                                                await confirmarEliminado("¿Desea eliminar la foto?");
                                                                                if (confirmacion) {
                                                                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                                                                                    return const CupertinoAlertDialog(
                                                                                      title: Text('Foto Eliminada'),
                                                                                    );
                                                                                  }));
                                                                                  await eliminarFoto(e);
                                                                                  Navigator.pop(context);
                                                                                  refrescarUsuario();
                                                                                }
                                                                                setState(() {
                                                                                  confirmacion = false;
                                                                                });
                                                                              },
                                                                        child: e.img ==
                                                                                'vacio'
                                                                            ? Text('Tomar Foto')
                                                                            : Text('Eliminar Foto')),
                                                                  ]),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(builder:
                                                                            (BuildContext
                                                                                context) {
                                                                      return cam(
                                                                          e);
                                                                    }));
                                                                  },
                                                                  child: Text(
                                                                      'Consumo Automatico ')),
                                                              Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceEvenly,
                                                                children: [
                                                                  ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        showPrintDialog(
                                                                            e);
                                                                      },
                                                                      child: Text(
                                                                          'Imprimir Consumo')),
                                                                ],
                                                              )
                                                            ],
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ))
                                            .toList(),
                              );
                            },
                          );
                        })),
              )
            ],
          )),
    );
  }
}

convertPdfToImage(String path) async {
  final pdf1 = await render_pdf.PdfDocument.openFile(path);
  final page = await pdf1.getPage(1);
  final image = await page.render(
    width: page.width,
    height: page.height,
    format: render_pdf.PdfPageImageFormat.png,
    backgroundColor: '#FFFFFF',
  );
  final bytes = image.bytes;
  return image.bytes;
}

void eliminarFoto(usuario e) async {
  await datab.update(usuario(
      id: e.id,
      nombre: e.nombre,
      identificacion: e.identificacion,
      numcuenta: e.numcuenta,
      nummedidor: e.nummedidor,
      marcamedidor: e.marcamedidor,
      direccion: e.direccion,
      ruta: e.ruta,
      ordruta: e.ordruta,
      ultconsumo: e.ultconsumo,
      fechaultconsumo: e.fechaultconsumo,
      promedio: e.promedio,
      idlector: e.idlector,
      tiempo: e.tiempo,
      sensor: e.sensor,
      consumo: e.consumo,
      novedad: e.novedad,
      cordenadax: e.consumo == '0' ? 'vacio' : e.cordenadax, //latitud
      cordenaday: e.consumo == '0' ? 'vacio' : e.cordenaday,
      img: 'vacio',
      lecturainicial: e.lecturainicial,
      aclaracion: e.aclaracion));
  await Future.delayed(Duration(seconds: 1));
}

void guardarAclaracion(usuario e, String aclaracion) async {
  await datab.update(usuario(
      id: e.id,
      nombre: e.nombre,
      identificacion: e.identificacion,
      numcuenta: e.numcuenta,
      nummedidor: e.nummedidor,
      marcamedidor: e.marcamedidor,
      direccion: e.direccion,
      ruta: e.ruta,
      ordruta: e.ordruta,
      ultconsumo: e.ultconsumo,
      fechaultconsumo: e.fechaultconsumo,
      promedio: e.promedio,
      idlector: e.idlector,
      tiempo: e.tiempo,
      sensor: e.sensor,
      consumo: e.consumo,
      novedad: e.novedad,
      cordenadax: e.cordenadax, //latitud
      cordenaday: e.cordenaday,
      img: e.img,
      lecturainicial: e.lecturainicial,
      aclaracion: aclaracion));
}

class listitems {
  final icon;
  final title;
  bool bactive = false;
  final num;
  listitems(this.icon, this.title, this.bactive, this.num);
}
