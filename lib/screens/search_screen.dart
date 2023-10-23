import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  String? jsonKey = dotenv.env['JSONKEY'];
  bool error = false;
  void displayError() {
    setState(() {
      error = true;
    });
  }

  Future<List<String>> getGoogleSheet(String leader) async {
    final credentials = ServiceAccountCredentials.fromJson(jsonKey);
    final client = await clientViaServiceAccount(
        credentials, [sheets.SheetsApi.spreadsheetsReadonlyScope]);
    final sheetsApi = sheets.SheetsApi(client);
    const sheet = '1OoT6ET5_zLoKslwpEWLDATWXs5DbGgC4zGf62EjHm9M';
    const range = 'Form Responses 2023!B:D';
    final List<String> studentList = [];
    List<List<Object?>?>? responseValues; // Declare a local variable

// Use the API to access your Google Sheet
    try {
      final response = await sheetsApi.spreadsheets.values.get(sheet, range);
      print('got that response ');
      responseValues =
          response.values; // Assign the property to the local variable

      if (responseValues != null) {
        for (var row in responseValues) {
          if (row != null && row.length >= 3) {
            final columnBValue = row[0];
            final columnCValue = row[1];
            final columnJValue = row[2];

            if (columnJValue == leader) {
              studentList.add('$columnCValue, $columnBValue');
            }
          }
        }
      } else {
        print('No data found in the specified range.');
      }
    } catch (e) {
      print('error: $e');
    }

    studentList.sort();
    print(studentList);
    return studentList;


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Code Verification')),
      body: Center(
        child: Container(
          width: double
              .infinity, // Expand the container to the maximum available width
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                constraints: const BoxConstraints(
                    maxWidth: 800), // Set a maximum width for the Card
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        const Text(
                            'Enter youth leader name (as would appear in form) to check students who have filled out the form',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400)),
                        TextFormField(
                          controller: searchController,
                          decoration: const InputDecoration(
                              hintText: 'Youth Leader Name',
                              helperText: 'ex: Thurgood Pastorname'),
                        ),
                        Visibility(
                          visible: error,
                          child: const Text(
                              'No form submissions found. (Check with parents or make sure you entered leader name correctly!)',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 114, 82, 255))),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (searchController.text.length > 1) {
                              String name = searchController.text;
                              print('Search submitted with $name');
                              getGoogleSheet(searchController.text);
                            } else {
                              print('Nope');
                              displayError();
                            }
                          },
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
