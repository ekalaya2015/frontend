import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/utils/util.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/screens/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

const String API_URL = 'http://10.147.17.205:8008/api/v1';

class ResetPassword extends StatefulWidget {
  ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formkey = GlobalKey<FormState>();
  final txtNewPassword = TextEditingController();
  final txtConfirmPassword = TextEditingController();
  late bool isLoading = false;
  bool isHidden = false;

  void _validateInputs() {
    if (_formkey.currentState!.validate()) {
      //If all data are correct then save data to out variables
      _formkey.currentState!.save();
      doUpdate();
    }
  }

  doUpdate() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
    }
    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString('token');
    var url = '$API_URL/users/me/reset-password';
    final body = jsonEncode({'password': txtNewPassword.text});
    final response = await http
        .post(Uri.parse(url),
            headers: {
              'accept': 'application/json',
              'content-type': 'application/json',
              'Access-Control_Allow_Origin': '*',
              'Authorization': 'Bearer $token'
            },
            body: body,
            encoding: Encoding.getByName('utf-8'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      showTopSnackBar(context,
          const CustomSnackBar.success(message: 'Reset password success'));
    } else {
      // ignore: use_build_context_synchronously
      showTopSnackBar(context,
          const CustomSnackBar.error(message: 'Reset password failed'));
    }
    setState(() {
      isLoading = false;
    });
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
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => Profile(),
              ),
              (route) => false,
            );
          },
          child: const Icon(Icons.arrow_back),
        ),
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Reset Password'),
        ),
        body: Form(
          key: _formkey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 40),
                      child: SizedBox(
                        height: 100,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextFormField(
                          obscureText: isHidden,
                          decoration: InputDecoration(
                            suffixIcon: InkWell(
                              onTap: __togglepassword,
                              child: (isHidden)
                                  ? const Icon(Icons.visibility_off)
                                  : const Icon(Icons.visibility),
                            ),
                            labelText: 'New password',
                          ),
                          controller: txtNewPassword,
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 40),
                      child: SizedBox(
                        height: 100,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextFormField(
                          controller: txtConfirmPassword,
                          obscureText: isHidden,
                          decoration: InputDecoration(
                              suffixIcon: InkWell(
                                onTap: __togglepassword,
                                child: (isHidden)
                                    ? const Icon(Icons.visibility_off)
                                    : const Icon(Icons.visibility),
                              ),
                              labelText: 'Confirm password'),
                          validator: (value) {
                            if (value != txtNewPassword.text) {
                              return 'Kedua password harus sama';
                            } else if (value!.isEmpty) {
                              return 'password tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: 32,
                          child: ElevatedButton(
                            child: (isLoading)
                                ? const SizedBox(
                                    width: 16,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ))
                                : const Text(
                                    'Reset',
                                    style: TextStyle(fontSize: 16),
                                  ),
                            onPressed: () {
                              _validateInputs();
                            },
                          ))),
                )
              ]),
        ));
  }

  void __togglepassword() {
    setState(() {
      isHidden = !isHidden;
    });
  }
}
