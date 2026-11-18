import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart' hide TransactionTag;
import 'package:budget/functions.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/struct/accountTypes.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/transactionEntryTag.dart';
import 'package:budget/widgets/walletIcon.dart';
import 'package:budget/widgets/walletEntry.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide SliverReorderableList;
import 'package:flutter/services.dart' hide TextInput;
import 'package:budget/widgets/editRowEntry.dart';
import 'package:budget/modified/reorderable_list.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'exchangeRatesPage.dart';

class EditWalletsPage extends StatefulWidget {
  EditWalletsPage({Key? key, this.runWhenOpen, this.title}) : super(key: key);

  final VoidCallback? runWhenOpen;
  final String? title;

  @override
  EditWalletsPageState createState() => EditWalletsPageState();
}

class EditWalletsPageState extends State<EditWalletsPage> {
  final GlobalKey<PageFrameworkState> _pageFrameworkKey = GlobalKey();
  bool dragDownToDismissEnabled = true;
  int currentReorder = -1;
  String searchValue = "";
  bool isFocused = false;

  void scrollToTop() {
    _pageFrameworkKey.currentState?.scrollToTop();
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (widget.runWhenOpen != null) {
        widget.runWhenOpen!();
      }
      database.fixOrderWallets();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (searchValue != "") {
          setState(() {
            searchValue = "";
          });
          return false;
        } else {
          return true;
        }
      },
      child: PageFramework(
        key: _pageFrameworkKey,
        horizontalPaddingConstrained: true,
        dragDownToDismiss: true,
        dragDownToDismissEnabled: dragDownToDismissEnabled,
        scrollToTopButton: true,
        title: widget.title ?? "edit-accounts".tr(),
        floatingActionButton: AnimateFABDelayed(
          fab: AddFAB(
            tooltip: "add-account".tr(),
            openPage: AddWalletPage(
              routesToPopAfterDelete: RoutesToPopAfterDelete.None,
            ),
          ),
        ),
        actions: [
          CustomPopupMenuButton(
            showButtons: true,
            keepOutFirst: true,
            items: [
              DropdownItemMenu(
                id: "add-account",
                label: "add-account".tr(),
                icon: appStateSettings["outlinedIcons"]
                    ? Icons.add_outlined
                    : Icons.add_rounded,
                action: () {
                  pushRoute(
                    context,
                    AddWalletPage(
                      routesToPopAfterDelete: RoutesToPopAfterDelete.None,
                    ),
                  );
                },
              ),
              DropdownItemMenu(
                id: "settings",
                label: "settings".tr(),
                icon: appStateSettings["outlinedIcons"]
                    ? Icons.more_vert_outlined
                    : Icons.more_vert_rounded,
                action: () => openBottomSheet(
                  context,
                  PopupFramework(
                    hasPadding: false,
                    child: WalletsSettings(
                        backgroundColor: getPopupBackgroundColor(context)),
                  ),
                ),
              ),
            ],
          ),
        ],
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 8.0),
              child: Focus(
                onFocusChange: (value) {
                  setState(() {
                    isFocused = value;
                  });
                },
                child: TextInput(
                  labelText: "search-accounts-placeholder".tr(),
                  icon: appStateSettings["outlinedIcons"]
                      ? Icons.search_outlined
                      : Icons.search_rounded,
                  onSubmitted: (value) {
                    setState(() {
                      searchValue = value;
                    });
                  },
                  onChanged: (value) {
                    setState(() {
                      searchValue = value;
                    });
                  },
                  autoFocus: false,
                ),
              ),
            ),
          ),
          // SliverToBoxAdapter(
          //   child: AnimatedExpanded(
          //     expand: hideIfSearching(searchValue, isFocused, context) == false,
          //     child: ShowAccountLabelSettingToggle(),
          //   ),
          // ),
          // SliverToBoxAdapter(
          //   child: AnimatedExpanded(
          //     expand: hideIfSearching(searchValue, isFocused, context) == false,
          //     child: SettingsContainerOpenPage(
          //       onOpen: () {
          //         checkIfExchangeRateChangeBefore();
          //       },
          //       onClosed: () {
          //         checkIfExchangeRateChangeAfter();
          //       },
          //       openPage: ExchangeRates(),
          //       title: "exchange-rates".tr(),
          //       icon: appStateSettings["outlinedIcons"]
          //           ? Icons.account_balance_wallet_outlined
          //           : Icons.account_balance_wallet_rounded,
          //     ),
          //   ),
          // ),
          // SliverToBoxAdapter(
          //   child: AnimatedExpanded(
          //     expand: hideIfSearching(searchValue, isFocused, context) == false,
          //     child: SettingsContainer(
          //       onTap: () {
          //         openBottomSheet(
          //           context,
          //           fullSnap: true,
          //           TransferBalancePopup(
          //             allowEditWallet: true,
          //             wallet: Provider.of<AllWallets>(context, listen: false)
          //                 .indexedByPk[appStateSettings["selectedWalletPk"]]!,
          //           ),
          //         );
          //       },
          //       title: "transfer-balance".tr(),
          //       icon: appStateSettings["outlinedIcons"]
          //           ? Icons.compare_arrows_outlined
          //           : Icons.compare_arrows_rounded,
          //     ),
          //   ),
          // ),
          StreamBuilder<List<WalletWithDetails>>(
            stream: database.watchAllWalletsWithDetails(
                searchFor: searchValue == "" ? null : searchValue),
            builder: (context, snapshot) {
              if (snapshot.hasData && (snapshot.data ?? []).length <= 0) {
                return SliverToBoxAdapter(
                  child: NoResults(
                    message: "no-accounts-found".tr(),
                  ),
                );
              }
              if (snapshot.hasData && (snapshot.data ?? []).length > 0) {
                List<WalletWithDetails> activeWallets = (snapshot.data ?? [])
                    .where((w) => !w.wallet.archived)
                    .toList();
                List<WalletWithDetails> archivedWallets = (snapshot.data ?? [])
                    .where((w) => w.wallet.archived)
                    .toList();

                Map<AccountType, List<WalletWithDetails>> groupedWallets = {};
                for (AccountType type in AccountType.values) {
                  groupedWallets[type] = [];
                }
                for (WalletWithDetails w in activeWallets) {
                  AccountType type = getAccountTypeFromWallet(w.wallet);
                  groupedWallets[type]!.add(w);
                }

                return MultiSliver(
                  children: [
                    for (AccountType type in AccountType.values)
                      if ((groupedWallets[type] ?? []).isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(
                              top: 22,
                              bottom: 8,
                              start: 22,
                              end: 22,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  getAccountTypeIcon(
                                    type,
                                    outlined: appStateSettings["outlinedIcons"],
                                  ),
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: TextFont(
                                          text: getAccountTypeName(type),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          maxLines: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: getColor(
                                              context, "lightDarkAccentHeavy"),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: TextFont(
                                          text: groupedWallets[type]!
                                              .length
                                              .toString(),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          textColor:
                                              getColor(context, "textLight"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextFont(
                                  text: convertToMoney(
                                    Provider.of<AllWallets>(context),
                                    groupedWallets[type]!.fold<double>(
                                      0,
                                      (sum, w) => sum + (w.totalSpent ?? 0),
                                    ),
                                  ),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  textColor: getColor(context, "textLight"),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverReorderableList(
                          onReorderStart: (index) {
                            HapticFeedback.heavyImpact();
                            setState(() {
                              dragDownToDismissEnabled = false;
                              currentReorder = index;
                            });
                          },
                          onReorderEnd: (_) {
                            setState(() {
                              dragDownToDismissEnabled = true;
                              currentReorder = -1;
                            });
                          },
                          itemBuilder: (context, index) {
                            List<WalletWithDetails> typeWallets =
                                groupedWallets[type]!;
                            WalletWithDetails walletWithDetails =
                                typeWallets[index];
                            TransactionWallet wallet =
                                walletWithDetails.wallet;
                            Color accentColor = dynamicPastel(
                                context,
                                HexColor(wallet.colour,
                                    defaultColor:
                                        Theme.of(context).colorScheme.primary),
                                amountLight: 0.55,
                                amountDark: 0.35);
                            final bool isPrimary =
                                Provider.of<SelectedWalletPk>(context)
                                        .selectedWalletPk ==
                                    wallet.walletPk;

                            return EditRowEntry(
                              extraIcon: null,
                              onExtra: null,
                              extraWidget: null,
                              canDelete: false,
                              onDelete: null,
                              canReorder: searchValue == "" &&
                                  typeWallets.length > 1,
                              currentReorder: currentReorder != -1 &&
                                  currentReorder != index,
                              index: index,
                              accentColor: accentColor,
                              content: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  WalletIcon(
                                    wallet: wallet,
                                    size: 26,
                                    sizePadding: 10,
                                    borderRadius: 12,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFont(
                                                text: wallet.name,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                            if (isPrimary)
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .only(start: 6),
                                                child: TransactionTag(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .symmetric(
                                                      horizontal: 7,
                                                      vertical: 1.5),
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  name: "primary-default".tr(),
                                                  margin: EdgeInsetsDirectional
                                                      .zero,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        TextFont(
                                          textAlign: TextAlign.start,
                                          text: convertToMoney(
                                            Provider.of<AllWallets>(context),
                                            walletWithDetails.totalSpent ?? 0,
                                            currencyKey: wallet.currency,
                                            decimals: wallet.decimals,
                                            addCurrencyName: true,
                                          ).toString(),
                                          fontSize: 15,
                                        ),
                                        const SizedBox(height: 2),
                                        TextFont(
                                          textAlign: TextAlign.start,
                                          text: walletWithDetails
                                                  .numberTransactions
                                                  .toString() +
                                              " " +
                                              (walletWithDetails
                                                          .numberTransactions ==
                                                      1
                                                  ? "transaction"
                                                      .tr()
                                                      .toLowerCase()
                                                  : "transactions"
                                                      .tr()
                                                      .toLowerCase()),
                                          fontSize: 13,
                                          textColor: getColor(context, "black")
                                              .withOpacity(0.6),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              openPage: WatchedWalletDetailsPage(
                                walletPk: wallet.walletPk,
                              ),
                              key: ValueKey(wallet.walletPk),
                            );
                          },
                          itemCount: groupedWallets[type]!.length,
                          onReorder: (_intPrevious, _intNew) async {
                            List<WalletWithDetails> typeWallets =
                                groupedWallets[type]!;
                            WalletWithDetails oldWalletWithDetails =
                                typeWallets[_intPrevious];
                            TransactionWallet oldWallet =
                                oldWalletWithDetails.wallet;
                            int targetIndex =
                                _intNew > _intPrevious ? _intNew - 1 : _intNew;
                            WalletWithDetails targetWalletWithDetails =
                                typeWallets[targetIndex];
                            TransactionWallet targetWallet =
                                targetWalletWithDetails.wallet;

                            await database.moveWallet(oldWallet.walletPk,
                                targetWallet.order, oldWallet.order);
                            return true;
                          },
                        ),
                      ],
                    if (archivedWallets.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(
                            top: 25,
                            bottom: 8,
                            start: 22,
                            end: 22,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                appStateSettings["outlinedIcons"]
                                    ? Icons.archive_outlined
                                    : Icons.archive_rounded,
                                size: 18,
                                color: getColor(context, "textLight"),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Row(
                                  children: [
                                    TextFont(
                                      text: "archived-accounts".tr(),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      textColor: getColor(context, "textLight"),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: getColor(
                                            context, "lightDarkAccentHeavy"),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: TextFont(
                                        text: archivedWallets.length.toString(),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        textColor: getColor(context, "textLight"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextFont(
                                text: convertToMoney(
                                  Provider.of<AllWallets>(context),
                                  archivedWallets.fold<double>(
                                    0,
                                    (sum, w) => sum + (w.totalSpent ?? 0),
                                  ),
                                ),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                textColor: getColor(context, "textLight"),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            WalletWithDetails walletWithDetails =
                                archivedWallets[index];
                            TransactionWallet wallet = walletWithDetails.wallet;
                            Color accentColor = dynamicPastel(
                                context,
                                HexColor(wallet.colour,
                                    defaultColor:
                                        Theme.of(context).colorScheme.primary),
                                amountLight: 0.55,
                                amountDark: 0.35);
                            return EditRowEntry(
                              extraIcon: null,
                              onExtra: null,
                              extraWidget: null,
                              canDelete: false,
                              onDelete: null,
                              opacity: 0.6,
                              canReorder: false,
                              currentReorder: false,
                              index: index,
                              accentColor: accentColor,
                              content: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  WalletIcon(
                                    wallet: wallet,
                                    size: 26,
                                    sizePadding: 10,
                                    borderRadius: 12,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFont(
                                                text: wallet.name,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsetsDirectional.only(
                                                      start: 6),
                                              child: TransactionTag(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .symmetric(
                                                    horizontal: 7, vertical: 1.5),
                                                color: getColor(
                                                    context, "textLight"),
                                                name: "archived-accounts".tr(),
                                                margin:
                                                    EdgeInsetsDirectional.zero,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        TextFont(
                                          textAlign: TextAlign.start,
                                          text: convertToMoney(
                                            Provider.of<AllWallets>(context),
                                            walletWithDetails.totalSpent ?? 0,
                                            currencyKey: wallet.currency,
                                            decimals: wallet.decimals,
                                            addCurrencyName: true,
                                          ).toString(),
                                          fontSize: 15,
                                        ),
                                        const SizedBox(height: 2),
                                        TextFont(
                                          textAlign: TextAlign.start,
                                          text: walletWithDetails
                                                  .numberTransactions
                                                  .toString() +
                                              " " +
                                              (walletWithDetails
                                                          .numberTransactions ==
                                                      1
                                                  ? "transaction"
                                                      .tr()
                                                      .toLowerCase()
                                                  : "transactions"
                                                      .tr()
                                                      .toLowerCase()),
                                          fontSize: 13,
                                          textColor: getColor(context, "black")
                                              .withOpacity(0.6),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              openPage: WatchedWalletDetailsPage(
                                walletPk: wallet.walletPk,
                              ),
                              key: ValueKey("archived_" + wallet.walletPk),
                            );
                          },
                          childCount: archivedWallets.length,
                        ),
                      ),
                    ],
                  ],
                );
              }
              return SliverToBoxAdapter(
                child: Container(),
              );
            },
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 85),
          ),
        ],
      ),
    );
  }
}

Future<DeletePopupAction?> deleteWalletPopup(
  BuildContext context, {
  required TransactionWallet wallet,
  required RoutesToPopAfterDelete routesToPopAfterDelete,
}) async {
  DeletePopupAction? action = await openDeletePopup(
    context,
    title: "delete-account-question".tr(),
    subtitle: wallet.name,
    description: "delete-account-question-description".tr(),
  );
  if (action == DeletePopupAction.Delete) {
    int transactionsFromWalletLength =
        (await database.getAllTransactionsFromWallet(wallet.walletPk)).length;
    dynamic result = true;
    if (transactionsFromWalletLength > 0) {
      result = await openPopup(
        context,
        title: "delete-all-transactions-question".tr(),
        description: "delete-account-merge-warning".tr(),
        icon: appStateSettings["outlinedIcons"]
            ? Icons.warning_outlined
            : Icons.warning_rounded,
        onCancel: () {
          popRoute(context, false);
        },
        onCancelLabel: "cancel".tr(),
        onSubmit: () async {
          popRoute(context, true);
        },
        onExtra2: () {
          popRoute(context, false);
          mergeWalletPopup(
            context,
            walletOriginal: wallet,
            routesToPopAfterDelete: routesToPopAfterDelete,
          );
        },
        onExtraLabel2: "move-transactions".tr(),
        onSubmitLabel: "delete".tr(),
      );
    }
    if (result == true) {
      if (routesToPopAfterDelete == RoutesToPopAfterDelete.All) {
        popAllRoutes(context);
      } else if (routesToPopAfterDelete == RoutesToPopAfterDelete.One) {
        popRoute(context);
      }
      openLoadingPopupTryCatch(() async {
        await database.deleteWallet(wallet.walletPk, wallet.order);
        openSnackbar(
          SnackbarMessage(
            title: "deleted-account".tr(),
            icon: Icons.delete,
            description: wallet.name,
          ),
        );
      });
    }
  }
  return action;
}

void mergeWalletPopup(
  BuildContext context, {
  required TransactionWallet walletOriginal,
  required RoutesToPopAfterDelete routesToPopAfterDelete,
}) async {
  var selectedWalletResult = await selectWalletPopup(
    context,
    removeWalletPks: [walletOriginal.walletPk],
    subtitle: "account-to-transfer-all-transactions-to".tr(),
    allowEditWallet: false,
  );
  if (selectedWalletResult != null) {
    final result = await openPopup(
      context,
      title: "merge-into".tr() + " " + selectedWalletResult.name + "?",
      description: "merge-into-description-accounts".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.merge_outlined
          : Icons.merge_rounded,
      onSubmit: () async {
        popRoute(context, true);
      },
      onSubmitLabel: "merge".tr(),
      onCancelLabel: "cancel".tr(),
      onCancel: () {
        popRoute(context);
      },
    );
    if (result == true) {
      if (routesToPopAfterDelete == RoutesToPopAfterDelete.All) {
        popAllRoutes(context);
      } else if (routesToPopAfterDelete == RoutesToPopAfterDelete.One) {
        popRoute(context);
      }
      openLoadingPopupTryCatch(() async {
        await database.moveWalletTransactions(
          Provider.of<AllWallets>(context, listen: false),
          walletOriginal.walletPk,
          selectedWalletResult.walletPk,
        );
        if (walletOriginal.walletPk == "0") {
          await database.convertToPrimaryWallet(selectedWalletResult);
        } else {
          await database.deleteWallet(
              walletOriginal.walletPk, walletOriginal.order);
        }

        openSnackbar(
          SnackbarMessage(
            title: "merged-account".tr(),
            icon: appStateSettings["outlinedIcons"]
                ? Icons.merge_outlined
                : Icons.merge_rounded,
            description:
                walletOriginal.name + " → " + selectedWalletResult.name,
          ),
        );
      });
    }
  }
}

Future<TransactionWallet?> selectWalletPopup(
  BuildContext context, {
  List<String>? removeWalletPks,
  String? subtitle,
  TransactionWallet? selectedWallet,
  required bool allowEditWallet,
  bool allowDeleteWallet = true,
  bool currencyOnly = false,
  String? title,
}) async {
  dynamic wallet = await openBottomSheet(
    context,
    PopupFramework(
      title: title ?? "select-account".tr(),
      subtitle: subtitle,
      child: StreamBuilder<List<WalletWithDetails>>(
        stream: database.watchAllWalletsWithDetails(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<WalletWithDetails> walletsWithoutOneDeleted = snapshot.data!;
            if (removeWalletPks != null)
              walletsWithoutOneDeleted.removeWhere((WalletWithDetails w) =>
                  removeWalletPks.contains(w.wallet.walletPk));
            if (walletsWithoutOneDeleted.isEmpty) {
              return Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 15),
                child: NoResults(message: "no-accounts-found".tr()),
              );
            }
            return RadioItems(
              getSelected: (Object? object) {
                TransactionWallet? wallet;
                if (object is WalletWithDetails) wallet = object.wallet;
                if (wallet?.walletPk == selectedWallet?.walletPk) return true;
                return false;
              },
              items: walletsWithoutOneDeleted,
              colorFilter: (Object? object) {
                TransactionWallet? wallet;
                if (object is WalletWithDetails) wallet = object.wallet;
                if (wallet == null) return null;
                return dynamicPastel(
                  context,
                  lightenPastel(
                    HexColor(
                      wallet.colour,
                      defaultColor: Theme.of(context).colorScheme.primary,
                    ),
                    amount: 0.2,
                  ),
                  amount: 0.1,
                );
              },
              displayFilter: (Object? object) {
                TransactionWallet? wallet;
                if (object is WalletWithDetails) wallet = object.wallet;
                if (currencyOnly) {
                  return (wallet?.currency ?? "").allCaps;
                }
                return wallet?.name ?? "";
              },
              getEndInfo: currencyOnly
                  ? null
                  : (Object? object) {
                      TransactionWallet? wallet;
                      double totalSpent = 0;
                      if (object is WalletWithDetails) {
                        wallet = object.wallet;
                        totalSpent = object.totalSpent ?? 0;
                      }
                      return convertToMoney(
                        Provider.of<AllWallets>(context),
                        totalSpent,
                        finalNumber: totalSpent,
                        currencyKey: wallet?.currency,
                        decimals: wallet?.decimals,
                        addCurrencyName: true,
                      );
                    },
              initial: selectedWallet,
              onChanged: (Object? object) {
                TransactionWallet? wallet;
                if (object is WalletWithDetails) wallet = object.wallet;
                popRoute(context, wallet);
              },
              onLongPress: (Object? object) {
                TransactionWallet? wallet;
                if (object is WalletWithDetails) wallet = object.wallet;
                if (allowEditWallet)
                  pushRoute(
                    context,
                    AddWalletPage(
                      routesToPopAfterDelete: allowDeleteWallet == false
                          ? RoutesToPopAfterDelete.PreventDelete
                          : RoutesToPopAfterDelete.One,
                      wallet: wallet,
                    ),
                  );
              },
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    ),
  );

  if (wallet is TransactionWallet) return wallet;
  return null;
}

class ShowAccountLabelSettingToggle extends StatelessWidget {
  const ShowAccountLabelSettingToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "account-label".tr(),
      description: "account-label-description".tr(),
      onSwitched: (value) {
        updateSettings("showAccountLabelTagInTransactionEntry", value,
            updateGlobalState: true);
      },
      initialValue: appStateSettings["showAccountLabelTagInTransactionEntry"],
      icon: appStateSettings["outlinedIcons"]
          ? Icons.label_outlined
          : Icons.label_rounded,
    );
  }
}

class ShowCurrencyLabelSettingToggle extends StatelessWidget {
  const ShowCurrencyLabelSettingToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedExpanded(
      expand:
          Provider.of<AllWallets>(context).allContainSameCurrency() == false,
      child: SettingsContainerSwitch(
        title: "currency-label".tr(),
        description: "currency-label-description".tr(),
        onSwitched: (value) {
          updateSettings("showCurrencyLabel", value, updateGlobalState: true);
        },
        initialValue: appStateSettings["showCurrencyLabel"] == true,
        icon: appStateSettings["outlinedIcons"]
            ? Symbols.event_list_sharp
            : Symbols.event_list_rounded,
      ),
    );
  }
}

class ExchangeRateSettingPage extends StatelessWidget {
  const ExchangeRateSettingPage({this.backgroundColor, super.key});
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SettingsContainerOpenPage(
      backgroundColor: backgroundColor,
      onOpen: () {
        checkIfExchangeRateChangeBefore();
      },
      onClosed: () {
        checkIfExchangeRateChangeAfter();
      },
      openPage: ExchangeRates(),
      title: "exchange-rates".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.account_balance_wallet_outlined
          : Icons.account_balance_wallet_rounded,
    );
  }
}

class PrimaryCurrencySetting extends StatelessWidget {
  const PrimaryCurrencySetting({super.key});

  @override
  Widget build(BuildContext context) {
    VoidCallback changeCurrencyPopup = () => openPopup(
          context,
          title: "change-currency".tr(),
          icon: appStateSettings["outlinedIcons"]
              ? Icons.card_membership_outlined
              : Icons.card_membership_rounded,
          description: "change-currency-description".tr(),
          onSubmit: () {
            popRoute(context);
          },
          onSubmitLabel: "ok".tr(),
        );
    return SettingsContainerOpenPage(
      title: "primary-currency".tr().capitalizeFirst,
      icon: appStateSettings["outlinedIcons"]
          ? Icons.card_membership_outlined
          : Icons.card_membership_rounded,
      afterWidget: Tappable(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: 10,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16, vertical: 10),
          child: Builder(builder: (context) {
            return TextFont(
              text: (Provider.of<AllWallets>(context)
                      .indexedByPk[appStateSettings["selectedWalletPk"]]
                      ?.currency
                      ?.allCaps) ??
                  "",
              fontSize: 14,
            );
          }),
        ),
      ),
      openPage: Provider.of<AllWallets>(context).indexedByPk.length > 1
          ? EditWalletsPage(
              runWhenOpen: changeCurrencyPopup,
            )
          : AddWalletPage(
              runWhenOpen: changeCurrencyPopup,
              routesToPopAfterDelete: RoutesToPopAfterDelete.PreventDelete,
              wallet: Provider.of<AllWallets>(context)
                  .indexedByPk[appStateSettings["selectedWalletPk"]],
            ),
    );
  }
}

class WalletsSettings extends StatelessWidget {
  const WalletsSettings({this.backgroundColor, super.key});
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShowAccountLabelSettingToggle(),
        ShowCurrencyLabelSettingToggle(),
        ExchangeRateSettingPage(backgroundColor: backgroundColor),
      ],
    );
  }
}
