import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getToken() async {
  // ignore: no_leading_underscores_for_local_identifiers
  SharedPreferences _pref = await SharedPreferences.getInstance();
  return _pref.getString('token');
}
