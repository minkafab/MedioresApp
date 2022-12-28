// @dart=2.9

import 'package:flutter/material.dart';
import 'package:milton/dats.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';

class login extends StatefulWidget {
  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  String user, password;
  bool _passwordVisible;
  @override
  void initState() {
    _passwordVisible = false;
  }

  Future noencontrado(String novedad) async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(novedad),
            content: Text('¿Volver a ingresar?'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context, 'Si');
                },
                child: Text('Si'),
              ),
            ],
          );
        })) {
      case 'Si':
        break;
    }
  }

  Future<void> peticion() async {
    Uri url = Uri.http('m2mlight.com', '/minka/app_login.php',
        {'user': user, 'password': password});

    var respuesta = await http.get(url);

    String response = '';
    response = respuesta.body;

    Uri url1 = Uri.http(
        'm2mlight.com', '/minka/dame_mi_ruta.php', {'id_user': response});

    var ruta = await http.get(url1);
    String rutaresp = '';
    rutaresp = ruta.body;

    int idlog = int.parse(response);

    if (idlog != 0 && rutaresp != '0') {
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return dats(true, rutaresp);
      }));
    } else {
      noencontrado(idlog == 0
          ? 'Usuario no encontrado'
          : 'El usuario no tiene rutas asignadas');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
          reverse: true,
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(70),
                          bottomRight: Radius.circular(70))),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Text('Lectura Medidores V1.4.2',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height / 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.height /
                                                30,
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: (value) {
                                      setState(() {
                                        user = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.admin_panel_settings,
                                          color: Colors.blue,
                                        ),
                                        labelText: 'Usuario'),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    obscureText: !_passwordVisible,
                                    onChanged: (value) {
                                      setState(() {
                                        password = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.lock,
                                          color: Colors.blue,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            // Based on passwordVisible state choose the icon
                                            _passwordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                          onPressed: () {
                                            // Update the state i.e. toogle the state of passwordVisible variable
                                            setState(() {
                                              _passwordVisible =
                                                  !_passwordVisible;
                                            });
                                          },
                                        ),
                                        labelText: 'Contraseña'),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 1.4 *
                                          (MediaQuery.of(context).size.height /
                                              20),
                                      width: 5 *
                                          (MediaQuery.of(context).size.width /
                                              10),
                                      margin: EdgeInsets.all(20),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          peticion();
                                        },
                                        child: Text('login'),
                                      ),
                                    ),
                                    Container(
                                      height: 1.4 *
                                          (MediaQuery.of(context).size.height /
                                              20),
                                      width: 5 *
                                          (MediaQuery.of(context).size.width /
                                              10),
                                      margin: EdgeInsets.all(20),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(builder:
                                                  (BuildContext context) {
                                            return dats(false, null);
                                          }));
                                        },
                                        child: Text('login off'),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            )),
                      ),
                    ],
                  ),
                ],
              )
            ],
          )),
    ));
  }
}
