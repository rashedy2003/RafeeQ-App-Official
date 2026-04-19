import 'package:flutter/material.dart';

class LazyLoadWrapper extends StatefulWidget {
  final Widget child;
  final bool isSelected;

  const LazyLoadWrapper({super.key, required this.child, required this.isSelected});

  @override
  State<LazyLoadWrapper> createState() => _LazyLoadWrapperState();
}

class _LazyLoadWrapperState extends State<LazyLoadWrapper> {
  bool _initialized = false;

  @override
  void didUpdateWidget(covariant LazyLoadWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // لو الصفحة تم اختيارها ولسا مابنتهش، ابنيها
    if (widget.isSelected && !_initialized) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // لو الصفحة هي اللي ظاهرة دلوقتي، اظهرها.. لو لا وهي لسا مابنتهش اظهر فراغ
    if (_initialized || widget.isSelected) {
      _initialized = true;
      return widget.child;
    }
    return const SizedBox.shrink(); // صفحة فاضية في الخلفية لحد ما نحتاجها
  }
}