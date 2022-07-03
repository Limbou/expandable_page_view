import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactTile extends StatelessWidget {
  const ContactTile({
    required this.name,
    Key? key,
  }) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.account_circle_rounded,
          size: 48,
          color: Colors.white,
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
