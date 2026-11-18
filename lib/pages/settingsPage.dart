import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart' hide AppSettings;
import 'package:budget/pages/aboutPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/billSplitter.dart';
import 'package:budget/pages/budgetsListPage.dart';
import 'package:budget/pages/creditDebtTransactionsPage.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/editObjectivesPage.dart';
import 'package:budget/pages/homePage/homePageNetWorth.dart';
import 'package:budget/pages/objectivesListPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/pages/upcomingOverdueTransactionsPage.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/struct/defaultPreferences.dart';
import 'package:budget/struct/languageMap.dart';
import 'package:budget/struct/navBarIconsData.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/exportDB.dart';
import 'package:budget/widgets/importCSV.dart';
import 'package:budget/widgets/exportCSV.dart';
import 'package:budget/pages/autoTransactionsPageEmail.dart';
import 'package:budget/pages/activityPage.dart';
import 'package:budget/pages/editAssociatedTitlesPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/pages/editWalletsPage.dart';
import 'package:budget/pages/notificationsPage.dart';
import 'package:budget/pages/managePinnedTransactionsPage.dart';
import 'package:budget/pages/initialInputPromptsPage.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/importDB.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/restartApp.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/struct/initializeBiometrics.dart';
import 'package:budget/widgets/sliderSelector.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/util/checkWidgetLaunch.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:app_settings/app_settings.dart';
import 'package:budget/widgets/outlinedButtonStacked.dart';

//To get SHA1 Key run
// ./gradlew signingReport
//in budget\Android
//Generate new OAuth and put JSON in budget\android\app folder

class MoreActionsPage extends StatefulWidget {
  const MoreActionsPage({
    Key? key,
  }) : super(key: key);

  @override
  State<MoreActionsPage> createState() => MoreActionsPageState();
}

class MoreActionsPageState extends State<MoreActionsPage> {
  GlobalKey<PageFrameworkState> pageState = GlobalKey();

  void refreshState() {
    print("refresh settings");
    setState(() {});
  }

  void scrollToTop() {
    pageState.currentState?.scrollToTop();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, _) {
      return PageFramework(
        key: pageState,
        title: "more-actions".tr(),
        backButton: false,
        horizontalPaddingConstrained: true,
        actions: [
          CustomPopupMenuButton(
            showButtons: true,
            keepOutFirst: true,
            items: [
              if (appStateSettings["showFAQAndHelpLink"] == true)
                DropdownItemMenu(
                  id: "open-faq",
                  label: "faq".tr(),
                  icon: appStateSettings["outlinedIcons"]
                      ? Icons.live_help_outlined
                      : Icons.live_help_rounded,
                  action: () {
                    openUrl("https://cashewapp.web.app/faq.html");
                  },
                ),
            ],
          ),
        ],
        listWidgets: [
          MorePages()
        ],
      );
    });
  }
}

class MorePages extends StatelessWidget {
  const MorePages({super.key});

  @override
  Widget build(BuildContext context) {
    bool hasSideNavigation = getIsFullScreen(context);

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
      child: Column(
        children: [
          if (hasSideNavigation == false)
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: SettingsContainerOpenPage(
                    openPage: SettingsPageFramework(
                      key: settingsPageFrameworkStateKey,
                    ),
                    title: navBarIconsData["settings"]!.labelLong.tr(),
                    icon: navBarIconsData["settings"]!.iconData,
                    description: appStateSettings["showExtraInfoText"] == false
                        ? null
                        : "settings-and-customization-description".tr(),
                    isOutlined: true,
                    // description: "Theme, Language, CSV Import",
                    isWideOutlined: true,
                  ),
                ),
              ],
            ),
          if (hasSideNavigation == false)
            Row(
              children: [
                Expanded(
                  child: SettingsContainerOpenPage(
                    openPage: WalletDetailsPage(wallet: null),
                    title: navBarIconsData["allSpending"]!.labelLong.tr(),
                    icon: navBarIconsData["allSpending"]!.iconData,
                    description: appStateSettings["showExtraInfoText"] == false
                        ? null
                        : "all-spending-description".tr(),
                    isOutlined: true,
                    isWideOutlined: true,
                  ),
                ),
              ],
            ),
            if (hasSideNavigation == false) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: SettingsContainerOpenPage(
                      openPage: AboutPage(),
                      title: "about-app".tr(namedArgs: {"app": globalAppName}),
                      icon: navBarIconsData["about"]!.iconData,
                      isOutlined: true,
                    ),
                  ),
                  Expanded(
                    child: GoogleAccountLoginButton(
                      key: settingsGoogleAccountLoginButtonKey,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: SettingsContainerOpenPage(
                      openPage: SubscriptionsPage(),
                      title: navBarIconsData["subscriptions"]!.label.tr(),
                      icon: navBarIconsData["subscriptions"]!.iconData,
                      isOutlined: true,
                    ),
                  ),
                  Expanded(
                    child: SettingsContainerOpenPage(
                      openPage:
                          UpcomingOverdueTransactions(overdueTransactions: null),
                      title: navBarIconsData["scheduled"]!.label.tr(),
                      icon: navBarIconsData["scheduled"]!.iconData,
                      isOutlined: true,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: SettingsContainerOpenPage(
                      openPage: ActivityPage(),
                      title: "activity-log".tr() != "activity-log"
                          ? "activity-log".tr()
                          : "Activity Log",
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.ballot_outlined
                          : Icons.ballot_rounded,
                      isOutlined: true,
                    ),
                  ),
                  Expanded(
                    child: SettingsContainerOpenPage(
                      openPage: BillSplitter(),
                      title: "bill-splitter".tr(),
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.summarize_outlined
                          : Icons.summarize_rounded,
                      isOutlined: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const EditDataGrid(),
            ],
            if (hasSideNavigation) SettingsPageContent(),
        ],
      ),
    );
  }
}

class EditDataGrid extends StatelessWidget {
  const EditDataGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 14,
            end: 14,
            top: 14,
            bottom: 6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFont(
                text: "edit-delete-and-reorder-data".tr() !=
                        "edit-delete-and-reorder-data"
                    ? "edit-delete-and-reorder-data".tr()
                    : "Edit, Delete, and Reorder Data",
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 2),
              TextFont(
                text: "edit-delete-and-reorder-data-description".tr() !=
                        "edit-delete-and-reorder-data-description"
                    ? "edit-delete-and-reorder-data-description".tr()
                    : "For accounts, categories, budgets, goals, loans",
                fontSize: 13,
                maxLines: 2,
                textColor:
                    Theme.of(context).colorScheme.secondary.withOpacity(0.6),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: SettingsContainerOpenPage(
                isOutlinedColumn: true,
                openPage: EditWalletsPage(),
                title: navBarIconsData["accountDetails"]!.label.tr(),
                icon: navBarIconsData["accountDetails"]!.iconData,
                isOutlined: true,
              ),
            ),
            Expanded(
              child: SettingsContainerOpenPage(
                isOutlinedColumn: true,
                openPage: EditCategoriesPage(),
                title: navBarIconsData["categoriesDetails"]!.label.tr(),
                icon: navBarIconsData["categoriesDetails"]!.iconData,
                isOutlined: true,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: SettingsContainerOpenPage(
                isOutlinedColumn: true,
                openPage: appStateSettings["customNavBarShortcut0"] !=
                            "budgets" &&
                        appStateSettings["customNavBarShortcut1"] !=
                            "budgets" &&
                        appStateSettings["customNavBarShortcut2"] !=
                            "budgets"
                    ? BudgetsListPage(enableBackButton: true)
                    : EditBudgetPage(),
                title: navBarIconsData["budgetDetails"]!.label.tr(),
                icon: navBarIconsData["budgetDetails"]!.iconData,
                iconScale: navBarIconsData["budgetDetails"]!.iconScale,
                isOutlined: true,
              ),
            ),
            Expanded(
              child: SettingsContainerOpenPage(
                isOutlinedColumn: true,
                openPage: EditObjectivesPage(
                  objectiveType: ObjectiveType.goal,
                ),
                title: navBarIconsData["goals"]!.label.tr(),
                icon: navBarIconsData["goals"]!.iconData,
                isOutlined: true,
              ),
            ),
            Expanded(
              child: SettingsContainerOpenPage(
                isOutlinedColumn: true,
                openPage: EditObjectivesPage(
                  objectiveType: ObjectiveType.loan,
                ),
                title: navBarIconsData["loans"]!.label.tr(),
                icon: navBarIconsData["loans"]!.iconData,
                isOutlined: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class EnterName extends StatelessWidget {
  const EnterName({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsContainer(
      title: "username".tr(),
      icon: Icons.edit,
      onTap: () {
        enterNameBottomSheet(context);
      },
    );
  }
}

Future<String> enterNameBottomSheet(context,
    {bool updatePageWhenSet = true}) async {
  return await openBottomSheet(
    context,
    popupWithKeyboard: true,
    PopupFramework(
      title: "enter-name".tr(),
      child: SelectText(
        buttonLabel: "set-name".tr(),
        icon: appStateSettings["outlinedIcons"]
            ? Icons.person_outlined
            : Icons.person_rounded,
        setSelectedText: (_) {},
        nextWithInput: (text) {
          updateSettings("username", text.trim(),
              pagesNeedingRefresh: updatePageWhenSet ? [0] : [],
              updateGlobalState: false);
        },
        selectedText: appStateSettings["username"],
        placeholder: "nickname".tr(),
        autoFocus: true,
      ),
    ),
  );
}

class SettingsPageFramework extends StatefulWidget {
  const SettingsPageFramework({super.key});

  @override
  State<SettingsPageFramework> createState() => SettingsPageFrameworkState();
}

class SettingsPageFrameworkState extends State<SettingsPageFramework> {
  void refreshState() {
    print("refresh settings framework");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      title: "settings".tr(),
      dragDownToDismiss: true,
      listWidgets: [SettingsPageContent()],
    );
  }
}

class SettingsHubCard extends StatelessWidget {
  const SettingsHubCard({required this.children, super.key});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    Color containerColor = Theme.of(context).brightness == Brightness.light
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF1E293B); // Slate 800

    return Padding(
      padding:
          const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }
}

class SettingsHubItem extends StatelessWidget {
  const SettingsHubItem({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      borderRadius: 0,
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: 18,
          end: 18,
          top: subtitle != null ? 14 : 16,
          bottom: subtitle != null ? 14 : 16,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 26,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFont(
                    text: title,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    TextFont(
                      text: subtitle!,
                      fontSize: 12.5,
                      maxLines: 2,
                      textColor: appStateSettings["increaseTextContrast"]
                          ? getColor(context, "textLight")
                          : Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.6),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class AccentColorSetting extends StatelessWidget {
  const AccentColorSetting({super.key});

  @override
  Widget build(BuildContext context) {
    late Color? selectedColor = HexColor(appStateSettings["accentColor"]);
    return SettingsContainer(
      onTap: () {
        openBottomSheet(
          context,
          useParentContextForTheme: false,
          PopupFramework(
            title: "select-color".tr(),
            child: Column(
              children: [
                getPlatform() == PlatformOS.isIOS
                    ? Padding(
                        padding: const EdgeInsetsDirectional.only(bottom: 8.0),
                        child: SettingsContainerSwitch(
                          title: "colorful-interface".tr(),
                          onSwitched: (value) {
                            updateSettings("materialYou", value,
                                updateGlobalState: true);
                          },
                          initialValue: appStateSettings["materialYou"],
                          icon: appStateSettings["outlinedIcons"]
                              ? Icons.brush_outlined
                              : Icons.brush_rounded,
                          enableBorderRadius: true,
                        ),
                      )
                    : const SizedBox.shrink(),
                SelectColor(
                  selectableColorsList: selectableAccentColors(context),
                  includeThemeColor: false,
                  selectedColor: selectedColor,
                  setSelectedColor: (color) {
                    selectedColor = color;
                    updateSettings("accentColor", toHexString(color),
                        updateGlobalState: true);
                    updateSettings("accentSystemColor", false,
                        updateGlobalState: true);
                    updateWidgetColorsAndText(context);
                  },
                  useSystemColorPrompt: true,
                ),
              ],
            ),
          ),
        );
      },
      title: "accent-color".tr(),
      description: "accent-color-description".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.color_lens_outlined
          : Icons.color_lens_rounded,
    );
  }
}

class MaterialYouSetting extends StatelessWidget {
  const MaterialYouSetting({super.key});

  @override
  Widget build(BuildContext context) {
    if (getPlatform() == PlatformOS.isIOS) return const SizedBox.shrink();
    return SettingsContainerSwitch(
      title: "material-you".tr(),
      description: "material-you-description".tr(),
      onSwitched: (value) {
        updateSettings("materialYou", value, updateGlobalState: true);
      },
      initialValue: appStateSettings["materialYou"],
      icon: appStateSettings["outlinedIcons"]
          ? Icons.brush_outlined
          : Icons.brush_rounded,
    );
  }
}

class LanguageSetting extends StatelessWidget {
  const LanguageSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainer(
      title: "language".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.language_outlined
          : Icons.language_rounded,
      afterWidget: Tappable(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: 10,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16, vertical: 10),
          child: TextFont(
            text: languageDisplayFilter(appStateSettings["locale"].toString()),
            fontSize: 14,
          ),
        ),
      ),
      onTap: () {
        openLanguagePicker(context);
      },
    );
  }
}

class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      title: "general-settings".tr(),
      dragDownToDismiss: true,
      horizontalPaddingConstrained: true,
      listWidgets: [
        BiometricsSettingToggle(),
        const NumberPadHapticFeedbackSetting(),
        SettingsContainerOpenPage(
          openPage: EditHomePage(),
          title: "edit-home-page".tr(),
          icon: appStateSettings["outlinedIcons"]
              ? Icons.home_outlined
              : Icons.home_rounded,
        ),
        SettingsContainerSwitch(
          title: "extra-info-text".tr() != "extra-info-text"
              ? "extra-info-text".tr()
              : "Extra Text Guides",
          description: "extra-info-text-description".tr() !=
                  "extra-info-text-description"
              ? "extra-info-text-description".tr()
              : "Display descriptive text across pages to help guide you.",
          icon: appStateSettings["outlinedIcons"]
              ? Icons.help_outline_outlined
              : Icons.help_outline_rounded,
          initialValue: appStateSettings["showExtraInfoText"] ?? true,
          onSwitched: (value) {
            updateSettings("showExtraInfoText", value, updateGlobalState: true);
          },
        ),
        const ScrollBehaviorSetting(),
        const LeftHandedSetting(),
        SettingsHeader(title: "edit-data".tr()),
        const EditDataGrid(),
        const SizedBox(height: 20),
      ],
    );
  }
}

class ThemeAndStyleSettingsPage extends StatelessWidget {
  const ThemeAndStyleSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      title: "theme-and-style".tr(),
      dragDownToDismiss: true,
      horizontalPaddingConstrained: true,
      listWidgets: [
        SettingsHeader(title: "theme".tr()),
        const AccentColorSetting(),
        const MaterialYouSetting(),
        const ThemeSettingsDropdown(),
        SettingsHeader(title: "style".tr()),
        const HeaderHeightSetting(),
        const OutlinedIconsSetting(),
        const CategoryIconPackSetting(),
        const FontPickerSetting(),
        const FontScaleSetting(),
        const LinearProgressBarStyleSetting(),
        const NetTotalStyleSetting(),
        const AppAnimationSetting(),
        const CountingNumberAnimationSetting(),
        const IncreaseTextContrastSetting(),
        const NonCompactTransactionsSetting(),
        const SizedBox(height: 20),
      ],
    );
  }
}

class TransactionsSettingsPage extends StatelessWidget {
  const TransactionsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      title: "transactions".tr(),
      dragDownToDismiss: true,
      horizontalPaddingConstrained: true,
      listWidgets: [
        SettingsHeader(
          title: "layout".tr() != "layout" ? "layout".tr() : "Layout",
        ),
        SettingsContainer(
          icon: appStateSettings["outlinedIcons"]
              ? Icons.table_rows_outlined
              : Icons.table_rows_rounded,
          title: "transactions-list-and-layout".tr() !=
                  "transactions-list-and-layout"
              ? "transactions-list-and-layout".tr()
              : "Transactions List & Layout",
          onTap: () {
            openBottomSheet(
              context,
              fullSnap: true,
              const SelectLayoutBottomSheet(),
            );
          },
        ),
        SettingsHeader(
          title: "add-new-transactions".tr() != "add-new-transactions"
              ? "add-new-transactions".tr()
              : "Add New Transactions",
        ),
        const TransferBalanceTabSetting(),
        const AddAttachmentsButtonSetting(),
        const AutoAddTitlesSetting(),
        SettingsContainerOpenPage(
          openPage: const InitialInputPromptsPage(),
          title: "initial-input-prompts".tr() != "initial-input-prompts"
              ? "initial-input-prompts".tr()
              : "Initial Input Prompts",
          description: "initial-input-prompts-description".tr() !=
                  "initial-input-prompts-description"
              ? "initial-input-prompts-description".tr()
              : "When first adding a transaction",
          icon: appStateSettings["outlinedIcons"]
              ? Icons.edit_note_outlined
              : Icons.edit_note_rounded,
        ),
        SettingsHeader(
          title: "scheduled-transactions".tr() != "scheduled-transactions"
              ? "scheduled-transactions".tr()
              : "Scheduled Transactions",
        ),
        const AutoPayUpcomingSetting(),
        const PaidDateSetting(),
        const ConfirmUpcomingTransactionAmountSetting(),
        SettingsContainerOpenPage(
          openPage: const NotificationsPage(),
          title: "notifications".tr(),
          icon: appStateSettings["outlinedIcons"]
              ? Icons.notifications_outlined
              : Icons.notifications_rounded,
        ),
        SettingsHeader(
          title: "pinned-transactions".tr() != "pinned-transactions"
              ? "pinned-transactions".tr()
              : "Pinned Transactions",
        ),
        SettingsContainerOpenPage(
          openPage: const ManagePinnedTransactionsPage(),
          title: "manage-pinned-transactions".tr() !=
                  "manage-pinned-transactions"
              ? "manage-pinned-transactions".tr()
              : "Manage Pinned Transactions",
          icon: appStateSettings["outlinedIcons"]
              ? Icons.push_pin_outlined
              : Icons.push_pin_rounded,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class LocalizationSettingsPage extends StatelessWidget {
  const LocalizationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      title: "${'localization'.tr()} & ${'formatting'.tr()}",
      dragDownToDismiss: true,
      horizontalPaddingConstrained: true,
      listWidgets: [
        SettingsHeader(title: "localization".tr()),
        const LanguageSetting(),
        const PrimaryCurrencySetting(),
        SettingsHeader(title: "formatting".tr()),
        const NumberFormattingSetting(),
        const PercentagePrecisionSetting(),
        const Time24HourFormatSetting(),
        const DateFormatSetting(),
        const DatePickerTypeSetting(),
        const FirstDayOfWeekSetting(updateHomePage: true),
        const NumberPadFormatSetting(),
        const ExtraZerosButtonSetting(),
        const SizedBox(height: 20),
      ],
    );
  }
}

class ImportExportSettingsPage extends StatelessWidget {
  const ImportExportSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      title: "import-and-export".tr(),
      dragDownToDismiss: true,
      horizontalPaddingConstrained: true,
      listWidgets: [
        SettingsHeader(title: "import-and-export".tr()),
        const ExportCSV(),
        const ImportCSV(),
        SettingsHeader(title: "backups".tr()),
        const ExportDB(),
        const ImportDB(),
        GoogleAccountLoginButton(
          isOutlinedButton: false,
          forceButtonName: "google-drive".tr(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class ExperimentalFeaturesSettingsPage extends StatelessWidget {
  const ExperimentalFeaturesSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      title: "experimental-features".tr(),
      dragDownToDismiss: true,
      horizontalPaddingConstrained: true,
      listWidgets: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
              start: 20, end: 20, top: 10, bottom: 15),
          child: TextFont(
            text: "experimental-features-description".tr(),
            fontSize: 14,
            maxLines: 10,
            textColor: getColor(context, "textLight"),
          ),
        ),
        SettingsContainerSwitch(
          title: "auto-email-transactions".tr(),
          description: "auto-email-transactions-description".tr() !=
                  "auto-email-transactions-description"
              ? "auto-email-transactions-description".tr()
              : null,
          icon: appStateSettings["outlinedIcons"]
              ? Icons.mark_email_unread_outlined
              : Icons.mark_email_unread_rounded,
          initialValue: appStateSettings["emailScanning"] == true,
          onSwitched: (value) {
            updateSettings("emailScanning", value, updateGlobalState: true);
          },
        ),
        if (appStateSettings["emailScanning"] == true)
          SettingsContainerOpenPage(
            openPage: AutoTransactionsPageEmail(),
            title: "auto-email-transactions".tr(),
            icon: appStateSettings["outlinedIcons"]
                ? Icons.email_outlined
                : Icons.email_rounded,
          ),
        if (getPlatform(ignoreEmulation: true) == PlatformOS.isAndroid) ...[
          SettingsContainerSwitch(
            title: "Notification Transactions",
            icon: appStateSettings["outlinedIcons"]
                ? Icons.edit_notifications_outlined
                : Icons.edit_notifications_rounded,
            initialValue:
                appStateSettings["notificationScanningDebug"] == true,
            onSwitched: (value) {
              updateSettings("notificationScanningDebug", value,
                  updateGlobalState: true);
            },
          ),
          if (appStateSettings["notificationScanningDebug"] == true)
            SettingsContainerOpenPage(
              title: "Notification Transactions",
              openPage: const AutoTransactionsPageNotifications(),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_active_rounded,
            ),
        ],
        const BillSplitterShortcutSetting(),
        const SizedBox(height: 20),
      ],
    );
  }
}

class SettingsPageContent extends StatelessWidget {
  const SettingsPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        SettingsHubCard(
          children: [
            SettingsHubItem(
              title: "general-settings".tr(),
              subtitle: "general-settings-description".tr(),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.settings_outlined
                  : Icons.settings_rounded,
              onTap: () {
                pushRoute(context, const GeneralSettingsPage());
              },
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: getColor(context, "dividerColor"),
            ),
            SettingsHubItem(
              title: "theme-and-style".tr(),
              subtitle: "theme-and-style-description".tr(),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.palette_outlined
                  : Icons.palette_rounded,
              onTap: () {
                pushRoute(context, const ThemeAndStyleSettingsPage());
              },
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: getColor(context, "dividerColor"),
            ),
            SettingsHubItem(
              title: "transactions".tr(),
              subtitle: "transactions-settings-description".tr(),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.dashboard_outlined
                  : Icons.dashboard_rounded,
              onTap: () {
                pushRoute(context, const TransactionsSettingsPage());
              },
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: getColor(context, "dividerColor"),
            ),
            SettingsHubItem(
              title: "${'localization'.tr()} & ${'formatting'.tr()}",
              subtitle: "localization-description".tr(),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.language_outlined
                  : Icons.language_rounded,
              onTap: () {
                pushRoute(context, const LocalizationSettingsPage());
              },
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: getColor(context, "dividerColor"),
            ),
            SettingsHubItem(
              title: "notifications".tr(),
              subtitle: "notifications-settings-description".tr(),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.notifications_outlined
                  : Icons.notifications_rounded,
              onTap: () {
                pushRoute(context, const NotificationsPage());
              },
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: getColor(context, "dividerColor"),
            ),
            SettingsHubItem(
              title: "import-and-export".tr(),
              subtitle: "import-and-export-settings-description".tr(),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.save_outlined
                  : Icons.save_rounded,
              onTap: () {
                pushRoute(context, const ImportExportSettingsPage());
              },
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: getColor(context, "dividerColor"),
            ),
            SettingsHubItem(
              title: "about-app".tr(namedArgs: {"app": globalAppName}),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.info_outline
                  : Icons.info_rounded,
              onTap: () {
                pushRoute(context, const AboutPage());
              },
            ),
          ],
        ),
        SettingsHeader(title: "tools-and-extras".tr()),
        SettingsHubCard(
          children: [
            SettingsHubItem(
              title: "bill-splitter".tr(),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.receipt_long_outlined
                  : Icons.receipt_long_rounded,
              onTap: () {
                pushRoute(context, const BillSplitter());
              },
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: getColor(context, "dividerColor"),
            ),
            SettingsHubItem(
              title: "advanced-automation".tr(),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.view_in_ar_outlined
                  : Icons.view_in_ar_rounded,
              trailing: Icon(
                appStateSettings["outlinedIcons"]
                    ? Icons.open_in_new_outlined
                    : Icons.open_in_new_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
              ),
              onTap: () {
                openUrl(
                    "https://github.com/jameskokoska/Cashew?tab=readme-ov-file#app-links");
              },
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: getColor(context, "dividerColor"),
            ),
            SettingsHubItem(
              title: "experimental-features".tr(),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.science_outlined
                  : Icons.science_rounded,
              onTap: () {
                pushRoute(context, const ExperimentalFeaturesSettingsPage());
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class ThemeSettingsDropdown extends StatefulWidget {
  const ThemeSettingsDropdown({super.key});

  @override
  State<ThemeSettingsDropdown> createState() => _ThemeSettingsDropdownState();
}

class _ThemeSettingsDropdownState extends State<ThemeSettingsDropdown> {
  @override
  Widget build(BuildContext context) {
    return SettingsContainerDropdown(
      key: ValueKey(appStateSettings["materialYou"].toString()),
      title: "theme-mode".tr(),
      icon: Theme.of(context).brightness == Brightness.light
          ? appStateSettings["outlinedIcons"]
              ? Icons.lightbulb_outlined
              : Icons.lightbulb_rounded
          : appStateSettings["outlinedIcons"]
              ? Icons.dark_mode_outlined
              : Icons.dark_mode_rounded,
      initial: appStateSettings["theme"].toString() == "black" &&
              appStateSettings["materialYou"] == false
          ? "dark"
          : appStateSettings["theme"].toString(),
      items: [
        "system",
        "light",
        "dark",
        if (appStateSettings["materialYou"] == true) "black"
      ],
      faintValues: [
        if (appStateSettings["materialYou"] == true &&
            appStateSettings["theme"].toString() == "system")
          appStateSettings["forceFullDarkBackground"] == true ? "dark" : "black"
      ],
      onChanged: (value) async {
        if (value == "black") {
          await updateSettings("forceFullDarkBackground", true,
              updateGlobalState: false);
        } else if (value == "dark") {
          await updateSettings("forceFullDarkBackground", false,
              updateGlobalState: false);
        }
        setState(() {});
        await updateSettings("theme", value, updateGlobalState: true);
        updateWidgetColorsAndText(context);
      },
      getLabel: (item) {
        return item.tr();
      },
    );
  }
}

class MoreOptionsPagePreferences extends StatelessWidget {
  const MoreOptionsPagePreferences({super.key});

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      title: "more".tr(),
      dragDownToDismiss: true,
      horizontalPaddingConstrained: true,
      listWidgets: [
        SettingsHeader(title: "style".tr()),
        HeaderHeightSetting(),
        OutlinedIconsSetting(),
        CategoryIconPackSetting(),
        FontPickerSetting(),
        FontScaleSetting(),
        LinearProgressBarStyleSetting(),
        NetTotalStyleSetting(),
        AppAnimationSetting(),
        CountingNumberAnimationSetting(),
        IncreaseTextContrastSetting(),
        NonCompactTransactionsSetting(),
        ScrollBehaviorSetting(),
        LeftHandedSetting(),
        SettingsHeader(title: "transactions".tr()),
        TransactionsSettings(),
        SelectTransactionTypeBeforeAddingSetting(),
        DefaultTransactionTypeSetting(),
        IncognitoKeyboardSetting(),
        BatterySaverSetting(),
        SettingsHeader(title: "accounts".tr()),
        WalletsSettings(),
        PrimaryCurrencySetting(),
        LongTermLoansDifferenceSetting(),
        CountBalanceCorrectionInSummarySetting(),
        SettingsHeader(title: "budgets".tr()),
        BudgetSettings(),
        SettingsHeader(title: "goals".tr()),
        ObjectiveSettings(),
        SettingsHeader(title: "titles".tr()),
        TitlesSettings(),
        SettingsHeader(title: "widgets".tr()),
        WidgetSettings(),
        SettingsHeader(title: "formatting".tr()),
        NumberFormattingSetting(),
        PercentagePrecisionSetting(),
        Time24HourFormatSetting(),
        DateFormatSetting(),
        FirstDayOfWeekSetting(updateHomePage: true),
        NumberPadFormatSetting(),
      ],
    );
  }
}

class WidgetSettings extends StatelessWidget {
  const WidgetSettings({super.key});

  @override
  Widget build(BuildContext context) {
    if (getPlatform(ignoreEmulation: true) != PlatformOS.isAndroid)
      return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsContainer(
          title: "net-worth-total-widget".tr(),
          description: "select-accounts-and-time-period".tr(),
          onTap: () async {
            await openNetWorthSettings(context);
            // We need to resfresh the widget rendering since it exists on the homepage!
            homePageStateKey.currentState?.refreshState();
          },
          icon: appStateSettings["outlinedIcons"]
              ? Icons.area_chart_outlined
              : Icons.area_chart_rounded,
        ),
        SettingsContainerDropdown(
          title: "widget-theme".tr(),
          icon: appStateSettings["outlinedIcons"]
              ? Icons.contrast_outlined
              : Icons.contrast_rounded,
          initial: appStateSettings["widgetTheme"].toString(),
          items: ["app", "light", "dark"],
          onChanged: (value) async {
            if (value == "app") value = "system";
            await updateSettings("widgetTheme", value,
                updateGlobalState: false);
            updateWidgetColorsAndText(context);
          },
          getLabel: (item) {
            return item.tr();
          },
        ),
        SettingsContainer(
          title: "widget-background-opacity".tr(),
          icon: appStateSettings["outlinedIcons"]
              ? Icons.blur_on_outlined
              : Icons.blur_on_rounded,
          descriptionWidget: Container(
            height: 28,
            padding: EdgeInsetsDirectional.only(end: 10),
            child: SliderTheme(
              data: SliderThemeData(
                trackShape: CustomTrackShape(),
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 9),
              ),
              child: SliderSelector(
                min: 0,
                max: 1,
                initialValue:
                    (appStateSettings["widgetOpacity"] ?? 1).toDouble(),
                onChange: (value) {},
                divisions: 20,
                onFinished: (value) {
                  updateSettings("widgetOpacity", value,
                      updateGlobalState: false);
                  updateWidgetColorsAndText(context);
                },
                displayFilter: (double number) {
                  return convertToPercent(number * 100, numberDecimals: 0);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight;
    final trackLeft = offset.dx;
    final trackTop =
        offset.dy + (parentBox.size.height - (trackHeight ?? 0)) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, (trackHeight ?? 0));
  }
}

class BiometricsSettingToggle extends StatefulWidget {
  const BiometricsSettingToggle({super.key});

  @override
  State<BiometricsSettingToggle> createState() =>
      _BiometricsSettingToggleState();
}

class _BiometricsSettingToggleState extends State<BiometricsSettingToggle> {
  bool isLocked = appStateSettings["requireAuth"];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        authAvailable || isLocked
            ? SettingsContainerSwitch(
                title: "biometric-lock".tr(),
                description: "biometric-lock-description".tr(),
                onSwitched: (value) async {
                  AuthResult authResult =
                      await checkBiometrics(checkAlways: true);
                  if (authResult == AuthResult.error) {
                    openPopup(
                      context,
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.warning_outlined
                          : Icons.warning_rounded,
                      title: getPlatform() == PlatformOS.isIOS
                          ? "biometrics-disabled".tr()
                          : "biometrics-error".tr(),
                      description: getPlatform() == PlatformOS.isIOS
                          ? "biometrics-disabled-description".tr()
                          : "biometrics-error-description".tr(),
                      onCancelLabel:
                          getPlatform() == PlatformOS.isIOS ? "ok".tr() : null,
                      onCancel: () {
                        popRoute(context);
                      },
                      onSubmitLabel: getPlatform() == PlatformOS.isIOS
                          ? "open-settings".tr()
                          : "ok".tr(),
                      onSubmit: () {
                        updateSettings("requireAuth", false,
                            updateGlobalState: false);
                        setState(() {
                          isLocked = false;
                        });
                        popRoute(context);
                        // On iOS the notification app settings page also has
                        // the permission for biometrics
                        if (getPlatform() == PlatformOS.isIOS) {
                          AppSettings.openAppSettings(
                              type: AppSettingsType.notification);
                        }
                      },
                    );
                  } else if (authResult == AuthResult.authenticated) {
                    updateSettings("requireAuth", value,
                        updateGlobalState: false);
                    setState(() {
                      isLocked = value;
                    });
                  }
                  return authResult == AuthResult.authenticated;
                },
                initialValue: isLocked,
                icon: isLocked
                    ? appStateSettings["outlinedIcons"]
                        ? Icons.lock_outlined
                        : Icons.lock_rounded
                    : appStateSettings["outlinedIcons"]
                        ? Icons.lock_open_outlined
                        : Icons.lock_open_rounded,
              )
            : SizedBox.shrink(),
        if (isLocked)
          SettingsContainerSwitch(
            title: "Auto-lock when app is closed",
            description: "Require authentication after leaving the app",
            initialValue:
                appStateSettings["biometricAutoLockOnBackground"] == true,
            icon: appStateSettings["outlinedIcons"]
                ? Icons.lock_clock_outlined
                : Icons.lock_clock_rounded,
            onSwitched: (value) async {
              await updateSettings("biometricAutoLockOnBackground", value,
                  updateGlobalState: false);
              return true;
            },
          ),
      ],
    );
  }
}

class HeaderHeightSetting extends StatelessWidget {
  const HeaderHeightSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedExpanded(
      // Indicates if it is enabled by default per device height
      expand: MediaQuery.sizeOf(context).height > MIN_HEIGHT_FOR_HEADER &&
          getPlatform() != PlatformOS.isIOS,
      child: SettingsContainerDropdown(
        title: "header-height".tr(),
        icon: appStateSettings["outlinedIcons"]
            ? Icons.subtitles_outlined
            : Icons.subtitles_rounded,
        initial: appStateSettings["forceSmallHeader"].toString(),
        items: ["true", "false"],
        onChanged: (value) async {
          bool boolValue = false;
          if (value == "true") {
            boolValue = true;
          } else if (value == "false") {
            boolValue = false;
          }
          await updateSettings(
            "forceSmallHeader",
            boolValue,
            updateGlobalState: false,
            setStateAllPageFrameworks: true,
            pagesNeedingRefresh: [0],
          );
        },
        getLabel: (item) {
          if (item == "true") return "short".tr();
          if (item == "false") return "tall".tr();
        },
      ),
    );
  }
}

// Changing this setting needs to update the UI, that's not something that happens when setting global state
class OutlinedIconsSetting extends StatelessWidget {
  const OutlinedIconsSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerDropdown(
      items: ["rounded", "outlined"],
      onChanged: (value) async {
        if (value == "rounded") {
          await updateSettings("outlinedIcons", false,
              updateGlobalState: false);
        } else {
          await updateSettings(
            "outlinedIcons",
            true,
            updateGlobalState: false,
          );
        }
        navBarIconsData = getNavBarIconsData();
        RestartApp.restartApp(context);
      },
      getLabel: (value) {
        return value.tr();
      },
      initial:
          appStateSettings["outlinedIcons"] == true ? "outlined" : "rounded",
      title: "icon-style".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.star_outline
          : Icons.star_rounded,
    );
  }
}

class CountingNumberAnimationSetting extends StatelessWidget {
  const CountingNumberAnimationSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerDropdown(
      title: "number-animation".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.pin_outlined
          : Icons.pin_rounded,
      initial: appStateSettings["numberCountUpAnimation"] == true
          ? "count-up"
          : "disabled",
      items: ["count-up", "disabled"],
      onChanged: (value) async {
        await updateSettings(
          "numberCountUpAnimation",
          value == "count-up" ? true : false,
          updateGlobalState: false,
        );
      },
      getLabel: (item) {
        return item.tr();
      },
    );
  }
}

class AppAnimationSetting extends StatelessWidget {
  const AppAnimationSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerDropdown(
      title: "app-animations".tr(),
      description: "app-animations-description".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.animation_outlined
          : Icons.animation_rounded,
      initial: appStateSettings["appAnimations"] == AppAnimations.all.index
          ? "all"
          : appStateSettings["appAnimations"] == AppAnimations.minimal.index
              ? "minimal"
              : appStateSettings["appAnimations"] ==
                      AppAnimations.disabled.index
                  ? "disabled"
                  : "all",
      items: ["all", "minimal"], // "disabled" is not yet supported
      onChanged: (value) async {
        await updateSettings(
          "appAnimations",
          value == "all"
              ? AppAnimations.all.index
              : value == "minimal"
                  ? AppAnimations.minimal.index
                  : value == "disabled"
                      ? AppAnimations.disabled.index
                      : "all",
          updateGlobalState: false,
          setStateAllPageFrameworks: true,
        );
        appStateKey.currentState?.refreshAppState();
      },
      getLabel: (item) {
        return item.tr();
      },
    );
  }
}

class IncreaseTextContrastSetting extends StatelessWidget {
  const IncreaseTextContrastSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "increase-text-contrast".tr(),
      description: "increase-text-contrast-description".tr(),
      onSwitched: (value) async {
        await updateSettings("increaseTextContrast", value,
            updateGlobalState: true);
      },
      initialValue: appStateSettings["increaseTextContrast"],
      icon: appStateSettings["outlinedIcons"]
          ? Icons.exposure_outlined
          : Icons.exposure_rounded,
      descriptionColor: appStateSettings["increaseTextContrast"]
          ? getColor(context, "black").withOpacity(0.84)
          : Theme.of(context).colorScheme.secondary.withOpacity(0.45),
    );
  }
}

class FontPickerSetting extends StatelessWidget {
  const FontPickerSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainer(
      title: "font".tr().capitalizeFirst,
      icon: appStateSettings["outlinedIcons"]
          ? Icons.font_download_outlined
          : Icons.font_download_rounded,
      afterWidget: Tappable(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: 10,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16, vertical: 10),
          child: Builder(builder: (context) {
            String displayFontName =
                fontNameDisplayFilter(appStateSettings["font"].toString());
            return TextFont(
              text: displayFontName,
              fontSize: 14,
            );
          }),
        ),
      ),
      onTap: () {
        openFontPicker(context);
      },
    );
  }
}

void openFontPicker(BuildContext context) {
  openBottomSheet(
    context,
    PopupFramework(
      title: "font".tr(),
      child: RadioItems(
        itemsAreFonts: true,
        items: [
          // These values match that of pubspec font family
          "Avenir",
          "DMSans",
          "Metropolis",
          // SF Pro removed - users on iOS can just select Platform font
          // Inter is the font family fallback
          "RobotoCondensed",
          "Inconsolata",
          "(Platform)",
        ],
        initial: appStateSettings["font"].toString(),
        displayFilter: fontNameDisplayFilter,
        onChanged: (value) async {
          updateSettings("font", value, updateGlobalState: true);
          await Future.delayed(Duration(milliseconds: 50));
          popRoute(context);
        },
      ),
    ),
  );
}

String fontNameDisplayFilter(String value) {
  if (value == "Avenir") {
    return "default".tr().capitalizeFirst;
  } else if (value == "(Platform)") {
    return "platform".tr().capitalizeFirst;
  } else if (value == "DMSans") {
    return "DM Sans";
  } else if (value == "RobotoCondensed") {
    return "Roboto Condensed";
  } else if (value == "Inconsolata") {
    return "Inconsolata Monospace";
  }
  return value.toString();
}

class NumberFormattingSetting extends StatelessWidget {
  const NumberFormattingSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainer(
      title: "number-format".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.one_x_mobiledata_outlined
          : Icons.one_x_mobiledata_rounded,
      afterWidget: IgnorePointer(
        child: Tappable(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: 10,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 16, vertical: 10),
            child: TextFont(
              text: convertToMoney(
                Provider.of<AllWallets>(context, listen: true),
                1234.56,
              ),
              fontSize: 14,
            ),
          ),
        ),
      ),
      onTap: () async {
        String originalSetting =
            appStateSettings["customNumberFormat"].toString() +
                appStateSettings["numberFormatDelimiter"].toString() +
                appStateSettings["numberFormatDecimal"].toString() +
                appStateSettings["numberFormatCurrencyFirst"].toString();
        await openBottomSheet(
          context,
          fullSnap: true,
          SetNumberFormatPopup(),
        );
        String newSetting = appStateSettings["customNumberFormat"].toString() +
            appStateSettings["numberFormatDelimiter"].toString() +
            appStateSettings["numberFormatDecimal"].toString() +
            appStateSettings["numberFormatCurrencyFirst"].toString();
        await updateSettings(
          "customNumberFormat",
          appStateSettings["customNumberFormat"],
          updateGlobalState: true,
          forceGlobalStateUpdate: originalSetting != newSetting,
        );
      },
    );
  }
}

class Time24HourFormatSetting extends StatelessWidget {
  const Time24HourFormatSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerDropdown(
      title: "clock-format".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.history_toggle_off_outlined
          : Icons.history_toggle_off_rounded,
      initial: appStateSettings["use24HourFormat"].toString(),
      items: ["system", "12-hour", "24-hour"],
      onChanged: (value) async {
        await updateSettings("use24HourFormat", value, updateGlobalState: true);
      },
      getLabel: (item) {
        return item.tr();
      },
    );
  }
}

class SetNumberFormatPopup extends StatefulWidget {
  const SetNumberFormatPopup({super.key});

  @override
  State<SetNumberFormatPopup> createState() => _SetNumberFormatPopupState();
}

class _SetNumberFormatPopupState extends State<SetNumberFormatPopup> {
  bool customNumberFormat = appStateSettings["customNumberFormat"] == true;

  @override
  Widget build(BuildContext context) {
    AllWallets allWallets = Provider.of<AllWallets>(context);
    return PopupFramework(
      title: "number-format".tr(),
      child: Column(
        children: [
          SettingsContainerSwitch(
            title: "short-number-format".tr(),
            onSwitched: (value) {
              updateSettings(
                "shortNumberFormat",
                value ? "compact" : null,
                updateGlobalState: true,
              );
            },
            initialValue: appStateSettings["shortNumberFormat"] == "compact",
            enableBorderRadius: true,
            icon: appStateSettings["outlinedIcons"]
                ? Icons.one_k_outlined
                : Icons.one_k_rounded,
          ),
          HorizontalBreak(),
          SizedBox(height: 10),
          AnimatedOpacity(
            duration: Duration(milliseconds: 500),
            opacity: customNumberFormat == false ? 1 : 0.5,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButtonStacked(
                    filled: customNumberFormat == false,
                    alignStart: true,
                    alignBeside: true,
                    padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 20, vertical: 20),
                    text: "default".tr(),
                    afterWidget: Padding(
                      padding:
                          const EdgeInsetsDirectional.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextFont(
                            textAlign: TextAlign.center,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            text: convertToMoney(
                              allWallets,
                              -1234.56,
                              forceNonCustomNumberFormat: true,
                              addCurrencyName: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    iconData: appStateSettings["outlinedIcons"]
                        ? Icons.check_circle_outlined
                        : Icons.check_circle_rounded,
                    onTap: () {
                      updateSettings("customNumberFormat", false,
                          updateGlobalState: false);
                      setState(() {
                        customNumberFormat = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 13),
          AnimatedOpacity(
            duration: Duration(milliseconds: 500),
            opacity: customNumberFormat == true ? 1 : 0.5,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButtonStacked(
                    filled: customNumberFormat == true,
                    alignStart: true,
                    alignBeside: true,
                    padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 20, vertical: 20),
                    text: "custom".tr(),
                    afterWidget: CustomNumberFormatPopup(onChangeAnyOption: () {
                      updateSettings("customNumberFormat", true,
                          updateGlobalState: false);
                      setState(() {
                        customNumberFormat = true;
                      });
                    }),
                    iconData: appStateSettings["outlinedIcons"]
                        ? Icons.tune_outlined
                        : Icons.tune_rounded,
                    onTap: () {
                      updateSettings("customNumberFormat", true,
                          updateGlobalState: false);
                      setState(() {
                        customNumberFormat = true;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Tappable(
            borderRadius: 10,
            color: Colors.transparent,
            onTap: () {
              popRoute(context);
              pushRoute(context, EditWalletsPage());
            },
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                  start: 8, end: 8, top: 5, bottom: 5),
              child: TextFont(
                text: "decimal-precision-edit-account-info".tr(),
                fontSize: 14,
                maxLines: 10,
                textColor: getColor(context, "textLight"),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomNumberFormatPopup extends StatefulWidget {
  const CustomNumberFormatPopup({super.key, this.onChangeAnyOption});
  final VoidCallback? onChangeAnyOption;

  @override
  State<CustomNumberFormatPopup> createState() =>
      _CustomNumberFormatPopupState();
}

class _CustomNumberFormatPopupState extends State<CustomNumberFormatPopup> {
  String customDelimiter = appStateSettings["numberFormatDelimiter"];
  String customDecimal = appStateSettings["numberFormatDecimal"];
  bool numberFormatCurrencyFirst =
      appStateSettings["numberFormatCurrencyFirst"];
  @override
  Widget build(BuildContext context) {
    AllWallets allWallets = Provider.of<AllWallets>(context);
    String formattedNumber = convertToMoney(
      allWallets,
      -1234.56,
      forceCustomNumberFormat: true,
      addCurrencyName: true,
      customSymbol: getCurrencyString(allWallets) == ""
          ? "⬚"
          : getCurrencyString(allWallets),
    );
    return Column(
      children: [
        SizedBox(height: 20),
        AnimatedSizeSwitcher(
          child: TextFont(
            key: ValueKey(formattedNumber),
            textAlign: TextAlign.center,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            text: formattedNumber,
          ),
        ),
        SizedBox(height: 30),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SettingsContainer(
                isOutlined: true,
                isOutlinedColumn: true,
                title: "delimiter".tr(),
                icon: appStateSettings["outlinedIcons"]
                    ? Symbols.decimal_decrease_sharp
                    : Symbols.decimal_decrease_rounded,
                onTap: () {
                  if (widget.onChangeAnyOption != null)
                    widget.onChangeAnyOption!();
                  openBottomSheet(
                    context,
                    popupWithKeyboard: true,
                    PopupFramework(
                      title: "set-delimiter".tr(),
                      child: SelectText(
                        maxLength: 5,
                        buttonLabel: "set-delimiter".tr(),
                        popContext: false,
                        setSelectedText: (_) {},
                        placeholder: "delimiter-symbol".tr(),
                        icon: appStateSettings["outlinedIcons"]
                            ? Symbols.decimal_decrease_sharp
                            : Symbols.decimal_decrease_rounded,
                        selectedText: customDelimiter,
                        nextWithInput: (text) async {
                          setState(() {
                            customDelimiter = text;
                          });
                          updateSettings("numberFormatDelimiter", text,
                              updateGlobalState: false);
                          popRoute(context);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: SettingsContainer(
                isOutlined: true,
                isOutlinedColumn: true,
                title: "symbol".tr() +
                    "\n" +
                    (numberFormatCurrencyFirst
                        ? "before".tr().capitalizeFirst
                        : "after".tr().capitalizeFirst),
                icon: appStateSettings["outlinedIcons"]
                    ? Icons.monetization_on_outlined
                    : Icons.monetization_on_rounded,
                onTap: () {
                  if (widget.onChangeAnyOption != null)
                    widget.onChangeAnyOption!();
                  setState(() {
                    numberFormatCurrencyFirst = !numberFormatCurrencyFirst;
                  });
                  updateSettings(
                      "numberFormatCurrencyFirst", numberFormatCurrencyFirst,
                      updateGlobalState: false);
                },
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: SettingsContainer(
                isOutlined: true,
                isOutlinedColumn: true,
                title: "decimal".tr(),
                icon: appStateSettings["outlinedIcons"]
                    ? Symbols.decimal_increase_sharp
                    : Symbols.decimal_increase_rounded,
                onTap: () {
                  if (widget.onChangeAnyOption != null)
                    widget.onChangeAnyOption!();
                  openBottomSheet(
                    context,
                    popupWithKeyboard: true,
                    PopupFramework(
                      title: "set-decimal".tr(),
                      child: SelectText(
                        maxLength: 5,
                        buttonLabel: "set-decimal".tr(),
                        popContext: false,
                        setSelectedText: (_) {},
                        placeholder: "decimal-symbol".tr(),
                        icon: appStateSettings["outlinedIcons"]
                            ? Symbols.decimal_increase_sharp
                            : Symbols.decimal_increase_rounded,
                        selectedText: customDecimal,
                        nextWithInput: (text) async {
                          setState(() {
                            customDecimal = text;
                          });
                          updateSettings("numberFormatDecimal", text,
                              updateGlobalState: false);
                          popRoute(context);
                        },
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ],
    );
  }
}

class NumberPadFormatSetting extends StatelessWidget {
  const NumberPadFormatSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainer(
      title: "number-pad-format".tr(),
      onTap: () {
        openBottomSheet(
          context,
          NumberPadFormatSettingPopup(),
        );
      },
      icon: appStateSettings["outlinedIcons"]
          ? Icons.dialpad_sharp
          : Icons.dialpad_rounded,
    );
  }
}

class NumberPadFormatSettingPopup extends StatefulWidget {
  const NumberPadFormatSettingPopup({super.key});

  @override
  State<NumberPadFormatSettingPopup> createState() =>
      _NumberPadFormatSettingPopupState();
}

class _NumberPadFormatSettingPopupState
    extends State<NumberPadFormatSettingPopup> {
  @override
  Widget build(BuildContext context) {
    return PopupFramework(
      title: "number-pad-format".tr(),
      child: Column(
        children: [
          ExtraZerosButtonSetting(
            enableBorderRadius: true,
            onChange: () {
              setState(() {});
            },
          ),
          NumberPadHapticFeedbackSetting(
            enableBorderRadius: true,
          ),
          HorizontalBreak(),
          SizedBox(height: 10),
          NumberPadFormatPicker(),
        ],
      ),
    );
  }
}

class NumberPadFormatPicker extends StatefulWidget {
  const NumberPadFormatPicker({super.key});

  @override
  State<NumberPadFormatPicker> createState() => _NumberPadFormatPickerState();
}

class _NumberPadFormatPickerState extends State<NumberPadFormatPicker> {
  NumberPadFormat selectedNumberPadFormat = getNumberPadFormat();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: selectedNumberPadFormat == NumberPadFormat.format123
                    ? 1
                    : 0.5,
                child: OutlinedButtonStacked(
                  filled: selectedNumberPadFormat == NumberPadFormat.format123,
                  alignStart: true,
                  alignBeside: true,
                  text: null,
                  afterWidget: IgnorePointer(
                    child: NumberPadAmount(
                      extraWidgetAboveNumbers: null,
                      addToAmount: (_) {},
                      enableDecimal: true,
                      removeToAmount: () {},
                      removeAll: () {},
                      canChange: () => true,
                      enableCalculator: true,
                      padding: EdgeInsetsDirectional.zero,
                      setState: () {},
                      format: NumberPadFormat.format123,
                    ),
                  ),
                  padding: EdgeInsetsDirectional.only(
                      start: 20, end: 15, top: 10, bottom: 15),
                  iconData: null,
                  onTap: () {
                    setState(() {
                      selectedNumberPadFormat = NumberPadFormat.format123;
                    });
                    updateSettings(
                        "numberPadFormat", NumberPadFormat.format123.index,
                        updateGlobalState: false);
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: selectedNumberPadFormat == NumberPadFormat.format789
                    ? 1
                    : 0.5,
                child: OutlinedButtonStacked(
                  filled: selectedNumberPadFormat == NumberPadFormat.format789,
                  alignStart: true,
                  alignBeside: true,
                  text: null,
                  afterWidget: IgnorePointer(
                    child: NumberPadAmount(
                      extraWidgetAboveNumbers: null,
                      addToAmount: (_) {},
                      enableDecimal: true,
                      removeToAmount: () {},
                      removeAll: () {},
                      canChange: () => true,
                      enableCalculator: true,
                      padding: EdgeInsetsDirectional.zero,
                      setState: () {},
                      format: NumberPadFormat.format789,
                    ),
                  ),
                  padding: EdgeInsetsDirectional.only(
                      start: 20, end: 15, top: 10, bottom: 15),
                  iconData: null,
                  onTap: () {
                    setState(() {
                      selectedNumberPadFormat = NumberPadFormat.format789;
                    });
                    updateSettings(
                        "numberPadFormat", NumberPadFormat.format789.index,
                        updateGlobalState: false);
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ExtraZerosButtonSetting extends StatelessWidget {
  const ExtraZerosButtonSetting(
      {this.onChange, this.enableBorderRadius = false, super.key});
  final bool enableBorderRadius;
  final VoidCallback? onChange;
  @override
  Widget build(BuildContext context) {
    return SettingsContainerDropdown(
      enableBorderRadius: enableBorderRadius,
      title: "extra-zeros-button".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Symbols.counter_0_sharp
          : Symbols.counter_0_rounded,
      initial: appStateSettings["extraZerosButton"].toString(),
      items: ["", "00", "000"],
      onChanged: (value) async {
        await updateSettings(
          "extraZerosButton",
          value == "" ? null : value,
          updateGlobalState: false,
        );
        if (onChange != null) onChange!();
      },
      getLabel: (item) {
        if (item == "") return "none".tr().capitalizeFirst;
        return item;
      },
    );
  }
}

class NumberPadHapticFeedbackSetting extends StatelessWidget {
  const NumberPadHapticFeedbackSetting(
      {this.enableBorderRadius = false, super.key});
  final bool enableBorderRadius;
  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      enableBorderRadius: enableBorderRadius,
      title: "haptic-feedback".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.vibration_outlined
          : Symbols.vibration_rounded,
      initialValue: appStateSettings["numberPadHapticFeedback"] == true,
      onSwitched: (value) async {
        if (value == true) HapticFeedback.heavyImpact();
        await updateSettings(
          "numberPadHapticFeedback",
          value,
          updateGlobalState: false,
        );
      },
    );
  }
}

class PercentagePrecisionSetting extends StatelessWidget {
  const PercentagePrecisionSetting({super.key});
  @override
  Widget build(BuildContext context) {
    return SettingsContainerDropdown(
      title: "percentage-precision".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.percent_outlined
          : Icons.percent_rounded,
      initial: appStateSettings["percentagePrecision"] == 2
          ? "2-decimals"
          : appStateSettings["percentagePrecision"] == 1
              ? "1-decimal"
              : "0-decimals",
      items: ["0-decimals", "1-decimal", "2-decimals"],
      onChanged: (value) async {
        updateSettings(
          "percentagePrecision",
          value == "2-decimals"
              ? 2
              : value == "1-decimal"
                  ? 1
                  : 0,
          updateGlobalState: true,
        );
      },
      getLabel: (item) {
        return item.tr();
      },
    );
  }
}

void savingHapticFeedback() {
  if (appStateSettings["savingHapticFeedback"] == true) {
    HapticFeedback.lightImpact();
  }
}

class FirstDayOfWeekSetting extends StatelessWidget {
  const FirstDayOfWeekSetting({required this.updateHomePage, super.key});
  final bool updateHomePage;
  @override
  Widget build(BuildContext context) {
    return SettingsContainerDropdown(
      title: "first-weekday".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.calendar_month_outlined
          : Icons.calendar_month_rounded,
      initial: appStateSettings["firstDayOfWeek"].toString(),
      items: ["-1", "0", "1"],
      onChanged: (value) async {
        int intValue = int.tryParse(value) ?? -1;
        await updateSettings(
          "firstDayOfWeek",
          intValue,
          updateGlobalState: false,
          pagesNeedingRefresh: updateHomePage ? [0] : [],
        );
      },
      getLabel: (item) {
        List<String> weekDayNames = getWeekdayNames();
        if (item == "-1") return "default".tr();
        if (item == "0") return weekDayNames[0];
        if (item == "1") return weekDayNames[1];
      },
    );
  }
}

List<String> getWeekdayNames() {
  List<String> localizedWeekdayNames = [];
  final String? locale = navigatorKey.currentContext?.locale.toString();

  // Use a fixed date that is not affected by daylight saving time.
  // December 31st, 2023, is a Sunday
  final DateTime baseDate = DateTime.utc(2023, 12, 31, 12, 0, 0);

  for (int i = 0; i < 7; i++) {
    final DateTime date = baseDate.add(Duration(days: i));
    final String weekdayName = DateFormat.EEEE(locale).format(date);
    localizedWeekdayNames.add(weekdayName);
  }

  return localizedWeekdayNames;
}

class CategoryIconPackSetting extends StatelessWidget {
  const CategoryIconPackSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerDropdown(
      title: "category-icon-pack".tr() != "category-icon-pack"
          ? "category-icon-pack".tr()
          : "Category Icon Pack",
      icon: appStateSettings["outlinedIcons"]
          ? Icons.collections_outlined
          : Icons.collections_rounded,
      initial: (appStateSettings["categoryIconPack"] ?? 0).toString(),
      items: ["0", "1", "2"],
      onChanged: (value) async {
        int intValue = int.tryParse(value) ?? 0;
        await updateSettings(
          "categoryIconPack",
          intValue,
          updateGlobalState: true,
          pagesNeedingRefresh: [0, 1, 2, 3],
        );
      },
      getLabel: (item) {
        if (item == "0") return "Default (Color)";
        if (item == "1") return "Monochrome";
        if (item == "2") return "Outlined";
        return item;
      },
    );
  }
}

class FontScaleSetting extends StatelessWidget {
  const FontScaleSetting({super.key});

  @override
  Widget build(BuildContext context) {
    double currentScale = (appStateSettings["fontScale"] ?? 1.0).toDouble();
    return SettingsContainer(
      title: "font-scale".tr() != "font-scale"
          ? "font-scale".tr()
          : "Font Scale",
      description: "${(currentScale * 100).toInt()}%",
      icon: appStateSettings["outlinedIcons"]
          ? Icons.format_size_outlined
          : Icons.format_size_rounded,
      afterWidget: SizedBox(
        width: 150,
        child: Slider(
          value: currentScale.clamp(0.8, 1.4),
          min: 0.8,
          max: 1.4,
          divisions: 6,
          label: "${(currentScale * 100).toInt()}%",
          onChanged: (value) async {
            await updateSettings(
              "fontScale",
              double.parse(value.toStringAsFixed(2)),
              updateGlobalState: true,
              pagesNeedingRefresh: [0, 1, 2, 3],
            );
          },
        ),
      ),
    );
  }
}

class LeftHandedSetting extends StatelessWidget {
  const LeftHandedSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "left-handed-access".tr() != "left-handed-access"
          ? "left-handed-access".tr()
          : "Left-Handed Access",
      description: "left-handed-access-description".tr() !=
              "left-handed-access-description"
          ? "left-handed-access-description".tr()
          : "Position action buttons for left-hand thumb reach",
      onSwitched: (value) async {
        await updateSettings("leftHandedFAB", value, updateGlobalState: true);
        await updateSettings("leftHandedNavbar", value,
            updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
      },
      initialValue: appStateSettings["leftHandedFAB"] == true,
      icon: appStateSettings["outlinedIcons"]
          ? Icons.front_hand_outlined
          : Icons.front_hand_rounded,
    );
  }
}

class DateFormatSetting extends StatelessWidget {
  const DateFormatSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerDropdown(
      title: "date-format".tr() != "date-format"
          ? "date-format".tr()
          : "Date Format",
      icon: appStateSettings["outlinedIcons"]
          ? Icons.edit_calendar_outlined
          : Icons.edit_calendar_rounded,
      initial: appStateSettings["dateFormat"]?.toString() ?? "full",
      items: ["full", "ddmmyyyy", "mmddyyyy", "yyyymmdd"],
      onChanged: (value) async {
        await updateSettings("dateFormat", value,
            updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
      },
      getLabel: (item) {
        if (item == "full") return "System Default (Locale)";
        if (item == "ddmmyyyy") return "DD/MM/YYYY (31/12/2026)";
        if (item == "mmddyyyy") return "MM/DD/YYYY (12/31/2026)";
        if (item == "yyyymmdd") return "YYYY-MM-DD (2026-12-31)";
        return item;
      },
    );
  }
}

class DefaultTransactionTypeSetting extends StatelessWidget {
  const DefaultTransactionTypeSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerDropdown(
      title: "default-transaction-type".tr() != "default-transaction-type"
          ? "default-transaction-type".tr()
          : "Default Transaction Type",
      icon: appStateSettings["outlinedIcons"]
          ? Icons.swap_horiz_outlined
          : Icons.swap_horiz_rounded,
      initial:
          appStateSettings["defaultTransactionType"]?.toString() ?? "expense",
      items: ["expense", "income"],
      onChanged: (value) async {
        await updateSettings("defaultTransactionType", value,
            updateGlobalState: true);
      },
      getLabel: (item) {
        if (item == "expense") return "expense".tr().capitalizeFirst;
        if (item == "income") return "income".tr().capitalizeFirst;
        return item;
      },
    );
  }
}

class LinearProgressBarStyleSetting extends StatelessWidget {
  const LinearProgressBarStyleSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerDropdown(
      title: "progress-bar-style".tr() != "progress-bar-style"
          ? "progress-bar-style".tr()
          : "Progress Bar Style",
      icon: appStateSettings["outlinedIcons"]
          ? Icons.linear_scale_outlined
          : Icons.linear_scale_rounded,
      initial: (appStateSettings["linearProgressBarStyle"] ?? 0).toString(),
      items: ["0", "1"],
      onChanged: (value) async {
        int intValue = int.tryParse(value) ?? 0;
        await updateSettings("linearProgressBarStyle", intValue,
            updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
      },
      getLabel: (item) {
        if (item == "0") return "Simple (Flat)";
        if (item == "1") return "Wavy (Modern)";
        return item;
      },
    );
  }
}

class NetTotalStyleSetting extends StatelessWidget {
  const NetTotalStyleSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerDropdown(
      title: "net-total-style".tr(),
      description: "net-total-style-description".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.palette_outlined
          : Icons.palette_rounded,
      initial: appStateSettings["netTotalsColorful"] == true ? "colorful" : "simple",
      items: const ["simple", "colorful"],
      onChanged: (value) async {
        await updateSettings("netTotalsColorful", value == "colorful",
            updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
      },
      getLabel: (item) {
        return item.tr();
      },
    );
  }
}

class NonCompactTransactionsSetting extends StatelessWidget {
  const NonCompactTransactionsSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "large-transaction-entry".tr() != "large-transaction-entry"
          ? "large-transaction-entry".tr()
          : "Large Transaction Entry",
      description: "show-more-info-transaction-entry".tr() !=
              "show-more-info-transaction-entry"
          ? "show-more-info-transaction-entry".tr()
          : "Show more information in a transaction entry",
      onSwitched: (value) {
        updateSettings("nonCompactTransactions", value,
            updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
      },
      initialValue: appStateSettings["nonCompactTransactions"] == true,
      icon: appStateSettings["outlinedIcons"]
          ? Icons.view_agenda_outlined
          : Icons.view_agenda_rounded,
    );
  }
}

class ScrollBehaviorSetting extends StatelessWidget {
  const ScrollBehaviorSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerDropdown(
      title: "scroll-behavior".tr() != "scroll-behavior"
          ? "scroll-behavior".tr()
          : "Scroll Behavior",
      icon: appStateSettings["outlinedIcons"]
          ? Icons.swap_vert_outlined
          : Icons.swap_vert_rounded,
      initial: appStateSettings["scrollBehavior"]?.toString() ?? "default",
      items: ["default", "bouncing", "clamping"],
      onChanged: (value) async {
        await updateSettings("scrollBehavior", value,
            updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
      },
      getLabel: (item) {
        if (item == "default") return "System Default";
        if (item == "bouncing") return "Bouncing (iOS Style)";
        if (item == "clamping") return "Clamping (Android Style)";
        return item;
      },
    );
  }
}

class BatterySaverSetting extends StatelessWidget {
  const BatterySaverSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "battery-saver".tr() != "battery-saver"
          ? "battery-saver".tr()
          : "Battery Saver",
      description: "battery-saver-description".tr() !=
              "battery-saver-description"
          ? "battery-saver-description".tr()
          : "Reduce animations and shadows to save battery",
      onSwitched: (value) {
        updateSettings("batterySaver", value,
            updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
      },
      initialValue: appStateSettings["batterySaver"] == true,
      icon: appStateSettings["outlinedIcons"]
          ? Icons.battery_saver_outlined
          : Icons.battery_saver_rounded,
    );
  }
}

class IncognitoKeyboardSetting extends StatelessWidget {
  const IncognitoKeyboardSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "incognito-keyboard".tr() != "incognito-keyboard"
          ? "incognito-keyboard".tr()
          : "Incognito Keyboard",
      description: "incognito-keyboard-description".tr() !=
              "incognito-keyboard-description"
          ? "incognito-keyboard-description".tr()
          : "Request keyboard to disable personalized learning",
      onSwitched: (value) {
        updateSettings("incognitoKeyboard", value,
            updateGlobalState: true);
      },
      initialValue: appStateSettings["incognitoKeyboard"] == true,
      icon: appStateSettings["outlinedIcons"]
          ? Icons.keyboard_hide_outlined
          : Icons.keyboard_hide_rounded,
    );
  }
}

class BillSplitterShortcutSetting extends StatelessWidget {
  const BillSplitterShortcutSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "bill-splitter-shortcut".tr() != "bill-splitter-shortcut"
          ? "bill-splitter-shortcut".tr()
          : "Bill Splitter Shortcut",
      description: "show-bill-splitter-shortcut-description".tr() !=
              "show-bill-splitter-shortcut-description"
          ? "show-bill-splitter-shortcut-description".tr()
          : "Show Bill Splitter in the quick actions menu",
      onSwitched: (value) {
        updateSettings("showBillSplitterShortcut", value,
            updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
      },
      initialValue: appStateSettings["showBillSplitterShortcut"] == true,
      icon: appStateSettings["outlinedIcons"]
          ? Icons.summarize_outlined
          : Icons.summarize_rounded,
    );
  }
}

class LongTermLoansDifferenceSetting extends StatelessWidget {
  const LongTermLoansDifferenceSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "loan-difference-tracking".tr() != "loan-difference-tracking"
          ? "loan-difference-tracking".tr()
          : "Loan Difference Tracking",
      description: "loan-difference-tracking-description".tr() !=
              "loan-difference-tracking-description"
          ? "loan-difference-tracking-description".tr()
          : "Track offset and difference between lent and borrowed totals",
      onSwitched: (value) {
        updateSettings("longTermLoansDifferenceFeature", value,
            updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
      },
      initialValue: appStateSettings["longTermLoansDifferenceFeature"] == true,
      icon: appStateSettings["outlinedIcons"]
          ? Icons.compare_arrows_outlined
          : Icons.compare_arrows_rounded,
    );
  }
}

class CountBalanceCorrectionInSummarySetting extends StatelessWidget {
  const CountBalanceCorrectionInSummarySetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "Count Balance Corrections in Summary",
      description:
          "Count account balance correction adjustments as expense or income in total spending and summary",
      onSwitched: (value) {
        updateSettings("countBalanceCorrectionInSummary", value,
            updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
      },
      initialValue: appStateSettings["countBalanceCorrectionInSummary"] == true,
      icon: appStateSettings["outlinedIcons"]
          ? Icons.account_balance_wallet_outlined
          : Icons.account_balance_wallet_rounded,
    );
  }
}

class SelectTransactionTypeBeforeAddingSetting extends StatelessWidget {
  const SelectTransactionTypeBeforeAddingSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "Speed Dial Mini-List on Add Button",
      description:
          "Show floating Expense, Income, and Transfer options when pressing the + button instead of opening add transaction directly",
      onSwitched: (value) {
        updateSettings("selectTransactionTypeBeforeAdding", value,
            updateGlobalState: true);
      },
      initialValue:
          appStateSettings["selectTransactionTypeBeforeAdding"] == true,
      icon: appStateSettings["outlinedIcons"]
          ? Icons.unfold_more_outlined
          : Icons.unfold_more_rounded,
    );
  }
}

class AnimatedBudgetBackgroundSetting extends StatelessWidget {
  const AnimatedBudgetBackgroundSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "animated-budget-background".tr(),
      description: "disabling-can-increase-performance".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.animation_outlined
          : Icons.animation_rounded,
      initialValue: appStateSettings["animatedBudgetBackground"] ?? true,
      onSwitched: (value) {
        updateSettings("animatedBudgetBackground", value,
            updateGlobalState: true);
      },
    );
  }
}

class UseSubcategoryIconSetting extends StatelessWidget {
  const UseSubcategoryIconSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "use-subcategory-icon".tr(),
      description: "use-subcategory-icon-description".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.category_outlined
          : Icons.category_rounded,
      initialValue: appStateSettings["useSubcategoryIcon"] ?? true,
      onSwitched: (value) {
        updateSettings("useSubcategoryIcon", value,
            updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
      },
    );
  }
}

class ShowTransactionTimeSetting extends StatelessWidget {
  const ShowTransactionTimeSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "time".tr(),
      description: "show-time-description".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.schedule_outlined
          : Icons.schedule_rounded,
      initialValue: appStateSettings["showTransactionTime"] ?? false,
      onSwitched: (value) {
        updateSettings("showTransactionTime", value,
            updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
      },
    );
  }
}

class ConfirmUpcomingTransactionAmountSetting extends StatelessWidget {
  const ConfirmUpcomingTransactionAmountSetting({super.key});

  static String getConfirmUpcomingAmountSettingString(dynamic val) {
    if (val == 0 || val == "0" || val == "never") return "never";
    if (val == 1 || val == "1" || val == "always") return "always";
    if (val == 2 || val == "2" || val == "if-amount-is-zero") {
      return "if-amount-is-zero";
    }
    return "never";
  }

  @override
  Widget build(BuildContext context) {
    return SettingsContainerDropdown(
      title: "confirm-amount".tr() != "confirm-amount"
          ? "confirm-amount".tr()
          : "Confirm Amount",
      description: "confirm-amount-description".tr() !=
              "confirm-amount-description"
          ? "confirm-amount-description".tr()
          : "When manually paying scheduled transactions",
      icon: appStateSettings["outlinedIcons"]
          ? Icons.calculate_outlined
          : Icons.calculate_rounded,
      initial: getConfirmUpcomingAmountSettingString(
          appStateSettings["confirmUpcomingAmount"]),
      items: const ["never", "always", "if-amount-is-zero"],
      onChanged: (value) async {
        await updateSettings("confirmUpcomingAmount", value,
            updateGlobalState: true);
        await updateSettings(
            "confirmUpcomingTransactionAmount", value == "always",
            updateGlobalState: true);
      },
      getLabel: (item) {
        if (item == "never") {
          return "never".tr() != "never" ? "never".tr() : "Never";
        }
        if (item == "always") {
          return "always".tr() != "always" ? "always".tr() : "Always";
        }
        if (item == "if-amount-is-zero") {
          return "if-amount-is-zero".tr() != "if-amount-is-zero"
              ? "if-amount-is-zero".tr()
              : "If amount is 0";
        }
        return item.tr();
      },
    );
  }
}

class TransferBalanceTabSetting extends StatelessWidget {
  const TransferBalanceTabSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "Transfer Balance Tab",
      description: "On 'Add New Transaction' page",
      icon: appStateSettings["outlinedIcons"]
          ? Icons.swap_horiz_outlined
          : Icons.swap_horiz_rounded,
      initialValue: appStateSettings["showTransferBalanceTab"] ?? true,
      onSwitched: (value) {
        updateSettings("showTransferBalanceTab", value,
            updateGlobalState: true);
      },
    );
  }
}

class AddAttachmentsButtonSetting extends StatelessWidget {
  const AddAttachmentsButtonSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "add-attachments-button".tr() != "add-attachments-button"
          ? "add-attachments-button".tr()
          : "Add Attachments Button",
      description: "add-attachments-button-description".tr() !=
              "add-attachments-button-description"
          ? "add-attachments-button-description".tr()
          : "Show under the notes section",
      icon: appStateSettings["outlinedIcons"]
          ? Icons.attach_file_outlined
          : Icons.attach_file_rounded,
      initialValue: appStateSettings["showAddAttachmentsButton"] ?? true,
      onSwitched: (value) {
        updateSettings("showAddAttachmentsButton", value,
            updateGlobalState: true);
      },
    );
  }
}

class AutoAddTitlesSetting extends StatelessWidget {
  const AutoAddTitlesSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "auto-add-titles".tr() != "auto-add-titles"
          ? "auto-add-titles".tr()
          : "Automatically Add Titles",
      description: "auto-add-titles-description".tr() !=
              "auto-add-titles-description"
          ? "auto-add-titles-description".tr()
          : "When a transaction is added",
      icon: appStateSettings["outlinedIcons"]
          ? Icons.playlist_add_check_outlined
          : Icons.playlist_add_check_rounded,
      initialValue: appStateSettings["autoAddAssociatedTitles"] ?? false,
      onSwitched: (value) {
        updateSettings("autoAddAssociatedTitles", value,
            updateGlobalState: true);
      },
    );
  }
}

class AutoPayUpcomingSetting extends StatelessWidget {
  const AutoPayUpcomingSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "auto-pay-transactions".tr() != "auto-pay-transactions"
          ? "auto-pay-transactions".tr()
          : "Automatically Pay Transactions",
      description: "auto-pay-transactions-description".tr() !=
              "auto-pay-transactions-description"
          ? "auto-pay-transactions-description".tr()
          : "Automatically mark overdue transactions as paid",
      icon: appStateSettings["outlinedIcons"]
          ? Icons.event_available_outlined
          : Icons.event_available_rounded,
      initialValue: appStateSettings["automaticallyPayUpcoming"] ??
          appStateSettings["autoPayUpcoming"] ??
          true,
      onSwitched: (value) async {
        await updateSettings("automaticallyPayUpcoming", value,
            updateGlobalState: true);
        await updateSettings("autoPayUpcoming", value,
            updateGlobalState: true);
      },
    );
  }
}

class PaidDateSetting extends StatelessWidget {
  const PaidDateSetting({super.key});

  static String getPaidDateSettingString(dynamic val) {
    if (val == 0 || val == "0" || val == "currentDate") return "currentDate";
    if (val == 1 || val == "1" || val == "scheduledDate") return "scheduledDate";
    return "currentDate";
  }

  @override
  Widget build(BuildContext context) {
    return SettingsContainerDropdown(
      title: "paid-date".tr() != "paid-date" ? "paid-date".tr() : "Paid Date",
      description: "paid-date-description".tr() != "paid-date-description"
          ? "paid-date-description".tr()
          : "When a transaction is manually marked",
      icon: appStateSettings["outlinedIcons"]
          ? Icons.edit_calendar_outlined
          : Icons.edit_calendar_rounded,
      initial: getPaidDateSettingString(appStateSettings["markPaidDate"]),
      items: const ["currentDate", "scheduledDate"],
      onChanged: (value) async {
        await updateSettings("markPaidDate", value, updateGlobalState: true);
        await updateSettings(
            "markAsPaidOnOriginalDay", value == "scheduledDate",
            updateGlobalState: true);
      },
      getLabel: (item) {
        if (item == "currentDate") return "Current Date";
        if (item == "scheduledDate") return "Scheduled Date";
        return item;
      },
    );
  }
}

class TagIconSetting extends StatelessWidget {
  const TagIconSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "tag-icon".tr() != "tag-icon" ? "tag-icon".tr() : "Tag Icon",
      description: "tag-icon-description".tr() != "tag-icon-description"
          ? "tag-icon-description".tr()
          : "Show relating icon for the tag",
      icon: appStateSettings["outlinedIcons"]
          ? Icons.image_outlined
          : Icons.image_rounded,
      initialValue: appStateSettings["showTagIcons"] ?? true,
      onSwitched: (value) {
        updateSettings("showTagIcons", value,
            updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
      },
    );
  }
}

class SelectLayoutBottomSheet extends StatefulWidget {
  const SelectLayoutBottomSheet({super.key});

  @override
  State<SelectLayoutBottomSheet> createState() =>
      _SelectLayoutBottomSheetState();
}

class _SelectLayoutBottomSheetState extends State<SelectLayoutBottomSheet> {
  @override
  Widget build(BuildContext context) {
    bool isLarge = appStateSettings["largeTransactionEntry"] == true;

    return PopupFramework(
      title: "select-layout".tr() != "select-layout"
          ? "select-layout".tr()
          : "Select Layout",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextFont(
                  text: getWordedDateShort(DateTime.now()),
                  fontSize: 13,
                  textColor: getColor(context, "textLight"),
                ),
                TextFont(
                  text: convertToMoney(Provider.of<AllWallets>(context), 100),
                  fontSize: 13,
                  textColor: getColor(context, "textLight"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Compact layout preview card
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isLarge
                    ? Theme.of(context).colorScheme.outline.withOpacity(0.15)
                    : Theme.of(context).colorScheme.primary,
                width: isLarge ? 1.5 : 2,
              ),
            ),
            child: Tappable(
              borderRadius: 20,
              color: isLarge
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withOpacity(0.35),
              onTap: () async {
                await updateSettings("largeTransactionEntry", false,
                    updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3D2ED),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.fastfood_rounded,
                      color: Color(0xFFC75185),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TextFont(
                          text: "Transaction Name Placeh...",
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8D4F8),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const TextFont(
                                text: "Axis Bank",
                                fontSize: 11,
                                textColor: Color(0xFF5B307D),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE0D0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const TextFont(
                                text: "🍜 Food",
                                fontSize: 11,
                                textColor: Color(0xFF94451A),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD7EFE6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const TextFont(
                                text: "Info Ta...",
                                fontSize: 11,
                                textColor: Color(0xFF226E52),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 15,
                            color: getColor(context, "textLight"),
                          ),
                          const SizedBox(width: 4),
                          TextFont(
                            text: "2:47 pm",
                            fontSize: 11.5,
                            textColor: getColor(context, "textLight"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color: Colors.red,
                          ),
                          TextFont(
                            text: convertToMoney(
                                Provider.of<AllWallets>(context), 100),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            textColor: getColor(context, "expenseAmount"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
          // Large / Non-compact layout preview card
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isLarge
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.15),
                width: isLarge ? 2 : 1.5,
              ),
            ),
            child: Tappable(
              borderRadius: 20,
              color: isLarge
                  ? Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withOpacity(0.35)
                  : Theme.of(context).colorScheme.surface,
              onTap: () async {
                await updateSettings("largeTransactionEntry", true,
                    updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3D2ED),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fastfood_rounded,
                        color: Color(0xFFC75185),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TextFont(
                            text: "Transaction Name\nPlaceholder",
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.article_outlined,
                                size: 15,
                                color: getColor(context, "textLight"),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: TextFont(
                                  text:
                                      "This is a note that is part of the transaction. It is just a placeholder.",
                                  fontSize: 11,
                                  textColor: getColor(context, "textLight"),
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8D4F8),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const TextFont(
                                  text: "Axis Bank",
                                  fontSize: 11,
                                  textColor: Color(0xFF5B307D),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE0D0),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const TextFont(
                                  text: "🍜 Food",
                                  fontSize: 11,
                                  textColor: Color(0xFF94451A),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD7EFE6),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const TextFont(
                                    text: "Info Tag Placeholder",
                                    fontSize: 11,
                                    maxLines: 1,
                                    textColor: Color(0xFF226E52),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextFont(
                          text: "2:47 pm",
                          fontSize: 11.5,
                          textColor: getColor(context, "textLight"),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_drop_down,
                              size: 18,
                              color: Colors.red,
                            ),
                            TextFont(
                              text: convertToMoney(
                                  Provider.of<AllWallets>(context), 100),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              textColor: getColor(context, "expenseAmount"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const TransactionActionSetting(),
          const NetSpendingDayTotalSetting(),
          const ShowAccountLabelSettingToggle(),
          const TagIconSetting(),
          const UseSubcategoryIconSetting(),
          const ShowTransactionTimeSetting(),
          SettingsHeader(
            title: "related-settings".tr() != "related-settings"
                ? "related-settings".tr()
                : "Related Settings",
          ),
          const CategoryIconPackSetting(),
          const CountBalanceCorrectionInSummarySetting(),
          const NumberFormattingSetting(),
          const DateFormatSetting(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class GroupTransfersSetting extends StatelessWidget {
  const GroupTransfersSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "group-transfers".tr() != "group-transfers"
          ? "group-transfers".tr()
          : "Group Transfers",
      icon: appStateSettings["outlinedIcons"]
          ? Icons.compare_arrows_outlined
          : Icons.compare_arrows_rounded,
      initialValue: appStateSettings["groupTransfers"] ?? true,
      onSwitched: (value) {
        updateSettings("groupTransfers", value,
            updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
      },
    );
  }
}

class DatePickerTypeSetting extends StatelessWidget {
  const DatePickerTypeSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerDropdown(
      title: "date-picker".tr() != "date-picker"
          ? "date-picker".tr()
          : "Date Picker",
      icon: appStateSettings["outlinedIcons"]
          ? Icons.calendar_month_outlined
          : Icons.calendar_month_rounded,
      initial: (appStateSettings["datePickerType"] == 1 ||
              appStateSettings["datePickerType"] == "wheel")
          ? "wheel"
          : "calendar",
      items: ["calendar", "wheel"],
      onChanged: (value) async {
        await updateSettings("datePickerType", value == "wheel" ? 1 : 0,
            updateGlobalState: true);
      },
      getLabel: (item) {
        if (item == "calendar") return "calendar".tr();
        if (item == "wheel") {
          return "scrollable-list".tr() != "scrollable-list"
              ? "scrollable-list".tr()
              : "Scrolling List";
        }
        return item.tr();
      },
    );
  }
}

class TransactionActionSetting extends StatelessWidget {
  const TransactionActionSetting({super.key});

  static String getTransactionActionString(dynamic val) {
    if (val == 1 || val == "1" || val == "openEdit") return "openEdit";
    return "tapToExpand";
  }

  @override
  Widget build(BuildContext context) {
    return SettingsContainerDropdown(
      title: "transaction-actions".tr() != "transaction-actions"
          ? "transaction-actions".tr()
          : "Transaction Actions",
      description: "tap-to-expand-help-description".tr() !=
              "tap-to-expand-help-description"
          ? "tap-to-expand-help-description".tr()
          : "Tap a transaction to expand options or open directly",
      icon: appStateSettings["outlinedIcons"]
          ? Icons.speed_outlined
          : Icons.speed_rounded,
      initial:
          getTransactionActionString(appStateSettings["transactionAction"]),
      items: ["tapToExpand", "openEdit"],
      onChanged: (value) async {
        await updateSettings("transactionAction", value,
            updateGlobalState: true);
      },
      getLabel: (item) {
        if (item == "tapToExpand") {
          return "tap-to-expand".tr() != "tap-to-expand"
              ? "tap-to-expand".tr()
              : "Tap To Expand";
        }
        if (item == "openEdit") {
          return "edit-transaction".tr() != "edit-transaction"
              ? "edit-transaction".tr()
              : "Open Directly";
        }
        return item.tr();
      },
    );
  }
}
