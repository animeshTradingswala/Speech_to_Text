import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MainSpeechToText extends StatefulWidget {
  const MainSpeechToText({Key? key}) : super(key: key);

  @override
  _MainSpeechToTextState createState() => _MainSpeechToTextState();
}

class _MainSpeechToTextState extends State<MainSpeechToText> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press me';
  double _confidence = 1.0;

  final Map<String, HighlightedWord> _highlightWords = {
    'flutter': HighlightedWord(
        onTap: () => print('1'),
        textStyle: TextStyle(fontWeight: FontWeight.bold)),
    'animesh': HighlightedWord(
        onTap: () => print('2'),
        textStyle: TextStyle(fontWeight: FontWeight.bold)),
    'accuracy': HighlightedWord(
        onTap: () => print('3'),
        textStyle: TextStyle(fontWeight: FontWeight.bold)),
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accuracy ${(_confidence * 100.0).toStringAsFixed(1)}%'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
          animate: _isListening,
          glowColor: Colors.red.shade400,
          endRadius: 75.0,
          duration: const Duration(microseconds: 2000),
          repeatPauseDuration: const Duration(microseconds: 100),
          repeat: true,
          showTwoGlows: true,
          child: FloatingActionButton(
            onPressed: _listen,
            child: Icon(_isListening ? Icons.mic : Icons.mic_none),
          )),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 150),
          child: TextHighlight(
            text: _text,
            words: _highlightWords,
          ),
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus $val'),
        onError: (val) => print('onStatus $val'),
      );
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speech.listen(
            onResult: (val) => setState(
                  () {
                    _text = val.recognizedWords;
                    if (val.hasConfidenceRating && val.confidence > 0) {
                      _confidence = val.confidence;
                    }
                  },
                ));
      }
    } else {
      setState(() {
        _isListening = false;
      });
      _speech.stop();
    }
  }
}
