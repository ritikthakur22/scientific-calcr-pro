import 'package:flutter/material.dart';

class ScientificKey extends StatelessWidget {
  final String mainLabel;
  final String? shiftLabel;
  final String? alphaLabel;
  final Color mainColor;
  final Color textColor;
  final VoidCallback onMainTap;
  final VoidCallback? onShiftTap;
  final VoidCallback? onAlphaTap;
  final bool isShiftActive;
  final bool isAlphaActive;

  const ScientificKey({
    super.key,
    required this.mainLabel,
    this.shiftLabel,
    this.alphaLabel,
    required this.mainColor,
    this.textColor = Colors.white,
    required this.onMainTap,
    this.onShiftTap,
    this.onAlphaTap,
    this.isShiftActive = false,
    this.isAlphaActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 3.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Top labels
            SizedBox(
              height: 14,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (shiftLabel != null)
                    Positioned(
                      left: 2,
                      bottom: 0,
                      child: Text(
                        shiftLabel!,
                        style: TextStyle(
                          fontSize: 10,
                          color: isShiftActive ? Colors.amber[700] : Colors.amber[600],
                          fontWeight: isShiftActive ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                    ),
                  if (alphaLabel != null)
                    Positioned(
                      right: 2,
                      bottom: 0,
                      child: Text(
                        alphaLabel!,
                        style: TextStyle(
                          fontSize: 10,
                          color: isAlphaActive ? Colors.red[400] : Colors.red[300],
                          fontWeight: isAlphaActive ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            // Main button
            Expanded(
              child: Material(
                color: mainColor,
                borderRadius: BorderRadius.circular(6),
                elevation: 2,
                shadowColor: Colors.black45,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    if (isShiftActive && onShiftTap != null) {
                      onShiftTap!();
                    } else if (isAlphaActive && onAlphaTap != null) {
                      onAlphaTap!();
                    } else {
                      onMainTap();
                    }
                  },
                  child: Center(
                    child: Text(
                      mainLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
