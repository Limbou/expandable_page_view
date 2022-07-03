import 'package:example/view/view.dart';
import 'package:example/widgets/widgets.dart';
import 'package:flutter/material.dart';

const List<String> _names = [
  'Mastercard',
  'Visa',
  'American Express',
];

const List<Color> _colors = [
  Colors.orange,
  Colors.lightBlue,
  Colors.yellow,
];

class CardsTile extends StatelessWidget {
  const CardsTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InfoTile(
      title: 'Your cards',
      body: ListView.separated(
        shrinkWrap: true,
        itemCount: 3,
        padding: EdgeInsets.zero,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          return CardTile(
            name: _names[index],
            color: _colors[index],
          );
        },
      ),
      supplementaryView: AddContactButton(),
    );
  }
}
