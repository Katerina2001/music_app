# Mugician

This application allows converting **MusicXML** files to **MIDI** using Audiveris and a Flask-based server.

## Getting Started

The following instructions are taken from the server repo, please set the server up first for full functionality.
https://github.com/Katerina2001/xml_to_midi_server

### 1. Clone the Repository
```sh
git clone https://github.com/Katerina2001/xml_to_midi_app.git
cd xml_to_midi_app
```

### 2. Install **Flutter**
If you don't have Flutter installed, download it from the [official site](https://flutter.dev/docs/get-started/install) and follow the instructions.

Verify the installation with:
```sh
flutter doctor
```

### 3. Install Dependencies
```sh
flutter pub get
```

### 4. Set Up the Server
The server must be running for the application to work.

Follow the instructions in **server_README.txt** and ensure the server is running at:

🌍 **http://127.0.0.1:5000/**

### 5. Run the Application
To test on an emulator or physical device, run:
```sh
flutter run
```

## Application Features
✔️ Select a MusicXML file
✔️ Send it to the server
✔️ Receive and play the MIDI file
✔️ Display an error message if conversion fails

## Requirements
- **Flutter 3.0+**
- **Dart SDK**
- **Connection to the server**

## Notes
If you encounter issues, check `flutter doctor` and ensure the server is running.

## Additional Flutter Resources
A new Flutter project.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

