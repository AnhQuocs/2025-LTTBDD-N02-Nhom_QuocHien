import 'package:fin_track/features/auth/presentation/ui/sign_in_screen.dart';
import 'package:fin_track/features/auth/presentation/ui/sign_up_screen.dart';
import 'package:fin_track/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:fin_track/features/main/main_screen.dart';
import 'package:fin_track/features/transaction/data/datasource/hive_datasource.dart';
import 'package:fin_track/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:fin_track/features/transaction/domain/usecases/read/get_transactions_by_category_id_use_case.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'features/auth/data/repository/user_repository_impl.dart';
import 'features/auth/data/source/firebase_auth_service.dart';
import 'features/auth/domain/usecase/get_user_usecase.dart';
import 'features/auth/domain/usecase/reset_password_usecase.dart';
import 'features/auth/domain/usecase/sign_in_usecase.dart';
import 'features/auth/domain/usecase/sign_out_usecase.dart';
import 'features/auth/domain/usecase/sign_up_usecase.dart';
import 'features/category/data/data_source/hive_category_data_source.dart';
import 'features/category/data/respository/category_repository_impl.dart';
import 'features/category/domain/entity/category.dart';
import 'features/category/domain/usecase/add_category_usecase.dart';
import 'features/category/domain/usecase/delete_category_usecase.dart';
import 'features/category/domain/usecase/get_all_categories_usecase.dart';
import 'features/category/presentation/viewmodel/category_viewmodel.dart';
import 'features/transaction/domain/usecases/create/add_transaction_usecase.dart';
import 'features/transaction/domain/usecases/delete/delete_transaction_usecase.dart';
import 'features/transaction/domain/usecases/read/get_all_transaction_usecase.dart';
import 'features/transaction/domain/usecases/read/get_daily_budget_usecase.dart';
import 'features/transaction/domain/usecases/read/get_daily_progress_usecase.dart';
import 'features/transaction/domain/usecases/read/get_daily_summaries_usecase.dart';
import 'features/transaction/domain/usecases/read/get_monthly_total_use_case.dart';
import 'features/transaction/domain/usecases/read/get_total_balance_use_case.dart';
import 'features/transaction/domain/usecases/read/get_total_expense_usecase.dart';
import 'features/transaction/domain/usecases/read/get_weekly_total_use_case.dart';
import 'features/transaction/domain/usecases/update/update_daily_pudget_usecase.dart';
import 'features/transaction/domain/usecases/update/update_transaction_usecase.dart';
import 'features/transaction/presentation/viewmodel/transaction_view_model.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Auth
  final authService = FirebaseAuthService();
  final authRepository = AuthRepositoryImpl(authService);

  // Hive
  final hive = HiveDataSource();
  await hive.init(clearOldData: false);

  final repository = TransactionRepositoryImpl(hive);

  final addTransactionUseCase = AddTransactionUseCase(repository);
  final updateTransactionUseCase = UpdateTransactionUseCase(repository);
  final deleteTransactionUseCase = DeleteTransactionUseCase(repository);
  final getAllTransactionsUseCase = GetAllTransactionsUseCase(repository);
  final getTotalBalanceUseCase = GetTotalBalanceUseCase(repository);
  final getTotalExpenseUseCase = GetTotalExpenseUseCase(repository);
  final getDailyProgressUseCase = GetDailyProgressUseCase(repository);

  // Category
  final hiveCategoryDataSource = HiveCategoryDataSource();
  await hiveCategoryDataSource.init();

  final categoryRepository = CategoryRepositoryImpl(hiveCategoryDataSource);

  final getAllCategoriesUseCase = GetAllCategoriesUseCase(categoryRepository);
  final addCategoryUseCase = AddCategoryUseCase(categoryRepository);
  final deleteCategoryUseCase = DeleteCategoryUseCase(categoryRepository);

  ChangeNotifierProvider(
    create: (_) => CategoryViewModel(
      getAllCategoriesUseCase: getAllCategoriesUseCase,
      addCategoryUseCase: addCategoryUseCase,
      deleteCategoryUseCase: deleteCategoryUseCase,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        // AuthViewModel provider
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            signInUseCase: SignInUseCase(authRepository),
            signUpUseCase: SignUpUseCase(authRepository),
            signOutUseCase: SignOutUseCase(authRepository),
            resetPasswordUseCase: ResetPasswordUseCase(authRepository),
            getCurrentUserUseCase: GetCurrentUserUseCase(authRepository),
          ),
        ),

        // TransactionViewModel provider
        ChangeNotifierProvider(
          create: (_) => TransactionViewModel(
            addTransactionUseCase: addTransactionUseCase,
            updateTransactionUseCase: updateTransactionUseCase,
            deleteTransactionUseCase: deleteTransactionUseCase,
            getAllTransactionsUseCase: getAllTransactionsUseCase,
            getTotalBalanceUseCase: getTotalBalanceUseCase,
            getTotalExpenseUseCase: getTotalExpenseUseCase,
            getDailyProgressUseCase: getDailyProgressUseCase,
            updateDailyBudgetUseCase: UpdateDailyBudgetUseCase(repository),
            getDailyBudgetUseCase: GetDailyBudgetUseCase(repository),
            getDailySummariesUseCase: GetDailySummariesUseCase(repository),
            getWeeklyTotalUseCase: GetWeeklyTotalUseCase(repository),
            getMonthlyTotalUseCase: GetMonthlyTotalUseCase(repository),
            getTransactionsByCategoryIdUseCase: GetTransactionsByCategoryIdUseCase(repository)
          ),
        ),

        // CategoryViewModel provider
        ChangeNotifierProvider(
          create: (_) => CategoryViewModel(
            getAllCategoriesUseCase: getAllCategoriesUseCase,
            addCategoryUseCase: addCategoryUseCase,
            deleteCategoryUseCase: deleteCategoryUseCase,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fin Track',
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('vi')],
      home: AuthWrapper(onLocaleChange: setLocale),
      routes: {
        '/signIn': (context) => const SignInScreen(),
        '/signUp': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final void Function(Locale locale)? onLocaleChange;

  const AuthWrapper({super.key, this.onLocaleChange});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // login -> load transactions for current user
          final txVm = Provider.of<TransactionViewModel>(
            context,
            listen: false,
          );
          txVm.loadTransactions(userId: snapshot.data!.uid);
          return HomeScreen(onLocaleChange: onLocaleChange);
        }

        return SignInScreen(onLocaleChange: onLocaleChange);
      },
    );
  }
}
