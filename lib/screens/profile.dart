// ignore_for_file: empty_constructor_bodies

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/screens/home_page.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/widgets/display_image.dart';
import 'package:frontend/screens/edit_name.dart';
import 'package:frontend/screens/edit_address.dart';
import 'package:frontend/screens/edit_phone.dart';
import 'package:frontend/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String API_URL = 'http://10.147.17.205:8008/api/v1';

// ignore: must_be_immutable
class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // void navigateSecondPage(BuildContext context, Widget editForm) {}
  late Future<User> futureUser;
  User initUser() {
    return User(
        id: 'id',
        nik: 'nik',
        first_name: 'first_name',
        last_name: 'last_name',
        username: 'username',
        address: 'address',
        phone_no: 'phone_no',
        role: 'role',
        devices: []);
  }

  Future<User> fetchUser() async {
    const url = '$API_URL/users/me';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        ),
        body: FutureBuilder<User>(
            future: futureUser,
            // initialData: initUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Center(child: CircularProgressIndicator()),
                    Visibility(
                      visible: snapshot.hasData,
                      child: const Text(
                        'Loading',
                        style:
                            TextStyle(color: Colors.transparent, fontSize: 24),
                      ),
                    ),
                  ],
                );
              } else if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  // debugPrint(snapshot.toString());
                  return const Text(
                    'Loading data failed\ncheck your internet connection',
                    style: TextStyle(color: Colors.red),
                  );
                } else if (snapshot.hasData) {
                  // debugPrint(snapshot.data!.address);
                  return Padding(
                    padding:
                        const EdgeInsets.only(top: 10, right: 20, left: 40),
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
                        buildUserInfoDisplay(context, snapshot.data!.username,
                            'Email', false, null),
                        buildUserInfoDisplay(
                            context, snapshot.data!.nik, 'NIK', false, null),
                        buildUserInfoDisplay(context, snapshot.data!.address,
                            'Address', true, EditAddress()),
                        buildUserInfoDisplay(context, snapshot.data!.phone_no,
                            'Phone', true, EditPhone()),
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
            }));
  }
}

Widget buildUserInfoDisplay(BuildContext context, String getValue, String title,
        bool canBeEdited, Widget? editpage) =>
    Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
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
                    style: const TextStyle(fontSize: 11, height: 1.4),
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
                      : Icon(
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
