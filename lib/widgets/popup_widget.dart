// =============================================================================
// POPUP WIDGET
// =============================================================================

import 'package:flutter/material.dart';

class PopupWidget extends StatelessWidget {
  final String title;
  final String message;
  final List<String> buttons;
  final Function(int) onButtonPressed;

  const PopupWidget({
    super.key,
    required this.title,
    required this.message,
    required this.buttons,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Overlay
        Positioned.fill(
          child: GestureDetector(
            onTap: () {}, // Block taps
            child: Container(color: const Color(0xCC000000)),
          ),
        ),
        // Popup panel
        Center(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF0C040), width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFFF0C040), fontSize: 26, fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                Text(message, style: const TextStyle(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(buttons.length, (i) {
                    return Padding(
                      padding: EdgeInsets.only(left: i > 0 ? 12.0 : 0),
                      child: ElevatedButton(
                        onPressed: () => onButtonPressed(i),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: i == 0 ? const Color(0xFF2C3E50) : const Color(0xFF27AE60),
                          minimumSize: const Size(100, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(buttons[i], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}