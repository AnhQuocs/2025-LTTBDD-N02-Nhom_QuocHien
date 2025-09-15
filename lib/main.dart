import 'package:fin_track/features/auth/presentation/ui/sign_in_screen.dart';
import 'package:fin_track/features/auth/presentation/ui/sign_up_screen.dart';
import 'package:fin_track/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:fin_track/features/dashboard/ui/dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/auth/data/repository/user_repository_impl.dart';
import 'features/auth/data/source/firebase_auth_service.dart';
import 'features/auth/domain/usecase/reset_password_usecase.dart';
import 'features/auth/domain/usecase/sign_in_usecase.dart';
import 'features/auth/domain/usecase/sign_out_usecase.dart';
import 'features/auth/domain/usecase/sign_up_usecase.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authService = FirebaseAuthService();
  final authRepository = AuthRepositoryImpl(authService);

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) =>
                AuthViewModel(
                    signInUseCase: SignInUseCase(authRepository),
                    signUpUseCase: SignUpUseCase(authRepository),
                    signOutUseCase: SignOutUseCase(authRepository),
                    resetPasswordUseCase: ResetPasswordUseCase(authRepository)
                ),
          )
        ],
        child: const MyApp(),
      ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fin Track',
      home: AuthWrapper(),
      routes: {
        '/signIn': (context) => const SignInScreen(),
        '/signUp': (context) => const SignUpScreen(),
        '/dashboard': (context) => const DashboardScreen()
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if(snapshot.hasData) {
          return const DashboardScreen();
        }

        return const SignInScreen();
      },
    );
  }
}