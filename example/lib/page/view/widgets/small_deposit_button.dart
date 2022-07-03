import 'package:flutter/material.dart';

class SmallDepositButton extends StatelessWidget {
  const SmallDepositButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xff3a0ca3),
      ),
      child: Icon(
        Icons.arrow_upward_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}
