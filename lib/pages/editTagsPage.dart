import 'dart:async';
import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTagPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/editRowEntry.dart';
import 'package:budget/modified/reorderable_list.dart';
import 'package:drift/drift.dart' show Value;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide SliverReorderableList;
import 'package:flutter/services.dart' hide TextInput;

class EditTagsPage extends StatefulWidget {
  EditTagsPage({Key? key}) : super(key: key);

  @override
  _EditTagsPageState createState() => _EditTagsPageState();
}

class _EditTagsPageState extends State<EditTagsPage> {
  bool dragDownToDismissEnabled = true;
  int currentReorder = -1;
  String searchValue = "";

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      database.fixOrderTags();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      horizontalPaddingConstrained: true,
      dragDownToDismiss: true,
      dragDownToDismissEnabled: dragDownToDismissEnabled,
      title: "edit-tags".tr() != "edit-tags" ? "edit-tags".tr() : "Edit Tags",
      scrollToTopButton: true,
      floatingActionButton: AnimateFABDelayed(
        fab: AddFAB(
          tooltip: "add-tag".tr() != "add-tag" ? "add-tag".tr() : "Add Tag",
          openPage: AddTagPage(
            routesToPopAfterDelete: RoutesToPopAfterDelete.None,
          ),
        ),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 8.0),
            child: TextInput(
              labelText: "search-placeholder".tr() != "search-placeholder"
                  ? "search-placeholder".tr()
                  : "Search",
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
        StreamBuilder<List<TransactionTag>>(
          stream: database.watchAllTags(includeArchived: true),
          builder: (context, snapshot) {
            if (snapshot.hasData == false || snapshot.data!.isEmpty) {
              return SliverToBoxAdapter(
                child: NoResults(
                  message: "no-tags-found".tr() != "no-tags-found"
                      ? "no-tags-found".tr()
                      : "No tags found",
                ),
              );
            }
            List<TransactionTag> tagsList = snapshot.data ?? [];
            if (searchValue.trim().isNotEmpty) {
              tagsList = tagsList
                  .where((t) => t.name
                      .toLowerCase()
                      .contains(searchValue.toLowerCase().trim()))
                  .toList();
            }
            return SliverReorderableList(
              onReorder: (int from, int to) async {
                if (from < to) to--;
                List<TransactionTag> newOrder = [...tagsList];
                final item = newOrder.removeAt(from);
                newOrder.insert(to, item);
                for (int i = 0; i < newOrder.length; i++) {
                  await (database.update(database.tags)
                        ..where((t) => t.tagPk.equals(newOrder[i].tagPk)))
                      .write(TagsCompanion(order: Value(i)));
                }
                return true;
              },
              itemBuilder: (context, index) {
                TransactionTag tag = tagsList[index];
                return EditRowEntry(
                  canReorder: searchValue.isEmpty,
                  currentReorder:
                      currentReorder != -1 && currentReorder != index,
                  key: ValueKey(tag.tagPk),
                  padding:
                      const EdgeInsetsDirectional.symmetric(horizontal: 5),
                  content: Row(
                    children: [
                      CategoryIcon(
                        categoryPk: '-1',
                        size: 30,
                        category: null,
                        label: false,
                        labelShorten: false,
                        outline: false,
                        emojiIconName: tag.emojiIconName,
                        iconName: tag.iconName,
                        colorIconName: tag.colour,
                        noBackground: true,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFont(
                          text: tag.name,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  index: index,
                  extraIcon: tag.archived
                      ? (appStateSettings["outlinedIcons"]
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_off_rounded)
                      : (appStateSettings["outlinedIcons"]
                          ? Icons.visibility_outlined
                          : Icons.visibility_rounded),
                  onExtra: () async {
                    await database.archiveTag(tag.tagPk, !tag.archived);
                  },
                  opacity: tag.archived ? 0.5 : 1,
                  onDelete: () async {
                    await database.deleteTag(tag.tagPk);
                    openSnackbar(SnackbarMessage(
                      title: "deleted".tr(),
                      icon: appStateSettings['outlinedIcons']
                          ? Icons.delete_outlined
                          : Icons.delete_rounded,
                    ));
                    return true;
                  },
                  openPage: AddTagPage(
                    tag: tag,
                    routesToPopAfterDelete: RoutesToPopAfterDelete.None,
                  ),
                );
              },
              itemCount: tagsList.length,
            );
          },
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 75),
        ),
      ],
    );
  }
}
