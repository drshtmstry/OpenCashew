import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/modified/reorderable_list.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/struct/languageMap.dart';
import 'package:budget/struct/navBarIconsData.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart' hide SliverReorderableList;
import 'package:flutter/material.dart' hide SliverReorderableList;
import 'package:flutter/services.dart';

const List<String> defaultMorePageOrder = [
  "settings",
  "allSpending",
  "calendar",
  "subscriptions",
  "scheduled",
  "activityLog",
  "billSplitter",
  "about",
  "googleAccount",
  "editData",
];

class EditMorePageItem {
  final IconData icon;
  final String name;
  bool isEnabled;
  final Function(bool value) onSwitched;

  EditMorePageItem({
    required this.icon,
    required this.name,
    required this.isEnabled,
    required this.onSwitched,
  });
}

class EditMorePage extends StatefulWidget {
  const EditMorePage({super.key});

  @override
  State<EditMorePage> createState() => _EditMorePageState();
}

class _EditMorePageState extends State<EditMorePage> {
  late List<String> currentOrder;
  late List<String> disabledList;

  @override
  void initState() {
    super.initState();
    List<dynamic> savedOrder = appStateSettings["morePageOrder"] ?? [];
    currentOrder = List<String>.from(savedOrder.map((e) => e.toString()));
    for (String defKey in defaultMorePageOrder) {
      if (!currentOrder.contains(defKey)) {
        currentOrder.add(defKey);
      }
    }
    List<dynamic> savedDisabled = appStateSettings["morePageDisabled"] ?? [];
    disabledList = List<String>.from(savedDisabled.map((e) => e.toString()));
  }

  void _saveSettings() {
    updateSettings("morePageOrder", currentOrder, updateGlobalState: true);
    updateSettings("morePageDisabled", disabledList, updateGlobalState: true);
  }

  Map<String, EditMorePageItem> _getItems(BuildContext context) {
    return {
      "settings": EditMorePageItem(
        icon: navBarIconsData["settings"]!.iconData,
        name: navBarIconsData["settings"]!.labelLong.tr(),
        isEnabled: !disabledList.contains("settings"),
        onSwitched: (val) {
          setState(() {
            if (val) {
              disabledList.remove("settings");
            } else {
              disabledList.add("settings");
            }
          });
          _saveSettings();
        },
      ),
      "allSpending": EditMorePageItem(
        icon: navBarIconsData["allSpending"]!.iconData,
        name: navBarIconsData["allSpending"]!.labelLong.tr(),
        isEnabled: !disabledList.contains("allSpending"),
        onSwitched: (val) {
          setState(() {
            if (val) {
              disabledList.remove("allSpending");
            } else {
              disabledList.add("allSpending");
            }
          });
          _saveSettings();
        },
      ),
      "calendar": EditMorePageItem(
        icon: appStateSettings["outlinedIcons"]
            ? Icons.calendar_month_outlined
            : Icons.calendar_month_rounded,
        name: "calendar".tr(),
        isEnabled: !disabledList.contains("calendar"),
        onSwitched: (val) {
          setState(() {
            if (val) {
              disabledList.remove("calendar");
            } else {
              disabledList.add("calendar");
            }
          });
          _saveSettings();
        },
      ),
      "subscriptions": EditMorePageItem(
        icon: navBarIconsData["subscriptions"]!.iconData,
        name: navBarIconsData["subscriptions"]!.label.tr(),
        isEnabled: !disabledList.contains("subscriptions"),
        onSwitched: (val) {
          setState(() {
            if (val) {
              disabledList.remove("subscriptions");
            } else {
              disabledList.add("subscriptions");
            }
          });
          _saveSettings();
        },
      ),
      "scheduled": EditMorePageItem(
        icon: navBarIconsData["scheduled"]!.iconData,
        name: navBarIconsData["scheduled"]!.label.tr(),
        isEnabled: !disabledList.contains("scheduled"),
        onSwitched: (val) {
          setState(() {
            if (val) {
              disabledList.remove("scheduled");
            } else {
              disabledList.add("scheduled");
            }
          });
          _saveSettings();
        },
      ),
      "activityLog": EditMorePageItem(
        icon: appStateSettings["outlinedIcons"]
            ? Icons.ballot_outlined
            : Icons.ballot_rounded,
        name: "activity-log".tr() != "activity-log"
            ? "activity-log".tr()
            : "Activity Log",
        isEnabled: !disabledList.contains("activityLog"),
        onSwitched: (val) {
          setState(() {
            if (val) {
              disabledList.remove("activityLog");
            } else {
              disabledList.add("activityLog");
            }
          });
          _saveSettings();
        },
      ),
      "billSplitter": EditMorePageItem(
        icon: appStateSettings["outlinedIcons"]
            ? Icons.summarize_outlined
            : Icons.summarize_rounded,
        name: "bill-splitter".tr(),
        isEnabled: !disabledList.contains("billSplitter"),
        onSwitched: (val) {
          setState(() {
            if (val) {
              disabledList.remove("billSplitter");
            } else {
              disabledList.add("billSplitter");
            }
          });
          _saveSettings();
        },
      ),
      "about": EditMorePageItem(
        icon: navBarIconsData["about"]!.iconData,
        name: "about-app".tr(namedArgs: {"app": globalAppName}),
        isEnabled: !disabledList.contains("about"),
        onSwitched: (val) {
          setState(() {
            if (val) {
              disabledList.remove("about");
            } else {
              disabledList.add("about");
            }
          });
          _saveSettings();
        },
      ),
      "googleAccount": EditMorePageItem(
        icon: appStateSettings["outlinedIcons"]
            ? Icons.cloud_outlined
            : Icons.cloud_rounded,
        name: "Google Drive Sync",
        isEnabled: !disabledList.contains("googleAccount"),
        onSwitched: (val) {
          setState(() {
            if (val) {
              disabledList.remove("googleAccount");
            } else {
              disabledList.add("googleAccount");
            }
          });
          _saveSettings();
        },
      ),
      "editData": EditMorePageItem(
        icon: appStateSettings["outlinedIcons"]
            ? Icons.edit_note_outlined
            : Icons.edit_note_rounded,
        name: "edit-delete-and-reorder-data".tr() !=
                "edit-delete-and-reorder-data"
            ? "edit-delete-and-reorder-data".tr()
            : "Edit, Delete, and Reorder Data",
        isEnabled: !disabledList.contains("editData"),
        onSwitched: (val) {
          setState(() {
            if (val) {
              disabledList.remove("editData");
            } else {
              disabledList.add("editData");
            }
          });
          _saveSettings();
        },
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    Map<String, EditMorePageItem> items = _getItems(context);

    return PageFramework(
      title: "edit-shortcuts".tr() != "edit-shortcuts"
          ? "edit-shortcuts".tr()
          : "Edit Shortcuts",
      dragDownToDismiss: true,
      actions: [
        IconButton(
          tooltip: "reset".tr(),
          icon: Icon(
            appStateSettings["outlinedIcons"]
                ? Icons.restart_alt_outlined
                : Icons.restart_alt_rounded,
          ),
          onPressed: () async {
            bool? reset = await openPopup(
              context,
              title: "reset-order-question".tr() != "reset-order-question"
                  ? "reset-order-question".tr()
                  : "Reset order?",
              description: "reset-order-description".tr() !=
                      "reset-order-description"
                  ? "reset-order-description".tr()
                  : "Are you sure you want to reset shortcut order to default?",
              onSubmit: () {
                popRoute(context, true);
              },
              onCancel: () {
                popRoute(context, false);
              },
              onSubmitLabel: "reset".tr(),
            );
            if (reset == true) {
              setState(() {
                currentOrder = List<String>.from(defaultMorePageOrder);
                disabledList = [];
              });
              _saveSettings();
            }
          },
        ),
      ],
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 18,
              end: 18,
              top: 10,
              bottom: 10,
            ),
            child: TextFont(
              text: "drag-to-reorder".tr() != "drag-to-reorder"
                  ? "drag-to-reorder".tr()
                  : "Drag to reorder shortcuts or toggle to show/hide on the More page.",
              fontSize: 14,
              maxLines: 3,
              textColor: getColor(context, "black").withOpacity(0.6),
            ),
          ),
        ),
        SliverReorderableList(
          onReorderStart: (index) {
            HapticFeedback.heavyImpact();
          },
          itemCount: currentOrder.length,
          onReorder: (oldIndex, newIndex) async {
            setState(() {
              if (newIndex > oldIndex) newIndex -= 1;
              final String item = currentOrder.removeAt(oldIndex);
              currentOrder.insert(newIndex, item);
            });
            _saveSettings();
            HapticFeedback.mediumImpact();
            return true;
          },
          itemBuilder: (context, index) {
            String key = currentOrder[index];
            EditMorePageItem? item = items[key];
            if (item == null) return const SizedBox.shrink();

            return HomePageEditRowEntry(
              key: ValueKey(key),
              text: item.name,
              iconData: item.icon,
              toggleSwitch: () {
                item.onSwitched(!item.isEnabled);
              },
              switchValue: item.isEnabled,
              canReorder: true,
              currentReorder: false,
              extraWidgetsBelow: null,
              onTap: () {
                item.onSwitched(!item.isEnabled);
              },
              index: index,
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 50)),
      ],
    );
  }
}
