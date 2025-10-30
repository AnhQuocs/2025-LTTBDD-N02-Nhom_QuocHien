import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class LanguageScreen extends StatefulWidget {
  final void Function(Locale)? onLocaleChange;
  const LanguageScreen({super.key, this.onLocaleChange});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  Locale _selectedLocale = const Locale('en');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.language,
          style: const TextStyle(fontSize: 24),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  RadioListTile<Locale>(
                    value: const Locale('en'),
                    groupValue: _selectedLocale,
                    onChanged: (Locale? value) {
                      setState(() {
                        _selectedLocale = value!;
                      });
                    },
                    title: Text('${l10n.english} 🇬🇧'),
                    activeColor: Colors.blue,
                  ),
                  RadioListTile<Locale>(
                    value: const Locale('vi'),
                    groupValue: _selectedLocale,
                    onChanged: (Locale? value) {
                      setState(() {
                        _selectedLocale = value!;
                      });
                    },
                    title: Text('${l10n.vietnamese} 🇻🇳'),
                    activeColor: Colors.blue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.onLocaleChange?.call(_selectedLocale);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.apply,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}