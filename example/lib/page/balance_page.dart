import 'package:example/page/view/available_balance_tile.dart';
import 'package:example/page/view/cards_tile.dart';
import 'package:example/page/view/contacts_tile.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';

import 'view/widgets/hide_cards_button.dart';

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
