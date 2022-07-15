import 'dart:convert';

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
    debugPrint(json['devices'].toString());
    List<Device> list = [];
    for (final element in json['devices']) {
      list.add(Device.fromJson(element));
    }
    return User(
        id: json['id'],
        username: json['username'],
        nik: json['nik'],
        first_name: json['first_name'],
        last_name: json['last_name'],
        address: json['address'],
        phone_no: json['phone_no'],
        role: json['role'],
        devices: list);
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
  String serial_num;
  String description;
  double lat;
  double lon;
  String status;
  bool isExpanded;
  Device(
      {required this.id,
      required this.name,
      required this.serial_num,
      required this.description,
      required this.lat,
      required this.lon,
      required this.status,
      this.isExpanded = false});
  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
        id: json['id'],
        name: json['name'],
        serial_num: json['serial_num'],
        description: json['description'],
        lat: json['lat'],
        lon: json['lon'],
        status: json['status']);
  }
}
