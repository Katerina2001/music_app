import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isAnswerCorrect = false;
  bool _isAnswered = false;
  late AudioPlayer _audioPlayer;
  late List<String> _currentOptions;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadQuestions();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final metadataFile = File('${directory.path}/metadata.json');

      if (await metadataFile.exists()) {
        final content = await metadataFile.readAsString();
        final List<dynamic> metadata = jsonDecode(content);
        setState(() {
          _questions = metadata.map((item) => item as Map<String, dynamic>).toList();
          _generateOptionsForCurrentQuestion();
        });
      }
    } catch (e) {
      debugPrint("Error loading questions: $e");
    }
  }

  Future<void> _playAudio(String midiPath) async {
    try {
      final file = File(midiPath);
      if (await file.exists()) {
        await _audioPlayer.play(DeviceFileSource(file.path));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('MIDI file does not exist locally.')),
        );
      }
    } catch (e) {
      debugPrint("Error playing audio: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: $e')),
      );
    }
  }

  void _generateOptionsForCurrentQuestion() {
    final correctAnswer = _questions[_currentQuestionIndex]['keySignature'];
    final Set<String> uniqueOptions = {correctAnswer}; // Use Set to ensure uniqueness
    
    final allOptions = [
      'C Major', 'G Major', 'D Major', 'A Major',
      'E Major', 'B Major', 'F# Major', 'C# Major',
      'F Major', 'Bb Major', 'Eb Major', 'Ab Major',
      'A Minor', 'E Minor', 'B Minor', 'F# Minor',
      'C# Minor', 'G# Minor', 'D Minor', 'G Minor'
    ];

    // Remove the correct answer from available options
    allOptions.remove(correctAnswer);
    allOptions.shuffle();

    // Add random options until we have 4 unique options
    for (String option in allOptions) {
      if (uniqueOptions.length < 4) {
        uniqueOptions.add(option);
      } else {
        break;
      }
    }

    setState(() {
      _currentOptions = uniqueOptions.toList()..shuffle();
    });
  }

  void _selectAnswer(String selectedKey) {
    setState(() {
      _isAnswered = true;
      _isAnswerCorrect = selectedKey == _questions[_currentQuestionIndex]['keySignature'];
    });

    Future.delayed(const Duration(seconds: 1), () {
      _audioPlayer.stop(); // Stop audio before proceeding
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _isAnswered = false;
          _generateOptionsForCurrentQuestion();
        });
      } else {
        // Show completion message and return to home screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Congratulations! You completed all songs!'),
            duration: Duration(seconds: 2),
          ),
        );
        
        // Wait for snackbar, stop audio, then navigate to home
        Future.delayed(const Duration(seconds: 2), () {
          _audioPlayer.stop();
          Navigator.of(context).popUntil((route) => route.isFirst);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Music Quiz',
            style: TextStyle(
              fontFamily: 'CustomFont',
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Music Quiz',
          style: TextStyle(
            fontFamily: 'CustomFont',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Speaker Icon Section
            Expanded(
              flex: 2,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: IconButton(
                    icon: const Icon(Icons.volume_up, color: Colors.red),
                    iconSize: 64,
                    onPressed: () => _playAudio(currentQuestion['midiPath']),
                  ),
                ),
              ),
            ),

            // Question Text
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'What is the key signature of this music piece?',
                style: const TextStyle(
                  fontFamily: 'CustomFont',
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Answer Grid
            Expanded(
              flex: 2,
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: _currentOptions.map((option) {
                  final isCorrect = option == currentQuestion['keySignature'];
                  return GestureDetector(
                    onTap: () {
                      if (!_isAnswered) {
                        _selectAnswer(option);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isAnswered
                            ? (isCorrect ? Colors.green : Colors.red)
                            : Colors.grey[800],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        option,
                        style: const TextStyle(
                          fontFamily: 'CustomFont',
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
