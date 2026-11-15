import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/incomeAmountArrow.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectTransactionTypeModal extends StatelessWidget {
  const SelectTransactionTypeModal({
    this.openPage,
    super.key,
  });

  final Widget? openPage;

  Widget _buildTypeTile(
    BuildContext context, {
    required String title,
    required String description,
    required Widget icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 10),
      child: Tappable(
        color: getColor(context, "lightDarkAccentHeavyLight"),
        borderRadius: 16,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFont(
                      text: title,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 2),
                    TextFont(
                      text: description,
                      fontSize: 13,
                      textColor: getColor(context, "textLight"),
                    ),
                  ],
                ),
              ),
              Icon(
                appStateSettings["outlinedIcons"]
                    ? Icons.arrow_forward_ios_outlined
                    : Icons.arrow_forward_ios_rounded,
                size: 16,
                color: getColor(context, "textLight").withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openTransactionPage(BuildContext context, bool isIncome) {
    BuildContext targetContext = navigatorKey.currentContext ?? context;
    popRoute(context);
    AddTransactionPage pageToOpen;
    if (openPage is AddTransactionPage) {
      AddTransactionPage orig = openPage as AddTransactionPage;
      pageToOpen = AddTransactionPage(
        transaction: orig.transaction,
        selectedBudget: orig.selectedBudget,
        selectedType: orig.selectedType,
        selectedObjective: orig.selectedObjective,
        selectedIncome: isIncome,
        useCategorySelectedIncome: orig.useCategorySelectedIncome,
        selectedAmount: orig.selectedAmount,
        selectedTitle: orig.selectedTitle,
        selectedCategory: orig.selectedCategory,
        selectedSubCategory: orig.selectedSubCategory,
        selectedWallet: orig.selectedWallet,
        selectedDate: orig.selectedDate,
        selectedNotes: orig.selectedNotes,
        startInitialAddTransactionSequence:
            orig.startInitialAddTransactionSequence,
        transferBalancePopup: false,
        routesToPopAfterDelete: orig.routesToPopAfterDelete,
      );
    } else {
      pageToOpen = AddTransactionPage(
        selectedIncome: isIncome,
        routesToPopAfterDelete: RoutesToPopAfterDelete.None,
      );
    }
    pushRoute(targetContext, pageToOpen);
  }

  void _openTransfer(BuildContext context) {
    BuildContext targetContext = navigatorKey.currentContext ?? context;
    popRoute(context);
    AllWallets allWallets =
        Provider.of<AllWallets>(targetContext, listen: false);
    if (allWallets.indexedByPk.keys.length < 2) {
      openPopup(
        targetContext,
        icon: appStateSettings["outlinedIcons"]
            ? Icons.compare_arrows_outlined
            : Icons.compare_arrows_rounded,
        title: "transfer".tr(),
        description: "select-2-different-accounts".tr(),
        onSubmit: () {
          popRoute(targetContext);
          pushRoute(
            targetContext,
            AddWalletPage(
              routesToPopAfterDelete: RoutesToPopAfterDelete.None,
            ),
          );
        },
        onSubmitLabel: "add-account".tr(),
      );
    } else {
      openBottomSheet(
        targetContext,
        fullSnap: true,
        TransferBalancePopup(
          allowEditWallet: true,
          wallet: allWallets.indexedByPk[appStateSettings["selectedWalletPk"]] ??
              allWallets.list.firstOrNull,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTypeTile(
          context,
          title: "expense".tr(),
          description: "Record an expense",
          icon: IncomeOutcomeArrow(
            isIncome: false,
            width: 22,
            color: getColor(context, "expenseAmount"),
          ),
          color: getColor(context, "expenseAmount"),
          onTap: () => _openTransactionPage(context, false),
        ),
        _buildTypeTile(
          context,
          title: "income".tr(),
          description: "Record income",
          icon: IncomeOutcomeArrow(
            isIncome: true,
            width: 22,
            color: getColor(context, "incomeAmount"),
          ),
          color: getColor(context, "incomeAmount"),
          onTap: () => _openTransactionPage(context, true),
        ),
        _buildTypeTile(
          context,
          title: "transfer".tr(),
          description: "Transfer between accounts",
          icon: Icon(
            appStateSettings["outlinedIcons"]
                ? Icons.compare_arrows_outlined
                : Icons.compare_arrows_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 26,
          ),
          color: Theme.of(context).colorScheme.primary,
          onTap: () => _openTransfer(context),
        ),
        const SizedBox(height: 4),
        Tappable(
          color: Colors.transparent,
          borderRadius: 12,
          onTap: () {
            popRoute(context);
            openBottomSheet(
              navigatorKey.currentContext ?? context,
              PopupFramework(
                child: const AddMoreThingsPopup(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
                vertical: 8, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  appStateSettings["outlinedIcons"]
                      ? Icons.more_horiz_outlined
                      : Icons.more_horiz_rounded,
                  size: 20,
                  color: getColor(context, "textLight"),
                ),
                const SizedBox(width: 6),
                TextFont(
                  text: "more-options".tr(),
                  fontSize: 14,
                  textColor: getColor(context, "textLight"),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}
