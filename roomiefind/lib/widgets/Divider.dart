import 'package:flutter/material.dart';

class DividerOr extends StatelessWidget {
  const DividerOr({super.key});
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text('o'),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}