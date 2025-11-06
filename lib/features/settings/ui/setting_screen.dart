import 'package:fin_track/features/settings/ui/setting_account.dart';
import 'package:fin_track/features/settings/ui/setting_language.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/viewmodel/auth_viewmodel.dart';

class SettingScreen extends StatefulWidget {
  final void Function(Locale locale)? onLocaleChange;

  const SettingScreen({super.key, this.onLocaleChange});

  @override
  State<StatefulWidget> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authViewModel = Provider.of<AuthViewModel>(context);
    final user = authViewModel.user;

    // ✅ Nếu user null => hiển thị loading hoặc fallback
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  l10n.setting,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Avatar + user info
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Image.asset('assets/images/user_avatar.png'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.displayName ?? 'User',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      user.email ?? '@example.com',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              SettingItem(
                icon: Icons.person_2_outlined,
                text: l10n.account,
                onClick: () {
                  navigateWithSlide(context, const AccountScreen());
                },
              ),

              const Divider(height: 36, color: Colors.black12),

              SettingItem(
                icon: Icons.language_outlined,
                text: l10n.language,
                onClick: () {
                  navigateWithSlide(
                    context,
                    LanguageScreen(onLocaleChange: widget.onLocaleChange),
                  );
                },
              ),

              const Divider(height: 36, color: Colors.black12),

              SettingItem(
                icon: Icons.help_center_outlined,
                text: l10n.help_center,
                onClick: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.growing_feat,
                        style: const TextStyle(color: Colors.black),
                      ),
                      backgroundColor: Colors.greenAccent,
                      action: SnackBarAction(
                        label: 'Ok',
                        textColor: Colors.white,
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                              .hideCurrentSnackBar();
                        },
                      ),
                    ),
                  );
                },
              ),

              const Divider(height: 36, color: Colors.black12),

              SettingItem(
                icon: Icons.policy_outlined,
                text: l10n.privacy_policy,
                onClick: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.growing_feat,
                        style: const TextStyle(color: Colors.black),
                      ),
                      backgroundColor: Colors.greenAccent,
                      action: SnackBarAction(
                        label: 'Ok',
                        textColor: Colors.white,
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                              .hideCurrentSnackBar();
                        },
                      ),
                    ),
                  );
                },
              ),

              const Divider(height: 36, color: Colors.black12),

              SettingItem(
                icon: Icons.logout,
                text: l10n.logout,
                onClick: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.logout),
                      content: Text(l10n.confirm_logout),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () {
                            authViewModel.signOut();
                            Navigator.of(context).pop();
                          },
                          child: Text(l10n.confirm),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
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
    super.key,
    required this.icon,
    required this.text,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF808080), size: 26),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 20,
            color: Colors.black54,
          ),
        ],
      ),
    );
  }
}

Future navigateWithSlide(BuildContext context, Widget screen) {
  return Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => screen,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.ease));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    ),
  );
}