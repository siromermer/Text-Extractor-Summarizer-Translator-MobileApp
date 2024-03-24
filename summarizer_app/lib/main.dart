// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/*
  !!!!!!!!!!!!!!!!    Important Warning   !!!!!!!!!!!!!!!!
  if you want to use this app with your phone you need to change 2 line ,  go to the line 54-60 and 296-299
  
  If you just want it to use it with your Computer you can just run server.py and main.dart

*/

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Summarizer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  String? _selectedModel;
  List<Map<String, String>> _summaries = [];
  String extracted_text = "text";

  final List<String> modelNames = [
    'xsum',
    'pegasus-daily-maily',
    'bart-daily-maily'
  ];

  //final String my_ip = "your_ip"; if you want to use this app with your phone paste your ip here , in this way you will server from your computer and your phone can communicate without problem

  Future<void> _pickImageAndSend() async {
    if (_selectedModel != null && _image != null) {
      final uri = Uri.parse(
          'http://127.0.0.1:50162/upload'); // if you want to use it this app from your computer  , this line works ,

      // final uri = Uri.parse('http://$my_ip:50162/upload');  --> for using this app with phone

      final request = http.MultipartRequest('POST', uri);
      request.fields['model'] = _selectedModel!;
      request.files
          .add(await http.MultipartFile.fromPath('image', _image!.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final parsedResponse = jsonDecode(responseBody);

        setState(() {
          _summaries
              .add({'model': _selectedModel!, 'text': parsedResponse['text']});
          extracted_text = parsedResponse["paragraph"];
        });
      } else {
        print('Failed to upload image. Error: ${response.reasonPhrase}');
      }
    } else {
      print('Please select both an image and a model.');
    }
  }

  void _resetAll() {
    setState(() {
      _image = null;
      _selectedModel = null;
      _summaries.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove gradient from scaffold's background
      backgroundColor: Color.fromARGB(255, 64, 255, 160),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 64, 156, 255), // Top color
              Color.fromARGB(255, 64, 255,
                  160), // Bottom color // Change bottom color to transparent
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 20),
                  if (_image != null)
                    Image.file(
                      _image!,
                      width: 300,
                      height: 300,
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 20, 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 30),
                            child: const Text(
                                'Press button in the right below \n          for picking image'),
                          ),
                          SvgPicture.asset(
                            'assets/monkey.svg',
                            width: 200,
                            height: 200,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: const Text(
                            'Choose Summarizer Model',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(135, 168, 235, 97),
                            borderRadius: BorderRadius.circular(
                                15), // Adjust the radius as needed
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                15), // Match the radius with the container
                            child: DropdownButton<String>(
                              value: _selectedModel,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedModel = newValue;
                                });
                                _pickImageAndSend();
                              },
                              items: modelNames.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Padding(
                                    // Add padding around the text
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical:
                                            8), // Adjust padding as needed
                                    child: Text(value),
                                  ),
                                );
                              }).toList(),
                              hint: Padding(
                                // Add padding for the hint text as well
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8), // Adjust padding as needed
                                child: const Text('  Summary'),
                              ),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Color.fromARGB(255, 241, 4, 202),
                              ),
                              elevation: 4,
                              underline: Container(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  for (var summary in _summaries) ...[
                    Container(
                      //color: Color.fromARGB(255, 13, 171, 228),
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Text(
                        ' Summary (${summary['model']})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 50),
                      child: Container(
                        child: Text(
                          summary['text']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (_summaries.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AdditionalPage(extractedText: extracted_text),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 199, 242, 114),
                        ),
                        child: Text(
                          'Extract Text',
                          style: TextStyle(
                            color: Color.fromARGB(255, 70, 45, 25),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        width: 30,
        height: 30,
        child: FloatingActionButton(
          onPressed: () async {
            final picker = ImagePicker();
            final pickedImage =
                await picker.pickImage(source: ImageSource.gallery);
            if (pickedImage != null) {
              setState(() {
                _resetAll();
                _image = File(pickedImage.path);
              });
            }
          },
          tooltip: 'Pick Image',
          child: const Icon(Icons.image),
        ),
      ),
    );
  }
}

Future<String?> sendLanguageSelection(String language) async {
  //final String myIp = "your_ip"; if you want to use this app with your phone paste your ip here , in this way you will server from your computer and your phone can communicate without problem
  try {
    var response = await http.post(
      // Uri.parse('http://$myIp:50162/select_language'), --> for using this app with phone

      Uri.parse(
          'http://127.0.0.1:50162/select_language'), // if you want to use it this app from your computer  , this line works ,
      body: {'language': language},
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['translated_text'];
    } else {
      print('Failed to select language: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error selecting language: $e');
    return null;
  }
}

class AdditionalPage extends StatefulWidget {
  final String extractedText;

  const AdditionalPage({Key? key, required this.extractedText})
      : super(key: key);

  @override
  _AdditionalPageState createState() => _AdditionalPageState();
}

class _AdditionalPageState extends State<AdditionalPage> {
  String selectedLanguage = 'English';
  late String translatedText = '';

  @override
  void initState() {
    super.initState();

    translateText(selectedLanguage);
  }

  Future<void> translateText(String language) async {
    String? translated = await sendLanguageSelection(language);
    if (translated != null) {
      setState(() {
        translatedText = translated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 64, 255, 160),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: AppBar(
          title: const Text('Extracted Text'),
          backgroundColor: Color.fromARGB(255, 93, 138, 190),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 64, 156, 255),
              Color.fromARGB(255, 64, 255, 160),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  DropdownButton<String>(
                    value: selectedLanguage,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedLanguage = newValue;
                          translateText(selectedLanguage);
                        });
                      }
                    },
                    items: <String>[
                      'English',
                      'Spanish',
                      'French',
                      'Turkish',
                      'German',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    translatedText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Clipboard.setData(ClipboardData(text: translatedText));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Text copied to clipboard'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        tooltip: 'Copy Text',
        child: const Icon(Icons.content_copy),
        backgroundColor: Colors.orange,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
