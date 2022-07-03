import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HideCardsButton extends StatelessWidget {
  const HideCardsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 24,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Color(0xff3a0ca3),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 7,
              offset: Offset(0, 6),
            ),
          ]),
      child: Column(
        children: [
          Text(
            'Hide cards',
            style: GoogleFonts.lato(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
