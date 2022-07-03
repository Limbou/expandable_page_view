import 'package:example/page/page.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';

class VerticalBalancePage extends StatelessWidget {
  const VerticalBalancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ExpandablePageView(
            alignment: Alignment.centerLeft,
            scrollDirection: Axis.vertical,
            children: [
              const SmallInfoTile(
                icon: Icon(
                  Icons.euro,
                  size: 36,
                  color: Colors.white,
                ),
                text: '54,00',
              ),
              const SmallInfoTile(
                icon: Icon(
                  Icons.currency_pound,
                  size: 36,
                  color: Colors.white,
                ),
                text: '4.457,00',
              ),
              const SmallInfoTile(
                icon: Icon(
                  Icons.currency_bitcoin,
                  size: 36,
                  color: Colors.white,
                ),
                text: '14,1230044',
              ),
            ],
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SmallDepositButton(),
                const SizedBox(height: 12),
                SmallWithdrawButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
