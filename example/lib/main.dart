import 'package:emoji_picker_plus/emoji_picker_plus.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emoji Picker Demo',
      theme: ThemeData.light(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  bool _showPicker = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emoji Picker Demo')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.topLeft,
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                maxLines: null,
              ),
            ),
          ),
          if (_showPicker)
            SizedBox(
              height: 300,
              child: EmojiPicker(
                onEmojiSelected: (emoji) {
                  _controller.text += emoji.char;
                },
                onBackspacePressed: () => _controller.text = _controller.text.characters.skipLast(1).toString(),
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.emoji_emotions_outlined),
                onPressed: () => setState(() => _showPicker = !_showPicker),
              ),
              Expanded(
                child: TextField(controller: _controller),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
