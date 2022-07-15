import 'dart:async';
import 'dart:convert';
import 'package:frontend/screens/profile.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/custom_card.dart';
import 'dart:math';
import 'package:frontend/models/data.dart';
import 'package:frontend/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/login.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:frontend/utils/config.dart';

final fortmatCurrency = NumberFormat.simpleCurrency(locale: 'id-ID');

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Data> futureData;
  Future<Data> fetchData() async {
    Data? data;
    var response = await http.get(
        Uri.parse('${MonitaxConfig.API_BASE_URL}/invoices/analytics'),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'Access-Control_Allow_Origin': '*',
        });
    if (response.statusCode == 200) {
      data = Data.fromJson(jsonDecode(response.body));
    }
    // var rng = Random();
    // double sales = rng.nextInt(999) * 1000;
    // int trx = rng.nextInt(100);
    // double tax = sales * 11 / 100;
    // return Data.fromJson({'sales': sales, 'trx': trx, 'tax': tax});
    return data!;
  }

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            futureData = fetchData();
          });
        },
        child: const Icon(Icons.refresh_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      appBar: AppBar(
        title: const Text('Monitax'),
        actions: <Widget>[
          IconButton(
              onPressed: () async {
                SharedPreferences pref = await SharedPreferences.getInstance();
                String? strUser = pref.getString('user');

                // Map<String, dynamic> profile = jsonDecode(strUser!);
                // debugPrint(profile['id']);
                // ignore: use_build_context_synchronously
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => Profile(),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.person)),
          IconButton(
              onPressed: () async {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const Login(),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout)),
        ],
      ),
      body: FutureBuilder<Data>(
          future: futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ShimmerCard(context);
              // return Column(
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     const Center(
              //         child: CircularProgressIndicator(
              //       backgroundColor: Colors.transparent,
              //     )),
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
                showTopSnackBar(context,
                    const CustomSnackBar.error(message: 'Loading data failed'));
                return ShimmerCard(
                    context); //MonitaxWidget(Data(sales: 0.0, trx: 0, tax: 0.0));
                // return const Text(
                //   'Loading data failed\ncheck your internet connection',
                //   style: TextStyle(color: Colors.red),
                // );
              } else if (snapshot.hasData) {
                return MonitaxWidget(snapshot.data);
              } else {
                return const Text('Empty data');
              }
            } else {
              return Text('State: ${snapshot.connectionState}');
            }
          }),
    );
  }
}

// ignore: non_constant_identifier_names
Widget ShimmerCard(BuildContext context) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade500,
    highlightColor: Colors.white,
    child: GridView.count(
      padding: const EdgeInsets.all(4),
      crossAxisCount: 2,
      children: const <Widget>[Card(), Card(), Card(), Card()],
    ),
  );
}

class MonitaxWidget extends StatelessWidget {
  final Data? data;
  const MonitaxWidget(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(4.0),
      crossAxisCount: 2,
      children: [
        GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (context) => const AlertDialog(
                      title: Text('Monitax'),
                      content: Text('Not implemented yet'),
                    ));
          },
          child: CustomCard(
              title: 'Pendapatan hari ini ',
              content: fortmatCurrency.format(data!.sales),
              image: 'assets/images/earn.png',
              color: Colors.blue),
        ),
        CustomCard(
          title: 'Transaksi hari ini ',
          content: data!.trx.toString(),
          image: 'assets/images/trx.png',
          color: Colors.greenAccent,
        ),
        CustomCard(
            title: 'Pajak pendapatan ',
            content: fortmatCurrency.format(data!.tax),
            image: 'assets/images/tax.png',
            color: Colors.purpleAccent),
        CustomCard(
            title: 'Notifikasi ',
            content: "test",
            image: 'assets/images/notification.png',
            color: Colors.amberAccent),
      ],
    );
  }
}
