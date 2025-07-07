import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchFieldWidget extends StatefulWidget {
  final String query;
  final ValueChanged<String> onChanged;
  final String hintText;
  final TextStyle? textStyle;
  final bool autofocus;

  const SearchFieldWidget({
    super.key,
    required this.query,
    required this.onChanged,
    required this.hintText,
    this.autofocus = false,
    this.textStyle,
  });

  @override
  State<SearchFieldWidget> createState() => _SearchFieldWidgetState();
}

class _SearchFieldWidgetState extends State<SearchFieldWidget> {
  late final TextEditingController _controller;
  bool _updatingText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
    _controller.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(covariant SearchFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_updatingText && widget.query != _controller.text) {
      _controller.text = widget.query;
      _controller.selection = TextSelection.collapsed(offset: widget.query.length);
    }
  }

  void _handleTextChanged() {
    if (_controller.text != widget.query) {
      _updatingText = true;
      widget.onChanged(_controller.text);
      _updatingText = false;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: _controller,
        style: widget.textStyle,
        autofocus: widget.autofocus,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          hintText: widget.hintText,
          prefixIcon: Container(
            width: 24,
            height: 24,
            // padding: const EdgeInsets.only(left: 6),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/search.svg',
              package: 'awesome_emoji_picker',
              colorFilter: ColorFilter.mode(
                Theme.of(context).inputDecorationTheme.prefixIconColor ?? Colors.grey,
                BlendMode.srcIn,
              ),
              width: 24,
              height: 24,
            ),
          ),
          suffixIcon: widget.query.isNotEmpty
              ? GestureDetector(
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/delete.svg',
                      package: 'awesome_emoji_picker',
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).inputDecorationTheme.suffixIconColor ?? Colors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  onTap: () {
                    _controller.clear();
                  },
                )
              : null,
          filled: true,
        ),
      ),
    );
  }
}
