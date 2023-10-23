import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutterfire_ui/auth.dart';
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
  final String? jsonKey = dotenv.env['JSONKEY'];
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

    // google sheets api requirements
    final credentials = ServiceAccountCredentials.fromJson(jsonKey);
    final client = await clientViaServiceAccount(
        credentials, [sheets.SheetsApi.spreadsheetsReadonlyScope]);
    final sheetsApi = sheets.SheetsApi(client);
    const sheet = '1OoT6ET5_zLoKslwpEWLDATWXs5DbGgC4zGf62EjHm9M';
    const range = 'Form Responses 2023!B:D';
    // list variable to handle null exceptions error
    List<List<Object?>?>? responseValues;
    // list to hold returned and filtered students
    final List<String> studentList = [];

    // Google Sheets Api call
    try {
      final response = await sheetsApi.spreadsheets.values.get(sheet, range);
      print('got that response ');
      responseValues = response.values;

      if (responseValues != null && responseValues.isNotEmpty) {
        // successfully returned array contains objects with {FirstName, LastName, YouthLeader}
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
        if (studentList.isEmpty) {
          displayError(
              "0 form submissions found. Double check leader name entry to be sure this is correct!");
        }
      } else {
        print('No data found in the specified range.');
        displayError(
            "0 form submissions found. Double check leader name entry to be sure this is correct!");
      }
    } catch (e) {
      print('error: $e');
      displayError(
          'Ope, something went wrong on our end. Try again, or reach out if this continues!');
    }

    studentList.sort();
    print(studentList);
    toggleLoading();
    setStudents(studentList);
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text('Code Verification')),
  //     body: Center(
  //       child: Container(
  //         width: double
  //             .infinity, // Expand the container to the maximum available width
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: <Widget>[
  //             Container(
  //               constraints: const BoxConstraints(
  //                   maxWidth: 800), // Set a maximum width for the Card
  //               child: Card(
  //                 margin: const EdgeInsets.symmetric(horizontal: 20.0),
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(20.0),
  //                   child: Column(
  //                     children: <Widget>[
  //                       const Text(
  //                           'Enter youth leader name (as would appear in form) to check students who have filled out the form',
  //                           style: TextStyle(
  //                               fontSize: 16, fontWeight: FontWeight.w400)),
  //                       TextFormField(
  //                         controller: searchController,
  //                         decoration: const InputDecoration(
  //                             hintText: 'Youth Leader Name',
  //                             helperText: 'ex: Thurgood Pastorname'),
  //                       ),
  //                       Visibility(
  //                         visible: error,
  //                         child: Text(errorMessage,
  //                             style: const TextStyle(
  //                                 color: Color.fromARGB(255, 114, 82, 255))),
  //                       ),
  //                       ElevatedButton(
  //                         onPressed: () {
  //                           if (searchController.text.length > 1) {
  //                             String name = searchController.text;
  //                             print('Search submitted with $name');
  //                             getGoogleSheetData(searchController.text);
  //                           } else {
  //                             print('Nope');
  //                             displayError(
  //                                 'Something is wrong with your input, try again');
  //                           }
  //                         },
  //                         child: const Text('Submit'),
  //                       ),
  //                       Visibility(
  //                         visible: loading,
  //                         child: const LoadingIndicator(
  //                           size: 20.0,
  //                           borderWidth: 2.0,
  //                           color: Color.fromARGB(255, 114, 82, 255),
  //                         ),
  //                       ),
  //                       Visibility(
  //                         visible: studentsToShow.isNotEmpty,
  //                         child: SingleChildScrollView(
  //                           child: Column(
  //                             children: studentsToShow.map((String student) {
  //                               return ListTile(title: Text(student));
  //                             }).toList(),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(iconTheme: IconThemeData()),
      body: Center(
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                          'Enter youth leader name (as would appear in form) to check students who have filled out the form',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextFormField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            hintText: 'Youth Leader Name',
                            helperText: 'ex: Thurgood Pastorname',
                          ),
                        ),
                        Visibility(
                          visible: error,
                          child: Text(
                            errorMessage,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 114, 82, 255),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (searchController.text.length > 1) {
                              String name = searchController.text;
                              print('Search submitted with $name');
                              getGoogleSheetData(searchController.text);
                            } else {
                              print('Nope');
                              displayError(
                                  'Something is wrong with your input, try again');
                            }
                          },
                          child: const Text('Submit'),
                        ),
                        Visibility(
                          visible: loading,
                          child: const LoadingIndicator(
                            size: 20.0,
                            borderWidth: 2.0,
                            color: Color.fromARGB(255, 114, 82, 255),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: studentsToShow.isNotEmpty,
                child: Expanded(
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(8.0), // Adjust padding as needed
                      child: CustomScrollView(
                        slivers: <Widget>[
                          SliverAppBar(title: Text('Yay! You have ${studentsToShow.length} students with completed forms!'), pinned: true,),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                return ListTile(
                                    title: Text(studentsToShow[index]));
                              },
                              childCount: studentsToShow.length,
                            ),
                          ),
                        ],
                      ),
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
