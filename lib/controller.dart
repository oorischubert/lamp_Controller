import 'dart:convert';
import 'package:http/http.dart' as http;

//TODO: IMPLEMENT ERROR DETECTION

class Controller {
  final String url = "https://espledoori.herokuapp.com/color?key=";

  Future<void> setState({required String value, required String key}) async {
    await http.post(Uri.parse(url + key),
        body: json.encode({
          "value": value
        })); //remove color key? server has changed to be more versatile.

    //final decoded = json.decode(response.body); //as Map<String, dynamic>;
    //return decoded;
  }

  Future<bool> getState({required String key}) async {
    final response = await http.get(Uri.parse(url + key));
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    if (decoded['value'] == "b'H'") {
      return true;
    } else {
      return false;
    }
  }
}
