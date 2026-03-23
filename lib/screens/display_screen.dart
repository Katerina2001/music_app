import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'game_screen.dart';

class DisplayScreen extends StatefulWidget {
  final String imagePath; // Path to the image
  final String midiPath; // Local path to the MIDI file
  final String xmlPath; // Local path to the XML file
  final String keySignature; // Key signature of the music piece

  const DisplayScreen({
    Key? key,
    required this.imagePath,
    required this.midiPath,
    required this.xmlPath,
    required this.keySignature,
  }) : super(key: key);

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Map<String, dynamic>? _metadata;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadMetadata();

    // Add listener for audio completion
    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  Future<void> _loadMetadata() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final metadataFile = File('${directory.path}/metadata.json');

      if (await metadataFile.exists()) {
        final content = await metadataFile.readAsString();
        if (content.isNotEmpty) {
          final List<dynamic> allMetadata = jsonDecode(content);

          final currentMetadata = allMetadata.firstWhere(
            (item) => item['imagePath'] == widget.imagePath,
            orElse: () => null,
          );

          if (currentMetadata != null) {
            setState(() {
              _metadata = currentMetadata;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading metadata: $e");
    }
  }

  Future<void> _playAudio() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
      });
    } else {
      try {
        final file = File(widget.midiPath);
        if (await file.exists()) {
          await _audioPlayer.stop(); // Stop any previous playback
          await _audioPlayer.setSource(DeviceFileSource(file.path));
          await _audioPlayer.resume();
          setState(() {
            _isPlaying = true;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('MIDI file not found')),
          );
        }
      } catch (e) {
        debugPrint("Error playing audio: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error playing audio file')),
        );
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _showComingSoonMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming Soon!')),
    );
  }

  void _navigateToGameScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GameScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Sheet Music Display',
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
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey, width: 2),
              ),
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.red.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.music_note,
                    color: Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Key Signature: ',
                    style: const TextStyle(
                      fontFamily: 'CustomFont',
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    widget.keySignature,
                    style: const TextStyle(
                      fontFamily: 'CustomFont',
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _showComingSoonMessage,
                  icon: const Icon(
                    Icons.share,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                IconButton(
                  onPressed: _playAudio,
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
                IconButton(
                  onPressed: _navigateToGameScreen,
                  icon: const Icon(
                    Icons.sports_esports,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
