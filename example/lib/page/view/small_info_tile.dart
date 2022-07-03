import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SmallInfoTile extends StatelessWidget {
  const SmallInfoTile({
    required this.icon,
    required this.text,
    Key? key,
  }) : super(key: key);

  final Widget icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xff4361ee),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 7,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
