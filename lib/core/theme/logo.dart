import 'package:flutter/material.dart';

class NexuzeLogo extends StatelessWidget {
  const NexuzeLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/nexuze_logo.png',
      width: 180,
      fit: BoxFit.contain,
    );
  }
}