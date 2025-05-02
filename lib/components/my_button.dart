import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  final Function()? onTap;
  final Widget child;

  const MyButton({
    super.key,
    required this.onTap,
    required this.child,
  });

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(25),
          margin: const EdgeInsets.symmetric(horizontal: 25),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.deepPurple.shade100 : Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered ? Colors.deepPurple.shade300 : Colors.deepPurple.shade100,
              width: 2,
            ),
          ),
          child: Center(
            child: DefaultTextStyle(
              style: TextStyle(
                color: _isHovered ? Colors.deepPurple.shade500 : Colors.deepPurple.shade300,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}