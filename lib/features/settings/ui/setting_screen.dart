import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/viewmodel/auth_viewmodel.dart';

class SettingScreen extends StatefulWidget {
  final void Function(Locale locale)? onLocaleChange;

  const SettingScreen({super.key, this.onLocaleChange});

  @override
  State<StatefulWidget> createState() => _SettingScreen();
}

class _SettingScreen extends State<SettingScreen> {

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
                "Setting Screen"
            ),

            const SizedBox(height: 16),

            // Language switch
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    widget.onLocaleChange?.call(const Locale('en'));
                  },
                  child: Text('🇺🇸 ${l10n.english}'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    widget.onLocaleChange?.call(const Locale('vi'));
                  },
                  child: Text('🇻🇳 ${l10n.vietnamese}'),
                ),
              ],
            ),

            // Logout button
            ElevatedButton(
              onPressed: () {
                final authViewModel = context.read<AuthViewModel>();
                authViewModel.signOut();
              },
              child: Text(l10n.logout),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onClick;

  const SettingItem({
    Key? key,
    required this.icon,
    required this.text,
    required this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}