import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DepositButton extends StatelessWidget {
  const DepositButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(Icons.arrow_downward_rounded),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Color(0xff3a0ca3)),
      ),
      label: Text(
        'Deposit',
        style: GoogleFonts.lato(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
