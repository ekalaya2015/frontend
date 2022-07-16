import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/utils/util.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/screens/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:frontend/utils/config.dart';

class EditAddress extends StatefulWidget {
  EditAddress({Key? key}) : super(key: key);

  @override
  State<EditAddress> createState() => _EditAddressState();
}

class _EditAddressState extends State<EditAddress> {
  final _formkey = GlobalKey<FormState>();
  final txtAddress = TextEditingController();
  late bool isLoading = false;

  doUpdate() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString('token');
    var url = '${MonitaxConfig.API_BASE_URL}/users/me/profile';
    final body = jsonEncode({'address': txtAddress.text});
    final response = await http
        .patch(Uri.parse(url),
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
      setState(() {
        isLoading = false;
      });
      // ignore: use_build_context_synchronously
      showTopSnackBar(
          context, CustomSnackBar.success(message: 'Update success'));
    } else {
      // ignore: use_build_context_synchronously
      showTopSnackBar(context, CustomSnackBar.error(message: 'Update failed'));
    }
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
          title: const Text('Edit Address'),
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
                        padding: const EdgeInsets.only(top: 40, left: 40),
                        child: SizedBox(
                          height: 100,
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: TextFormField(
                            minLines: 2,
                            maxLines: 3,
                            keyboardType: TextInputType.name,
                            decoration: const InputDecoration(
                                labelText: 'Address',
                                prefixIcon: Icon(Icons.mail)),
                            controller: txtAddress,
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
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
                                    'Update',
                                    style: TextStyle(fontSize: 16),
                                  ),
                            onPressed: () {
                              doUpdate();
                            },
                          ),
                        )),
                  )
                ])));
  }
}
