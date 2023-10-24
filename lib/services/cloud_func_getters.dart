import 'dart:convert';
import 'package:http/http.dart' as http;

const endpointUrl =
    'https://us-central1-oasis-form-checker.cloudfunctions.net/';

Future<String> getCloudFunctionValue(String function, String value) async {
  final response = await http.get(Uri.parse(endpointUrl + function));
  print('this is the response: $response');
  final jsonResponse = json.decode(response.body);
  final returnValue = jsonResponse[value];
  return returnValue;
}
