import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'display_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _imageFile;
  bool _isProcessing = false;
  String? _localMidiPath;
  String? _localXmlPath;
  String? _keySignature;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final savedImagePath = await _saveImageToLocalDirectory(pickedFile.path);
        setState(() {
          _imageFile = File(savedImagePath);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _sendToServer() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final uri = Uri.parse('http://10.0.2.2:5000/process');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', _imageFile!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonData = jsonDecode(responseData);

        final midiUrl = jsonData['midi'];
        final xmlUrl = jsonData['xml'];

        final directory = await getApplicationDocumentsDirectory();
        _localMidiPath = '${directory.path}/output_${DateTime.now().millisecondsSinceEpoch}.mid';
        _localXmlPath = '${directory.path}/output_${DateTime.now().millisecondsSinceEpoch}.xml';

        await _downloadFile(midiUrl, _localMidiPath!);
        await _downloadFile(xmlUrl, _localXmlPath!);

        setState(() {
          _keySignature = jsonData['key_signature']['key'];
        });

        await _saveMetadata(
          _imageFile!.path,
          _localMidiPath!,
          _localXmlPath!,
          _keySignature ?? 'Unknown',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Processing completed successfully!')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisplayScreen(
              imagePath: _imageFile!.path,
              midiPath: _localMidiPath!,
              xmlPath: _localXmlPath!,
              keySignature: _keySignature ?? 'Unknown',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error connecting to server: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _downloadFile(String fileUrl, String savePath) async {
    final response = await http.get(Uri.parse(fileUrl));
    if (response.statusCode == 200) {
      final file = File(savePath);
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception('Failed to download file from $fileUrl');
    }
  }

  Future<String> _saveImageToLocalDirectory(String imagePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${directory.path}/images');

      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
      final savedImagePath = '${imageDir.path}/$fileName';

      final File imageFile = File(imagePath);
      await imageFile.copy(savedImagePath);

      return savedImagePath;
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }

  Future<void> _saveMetadata(String imagePath, String midiPath, String xmlPath, String keySignature) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final metadataFile = File('${directory.path}/metadata.json');

      if (!await metadataFile.exists()) {
        await metadataFile.create(recursive: true);
        await metadataFile.writeAsString('[]');
      }

      final metadata = {
        "imagePath": imagePath,
        "midiPath": midiPath,
        "xmlPath": xmlPath,
        "keySignature": keySignature,
      };

      final content = await metadataFile.readAsString();
      final existingData = content.isNotEmpty ? jsonDecode(content) as List : [];
      existingData.add(metadata);
      await metadataFile.writeAsString(jsonEncode(existingData));
    } catch (e) {
      debugPrint("Error saving metadata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Scan Music Sheet',
          style: TextStyle(fontFamily: 'CustomFont', fontSize: 24, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                  child: _imageFile == null
                      ? const Center(
                          child: Text(
                            'No Image Selected',
                            style: TextStyle(fontFamily: 'CustomFont', fontSize: 18, color: Colors.white70),
                          ),
                        )
                      : Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera, color: Colors.red, size: 40),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                    IconButton(
                      icon: const Icon(Icons.photo, color: Colors.red, size: 40),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                    IconButton(
                      icon: const Icon(Icons.music_note, color: Colors.red, size: 40),
                      onPressed: _sendToServer,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
