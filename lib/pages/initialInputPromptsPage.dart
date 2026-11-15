import 'package:budget/colors.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class InitialInputPromptsPage extends StatelessWidget {
  const InitialInputPromptsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      title: "initial-input-prompts".tr() != "initial-input-prompts"
          ? "initial-input-prompts".tr()
          : "Initial Input Prompts",
      dragDownToDismiss: true,
      horizontalPaddingConstrained: true,
      listWidgets: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: TextFont(
            text: "initial-input-prompts-full-description".tr() !=
                    "initial-input-prompts-full-description"
                ? "initial-input-prompts-full-description".tr()
                : "Make new transactions faster by customizing which fields you're prompted for. While creating a new transaction, you can exit the prompts at any time by closing the popup to edit the entire transaction.",
            fontSize: 13,
            textColor: getColor(context, "textLight"),
            maxLines: 6,
          ),
        ),
        SettingsContainerSwitch(
          title: "ask-for-transaction-title".tr() != "ask-for-transaction-title"
              ? "ask-for-transaction-title".tr()
              : "Ask For Transaction Title",
          description: "ask-for-transaction-title-description".tr() !=
                  "ask-for-transaction-title-description"
              ? "ask-for-transaction-title-description".tr()
              : "When adding a transaction",
          icon: appStateSettings["outlinedIcons"]
              ? Icons.title_outlined
              : Icons.title_rounded,
          initialValue: appStateSettings["askForTransactionTitle"] ?? true,
          onSwitched: (value) {
            updateSettings("askForTransactionTitle", value,
                updateGlobalState: true);
          },
        ),
        SettingsContainerSwitch(
          title: "ask-for-note-with-title".tr() != "ask-for-note-with-title"
              ? "ask-for-note-with-title".tr()
              : "Ask For Note",
          description: "Prompt for a note description",
          icon: appStateSettings["outlinedIcons"]
              ? Icons.notes_outlined
              : Icons.notes_rounded,
          initialValue:
              appStateSettings["askForTransactionNoteWithTitle"] ?? false,
          onSwitched: (value) {
            updateSettings("askForTransactionNoteWithTitle", value,
                updateGlobalState: true);
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
