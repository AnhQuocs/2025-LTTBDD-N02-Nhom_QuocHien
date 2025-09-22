import 'package:fin_track/features/auth/domain/usecase/reset_password_usecase.dart';
import 'package:fin_track/features/auth/domain/usecase/sign_in_usecase.dart';
import 'package:fin_track/features/auth/domain/usecase/sign_out_usecase.dart';
import 'package:fin_track/features/auth/domain/usecase/sign_up_usecase.dart';
import 'package:flutter/cupertino.dart';
import '../../domain/model/user.dart';
import '../../domain/usecase/get_user_usecase.dart';

class AuthViewModel extends ChangeNotifier {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  UserModel? _user;
  String? _error;
  bool _isLoading = false;

  AuthViewModel({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.resetPasswordUseCase,
    required this.getCurrentUserUseCase
  });

  UserModel? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await signInUseCase(email, password);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, String username) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await signUpUseCase(email, password, username);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await signOutUseCase();
      _user = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      await resetPasswordUseCase(email);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await getCurrentUserUseCase();
      _error = null;

      if (_user != null) {
        print('User: ${_user!.displayName}');
      } else {
        print('No user logged in');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}