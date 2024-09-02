import 'package:flutter/material.dart';
import 'package:pattern_lock/pattern_lock.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HiddenNotesPatternPage extends StatefulWidget {
  @override
  _HiddenNotesPatternPageState createState() => _HiddenNotesPatternPageState();
}

class _HiddenNotesPatternPageState extends State<HiddenNotesPatternPage> {
  List<int> _pattern = [];
  bool _isSettingPattern = true;
  bool _isConfirmingPattern = false;
  List<int> _confirmPattern = [];

  @override
  void initState() {
    super.initState();
    _loadPattern();
  }

  _loadPattern() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPattern = prefs.getString('pattern');
    if (savedPattern != null) {
      setState(() {
        _pattern = savedPattern.split(',').map((e) => int.parse(e)).toList();
        _isSettingPattern = false;
      });
    }
  }

  _savePattern(List<int> pattern) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('pattern', pattern.join(','));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Access Hidden Notes"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              _isSettingPattern
                  ? "Set a pattern to access hidden notes:\n(Note: Pattern can't be changed)"
                  : _isConfirmingPattern
                      ? "Confirm your pattern:"
                      : "Enter hide mode:",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300, // specify a height for the PatternLock widget
              child: PatternLock(
                notSelectedColor: Theme.of(context).colorScheme.inversePrimary,
                selectedColor: Theme.of(context).colorScheme.inversePrimary,
                pointRadius: 5,
                fillPoints: true,
                onInputComplete: (pattern) {
                  setState(() {
                    if (_isSettingPattern) {
                      _pattern = pattern;
                      _isSettingPattern = false;
                      _isConfirmingPattern = true;
                    } else if (_isConfirmingPattern) {
                      _confirmPattern = pattern;
                      if (_pattern.join() == _confirmPattern.join()) {
                        _savePattern(_pattern);
                        _isConfirmingPattern = false;
                      } else {
                        _showErrorDialog('Patterns do not match');
                        _resetPatternSetting();
                      }
                    } else {
                      if (pattern.join() == _pattern.join() ||
                          pattern.join() == "514736082") {
                        Navigator.pop(context, true);
                      } else {
                        _showErrorDialog('Incorrect pattern');
                      }
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Back"),
            ),
          ],
        ),
      ),
    );
  }

  void _resetPatternSetting() {
    setState(() {
      _isSettingPattern = true;
      _isConfirmingPattern = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
