import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Future<dynamic> openTransferBalancePage(
  BuildContext context, {
  TransactionWallet? wallet,
  bool allowEditWallet = true,
  bool showAllEditDetails = false,
  double? initialAmount,
  DateTime? initialDate,
  String? initialTitle,
  String? initialObjectiveLoanPk,
  bool? initialIsNegative,
}) async {
  return await openBottomSheet(
    context,
    fullSnap: true,
    TransferBalancePopup(
      wallet: wallet,
      allowEditWallet: allowEditWallet,
      showAllEditDetails: showAllEditDetails,
      initialAmount: initialAmount,
      initialDate: initialDate,
      initialTitle: initialTitle,
      initialObjectiveLoanPk: initialObjectiveLoanPk,
      initialIsNegative: initialIsNegative,
    ),
  );
}

class TransferBalancePage extends StatefulWidget {
  const TransferBalancePage({
    this.wallet,
    this.allowEditWallet = true,
    this.showAllEditDetails = false,
    this.initialAmount,
    this.initialDate,
    this.initialTitle,
    this.initialObjectiveLoanPk,
    this.initialIsNegative,
    super.key,
  });

  final TransactionWallet? wallet;
  final bool allowEditWallet;
  final bool showAllEditDetails;
  final double? initialAmount;
  final DateTime? initialDate;
  final String? initialTitle;
  final String? initialObjectiveLoanPk;
  final bool? initialIsNegative;

  @override
  State<TransferBalancePage> createState() => _TransferBalancePageState();
}

class _TransferBalancePageState extends State<TransferBalancePage> {
  @override
  Widget build(BuildContext context) {
    return PageFramework(
      title: "transfer-balance".tr(),
      dragDownToDismiss: true,
      horizontalPaddingConstrained: true,
      slivers: [
        SliverToBoxAdapter(
          child: TransferBalancePopup(
            wallet: widget.wallet,
            allowEditWallet: widget.allowEditWallet,
            showAllEditDetails: widget.showAllEditDetails,
            initialAmount: widget.initialAmount,
            initialDate: widget.initialDate,
            initialTitle: widget.initialTitle,
            initialObjectiveLoanPk: widget.initialObjectiveLoanPk,
            initialIsNegative: widget.initialIsNegative,
          ),
        ),
      ],
    );
  }
}
