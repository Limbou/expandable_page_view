import 'package:example/page/page.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';

class BalancePage extends StatelessWidget {
  const BalancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ExpandablePageView(
            children: [
              const AvailableBalanceTile(),
              const CardsTile(),
              const ContactsTile(),
            ],
          ),
          HideCardsButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
