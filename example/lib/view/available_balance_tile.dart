import 'package:example/view/view.dart';
import 'package:example/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AvailableBalanceTile extends StatelessWidget {
  const AvailableBalanceTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InfoTile(
      title: 'Available balance',
      body: Text(
        '\$32,300 💵',
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w700,
        ),
      ),
      supplementaryView: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DepositButton(),
          WithdrawButton(),
        ],
      ),
    );
  }
}
