import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Future<dynamic> openCorrectTotalBalancePage(
  BuildContext context, {
  required TransactionWallet wallet,
  bool showAllEditDetails = false,
}) async {
  return await openBottomSheet(
    context,
    fullSnap: true,
    CorrectBalancePopup(
      wallet: wallet,
      showAllEditDetails: showAllEditDetails,
    ),
  );
}

class CorrectTotalBalancePage extends StatefulWidget {
  const CorrectTotalBalancePage({
    required this.wallet,
    this.showAllEditDetails = false,
    super.key,
  });

  final TransactionWallet wallet;
  final bool showAllEditDetails;

  @override
  State<CorrectTotalBalancePage> createState() =>
      _CorrectTotalBalancePageState();
}

class _CorrectTotalBalancePageState extends State<CorrectTotalBalancePage> {
  @override
  Widget build(BuildContext context) {
    return PageFramework(
      title: "correct-total-balance".tr(),
      dragDownToDismiss: true,
      horizontalPaddingConstrained: true,
      slivers: [
        SliverToBoxAdapter(
          child: CorrectBalancePopup(
            wallet: widget.wallet,
            showAllEditDetails: widget.showAllEditDetails,
          ),
        ),
      ],
    );
  }
}
