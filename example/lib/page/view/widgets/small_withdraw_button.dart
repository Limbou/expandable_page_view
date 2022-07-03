import 'package:flutter/material.dart';

class SmallWithdrawButton extends StatelessWidget {
  const SmallWithdrawButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Color(0xff3a0ca3)),
      ),
      child: Icon(
        Icons.arrow_downward_rounded,
        color: Color(0xff3a0ca3),
        size: 26,
      ),
    );
  }
}
