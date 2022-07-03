import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WithdrawButton extends StatelessWidget {
  const WithdrawButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(
        Icons.arrow_upward_rounded,
        color: Color(0xff3a0ca3),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white),
      ),
      label: Text(
        'Withdraw',
        style: GoogleFonts.lato(
          color: Color(0xff3a0ca3),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
