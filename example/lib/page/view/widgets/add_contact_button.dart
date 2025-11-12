import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddContactButton extends StatelessWidget {
  const AddContactButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(
        Icons.add,
        color: Color(0xff3a0ca3),
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
      ),
      label: Text(
        'Add Contact',
        style: GoogleFonts.lato(
          color: Color(0xff3a0ca3),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
