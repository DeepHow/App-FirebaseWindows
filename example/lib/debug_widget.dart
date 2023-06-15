import 'package:flutter/material.dart';

class DebugWidget extends StatefulWidget {
  const DebugWidget({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<DebugWidget> createState() => _DebugWidgetState();
}

class _DebugWidgetState extends State<DebugWidget> {
  final ScrollController _scrollController = ScrollController();

  void onChanged() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderSide: BorderSide(
        width: 2,
        color: Colors.grey,
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextField(
        controller: widget.controller,
        decoration: const InputDecoration(
          enabledBorder: border,
          focusedBorder: border,
        ),
        maxLines: 15,
        onChanged: (value) => _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent),
        readOnly: true,
        scrollController: _scrollController,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black,
        ),
      ),
    );
  }
}
