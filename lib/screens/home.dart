import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:linguana/constants/jsondata.dart';
import 'package:linguana/screens/speech_to_text.dart';
import 'package:translator/translator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterTts flutterTts = FlutterTts();
  TextEditingController inputController = TextEditingController();
  final outputController = TextEditingController(text: "Result...");
  final translator = GoogleTranslator();

  String inputText = "";
  String inputLanguage = "en";
  String outputLanguage = "fr";
  String tempLanguage = "";
  bool isTranslating = false;
  List<Language> languages = [];

  List<Language> parseLanguages(String jsonData) {
    final List<dynamic> decodedJson = jsonDecode(jsonData);
    return decodedJson.map((json) => Language.fromJson(json)).toList();
  }

  Future<void> translateText() async {
    setState(() {
      isTranslating = true;
    });
    final translated = await translator.translate(inputController.text,
        from: inputLanguage, to: outputLanguage);
    setState(() {
      outputController.text = translated.text;
      isTranslating = false;
    });
  }

  void swapInputOutput() {
    setState(() {
      tempLanguage = inputLanguage;
      inputLanguage = outputLanguage;
      outputLanguage = tempLanguage;
    });
  }

  @override
  void initState() {
    super.initState();
    languages = parseLanguages(jsonData);
  }

  @override
  void dispose() {
    outputController.dispose();
    super.dispose();
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage(outputLanguage);
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    fit: BoxFit.contain,
                    height: 100,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Linguana",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("From"),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              dropdownColor: Colors.green,
                              value: inputLanguage,
                              onChanged: (newVal) {
                                setState(() {
                                  inputLanguage =
                                      newVal!; // Update the selected language
                                  if (inputController.text != "") {
                                    translateText(); // Call translation if input is not empty
                                  }
                                });
                              },
                              items: languages.map<DropdownMenuItem<String>>(
                                  (Language language) {
                                return DropdownMenuItem<String>(
                                  value: language
                                      .code, // Use the language code as the value
                                  child: Text(
                                    language.name,
                                    style: const TextStyle(color: Colors.white),
                                  ), // Display the language name
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 60,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                                onPressed: () {
                                  swapInputOutput();
                                },
                                icon: const Icon(
                                  Icons.swap_horiz,
                                  size: 35,
                                )),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("To"),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: outputLanguage,
                              dropdownColor: Colors.green,
                              onChanged: (newVal) {
                                setState(() {
                                  outputLanguage =
                                      newVal!; // Update the selected language
                                  if (inputController.text != "") {
                                    translateText(); // Call translation if input is not empty
                                  }
                                });
                              },
                              items: languages.map<DropdownMenuItem<String>>(
                                  (Language language) {
                                return DropdownMenuItem<String>(
                                  value: language
                                      .code, // Use the language code as the value
                                  child: Text(
                                    language.name,
                                    style: const TextStyle(color: Colors.white),
                                  ), // Display the language name
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: TextField(
                            controller: inputController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              hintText: "Enter a text to translate",
                            ),
                            onChanged: (value) {
                              setState(() {
                                inputText = value;
                              });
                              if (inputText != "") {
                                translateText();
                              }
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final result = await Navigator.of(context)
                              .push(MaterialPageRoute(
                                  fullscreenDialog: true,
                                  builder: (context) => SpeechToTextPage(
                                        localeID: inputLanguage,
                                      )));

                          if (result != "") {
                            setState(() {
                              inputController.text = result;
                            });
                            translateText();
                          }
                        },
                        icon: const Icon(
                          CupertinoIcons.mic_circle_fill,
                          size: 40,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: TextField(
                            enabled: false,
                            controller: outputController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              hintText: "Results",
                            ),
                            onChanged: (value) {
                              setState(() {
                                inputText = value;
                              });
                            },
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: inputController.text == ""
                              ? null
                              : () {
                                  speak(outputController.text);
                                },
                          icon: Icon(
                            CupertinoIcons.speaker_3_fill,
                            size: 40,
                            color: inputController.text == ""
                                ? null
                                : Colors.green,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Language {
  final String name;
  final String code;

  Language({required this.name, required this.code});

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      name: json['name'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
    };
  }
}
