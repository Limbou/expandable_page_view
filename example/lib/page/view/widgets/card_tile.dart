import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CardTile extends StatelessWidget {
  const CardTile({
    required this.name,
    required this.color,
    Key? key,
  }) : super(key: key);

  final Color color;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.credit_card_rounded,
          size: 48,
          color: color,
        ),
        const SizedBox(width: 16),
        Text(
          name,
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
