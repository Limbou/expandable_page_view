import 'package:example/view/small_info_tile.dart';
import 'package:flutter/material.dart';

class SmallBalanceTile extends StatelessWidget {
  const SmallBalanceTile({
    required this.icon,
    required this.value,
    Key? key,
  }) : super(key: key);

  final Icon icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SmallInfoTile(icon: icon, text: value);
  }
}
