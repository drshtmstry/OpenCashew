import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addButton.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/managePinnedTransactionsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/selectedTransactionsAppBar.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/util/keepAliveClientMixin.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class _PinnedTx {
  final Transaction transaction;
  final TransactionCategory category;
  _PinnedTx(this.transaction, this.category);
}

class HomePagePinnedTransactions extends StatefulWidget {
  const HomePagePinnedTransactions({super.key});

  @override
  State<HomePagePinnedTransactions> createState() =>
      _HomePagePinnedTransactionsState();
}

class _HomePagePinnedTransactionsState
    extends State<HomePagePinnedTransactions> {
  List<String> get pinnedPks {
    List<dynamic> list = appStateSettings["pinnedTransactions"] ?? [];
    return list.map((e) => e.toString()).toList();
  }

  void _unpin(String pk) {
    List<String> updated = List<String>.from(pinnedPks)..remove(pk);
    updateSettings("pinnedTransactions", updated, updateGlobalState: true);
    setState(() {});
  }

  Future<_PinnedTx?> _loadTx(String pk) async {
    try {
      Transaction t = await database.getTransactionFromPk(pk);
      TransactionCategory c = await database.getCategoryInstance(t.categoryFk);
      return _PinnedTx(t, c);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> pks = pinnedPks;

    if (pks.isEmpty) {
      return KeepAliveClientMixin(
        child: Padding(
          padding:
              const EdgeInsetsDirectional.only(start: 13, end: 13, bottom: 13),
          child: AddButton(
            onTap: () {
              pushRoute(context, const ManagePinnedTransactionsPage());
            },
            height: 90,
            width: null,
            margin: EdgeInsetsDirectional.zero,
            labelUnder: "pinned-transactions".tr() != "pinned-transactions"
                ? "pinned-transactions".tr()
                : "Pinned Transactions",
            icon: appStateSettings["outlinedIcons"]
                ? Icons.push_pin_outlined
                : Icons.push_pin_rounded,
          ),
        ),
      );
    }

    return KeepAliveClientMixin(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 18,
                end: 14,
                bottom: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        appStateSettings["outlinedIcons"]
                            ? Icons.push_pin_outlined
                            : Icons.push_pin_rounded,
                        size: 19,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      TextFont(
                        text: "pinned-transactions".tr() != "pinned-transactions"
                            ? "pinned-transactions".tr()
                            : "Pinned Transactions",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryContainer
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFont(
                          text: pks.length.toString(),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          textColor:
                              Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                  Tappable(
                    borderRadius: 8,
                    color: Colors.transparent,
                    onTap: () {
                      pushRoute(context, const ManagePinnedTransactionsPage());
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: TextFont(
                        text: "manage".tr() != "manage" ? "manage".tr() : "Manage",
                        fontSize: 13,
                        textColor: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: pks.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  String pk = pks[index];
                  return FutureBuilder<_PinnedTx?>(
                    future: _loadTx(pk),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return Container(
                          width: 160,
                          decoration: BoxDecoration(
                            color:
                                getColor(context, "lightDarkAccentHeavyLight"),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        );
                      }

                      Transaction transaction = snapshot.data!.transaction;
                      TransactionCategory category = snapshot.data!.category;

                      String displayName = transaction.name.isNotEmpty
                          ? transaction.name
                          : (transaction.payee?.isNotEmpty == true
                              ? transaction.payee!
                              : category.name);

                      return Container(
                        width: 175,
                        decoration: BoxDecoration(
                          color:
                              getColor(context, "lightDarkAccentHeavyLight"),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: getColor(context, "border").withOpacity(0.12),
                            width: 1,
                          ),
                          boxShadow: boxShadowCheck(boxShadowGeneral(context)),
                        ),
                        child: Tappable(
                          borderRadius: 15,
                          color: Colors.transparent,
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            await duplicateTransaction(
                              context,
                              transaction.transactionPk,
                              useCurrentDate: true,
                            );
                          },
                          onLongPress: () {
                            openBottomSheet(
                              context,
                              PopupFramework(
                                title: displayName,
                                subtitle: convertToMoney(
                                  Provider.of<AllWallets>(context, listen: false),
                                  transaction.amount,
                                ),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: Icon(
                                        appStateSettings["outlinedIcons"]
                                            ? Icons.add_circle_outline
                                            : Icons.add_circle_rounded,
                                      ),
                                      title: TextFont(
                                        text: "add-now".tr() != "add-now"
                                            ? "add-now".tr()
                                            : "Add Now (Current Date)",
                                      ),
                                      onTap: () async {
                                        popRoute(context);
                                        await duplicateTransaction(
                                          context,
                                          transaction.transactionPk,
                                          useCurrentDate: true,
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        appStateSettings["outlinedIcons"]
                                            ? Icons.edit_outlined
                                            : Icons.edit_rounded,
                                      ),
                                      title: TextFont(
                                        text: "edit-transaction".tr(),
                                      ),
                                      onTap: () {
                                        popRoute(context);
                                        pushRoute(
                                          context,
                                          AddTransactionPage(
                                            transaction: transaction,
                                            routesToPopAfterDelete:
                                                RoutesToPopAfterDelete.One,
                                          ),
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        appStateSettings["outlinedIcons"]
                                            ? Icons.push_pin_outlined
                                            : Icons.push_pin_rounded,
                                        color: Colors.red,
                                      ),
                                      title: TextFont(
                                        text: "unpin-transaction".tr() !=
                                                "unpin-transaction"
                                            ? "unpin-transaction".tr()
                                            : "Unpin",
                                        textColor: Colors.red,
                                      ),
                                      onTap: () {
                                        popRoute(context);
                                        _unpin(pk);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CategoryIcon(
                                      categoryPk: category.categoryPk,
                                      size: 30,
                                      sizePadding: 16,
                                      borderRadius: 10,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        size: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFont(
                                      text: displayName,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextFont(
                                          text: convertToMoney(
                                            Provider.of<AllWallets>(context),
                                            transaction.amount,
                                          ),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          textColor: transaction.income
                                              ? getColor(context, "incomeAmount")
                                              : getColor(context, "expenseAmount"),
                                        ),
                                        if (transaction.payee?.isNotEmpty == true &&
                                            transaction.name.isNotEmpty)
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .only(start: 4),
                                              child: TextFont(
                                                text: transaction.payee!,
                                                fontSize: 11,
                                                textColor: getColor(
                                                    context, "textLight"),
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
