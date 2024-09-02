import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minimal_notes_app/models/note_database.dart';
import 'package:minimal_notes_app/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'pages/notes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NoteDatabase()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChannels.lifecycle.setMessageHandler((msg) {
      if (msg == AppLifecycleState.detached.toString()) {}
      return Future.value(null);
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotesPage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
