import 'package:flutter/material.dart';

import '../transaction/presentation/ui/transaction_form.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<StatefulWidget> createState() => _CategoryScreen();
}

class _CategoryScreen extends State<CategoryScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                "Category Screen"
            ),

            SizedBox(height: 16,),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TransactionForm(),
            )
          ],
        ),
      ),
    );
  }
}