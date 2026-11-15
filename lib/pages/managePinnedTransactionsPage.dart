import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/selectedTransactionsAppBar.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManagePinnedTransactionsPage extends StatefulWidget {
  const ManagePinnedTransactionsPage({super.key});

  @override
  State<ManagePinnedTransactionsPage> createState() =>
      _ManagePinnedTransactionsPageState();
}

class _ManagePinnedTransactionsPageState
    extends State<ManagePinnedTransactionsPage> {
  List<String> get pinnedPks {
    List<dynamic> list = appStateSettings["pinnedTransactions"] ?? [];
    return list.map((e) => e.toString()).toList();
  }

  void _unpinTransaction(String pk) {
    List<String> updated = List<String>.from(pinnedPks)..remove(pk);
    updateSettings("pinnedTransactions", updated, updateGlobalState: true);
    setState(() {});
  }

  void _addPinnedTransaction() async {
    // Open a picker to choose a transaction to pin
    await openBottomSheet(
      context,
      PopupFramework(
        title: "pin-transactions-title".tr() != "pin-transactions-title"
            ? "pin-transactions-title".tr()
            : "Pin Transactions",
        child: FutureBuilder<List<Transaction>>(
          future: database.allTransactions,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return NoResults(
                message: "no-transactions-found".tr(),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Transaction transaction = snapshot.data![index];
                bool isPinned = pinnedPks.contains(transaction.transactionPk);
                return ListTile(
                  title: TextFont(
                    text: transaction.name.isEmpty
                        ? "transaction".tr()
                        : transaction.name,
                    fontWeight: FontWeight.bold,
                  ),
                  subtitle: TextFont(
                    text: getWordedDateShort(transaction.dateCreated),
                    fontSize: 12,
                    textColor: getColor(context, "textLight"),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      isPinned
                          ? (appStateSettings["outlinedIcons"]
                              ? Icons.push_pin
                              : Icons.push_pin_rounded)
                          : (appStateSettings["outlinedIcons"]
                              ? Icons.push_pin_outlined
                              : Icons.push_pin_rounded),
                      color: isPinned
                          ? Theme.of(context).colorScheme.primary
                          : getColor(context, "textLight"),
                    ),
                    onPressed: () {
                      List<String> updated = List<String>.from(pinnedPks);
                      if (isPinned) {
                        updated.remove(transaction.transactionPk);
                      } else {
                        updated.add(transaction.transactionPk);
                      }
                      updateSettings("pinnedTransactions", updated,
                          updateGlobalState: true);
                      setState(() {});
                      popRoute(context);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      title: "manage-pinned-transactions".tr() != "manage-pinned-transactions"
          ? "manage-pinned-transactions".tr()
          : "Manage Pinned Transactions",
      dragDownToDismiss: true,
      horizontalPaddingConstrained: true,
      actions: [
        IconButton(
          icon: Icon(
            appStateSettings["outlinedIcons"]
                ? Icons.add_outlined
                : Icons.add_rounded,
          ),
          onPressed: _addPinnedTransaction,
        ),
      ],
      listWidgets: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextFont(
            text: "pinned-transactions-description".tr() !=
                    "pinned-transactions-description"
                ? "pinned-transactions-description".tr()
                : "Tap a pinned transaction to quickly duplicate it. You can access pinned transactions by long pressing (+) from the home page.",
            fontSize: 13,
            textColor: getColor(context, "textLight"),
            maxLines: 5,
          ),
        ),
        if (pinnedPks.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: NoResults(
              message: "no-pinned-transactions-found".tr() !=
                      "no-pinned-transactions-found"
                  ? "no-pinned-transactions-found".tr()
                  : "No Pinned Transactions Found",
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pinnedPks.length,
            onReorder: (oldIndex, newIndex) {
              List<String> updated = List<String>.from(pinnedPks);
              if (newIndex > oldIndex) newIndex--;
              final item = updated.removeAt(oldIndex);
              updated.insert(newIndex, item);
              updateSettings("pinnedTransactions", updated,
                  updateGlobalState: true);
              setState(() {});
            },
            itemBuilder: (context, index) {
              String pk = pinnedPks[index];
              return FutureBuilder<Transaction>(
                key: ValueKey(pk),
                future: database.getTransactionFromPk(pk),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const SizedBox.shrink();
                  }
                  Transaction transaction = snapshot.data!;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    leading: Icon(
                      appStateSettings["outlinedIcons"]
                          ? Icons.push_pin_outlined
                          : Icons.push_pin_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: TextFont(
                      text: transaction.name.isEmpty
                          ? "transaction".tr()
                          : transaction.name,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    subtitle: TextFont(
                      text: convertToMoney(
                        Provider.of<AllWallets>(context),
                        transaction.amount,
                      ),
                      fontSize: 13,
                      textColor: getColor(context, "textLight"),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            appStateSettings["outlinedIcons"]
                                ? Icons.copy_outlined
                                : Icons.copy_rounded,
                            size: 20,
                          ),
                          onPressed: () async {
                            await duplicateTransaction(
                              context,
                              transaction.transactionPk,
                              useCurrentDate: true,
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            appStateSettings["outlinedIcons"]
                                ? Icons.close_outlined
                                : Icons.close_rounded,
                            size: 20,
                            color: Colors.red,
                          ),
                          onPressed: () => _unpinTransaction(pk),
                        ),
                        ReorderableDragStartListener(
                          index: index,
                          child: const Icon(Icons.drag_handle),
                        ),
                      ],
                    ),
                    onTap: () async {
                      await duplicateTransaction(
                        context,
                        transaction.transactionPk,
                        useCurrentDate: true,
                      );
                    },
                  );
                },
              );
            },
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}
