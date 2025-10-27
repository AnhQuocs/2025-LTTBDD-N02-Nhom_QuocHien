import 'package:fin_track/features/settings/ui/setting_account_password.dart';
import 'package:fin_track/features/settings/ui/setting_account_username.dart';
import 'package:fin_track/features/settings/ui/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/viewmodel/auth_viewmodel.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AccountScreen();
}

class _AccountScreen extends State<AccountScreen> {

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authViewModel = Provider.of<AuthViewModel>(context);
    final user = authViewModel.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.account, style: TextStyle(fontSize: 24),),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 8,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_2_outlined,
                        color: Colors.black54,
                        size: 26,
                      ),
                      SizedBox(width: 8,),
                      Text(
                        "${l10n.username}: ",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87
                        ),
                      ),
                      Text(
                        user!.displayName ?? "Username",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54
                        ),
                      )
                    ],
                  ),

                  GestureDetector(
                    onTap: () {
                      navigateWithSlide(context, UsernameScreen());
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 22,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24,),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        color: Colors.black54,
                        size: 26,
                      ),
                      SizedBox(width: 8,),
                      Text(
                        l10n.password,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87
                        ),
                      )
                    ],
                  ),

                  GestureDetector(
                    onTap: () {
                      navigateWithSlide(context, PasswordScreen());
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 22,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ),
    );
  }
}