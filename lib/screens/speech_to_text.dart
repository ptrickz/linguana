// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextPage extends StatefulWidget {
  final String localeID;
  const SpeechToTextPage({
    super.key,
    required this.localeID,
  });

  @override
  State<SpeechToTextPage> createState() => _SpeechToTextPageState();
}

class _SpeechToTextPageState extends State<SpeechToTextPage>
    with TickerProviderStateMixin {
  Color color = Colors.green.shade200;
  bool isPressing = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  List<LocaleName> locales = [];

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();

    setState(() {});
  }

  void _startListening() async {
    locales = await _speechToText.locales();
    var selectedLocale = locales
        .where((e) => e.localeId.toLowerCase().contains(widget.localeID))
        .first
        .localeId;
    print(selectedLocale);

    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: selectedLocale,
    );
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse(); // Reverse the animation
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward(); // Restart the animation
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: color,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _speechToText.isListening ? _lastWords : '',
              style: const TextStyle(fontSize: 25),
            ),
            Text(
              isPressing ? "Listening..." : "Hold to speak",
              style: const TextStyle(fontSize: 25),
            ),
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: isPressing ? 240 : 80,
                height: isPressing ? 240 : 80,
                child: GestureDetector(
                  onLongPressStart: (details) {
                    HapticFeedback.heavyImpact();
                    _startListening();
                    print("Pressing");
                    setState(() {
                      isPressing = true;
                      _controller.forward();
                      color = Colors.blue.shade300;
                    });
                  },
                  onLongPressEnd: (details) {
                    HapticFeedback.heavyImpact();
                    _stopListening();
                    setState(() {
                      isPressing = false;
                      _controller.stop();
                      color = Colors.green.shade300;
                    });
                    Navigator.pop(context, _lastWords);
                    print("Canceled");
                  },
                  child: ScaleTransition(
                    scale: _animation,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: isPressing ? Colors.blue : Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedScale(
                        scale: isPressing ? 2.5 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: const Icon(
                          CupertinoIcons.mic_fill,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
