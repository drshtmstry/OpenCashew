import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/settingsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/saveBottomButton.dart';
import 'package:budget/widgets/selectCategoryImage.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';

class AddTagPage extends StatefulWidget {
  AddTagPage({
    Key? key,
    this.tag,
    required this.routesToPopAfterDelete,
  }) : super(key: key);

  final TransactionTag? tag;
  final RoutesToPopAfterDelete routesToPopAfterDelete;

  @override
  _AddTagPageState createState() => _AddTagPageState();
}

class _AddTagPageState extends State<AddTagPage> {
  String? selectedTitle;
  String? selectedImage;
  String? selectedEmoji;
  Color? selectedColor;
  bool canAddTag = false;

  TextEditingController _titleController = TextEditingController();
  FocusNode _titleFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.tag != null) {
      selectedTitle = widget.tag!.name;
      _titleController.text = widget.tag!.name;
      selectedImage = widget.tag!.iconName;
      selectedEmoji = widget.tag!.emojiIconName;
      selectedColor =
          widget.tag!.colour != null ? HexColor(widget.tag!.colour) : null;
    }
    Future.delayed(Duration.zero, () {
      determineBottomButton();
    });
  }

  void setSelectedColor(Color? color) {
    setState(() {
      selectedColor = color;
    });
    determineBottomButton();
  }

  void setSelectedImage(String? image) {
    setState(() {
      selectedImage = (image ?? '').replaceFirst('assets/categories/', '');
      selectedEmoji = null;
    });
    determineBottomButton();
  }

  void setSelectedEmoji(String? emoji) {
    setState(() {
      selectedEmoji = emoji;
      selectedImage = null;
    });
    determineBottomButton();
  }

  void setSelectedTitle(String title, {bool modifyControllerValue = false}) {
    setState(() {
      selectedTitle = title;
    });
    if (modifyControllerValue) _titleController.text = title;
    determineBottomButton();
  }

  void determineBottomButton() {
    bool canAdd = selectedTitle != null && selectedTitle!.trim().isNotEmpty;
    if (canAddTag != canAdd) {
      setState(() {
        canAddTag = canAdd;
      });
    }
  }

  Future addTag() async {
    TransactionTag createdTag = await createTransactionTag();
    await database.createOrUpdateTag(
      createdTag,
      insert: widget.tag == null,
    );
    savingHapticFeedback();
    popRoute(context);
  }

  Future<TransactionTag> createTransactionTag() async {
    return TransactionTag(
      tagPk: widget.tag != null ? widget.tag!.tagPk : '-1',
      name: (selectedTitle ?? '').trim(),
      dateCreated:
          widget.tag != null ? widget.tag!.dateCreated : DateTime.now(),
      dateTimeModified: null,
      order: widget.tag != null
          ? widget.tag!.order
          : await database.getAmountOfTags(),
      colour: toHexString(selectedColor),
      iconName: selectedImage,
      emojiIconName: selectedEmoji,
      archived: widget.tag?.archived ?? false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: PageFramework(
          resizeToAvoidBottomInset: true,
          dragDownToDismiss: true,
          title: widget.tag == null
              ? ("add-tag".tr() != "add-tag" ? "add-tag".tr() : "Add Tag")
              : ("edit-tag".tr() != "edit-tag" ? "edit-tag".tr() : "Edit Tag"),
          actions: [
            if (widget.tag != null)
              IconButton(
                padding: EdgeInsetsDirectional.all(15),
                tooltip: "delete".tr(),
                icon: Icon(
                  appStateSettings['outlinedIcons']
                      ? Icons.delete_outlined
                      : Icons.delete_rounded,
                ),
                onPressed: () {
                  openPopup(
                    context,
                    icon: appStateSettings['outlinedIcons']
                        ? Icons.delete_outlined
                        : Icons.delete_rounded,
                    title: "delete".tr(),
                    description: "are-you-sure-delete".tr(),
                    onSubmit: () async {
                      await database.deleteTag(widget.tag!.tagPk);
                      popRoute(context);
                      openSnackbar(SnackbarMessage(
                        title: "deleted".tr(),
                        icon: appStateSettings['outlinedIcons']
                            ? Icons.delete_outlined
                            : Icons.delete_rounded,
                      ));
                    },
                    onSubmitLabel: 'delete'.tr(),
                    onCancelLabel: 'cancel'.tr(),
                    onCancel: () {
                      Navigator.pop(context);
                    },
                  );
                },
              ),
          ],
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 20),
                    child: CategoryIcon(
                      categoryPk: '-1',
                      size: 60,
                      category: null,
                      label: false,
                      labelShorten: false,
                      outline: true,
                      onTap: () {
                        openBottomSheet(
                          context,
                          PopupFramework(
                            title: 'select-icon'.tr(),
                            hasPadding: false,
                            child: SelectCategoryImage(
                              setSelectedImage: setSelectedImage,
                              setSelectedEmoji: setSelectedEmoji,
                              setSelectedTitle: (title) {
                                if ((selectedTitle ?? '').isEmpty &&
                                    title != null) {
                                  _titleController.text = title;
                                  setSelectedTitle(title);
                                }
                              },
                              selectedImage: selectedImage == null
                                  ? null
                                  : 'assets/categories/' + selectedImage!,
                            ),
                          ),
                        );
                      },
                      emojiIconName: selectedEmoji,
                      iconName: selectedImage,
                      colorIconName: toHexString(selectedColor),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.symmetric(horizontal: 20),
                    child: TextInput(
                      autoFocus: widget.tag == null,
                      labelText: 'name-placeholder'.tr(),
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      onChanged: (value) {
                        setSelectedTitle(value);
                      },
                      onSubmitted: (value) {
                        setSelectedTitle(value);
                      },
                    ),
                  ),
                  SizedBox(height: 14),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.symmetric(horizontal: 20),
                    child: SelectColor(
                      selectedColor: selectedColor,
                      setSelectedColor: setSelectedColor,
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ],
          overlay: Align(
            alignment: Alignment.bottomCenter,
            child: SaveBottomButton(
              label: widget.tag == null ? "add".tr() : "save".tr(),
              onTap: () {
                if (canAddTag) {
                  addTag();
                }
              },
              disabled: !canAddTag,
            ),
          ),
        ),
      ),
    );
  }
}
