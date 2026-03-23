import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'scan_screen.dart';
import 'display_screen.dart';
import '../widgets/sheet_card.dart'; // Add this import

final logger = Logger();

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Widget _buildTitle() {
    return RichText(
      textAlign: TextAlign.center, // Ensures the title is centered
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'Mu',
            style: TextStyle(
              fontFamily: 'CustomFont',
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          TextSpan(
            text: 'g',
            style: TextStyle(
              fontFamily: 'CustomFont',
              fontSize: 28,
              color: Colors.red,
            ),
          ),
          TextSpan(
            text: 'ician',
            style: TextStyle(
              fontFamily: 'CustomFont',
              fontSize: 28,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: _buildTitle(), // Use the RichText title
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/images/logo.png', // Correct path to your image
              height: 40, // Adjust as needed
              width: 40, // Adjust as needed
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      body: const HomeBody(),
    );
  }
}

class HomeBody extends StatefulWidget {
  const HomeBody({Key? key}) : super(key: key);

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  List<File> _imageFiles = [];
  List<Map<String, dynamic>> _metadata = [];

  @override
  void initState() {
    super.initState();
    _loadImagesAndMetadata();
  }

  Future<void> _loadImagesAndMetadata() async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDirectory = Directory('${directory.path}/images');
    final metadataFile = File('${directory.path}/metadata.json');

    if (await imageDirectory.exists()) {
      final files = imageDirectory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.png'))
          .toList();

      List<Map<String, dynamic>> metadata = [];
      if (await metadataFile.exists()) {
        final content = await metadataFile.readAsString();
        metadata = List<Map<String, dynamic>>.from(jsonDecode(content));
      }

      setState(() {
        _imageFiles = files;
        _metadata = metadata;
      });
    }
  }

  Future<void> _deleteImageAndMetadata(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final metadataFile = File('${directory.path}/metadata.json');

      // Delete the image
      if (await imageFile.exists()) {
        await imageFile.delete();
      }

      // Update metadata
      if (await metadataFile.exists()) {
        final content = await metadataFile.readAsString();
        List<Map<String, dynamic>> metadata = List<Map<String, dynamic>>.from(jsonDecode(content));

        metadata.removeWhere((item) => item['imagePath'] == imageFile.path);
        await metadataFile.writeAsString(jsonEncode(metadata));

        setState(() {
          _metadata = metadata;
          _imageFiles.remove(imageFile);
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image deleted successfully!')),
      );
    } catch (e) {
      debugPrint("Error deleting image or metadata: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting image or metadata: $e')),
      );
    }
  }

  Map<String, dynamic>? _getMetadataForImage(String imagePath) {
    try {
      return _metadata.firstWhere(
        (item) => item['imagePath'] == imagePath,
        orElse: () => {
          'imagePath': imagePath,
          'midiPath': imagePath.replaceFirst('.png', '.mid'),
          'xmlPath': imagePath.replaceFirst('.png', '.xml'),
          'keySignature': 'Unknown'
        },
      );
    } catch (e) {
      debugPrint("Error finding metadata: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Old Sheets",
            style: TextStyle(
              fontFamily: 'CustomFont',
              fontSize: 24,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _imageFiles.isEmpty
                ? const Center(
                    child: Text(
                      "No sheets available yet.",
                      style: TextStyle(
                        fontFamily: 'CustomFont',
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8, // Reduced spacing
                      mainAxisSpacing: 8, // Reduced spacing
                      childAspectRatio: 0.75, // Make images taller
                    ),
                    itemCount: _imageFiles.length,
                    itemBuilder: (context, index) {
                      final imageFile = _imageFiles[index];
                      final metadata = _getMetadataForImage(imageFile.path);
                      
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[700]!, width: 1),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DisplayScreen(
                                      imagePath: metadata!['imagePath'],
                                      midiPath: metadata['midiPath'],
                                      xmlPath: metadata['xmlPath'],
                                      keySignature: metadata['keySignature'],
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: Image.file(
                                  imageFile,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: Colors.grey[900],
                                      title: const Text(
                                        'Delete Sheet Music',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      content: const Text(
                                        'Are you sure you want to delete this sheet music?',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteImageAndMetadata(imageFile);
                                          },
                                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Center(
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.red, size: 40),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanScreen()),
                ).then((_) => _loadImagesAndMetadata());
              },
            ),
          ),
        ],
      ),
    );
  }
}
