import 'package:awesome_emoji_picker/awesome_emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const lightGrey = Color(0xFFF6F7F7);
    return MaterialApp(
      title: 'Emoji Picker Demo',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        hoverColor: lightGrey,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: lightGrey,
        textTheme: Theme.of(context).textTheme.copyWith(
              titleMedium: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'Inter',
              ),
            ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightGrey,
          hoverColor: lightGrey,
          focusColor: lightGrey,
          iconColor: lightGrey,
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Inter',
          ),
          contentPadding: EdgeInsets.zero,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
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
  bool _useFrenchCategories = false;

  // French translations of categories
  final Map<String, String> _frenchTranslations = {
    'Recents': 'Récents',
    'Smileys & People': 'Émoticônes et personnes',
    'Animals & Nature': 'Animaux et nature',
    'Food & Drink': 'Nourriture et boissons',
    'Activities': 'Activités',
    'Travel & Places': 'Voyages et lieux',
    'Objects': 'Objets',
    'Symbols': 'Symboles',
    'Flags': 'Drapeaux',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emoji Picker Demo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Use French'),
                Switch(
                  value: _useFrenchCategories,
                  onChanged: (value) {
                    setState(() {
                      _useFrenchCategories = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.topLeft,
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: GestureDetector(
                  onTap: _togglePicker,
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/smileys_emotion.svg',
                      package: 'awesome_emoji_picker',
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).inputDecorationTheme.prefixIconColor ?? Colors.grey,
                        BlendMode.srcIn,
                      ),
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
              ),
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }

  void _togglePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPicker(context),
    );
  }

  Widget _buildPicker(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.only(top: 20, bottom: keyboardHeight, left: 8, right: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        height: MediaQuery.sizeOf(context).height * 0.5 + keyboardHeight,
        child: AwesomeEmojiPicker(
          onEmojiSelected: (emoji) {
            final text = _controller.text;
            final selection = _controller.selection;
            String newText = text;
            if (selection.start == -1) {
              newText = text + emoji.char;
            } else {
              newText = text.replaceRange(
                selection.start,
                selection.end,
                emoji.char,
              );
            }
            _controller.text = newText;
            _controller.selection = TextSelection.collapsed(
              offset: selection.start + emoji.char.length,
            );
            Navigator.of(context).pop();
          },
          categoryTranslations: _useFrenchCategories ? _frenchTranslations : null,
          searchHintText: _useFrenchCategories ? 'Rechercher' : 'Search',
          searchResultsText: _useFrenchCategories ? 'Résultats de recherche' : 'Search Results',
          skinToneLabel: _useFrenchCategories ? 'Couleur de peau' : 'Skin Tone',
          categoryIconColor: Colors.grey,
          categoryIconSelectedColor: Colors.black,
          categoryBarPadding: const EdgeInsets.all(8),
          categoryBarHeight: 30,
          iconSize: 30,
          emojiSize: 40,
          cellSize: 50,
        ),
      ),
    );
  }
}
