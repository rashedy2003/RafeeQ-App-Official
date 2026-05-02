import 'package:flutter/material.dart';
import '../../../../core/theming/theme.dart';

class HomeEmptyState extends StatelessWidget {
  final String message;
  const HomeEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // تم التعديل ليرجع Column (RenderBox) بدلاً من Sliver
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 40),
        Opacity(
          opacity: 0.3,
          child: Icon(Icons.map_outlined, size: 70, color: Colors.grey[400]),
        ),
        const SizedBox(height: 10),
        Text(
          message,
          style: TextStyles.font12YellowSemiBold,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}