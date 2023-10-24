import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:oasis_forms_checker/services/cloud_func_getters.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  List<String> studentsToShow = [];
  bool error = false;
  String errorMessage = '';
  bool loading = false;

  void displayError(String message) {
    setState(() {
      errorMessage = message;
    });
    setState(() {
      error = true;
    });
  }

  void clearError() {
    setState(() {
      error = false;
      errorMessage = '';
    });
  }

  void setStudents(newList) {
    setState(() {
      studentsToShow = newList;
    });
  }

  void clearStudents() {
    setState(() {
      studentsToShow = [];
    });
  }

  void toggleLoading() {
    setState(() {
      loading = !loading;
    });
  }

  Future<void> getGoogleSheetData(String leader) async {
    // reset state
    clearError();
    clearStudents();
    toggleLoading();

    // Firebase Functions for env variables
    final jsonKey = await getCloudFunctionValue('getJsonKeyE', 'jsonKey');
    final sheet = await getCloudFunctionValue('getGoogleSheetE', 'gSheet');
    final String range =
        await getCloudFunctionValue('getRangeRequestE', 'range');

    // google sheets api requirements
    final credentials = ServiceAccountCredentials.fromJson(jsonKey);
    final client = await clientViaServiceAccount(
        credentials, [sheets.SheetsApi.spreadsheetsReadonlyScope]);
    final sheetsApi = sheets.SheetsApi(client);

    List<List<Object?>?>? responseValues;
    // list to hold returned and filtered students
    final List<String> studentList = [];

    // Google Sheets Api call
    try {
      final response = await sheetsApi.spreadsheets.values.get(sheet, range);
      responseValues = response.values;

      if (responseValues != null && responseValues.isNotEmpty) {
        // successfully returned array contains objects with {FirstName, LastName, YouthLeader}
        for (var row in responseValues) {
          if (row != null && row.length >= 3) {
            final firstNameValue = row[0];
            final lastNameValue = row[1];
            final leaderNameValue = row[2];

            if (leaderNameValue.toString().toLowerCase() ==
                leader.toLowerCase()) {
              studentList.add('$lastNameValue, $firstNameValue');
            }
          }
        }
        if (studentList.isEmpty) {
          displayError(
              "0 form submissions found. Double check leader name entry to be sure this is correct!");
        }
      } else {
        displayError(
            "0 form submissions found. Double check leader name entry to be sure this is correct!");
      }
    } catch (e) {
      displayError(
          'Ope, something went wrong on our end. Try again, or reach out if this continues!');
    }

    studentList.sort();
    toggleLoading();
    setStudents(studentList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/oasisL.png', height: 75),
        centerTitle: true,
      ),
      body: Center(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        const Text(
                          'Enter youth leader name (as it appears in the form) to check students who have filled out the form',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextFormField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            hintText: 'Youth Leader Name',
                            helperText: 'e.g., Thurgood Pastorname',
                          ),
                        ),
                        Visibility(
                          visible: error,
                          child: Text(
                            errorMessage,
                            style: const TextStyle(
                              color: Color(0xFF7252FF),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (searchController.text.length > 1) {
                              String name = searchController.text;
                              getGoogleSheetData(name);
                            } else {
                              clearStudents();
                              displayError(
                                  'Something is wrong with your input, try again');
                            }
                          },
                          child: const Text('Submit'),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Visibility(
                          visible: loading,
                          child: const LoadingIndicator(
                            size: 20.0,
                            borderWidth: 2.0,
                            color: Color(0xFF7252FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (studentsToShow.isNotEmpty)
                ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxHeight: 800, maxWidth: 800),
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          const SizedBox(
                            height: 12,
                          ),
                          Text(
                            'Yay! You have ${studentsToShow.length} students with completed forms!',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Copy the list of studentsToShow to the clipboard
                              final textToCopy = studentsToShow.join('\n');
                              Clipboard.setData(
                                  ClipboardData(text: textToCopy));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('List copied to clipboard')),
                              );
                            },
                            child: const Text('Copy List'),
                          ), // Add a divider for separation
                          ListView.builder(
                            shrinkWrap: true,
                            physics:
                                const ClampingScrollPhysics(), // To disable scrolling in the list
                            itemCount: studentsToShow.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                title: Text(studentsToShow[index]),
                              );
                            },
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
