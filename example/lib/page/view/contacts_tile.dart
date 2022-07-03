import 'package:example/page/page.dart';
import 'package:flutter/material.dart';

const List<String> _names = [
  'Mark',
  'Lisa',
  'Adam',
  'George',
  'John',
  'Sam',
];

class ContactsTile extends StatelessWidget {
  const ContactsTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InfoTile(
      title: 'Your contacts',
      body: ListView.separated(
        shrinkWrap: true,
        itemCount: 6,
        padding: EdgeInsets.zero,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          return ContactTile(name: _names[index]);
        },
      ),
      supplementaryView: AddContactButton(),
    );
  }
}
