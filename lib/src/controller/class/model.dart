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

class usuario {
  int id;
  String nombre;
  String identificacion;
  String numcuenta;
  String nummedidor;
  String marcamedidor;
  String direccion;
  String ruta;
  String ordruta;
  String ultconsumo;
  String fechaultconsumo;
  String promedio;
  String idlector;
  String tiempo;
  String sensor;
  String consumo;
  String novedad;
  String cordenadax;
  String cordenaday;
  String img;
  String lecturainicial;
  String aclaracion;

  usuario(
      this.id,
      this.nombre,
      this.identificacion,
      this.numcuenta,
      this.nummedidor,
      this.marcamedidor,
      this.direccion,
      this.ruta,
      this.ordruta,
      this.ultconsumo,
      this.fechaultconsumo,
      this.promedio,
      this.idlector,
      this.tiempo,
      this.sensor,
      this.consumo,
      this.novedad,
      this.cordenadax,
      this.cordenaday,
      this.img,
      this.lecturainicial,
      this.aclaracion);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'identificacion': identificacion,
      'numcuenta': numcuenta,
      'nummedidor': nummedidor,
      'marcamedidor': marcamedidor,
      'direccion': direccion,
      'ruta': ruta,
      'ordruta': ordruta,
      'ultconsumo': ultconsumo,
      'fechaultconsumo': fechaultconsumo,
      'promedio': promedio,
      'idlector': idlector,
      'tiempo': tiempo,
      'sensor': sensor,
      'consumo': consumo,
      'novedad': novedad,
      'cordenadax': cordenadax,
      'cordenaday': cordenaday,
      'img': img,
      'lecturainicial': lecturainicial,
      'aclaracion': aclaracion,
    };
  }
}
