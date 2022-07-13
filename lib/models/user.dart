import 'package:flutter/material.dart';

class User {
  String id;
  String username;
  String nik;
  String first_name;
  String last_name;
  String address;
  String phone_no;
  String role;
  List<Device> devices;
  User(
      {required this.id,
      required this.nik,
      required this.first_name,
      required this.last_name,
      required this.username,
      required this.address,
      required this.phone_no,
      required this.role,
      required this.devices});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        username: json['username'],
        nik: json['nik'],
        first_name: json['first_name'],
        last_name: json['last_name'],
        address: json['address'],
        phone_no: json['phone_no'],
        role: json['role'],
        devices: []);
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nik'] = nik;
    data['first_name'] = first_name;
    data['last_name'] = last_name;
    data['username'] = username;
    data['address'] = address;
    data['phone_no'] = phone_no;
    data['role'] = role;
    data['devices'] = devices;
    return data;
  }
}

class Device {
  String id;
  String name;
  String userid;
  String serialnum;
  double lat;
  double lon;
  String status;

  Device(
      {required this.id,
      required this.name,
      required this.userid,
      required this.serialnum,
      required this.lat,
      required this.lon,
      required this.status});
  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
        id: json['id'],
        name: json['name'],
        userid: json['userid'],
        serialnum: json['serialnum'] ?? '',
        lat: json['lat'] ?? 0.0,
        lon: json['lon'] ?? 0.0,
        status: json['status'] ?? '');
  }
}
