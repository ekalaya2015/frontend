// ignore_for_file: empty_constructor_bodies

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:frontend/screens/home_page.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/screens/reset_password.dart';
import 'package:frontend/widgets/display_image.dart';
import 'package:frontend/screens/edit_name.dart';
import 'package:frontend/screens/edit_address.dart';
import 'package:frontend/screens/edit_phone.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/screens/device_map.dart';
import 'package:frontend/utils/config.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // void navigateSecondPage(BuildContext context, Widget editForm) {}
  late Future<User> futureUser;
  late Future<List<Device>> futureDevices;

  Future<List<Device>> fetchDevices() async {
    const url = '${MonitaxConfig.API_BASE_URL}/devices/me';
    List<Device> devices = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    var response = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Access-Control_Allow_Origin': '*',
      'Authorization': 'Bearer $token'
    }).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      for (final element in jsonDecode(response.body)) {
        devices.add(Device.fromJson(element));
      }
    } else {
      const snackBar = SnackBar(
        content: Text('Loading failed. check your internet connection'),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 2),
      );
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return devices;
  }

  Future<User> fetchUser() async {
    const url = '${MonitaxConfig.API_BASE_URL}/users/me';
    User? user;
    // Future<String?> token = getToken();
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    // token.then((value) async {
    var response = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Access-Control_Allow_Origin': '*',
      'Authorization': 'Bearer $token'
    }).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      user = User.fromJson(jsonDecode(response.body));
    } else {
      const snackBar = SnackBar(
        content: Text('Loading failed. check your internet connection'),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 2),
      );
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    // });
    // await Future.delayed(Duration(seconds: 5));
    return user!;
  }

  @override
  void initState() {
    super.initState();
    futureUser = fetchUser();
    futureDevices = fetchDevices();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => HomePage(),
                  ),
                  (route) => false,
                );
              },
              child: const Icon(Icons.arrow_back),
            ),
            appBar: AppBar(
              title: const Text('Profile'),
              bottom: const TabBar(tabs: [
                Tab(
                  icon: Icon(Icons.account_circle_rounded),
                ),
                Tab(
                  icon: Icon(Icons.devices_other),
                )
              ]),
            ),
            body: TabBarView(children: [
              UserProfile(futureUser: futureUser),
              DeviceProfile(futureDevices: futureDevices),
            ])),
      ),
    );
  }
}

class DeviceProfile extends StatefulWidget {
  const DeviceProfile({
    Key? key,
    required this.futureDevices,
  }) : super(key: key);

  final Future<List<Device>> futureDevices;

  @override
  State<DeviceProfile> createState() => _DeviceProfileState();
}

class _DeviceProfileState extends State<DeviceProfile> {
  Widget buildPanel(data) {
    return Column(
      children: [
        ExpansionPanelList(
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              data[index].isExpanded = !isExpanded;
            });
          },
          children: data.map<ExpansionPanel>((Device device) {
            return ExpansionPanel(
                canTapOnHeader: true,
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                      title: Text(
                    device.name,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ));
                },
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0, bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              color: Colors.grey.shade200,
                              child: SizedBox(
                                height: 32,
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: Text(
                                  'Desc: ',
                                  softWrap: true,
                                  maxLines: 2,
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Container(
                              color: Colors.grey.shade200,
                              child: SizedBox(
                                height: 32,
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Text(
                                  device.description,
                                  softWrap: true,
                                  maxLines: 2,
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0, bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              child: SizedBox(
                                height: 32,
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: Text(
                                  'Serial#: ',
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Container(
                              child: SizedBox(
                                height: 32,
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Text(
                                  device.serial_num,
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0, bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              color: Colors.grey.shade200,
                              child: SizedBox(
                                height: 32,
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: Text(
                                  'Status: ',
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Container(
                              color: Colors.grey.shade200,
                              child: SizedBox(
                                height: 32,
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Text(
                                  device.status,
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0, bottom: 10),
                        child: Row(
                          children: [
                            Container(
                                child: SizedBox(
                              height: 32,
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: Text(
                                'Location',
                                style: GoogleFonts.poppins(
                                    fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            )),
                            Container(
                              child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  height: 32,
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: InkWell(
                                        onTap: () {
                                          navigateSecondPage(
                                              context,
                                              DeviceMap(
                                                  name: device.name,
                                                  lat: device.lat,
                                                  lon: device.lon));
                                        },
                                        child: const Icon(
                                          Icons.pin_drop_outlined,
                                          size: 24,
                                        )),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                isExpanded: device.isExpanded);
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.futureDevices,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<Device> data = snapshot.data as List<Device>;
          debugPrint(data.length.toString());
          return SingleChildScrollView(
            child: Container(
              child: buildPanel(data),
            ),
          );
        }
        return const Text('Empty');
      },
    );
  }
}

class UserProfile extends StatefulWidget {
  const UserProfile({
    Key? key,
    required this.futureUser,
  }) : super(key: key);

  final Future<User> futureUser;

  @override
  State<UserProfile> createState() => _UserProfileState();
}

Widget ShimmerProfile(BuildContext context) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade500,
    highlightColor: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: <Widget>[
          CircleAvatar(radius: 80),
          Padding(padding: EdgeInsets.only(bottom: 320)),
          ElevatedButton(onPressed: () {}, child: Text('reset password'))
        ],
      ),
    ),
  );
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
        future: widget.futureUser,
        // initialData: initUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerProfile(context);
            // return Column(
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: <Widget>[
            //     const Center(child: CircularProgressIndicator()),
            //     Visibility(
            //       visible: snapshot.hasData,
            //       child: const Text(
            //         'Loading',
            //         style: TextStyle(color: Colors.transparent, fontSize: 24),
            //       ),
            //     ),
            //   ],
            // );
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              // debugPrint(snapshot.toString());
              return const Text(
                'Loading data failed\ncheck your internet connection',
                style: TextStyle(color: Colors.red),
              );
            } else if (snapshot.hasData) {
              // debugPrint(snapshot.data!.devices.length.toString());
              return Padding(
                padding: const EdgeInsets.only(top: 10, right: 20, left: 40),
                child: Column(
                  children: [
                    InkWell(
                        onTap: () {},
                        child: DisplayImage(
                          imagePath:
                              'https://t4.ftcdn.net/jpg/04/43/35/27/360_F_443352708_Pcf1kZAK856AGaXe1Nz4H0IjrrbezhUq.jpg',
                          onPressed: () {},
                        )),
                    const SizedBox(
                      height: 10.0,
                    ),
                    buildUserInfoDisplay(
                        context,
                        '${snapshot.data!.first_name} ${snapshot.data!.last_name}',
                        'Name',
                        true,
                        EditName()),
                    buildUserInfoDisplay(
                        context, snapshot.data!.username, 'Email', false, null),
                    buildUserInfoDisplay(
                        context, snapshot.data!.nik, 'NIK', false, null),
                    buildUserInfoDisplay(context, snapshot.data!.address,
                        'Address', true, EditAddress()),
                    buildUserInfoDisplay(context, snapshot.data!.phone_no,
                        'Phone', true, EditPhone()),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                            child: ElevatedButton(
                          onPressed: () {
                            navigateSecondPage(context, ResetPassword());
                          },
                          child: const Text('reset password'),
                        )),
                      ],
                    )
                  ],
                ),
              );
            } else {
              return const Text('Empty data');
            }
          } else {
            return Text('State: ${snapshot.connectionState}');
          }
          // return Text(snapshot.hasData.toString());
        });
  }
}

Widget buildUserInfoDisplay(BuildContext context, String getValue, String title,
        bool canBeEdited, Widget? editpage) =>
    Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(
              height: 1,
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                height: 48,
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                  color: Colors.grey,
                  width: 1,
                ))),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Expanded(
                      child: Text(
                    getValue,
                    // overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    softWrap: true,
                    style: const TextStyle(fontSize: 11),
                  )),
                  canBeEdited
                      ? GestureDetector(
                          onTap: () {
                            navigateSecondPage(context, editpage);
                          },
                          child: const Icon(
                            Icons.edit,
                            color: Colors.grey,
                            size: 16.0,
                          ),
                        )
                      : const Icon(
                          Icons.lock,
                          color: Colors.grey,
                          size: 16,
                        )
                ]))
          ],
        ));

void navigateSecondPage(BuildContext context, editPage) {
  Route route = MaterialPageRoute(builder: (context) => editPage);
  Navigator.push(context, route).then(onGoBack);
}

FutureOr onGoBack(value) {}
