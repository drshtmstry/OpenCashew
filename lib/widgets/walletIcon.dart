import 'dart:io';
import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/accountTypes.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/selectCategoryImage.dart';
import 'package:budget/widgets/selectChips.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

String? cachedAccountIconsDirectoryPath;

/// Ensures and returns the directory path where custom account logos are stored.
Future<String> getAccountIconsDirectoryPath() async {
  if (cachedAccountIconsDirectoryPath != null) {
    return cachedAccountIconsDirectoryPath!;
  }
  final Directory docDir = await getApplicationDocumentsDirectory();
  final Directory iconDir = Directory(p.join(docDir.path, 'account_icons'));
  if (!await iconDir.exists()) {
    await iconDir.create(recursive: true);
  }
  cachedAccountIconsDirectoryPath = iconDir.path;
  return iconDir.path;
}

/// Resolves a stored icon string to a local File if it represents a custom image.
File? getAccountIconFile(String? iconName) {
  if (iconName == null || iconName.isEmpty || kIsWeb) return null;

  if (iconName.startsWith("custom_icon:")) {
    final String pathPart = iconName.replaceFirst("custom_icon:", "");
    final File directFile = File(pathPart);
    if (directFile.isAbsolute && directFile.existsSync()) {
      return directFile;
    }
    if (cachedAccountIconsDirectoryPath != null) {
      final File localFile =
          File(p.join(cachedAccountIconsDirectoryPath!, p.basename(pathPart)));
      if (localFile.existsSync()) return localFile;
    }
  } else {
    final File directFile = File(iconName);
    if (directFile.isAbsolute && directFile.existsSync()) {
      return directFile;
    }
  }
  return null;
}

/// Prompts user to pick an image from their gallery/files, copies it to local app storage,
/// and returns the custom icon identifier `custom_icon:<filename>`.
Future<String?> pickAndSaveAccountLogo(BuildContext context) async {
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 90,
    );
    if (image == null) return null;

    final String dirPath = await getAccountIconsDirectoryPath();
    final String extension =
        p.extension(image.path).isNotEmpty ? p.extension(image.path) : '.png';
    final String fileName =
        'account_logo_${DateTime.now().millisecondsSinceEpoch}$extension';
    final String fullPath = p.join(dirPath, fileName);

    final Uint8List bytes = await image.readAsBytes();
    final File savedFile = File(fullPath);
    await savedFile.writeAsBytes(bytes);

    return 'custom_icon:$fileName';
  } catch (e) {
    return null;
  }
}

/// Universal account icon widget that renders either:
/// 1. A custom local image logo (from device upload)
/// 2. An asset icon (from built-in icons)
/// 3. An emoji
/// 4. The default icon for the account's AccountType (bank, cash, card, etc.)
class WalletIcon extends StatelessWidget {
  const WalletIcon({
    super.key,
    this.wallet,
    this.iconName,
    this.emojiIconName,
    this.accountType,
    this.color,
    this.iconColor,
    this.size = 24,
    this.sizePadding = 12,
    this.borderRadius,
    this.noBackground = false,
    this.outline = false,
    this.onTap,
    this.onLongPress,
    this.margin,
  });

  final TransactionWallet? wallet;
  final String? iconName;
  final String? emojiIconName;
  final AccountType? accountType;
  final Color? color;
  final Color? iconColor;
  final double size;
  final double sizePadding;
  final double? borderRadius;
  final bool noBackground;
  final bool outline;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsDirectional? margin;

  @override
  Widget build(BuildContext context) {
    final String? effectiveIcon = iconName ?? wallet?.iconName;
    final String? effectiveEmoji = emojiIconName ?? wallet?.emojiIconName;
    final AccountType effectiveType =
        accountType ?? getAccountTypeFromWallet(wallet);

    final Color effectiveColor = color ??
        (wallet?.colour != null
            ? HexColor(wallet!.colour)
            : Theme.of(context).colorScheme.primary);

    final double effectiveRadius = borderRadius ?? (size * 0.45);

    Widget innerWidget;
    final File? customImageFile = getAccountIconFile(effectiveIcon);

    if (effectiveEmoji != null && effectiveEmoji.isNotEmpty) {
      innerWidget = EmojiIcon(
        emojiIconName: effectiveEmoji,
        size: size,
      );
    } else if (customImageFile != null) {
      innerWidget = ClipRRect(
        borderRadius: BorderRadius.circular(effectiveRadius * 0.8),
        child: Image.file(
          customImageFile,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildTypeIcon(context, effectiveType),
        ),
      );
    } else if (effectiveIcon != null &&
        (effectiveIcon.endsWith(".png") ||
            effectiveIcon.endsWith(".svg") ||
            effectiveIcon.startsWith("assets/"))) {
      final String assetPath = effectiveIcon.startsWith("assets/")
          ? effectiveIcon
          : getCategoryIconFolder() + effectiveIcon;
      innerWidget = Image.asset(
        assetPath,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) =>
            _buildTypeIcon(context, effectiveType),
      );
    } else {
      innerWidget = _buildTypeIcon(context, effectiveType);
    }

    final Widget iconContainer = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: margin,
      height: size + sizePadding,
      width: size + sizePadding,
      decoration: BoxDecoration(
        color: noBackground
            ? Colors.transparent
            : dynamicPastel(
                context,
                effectiveColor,
                amountLight: 0.55,
                amountDark: 0.35,
              ),
        borderRadius: BorderRadiusDirectional.circular(effectiveRadius),
        border: outline
            ? Border.all(
                color: dynamicPastel(
                  context,
                  effectiveColor,
                  amountLight: 0.5,
                  amountDark: 0.4,
                  inverse: true,
                ),
                width: 2.5,
              )
            : null,
      ),
      child: Center(child: innerWidget),
    );

    if (onTap != null || onLongPress != null) {
      return Tappable(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        onTap: onTap,
        onLongPress: onLongPress,
        child: iconContainer,
      );
    }

    return iconContainer;
  }

  Widget _buildTypeIcon(BuildContext context, AccountType type) {
    return Icon(
      getAccountTypeIcon(
        type,
        outlined: appStateSettings["outlinedIcons"],
      ),
      size: size,
      color: iconColor ?? getColor(context, "black").withOpacity(0.85),
    );
  }
}

/// Interactive preview widget used in AddWalletPage and color pickers.
class WalletIconPreview extends StatelessWidget {
  const WalletIconPreview({
    super.key,
    this.selectedIconName,
    this.selectedEmoji,
    this.selectedAccountType,
    this.selectedColor,
    this.size = 28,
    this.sizePadding = 16,
    this.borderRadius,
    this.smallPreview = false,
    this.onTap,
  });

  final String? selectedIconName;
  final String? selectedEmoji;
  final AccountType? selectedAccountType;
  final Color? selectedColor;
  final double size;
  final double sizePadding;
  final double? borderRadius;
  final bool smallPreview;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return WalletIcon(
      iconName: selectedIconName,
      emojiIconName: selectedEmoji,
      accountType: selectedAccountType,
      color: selectedColor,
      size: smallPreview ? 14 : size,
      sizePadding: smallPreview ? 8 : sizePadding,
      borderRadius: borderRadius ?? (smallPreview ? 8 : 18),
      onTap: onTap,
    );
  }
}

/// Opens the modal bottom sheet allowing users to select an icon, pick a custom
/// logo from device files, select from default AccountTypes, or choose emojis.
void openSelectWalletIconBottomSheet({
  required BuildContext context,
  required String? selectedIconName,
  required String? selectedEmoji,
  required AccountType selectedAccountType,
  required Color? selectedColor,
  required ValueChanged<String?> onSelectedIcon,
  required ValueChanged<String?> onSelectedEmoji,
  required ValueChanged<AccountType> onSelectedAccountType,
}) {
  openBottomSheet(
    context,
    PopupFramework(
      title: "Account Icon",
      child: SelectWalletIconBottomSheet(
        selectedIconName: selectedIconName,
        selectedEmoji: selectedEmoji,
        selectedAccountType: selectedAccountType,
        selectedColor: selectedColor,
        onSelectedIcon: onSelectedIcon,
        onSelectedEmoji: onSelectedEmoji,
        onSelectedAccountType: onSelectedAccountType,
      ),
    ),
  );
}

class SelectWalletIconBottomSheet extends StatefulWidget {
  const SelectWalletIconBottomSheet({
    super.key,
    required this.selectedIconName,
    required this.selectedEmoji,
    required this.selectedAccountType,
    required this.selectedColor,
    required this.onSelectedIcon,
    required this.onSelectedEmoji,
    required this.onSelectedAccountType,
  });

  final String? selectedIconName;
  final String? selectedEmoji;
  final AccountType selectedAccountType;
  final Color? selectedColor;
  final ValueChanged<String?> onSelectedIcon;
  final ValueChanged<String?> onSelectedEmoji;
  final ValueChanged<AccountType> onSelectedAccountType;

  @override
  State<SelectWalletIconBottomSheet> createState() =>
      _SelectWalletIconBottomSheetState();
}

class _SelectWalletIconBottomSheetState
    extends State<SelectWalletIconBottomSheet> {
  late String? _currentIcon;
  late String? _currentEmoji;
  late AccountType _currentType;

  @override
  void initState() {
    super.initState();
    _currentIcon = widget.selectedIconName;
    _currentEmoji = widget.selectedEmoji;
    _currentType = widget.selectedAccountType;
    // Pre-cache custom account icons directory
    getAccountIconsDirectoryPath();
  }

  void _openEmojiSelectorPopup() {
    openBottomSheet(
      context,
      popupWithKeyboard: true,
      PopupFramework(
        title: "enter-emoji".tr(),
        child: SelectText(
          buttonLabel: null,
          icon: appStateSettings["outlinedIcons"]
              ? Icons.emoji_emotions_outlined
              : Icons.emoji_emotions_rounded,
          setSelectedText: (value) {
            setState(() {
              _currentEmoji = value;
              _currentIcon = null;
            });
            widget.onSelectedEmoji(value);
            widget.onSelectedIcon(null);
          },
          popContextWhenSet: true,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(
                r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'))
          ],
          placeholder: "${'enter-emoji-placeholder'.tr()} 😀...",
          autoFocus: true,
        ),
      ),
    );
  }

  void _openBuiltInIconSelector() {
    openBottomSheet(
      context,
      PopupFramework(
        title: "select-icon".tr(),
        child: SelectCategoryImage(
          setSelectedImage: (image) {
            final String cleanImage =
                (image ?? "").replaceFirst("assets/categories/", "");
            setState(() {
              _currentIcon = cleanImage;
              _currentEmoji = null;
            });
            widget.onSelectedIcon(cleanImage);
            widget.onSelectedEmoji(null);
            popRoute(context);
          },
          setSelectedEmoji: (emoji) {
            setState(() {
              _currentEmoji = emoji;
              _currentIcon = null;
            });
            widget.onSelectedEmoji(emoji);
            widget.onSelectedIcon(null);
            popRoute(context);
          },
          selectedImage: _currentIcon != null
              ? "assets/categories/$_currentIcon"
              : null,
          setSelectedTitle: (_) {},
        ),
      ),
      showScrollbar: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasCustomOverride =
        _currentIcon != null || _currentEmoji != null;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Live preview card
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: WalletIcon(
                iconName: _currentIcon,
                emojiIconName: _currentEmoji,
                accountType: _currentType,
                color: widget.selectedColor,
                size: 40,
                sizePadding: 22,
                borderRadius: 22,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Action 1: Upload Custom Image / Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SettingsContainer(
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.add_photo_alternate_outlined
                  : Icons.add_photo_alternate_rounded,
              title: "Upload Custom Logo / Image",
              description: "Select an image or logo from your device files",
              onTap: () async {
                final String? customPath =
                    await pickAndSaveAccountLogo(context);
                if (!mounted) return;
                if (customPath != null) {
                  setState(() {
                    _currentIcon = customPath;
                    _currentEmoji = null;
                  });
                  widget.onSelectedIcon(customPath);
                  widget.onSelectedEmoji(null);
                  popRoute(context);
                }
              },
            ),
          ),

          // Action 2: Built-in Icons Library
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SettingsContainer(
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.grid_view_outlined
                  : Icons.grid_view_rounded,
              title: "Choose from Icon Library",
              description: "Browse categorized financial and everyday icons",
              onTap: () {
                popRoute(context);
                _openBuiltInIconSelector();
              },
            ),
          ),

          // Action 3: Choose Emoji
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SettingsContainer(
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.emoji_emotions_outlined
                  : Icons.emoji_emotions_rounded,
              title: "Choose Emoji",
              description: "Use an emoji symbol as your account icon",
              onTap: () {
                popRoute(context);
                _openEmojiSelectorPopup();
              },
            ),
          ),

          const SizedBox(height: 14),

          // Section Header: Default Type Icons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: TextFont(
              text: "Default Account Type Icons",
              fontSize: 15,
              fontWeight: FontWeight.bold,
              textColor: getColor(context, "textLight"),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: SelectChips<AccountType>(
              items: AccountType.values,
              getSelected: (type) =>
                  !hasCustomOverride && type == _currentType,
              onSelected: (type) {
                setState(() {
                  _currentType = type;
                  _currentIcon = null;
                  _currentEmoji = null;
                });
                widget.onSelectedAccountType(type);
                widget.onSelectedIcon(null);
                widget.onSelectedEmoji(null);
                popRoute(context);
              },
              getLabel: (type) => getAccountTypeName(type),
              getAvatar: (type) => Icon(
                getAccountTypeIcon(type,
                    outlined: appStateSettings["outlinedIcons"]),
                size: 16,
              ),
              wrapped: true,
            ),
          ),

          if (hasCustomOverride) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SettingsContainer(
                icon: appStateSettings["outlinedIcons"]
                    ? Icons.restart_alt_outlined
                    : Icons.restart_alt_rounded,
                title: "Reset to Default Icon",
                description:
                    "Revert to the default ${_currentType.name.toUpperCase()} icon",
                onTap: () {
                  setState(() {
                    _currentIcon = null;
                    _currentEmoji = null;
                  });
                  widget.onSelectedIcon(null);
                  widget.onSelectedEmoji(null);
                  popRoute(context);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
