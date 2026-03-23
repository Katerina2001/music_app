import 'package:flutter/material.dart';

class SheetCard extends StatelessWidget {
  final int index;

  SheetCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[300],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note,
              color: Colors.red,
              size: 40,
            ),
            Text(
              "Untitled\nscore $index",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'CustomFont',
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
