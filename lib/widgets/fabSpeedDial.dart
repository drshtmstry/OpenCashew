import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/managePinnedTransactionsPage.dart';
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

class TransactionSpeedDialFAB extends StatefulWidget {
  const TransactionSpeedDialFAB({
    this.openPage,
    this.color,
    this.colorIcon,
    this.tooltip,
    this.fabSize = 60,
    this.borderRadius = 18,
    super.key,
  });

  final Widget? openPage;
  final Color? color;
  final Color? colorIcon;
  final String? tooltip;
  final double fabSize;
  final double borderRadius;

  @override
  State<TransactionSpeedDialFAB> createState() =>
      _TransactionSpeedDialFABState();
}

class _TransactionSpeedDialFABState extends State<TransactionSpeedDialFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  OverlayEntry? _overlayEntry;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubicEmphasized,
        reverseCurve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isExpanded = false;
  }

  void _collapse() {
    if (!_isExpanded) return;
    _controller.reverse().then((_) {
      if (mounted) {
        _removeOverlay();
        setState(() {});
      }
    });
  }

  void _toggle() {
    if (_isExpanded) {
      _collapse();
    } else {
      _expand();
    }
  }

  void _expand() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final isLeftHanded = appStateSettings["leftHandedFAB"] == true;

    _isExpanded = true;
    setState(() {});

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return _SpeedDialOverlay(
          fabOffset: offset,
          fabSize: size,
          isLeftHanded: isLeftHanded,
          animation: _controller,
          borderRadius: widget.borderRadius,
          color: widget.color ?? Theme.of(context).colorScheme.secondary,
          colorIcon: widget.colorIcon ??
              Theme.of(context).colorScheme.onSecondary,
          onClose: _collapse,
          onSelectExpense: () {
            _collapse();
            _openTransactionPage(false);
          },
          onSelectIncome: () {
            _collapse();
            _openTransactionPage(true);
          },
          onSelectTransfer: () {
            _collapse();
            _openTransfer();
          },
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    _controller.forward();
  }

  void _openTransactionPage(bool isIncome) {
    BuildContext targetContext = navigatorKey.currentContext ?? context;
    AddTransactionPage pageToOpen;
    if (widget.openPage is AddTransactionPage) {
      AddTransactionPage orig = widget.openPage as AddTransactionPage;
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

  void _openTransfer() {
    BuildContext targetContext = navigatorKey.currentContext ?? context;
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
    Color containerColor =
        widget.color ?? Theme.of(context).colorScheme.secondary;
    Color iconColor =
        widget.colorIcon ?? Theme.of(context).colorScheme.onSecondary;

    return Tooltip(
      message: widget.tooltip ?? "",
      child: Tappable(
        color: containerColor,
        borderRadius: widget.borderRadius,
        onTap: _toggle,
        onLongPress: () {
          if (_isExpanded) {
            _collapse();
            return;
          }
          openBottomSheet(
            context,
            PopupFramework(
              child: AddMoreThingsPopup(
                onManagePinnedTransactions: () {
                  popRoute(context);
                  pushRoute(context, const ManagePinnedTransactionsPage());
                },
              ),
            ),
          );
        },
        child: Container(
          height: widget.fabSize,
          width: widget.fabSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: containerColor,
            boxShadow: [
              BoxShadow(
                color: containerColor.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: RotationTransition(
              turns: _rotationAnimation,
              child: Icon(
                appStateSettings["outlinedIcons"]
                    ? Icons.add_outlined
                    : Icons.add_rounded,
                color: iconColor,
                size: widget.fabSize * 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeedDialOverlay extends StatelessWidget {
  const _SpeedDialOverlay({
    required this.fabOffset,
    required this.fabSize,
    required this.isLeftHanded,
    required this.animation,
    required this.borderRadius,
    required this.color,
    required this.colorIcon,
    required this.onClose,
    required this.onSelectExpense,
    required this.onSelectIncome,
    required this.onSelectTransfer,
  });

  final Offset fabOffset;
  final Size fabSize;
  final bool isLeftHanded;
  final Animation<double> animation;
  final double borderRadius;
  final Color color;
  final Color colorIcon;
  final VoidCallback onClose;
  final VoidCallback onSelectExpense;
  final VoidCallback onSelectIncome;
  final VoidCallback onSelectTransfer;

  Widget _buildOption({
    required BuildContext context,
    required String label,
    required Widget icon,
    required Color itemColor,
    required VoidCallback onTap,
    required double beginInterval,
    required double endInterval,
  }) {
    Animation<double> curved = CurvedAnimation(
      parent: animation,
      curve: Interval(beginInterval, endInterval, curve: Curves.easeOutBack),
      reverseCurve:
          Interval(beginInterval, endInterval, curve: Curves.easeIn),
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        double progress = curved.value;
        if (progress <= 0.001) return const SizedBox.shrink();

        return Opacity(
          opacity: progress.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.6 + (0.4 * progress),
            alignment:
                isLeftHanded ? Alignment.bottomLeft : Alignment.bottomRight,
            child: Transform.translate(
              offset: Offset(0, 15 * (1 - progress)),
              child: child,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isLeftHanded) ...[
                _buildLabel(context, label),
                const SizedBox(width: 12),
                _buildMiniFab(context, icon, itemColor),
              ] else ...[
                _buildMiniFab(context, icon, itemColor),
                const SizedBox(width: 12),
                _buildLabel(context, label),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: getColor(context, "lightDarkAccentHeavyLight"),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFont(
        text: label,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMiniFab(BuildContext context, Widget icon, Color itemColor) {
    double miniSize = 48;
    return Container(
      width: miniSize,
      height: miniSize,
      decoration: BoxDecoration(
        color: itemColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: itemColor.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bottomPadding = screenSize.height - fabOffset.dy + 8;
    final rightPadding = !isLeftHanded
        ? screenSize.width - fabOffset.dx - fabSize.width
        : null;
    final leftPadding = isLeftHanded ? fabOffset.dx : null;

    Animation<double> rotationAnim =
        Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubicEmphasized,
        reverseCurve: Curves.easeIn,
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) onClose();
      },
      child: Stack(
        children: [
          // Dismissible full-screen backdrop
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClose,
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Container(
                    color: Colors.black.withOpacity(0.32 * animation.value),
                  );
                },
              ),
            ),
          ),
          // Floating speed dial items directly above the FAB
          Positioned(
            bottom: bottomPadding,
            right: rightPadding,
            left: leftPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: isLeftHanded
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                _buildOption(
                  context: context,
                  label: "transfer".tr(),
                  icon: Icon(
                    appStateSettings["outlinedIcons"]
                        ? Icons.compare_arrows_outlined
                        : Icons.compare_arrows_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  itemColor: Theme.of(context).colorScheme.primary,
                  onTap: onSelectTransfer,
                  beginInterval: 0.3,
                  endInterval: 1.0,
                ),
                _buildOption(
                  context: context,
                  label: "income".tr(),
                  icon: IncomeOutcomeArrow(
                    isIncome: true,
                    width: 20,
                    color: Colors.white,
                  ),
                  itemColor: getColor(context, "incomeAmount"),
                  onTap: onSelectIncome,
                  beginInterval: 0.15,
                  endInterval: 0.85,
                ),
                _buildOption(
                  context: context,
                  label: "expense".tr(),
                  icon: IncomeOutcomeArrow(
                    isIncome: false,
                    width: 20,
                    color: Colors.white,
                  ),
                  itemColor: getColor(context, "expenseAmount"),
                  onTap: onSelectExpense,
                  beginInterval: 0.0,
                  endInterval: 0.7,
                ),
              ],
            ),
          ),
          // Overlay duplicate FAB button that closes when tapped
          Positioned(
            top: fabOffset.dy,
            left: fabOffset.dx,
            width: fabSize.width,
            height: fabSize.height,
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: RotationTransition(
                    turns: rotationAnim,
                    child: Icon(
                      appStateSettings["outlinedIcons"]
                          ? Icons.add_outlined
                          : Icons.add_rounded,
                      color: colorIcon,
                      size: fabSize.width * 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
