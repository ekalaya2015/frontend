import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/utils/util.dart';
import 'package:frontend/screens/home_page.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:frontend/utils/config.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

var txtUsername = TextEditingController();
var txtPassword = TextEditingController();
final _formKey = GlobalKey<FormState>();

class _LoginState extends State<Login> {
  // ignore: non_constant_identifier_names
  bool isLoading = false;
  bool isHidden = false;
  double getSmallDiameter(BuildContext context) =>
      MediaQuery.of(context).size.width * 2 / 3;
  double getBiglDiameter(BuildContext context) =>
      MediaQuery.of(context).size.width * 7 / 8;

  Future<String?>? getProfile() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    Future<String?> token = getToken();
    token.then((value) async {
      const url = '${MonitaxConfig.API_BASE_URL}/users/me';
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Access-Control_Allow_Origin': '*',
        'Authorization': 'Bearer $value'
      }).timeout(const Duration(seconds: 10));
      // debugPrint(jsonDecode(response.body).toString());
      pref.setString('user', response.body);
      return jsonDecode(response.body).toString();
    }).onError((error, stackTrace) {
      return error.toString();
    });
    // return null;
  }

  void _validateInputs() {
    if (_formKey.currentState!.validate()) {
      //If all data are correct then save data to out variables
      _formKey.currentState!.save();
      doLogin(txtUsername.text, txtPassword.text);
    }
  }

  doLogin(username, password) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }
    SharedPreferences _pref = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    var url = '${MonitaxConfig.API_BASE_URL}/auth/access-token';
    Map<String, dynamic> body = {'username': username, 'password': password};
    // showLoaderDialog(context);
    try {
      final response = await http
          .post(Uri.parse(url),
              headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Accept': 'application/json',
                'Access-Control_Allow_Origin': '*'
              },
              body: body)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        Map<String, dynamic> payload = jsonDecode(response.body);
        final token = payload['access_token'].toString();
        _pref.setString('token', token);
        getProfile()!.then((value) {
          // _pref.setString('user', value.toString());
        }).onError((error, stackTrace) {
          debugPrintStack(stackTrace: stackTrace);
        });
        setState(() {
          isLoading = false;
        });
        // ignore: use_build_context_synchronously
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => HomePage(),
          ),
          (route) => false,
        );
      } else {
        setState(() {
          isLoading = false;
        });
        // ignore: use_build_context_synchronously
        showTopSnackBar(
            context, const CustomSnackBar.error(message: 'Login failed'));
      }
    } on TimeoutException catch (e) {
      // ignore: use_build_context_synchronously
      debugPrint(e.message);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isHidden = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: Colors.amber[100],
        body: Stack(
          children: <Widget>[
            Positioned(
              right: -getSmallDiameter(context) / 3,
              top: -getSmallDiameter(context) / 3,
              child: Container(
                width: getSmallDiameter(context),
                height: getSmallDiameter(context),
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 218, 131, 18),
                          Color.fromARGB(255, 241, 197, 156)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)),
              ),
            ),
            Positioned(
              left: -getBiglDiameter(context) / 4,
              top: -getBiglDiameter(context) / 4,
              child: Container(
                width: getBiglDiameter(context),
                height: getBiglDiameter(context),
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 252, 124, 40),
                          Color.fromARGB(255, 250, 190, 141)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)),
                child: Padding(
                  padding: const EdgeInsets.only(left: 60, top: 60),
                  child: Center(
                    child: Text("Monitax",
                        style: GoogleFonts.abel(
                            color: Colors.white,
                            fontSize: 48.0,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
            Positioned(
              right: -getBiglDiameter(context) / 2,
              bottom: -getBiglDiameter(context) / 2,
              child: Container(
                width: getBiglDiameter(context),
                height: getBiglDiameter(context),
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xFFF3E9EE)),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ListView(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        //border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.fromLTRB(20, 300, 20, 10),
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 25),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty ||
                                  RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                          .hasMatch(value) ==
                                      false) {
                                return 'alamat email tidak valid atau kosong';
                              }
                              return null;
                            },
                            onSaved: (String? value) {
                              txtUsername.text = value!;
                            },
                            controller: txtUsername,
                            decoration: InputDecoration(
                                icon: const Icon(
                                  Icons.email_outlined,
                                  color: Color.fromARGB(255, 245, 3, 3),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade100)),
                                labelText: "Email",
                                enabledBorder: InputBorder.none,
                                labelStyle:
                                    const TextStyle(color: Colors.grey)),
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'password tidak boleh kosong';
                              }
                              return null;
                            },
                            controller: txtPassword,
                            obscureText: isHidden,
                            decoration: InputDecoration(
                                suffixIcon: InkWell(
                                    onTap: _togglepassword,
                                    child: (isHidden)
                                        ? const Icon(Icons.visibility)
                                        : const Icon(Icons.visibility_off)),
                                icon: const Icon(
                                  Icons.lock_open_rounded,
                                  color: Color.fromARGB(255, 245, 3, 3),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade100)),
                                labelText: "Password",
                                enabledBorder: InputBorder.none,
                                labelStyle:
                                    const TextStyle(color: Colors.grey)),
                          )
                        ],
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 20, 10),
                          child: const Text(
                            "FORGOT PASSWORD?",
                            style: TextStyle(
                                color: Color(0xFFFF4891), fontSize: 11),
                          ))),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(92, 67, 28, 243),
                                      Color.fromARGB(255, 208, 209, 233)
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter)),
                            child: Material(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                splashColor:
                                    const Color.fromARGB(232, 31, 247, 247),
                                onTap: () {
                                  // doLogin(txtUsername.text, txtPassword.text);
                                  _validateInputs();
                                },
                                child: Center(
                                  child: (isLoading)
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ))
                                      : const Text(
                                          "SIGN IN",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Text(
                        "DON'T HAVE AN ACCOUNT ? ",
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        " SIGN UP",
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFFF4891),
                            fontWeight: FontWeight.w700),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _togglepassword() {
    setState(() {
      isHidden = !isHidden;
    });
  }
}
