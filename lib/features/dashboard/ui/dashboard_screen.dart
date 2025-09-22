import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/viewmodel/auth_viewmodel.dart';

class DashboardScreen extends StatefulWidget {
  final void Function(Locale locale)? onLocaleChange;

  const DashboardScreen({super.key, this.onLocaleChange});

  @override
  State<StatefulWidget> createState() => _DashboardScreen();
}

class _DashboardScreen extends State<DashboardScreen> {
  int selectedValue = 0;
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final authViewModel = Provider.of<AuthViewModel>(context);

    if (authViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (authViewModel.user == null) {
      return const Center(child: Text("Chưa đăng nhập"));
    } else {
      final user = authViewModel.user;

      return Scaffold(
        backgroundColor: Color(0xFF00D09E),
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${tr.hi}! ${tr.welcome_back}",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),

                                Text(
                                    "${user!.displayName}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 0.5
                                  ),
                                )
                              ],
                            ),

                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100)
                              ),
                              child: Icon(Icons.settings, color: Colors.black.withOpacity(0.7),),
                            )
                          ],
                        ),
                      )
                  )
              ),
            ),

            Expanded(
              flex: 6,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40)
                  )
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          final authViewModel = context.read<AuthViewModel>();
                          authViewModel.signOut();
                        },
                        child: Text(tr.logout),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              widget.onLocaleChange?.call(const Locale('en'));
                            },
                            child: Text('🇺🇸 ${tr.english}'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              widget.onLocaleChange?.call(const Locale('vi'));
                            },
                            child: Text('🇻🇳 ${tr.vietnamese}'),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ),
            )
          ],
        ),
      );
    }
  }
}