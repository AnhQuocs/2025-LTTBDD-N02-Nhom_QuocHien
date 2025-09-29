import 'package:flutter/cupertino.dart';

import '../../../l10n/app_localizations.dart';

class SegmentedControl extends StatefulWidget {
  const SegmentedControl({super.key});

  @override
  State<SegmentedControl> createState() => _SegmentedControlState();
}

class _SegmentedControlState extends State<SegmentedControl> {
  int groupValue = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CupertinoPageScaffold(
      backgroundColor: Color(0xFFF1FFF3),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10),
        child: CupertinoSlidingSegmentedControl<int>(
          backgroundColor: Color(0xFFDFF7E2),
          thumbColor: Color(0xFF00D09E),
          groupValue: groupValue,
          children: {
            0: buildSegment(l10n.daily),
            1: buildSegment(l10n.weekly),
            2: buildSegment(l10n.monthly),
          },
          onValueChanged: (groupValue) {
            setState(() => this.groupValue = groupValue!);
          },
        ),
      ),
    );
  }

  Widget buildSegment(String text) => Container(
    padding: const EdgeInsets.all(12),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16),
    ),
  );
}