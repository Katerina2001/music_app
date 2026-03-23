import 'package:flutter/material.dart';

class SheetCard extends StatelessWidget {
  final int index;

  const SheetCard({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.music_note,
              color: Colors.white,
              size: 50,
            ),
            Text(
              "Untitled\nscore $index",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'CustomFont',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
