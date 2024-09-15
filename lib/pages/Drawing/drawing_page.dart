import 'dart:io';
import 'dart:ui' as ui; // Ensure this import is present
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;
  final double strokeWidth;
  final bool isEraser;

  DrawingPainter({
    required this.points,
    this.color = Colors.black,
    this.strokeWidth = 4.0,
    this.isEraser = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isEraser ? Colors.white : color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DrawingPage extends StatefulWidget {
  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  List<Offset?> points = [];
  List<List<Offset?>> history = [];
  List<List<Offset?>> redoHistory = [];
  Color _color = Colors.black;
  double _strokeWidth = 4.0;
  bool _isEraser = false;
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  void _addToHistory() {
    history.add(List.from(points));
    redoHistory.clear();
  }

  void _undo() {
    if (history.isNotEmpty) {
      redoHistory.add(List.from(points));
      setState(() {
        points = history.removeLast();
      });
    }
  }

  void _redo() {
    if (redoHistory.isNotEmpty) {
      _addToHistory();
      setState(() {
        points = redoHistory.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Draw Something'),
        actions: [
          IconButton(
            icon: Icon(Icons.color_lens),
            onPressed: () {
              // Show color picker
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Pick a color'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        onColorSelected: (color) {
                          setState(() {
                            _color = color;
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.undo),
            onPressed: _undo,
          ),
          IconButton(
            icon: Icon(Icons.redo),
            onPressed: _redo,
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              await _saveDrawing();
              Navigator.pop(
                  context); // This will pop the current screen off the stack
            },
          ),
          IconButton(
            icon: Icon(_isEraser ? Icons.brush : Icons.remove),
            onPressed: () {
              setState(() {
                _isEraser = !_isEraser;
              });
            },
          ),
        ],
      ),
      body: Center(
        child: RepaintBoundary(
          key: _repaintBoundaryKey,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                points.add(renderBox.globalToLocal(details.globalPosition));
              });
            },
            onPanEnd: (details) {
              setState(() {
                points.add(null);
              });
            },
            child: CustomPaint(
              painter: DrawingPainter(
                points: points,
                color: _color,
                strokeWidth: _strokeWidth,
                isEraser: _isEraser,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveDrawing() async {
    final boundary = _repaintBoundaryKey.currentContext!.findRenderObject()
        as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(filePath);
    await file.writeAsBytes(buffer);

    print('Drawing saved to $filePath');
  }
}

class ColorPicker extends StatelessWidget {
  final ValueChanged<Color> onColorSelected;

  ColorPicker({required this.onColorSelected});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
      ),
      itemCount: Colors.primaries.length,
      itemBuilder: (context, index) {
        final color = Colors.primaries[index];
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            color: color,
            margin: EdgeInsets.all(4),
          ),
        );
      },
    );
  }
}
