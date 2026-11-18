import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:budget/widgets/util/showDatePicker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({
    this.initialDate,
    super.key,
  });

  final DateTime? initialDate;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedMonth;
  late DateTime _selectedDay;
  bool _showNetTotals = true;

  @override
  void initState() {
    super.initState();
    final DateTime initial = widget.initialDate ?? DateTime.now();
    _focusedMonth = DateTime(initial.year, initial.month, 1);
    _selectedDay = DateTime(initial.year, initial.month, initial.day);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
      _selectedDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
      _selectedDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    });
  }

  void _jumpToToday() {
    final DateTime now = DateTime.now();
    setState(() {
      _focusedMonth = DateTime(now.year, now.month, 1);
      _selectedDay = DateTime(now.year, now.month, now.day);
    });
  }

  Future<void> _pickMonth() async {
    final DateTime? picked = await showCustomDatePicker(
      context,
      _focusedMonth,
    );
    if (picked != null) {
      setState(() {
        _focusedMonth = DateTime(picked.year, picked.month, 1);
        _selectedDay = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  List<String> _getWeekdayHeaders(int firstDayOfWeek) {
    // 0 = Sunday, 1 = Monday
    const List<String> standard = ["S", "M", "T", "W", "T", "F", "S"];
    final List<String> rotated = [];
    for (int i = 0; i < 7; i++) {
      rotated.add(standard[(i + firstDayOfWeek) % 7]);
    }
    return rotated;
  }

  @override
  Widget build(BuildContext context) {
    final DateTime monthStart =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final DateTime monthEnd =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0, 23, 59, 59);

    final int firstDayOfWeek =
        (appStateSettings["firstDayOfWeek"] as int?) ?? 0;

    return StreamBuilder<List<TransactionWithCategory>>(
      stream: database.getTransactionCategoryWithDay(
        monthStart.subtract(const Duration(days: 7)),
        monthEnd.add(const Duration(days: 7)),
        budgetTransactionFilters: null,
        memberTransactionFilters: null,
      ),
      builder: (context, snapshot) {
        final List<TransactionWithCategory> allTxs = snapshot.data ?? [];

        // Aggregate daily transactions
        final Map<DateTime, List<TransactionWithCategory>> txsByDay = {};
        double monthIncome = 0;
        double monthExpense = 0;

        for (final tx in allTxs) {
          final DateTime txDate = tx.transaction.dateCreated;
          final DateTime dayKey =
              DateTime(txDate.year, txDate.month, txDate.day);

          txsByDay.putIfAbsent(dayKey, () => []).add(tx);

          // Only sum for focused month
          if (txDate.year == _focusedMonth.year &&
              txDate.month == _focusedMonth.month) {
            final double amount = tx.transaction.amount *
                (amountRatioToPrimaryCurrencyGivenPk(
                    Provider.of<AllWallets>(context, listen: false),
                    tx.transaction.walletFk));
            if (amount > 0) {
              monthIncome += amount;
            } else {
              monthExpense += amount;
            }
          }
        }

        final double monthNet = monthIncome + monthExpense;

        final DateTime selectedDayKey = DateTime(
          _selectedDay.year,
          _selectedDay.month,
          _selectedDay.day,
        );
        final List<TransactionWithCategory> selectedDayTxs =
            txsByDay[selectedDayKey] ?? [];

        double selectedDayTotal = 0;
        for (final tx in selectedDayTxs) {
          selectedDayTotal += tx.transaction.amount *
              (amountRatioToPrimaryCurrencyGivenPk(
                  Provider.of<AllWallets>(context, listen: false),
                  tx.transaction.walletFk));
        }

        return PageFramework(
          title: "calendar".tr(),
          dragDownToDismiss: true,
          scrollToTopButton: false,
          actions: [
            IconButton(
              tooltip: _showNetTotals
                  ? "Showing Net Totals (tap for Expense)"
                  : "Showing Expense Totals (tap for Net)",
              icon: Icon(
                _showNetTotals
                    ? (appStateSettings["outlinedIcons"]
                        ? Icons.swap_vert_outlined
                        : Icons.swap_vert_rounded)
                    : (appStateSettings["outlinedIcons"]
                        ? Icons.trending_down_outlined
                        : Icons.trending_down_rounded),
              ),
              onPressed: () {
                setState(() {
                  _showNetTotals = !_showNetTotals;
                });
              },
            ),
            IconButton(
              tooltip: "today".tr(),
              icon: Icon(
                appStateSettings["outlinedIcons"]
                    ? Icons.today_outlined
                    : Icons.today_rounded,
              ),
              onPressed: _jumpToToday,
            ),
          ],
          slivers: [
            // Month Navigation Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        appStateSettings["outlinedIcons"]
                            ? Icons.chevron_left_outlined
                            : Icons.chevron_left_rounded,
                      ),
                      onPressed: _previousMonth,
                    ),
                    GestureDetector(
                      onTap: _pickMonth,
                      child: Row(
                        children: [
                          TextFont(
                            text: DateFormat.yMMMM().format(_focusedMonth),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            appStateSettings["outlinedIcons"]
                                ? Icons.arrow_drop_down_outlined
                                : Icons.arrow_drop_down_rounded,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        appStateSettings["outlinedIcons"]
                            ? Icons.chevron_right_outlined
                            : Icons.chevron_right_rounded,
                      ),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ),
            ),

            // Monthly Summary Banner
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: getColor(context, "lightDarkAccent"),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem(
                        context,
                        label: "income".tr(),
                        amount: monthIncome,
                        color: getColor(context, "incomeAmount"),
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        color: getColor(context, "dividerColor"),
                      ),
                      _buildSummaryItem(
                        context,
                        label: "expense".tr(),
                        amount: monthExpense,
                        color: getColor(context, "expenseAmount"),
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        color: getColor(context, "dividerColor"),
                      ),
                      _buildSummaryItem(
                        context,
                        label: "net".tr(),
                        amount: monthNet,
                        color: monthNet >= 0
                            ? getColor(context, "incomeAmount")
                            : getColor(context, "expenseAmount"),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Calendar Day-of-Week Headers
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 12, bottom: 4),
                child: Row(
                  children: _getWeekdayHeaders(firstDayOfWeek).map((day) {
                    return Expanded(
                      child: Center(
                        child: TextFont(
                          text: day,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          textColor: getColor(context, "textLight"),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Calendar Days Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildCalendarGrid(
                  context,
                  firstDayOfWeek: firstDayOfWeek,
                  txsByDay: txsByDay,
                ),
              ),
            ),

            // Selected Day Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 22, right: 22, top: 20, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextFont(
                      text: DateFormat.yMMMMEEEEd().format(_selectedDay),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    if (selectedDayTxs.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: getColor(context, "lightDarkAccentHeavy"),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFont(
                          text: convertToMoney(
                            Provider.of<AllWallets>(context),
                            selectedDayTotal,
                          ),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          textColor: selectedDayTotal >= 0
                              ? getColor(context, "incomeAmount")
                              : getColor(context, "expenseAmount"),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Selected Day Transactions List
            if (selectedDayTxs.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          appStateSettings["outlinedIcons"]
                              ? Icons.event_busy_outlined
                              : Icons.event_busy_rounded,
                          size: 36,
                          color: getColor(context, "textLight").withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        TextFont(
                          text: "No transactions on this date",
                          fontSize: 14,
                          textColor: getColor(context, "textLight"),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            pushRoute(
                              context,
                              AddTransactionPage(
                                selectedDate: _selectedDay,
                                routesToPopAfterDelete:
                                    RoutesToPopAfterDelete.None,
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: Text("Add Transaction"),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final txWithCategory = selectedDayTxs[index];
                    return TransactionEntry(
                      openPage: AddTransactionPage(
                        transaction: txWithCategory.transaction,
                        routesToPopAfterDelete: RoutesToPopAfterDelete.One,
                      ),
                      transaction: txWithCategory.transaction,
                      category: txWithCategory.category,
                      subCategory: txWithCategory.subCategory,
                    );
                  },
                  childCount: selectedDayTxs.length,
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 60),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String label,
    required double amount,
    required Color color,
  }) {
    return Column(
      children: [
        TextFont(
          text: label,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          textColor: getColor(context, "textLight"),
        ),
        const SizedBox(height: 2),
        TextFont(
          text: convertToMoney(
            Provider.of<AllWallets>(context),
            amount,
          ),
          fontSize: 13,
          fontWeight: FontWeight.bold,
          textColor: color,
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context, {
    required int firstDayOfWeek,
    required Map<DateTime, List<TransactionWithCategory>> txsByDay,
  }) {
    final DateTime firstOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final int daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;

    // weekday is 1 for Mon, 7 for Sun
    final int firstWeekday = firstOfMonth.weekday % 7; // 0 for Sun .. 6 for Sat
    final int leadingDays = (firstWeekday - firstDayOfWeek + 7) % 7;

    final DateTime now = DateTime.now();
    final DateTime todayKey = DateTime(now.year, now.month, now.day);

    final List<Widget> dayWidgets = [];

    // Leading padding days from previous month
    final DateTime prevMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    final int prevMonthDays =
        DateTime(_focusedMonth.year, _focusedMonth.month, 0).day;

    for (int i = leadingDays - 1; i >= 0; i--) {
      final int dayNum = prevMonthDays - i;
      final DateTime cellDate =
          DateTime(prevMonth.year, prevMonth.month, dayNum);
      dayWidgets.add(_buildDayCell(
        context,
        date: cellDate,
        isCurrentMonth: false,
        isToday: false,
        isSelected: false,
        txs: txsByDay[cellDate] ?? [],
      ));
    }

    // Days in current month
    for (int day = 1; day <= daysInMonth; day++) {
      final DateTime cellDate =
          DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final bool isToday = cellDate == todayKey;
      final bool isSelected = cellDate.year == _selectedDay.year &&
          cellDate.month == _selectedDay.month &&
          cellDate.day == _selectedDay.day;

      dayWidgets.add(_buildDayCell(
        context,
        date: cellDate,
        isCurrentMonth: true,
        isToday: isToday,
        isSelected: isSelected,
        txs: txsByDay[cellDate] ?? [],
      ));
    }

    // Trailing padding days to fill 7 columns
    final int totalCells = dayWidgets.length;
    final int remainder = (7 - (totalCells % 7)) % 7;
    for (int i = 1; i <= remainder; i++) {
      final DateTime cellDate =
          DateTime(_focusedMonth.year, _focusedMonth.month + 1, i);
      dayWidgets.add(_buildDayCell(
        context,
        date: cellDate,
        isCurrentMonth: false,
        isToday: false,
        isSelected: false,
        txs: txsByDay[cellDate] ?? [],
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.85,
      children: dayWidgets,
    );
  }

  Widget _buildDayCell(
    BuildContext context, {
    required DateTime date,
    required bool isCurrentMonth,
    required bool isToday,
    required bool isSelected,
    required List<TransactionWithCategory> txs,
  }) {
    double dayTotal = 0;
    for (final tx in txs) {
      final double amt = tx.transaction.amount *
          (amountRatioToPrimaryCurrencyGivenPk(
              Provider.of<AllWallets>(context, listen: false),
              tx.transaction.walletFk));
      if (_showNetTotals) {
        dayTotal += amt;
      } else {
        if (amt < 0) dayTotal += amt;
      }
    }

    final bool hasTxs = txs.isNotEmpty;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = date;
          if (!isCurrentMonth) {
            _focusedMonth = DateTime(date.year, date.month, 1);
          }
        });
      },
      onDoubleTap: () {
        pushRoute(
          context,
          AddTransactionPage(
            selectedDate: date,
            routesToPopAfterDelete: RoutesToPopAfterDelete.None,
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.18)
              : isToday
                  ? getColor(context, "lightDarkAccentHeavy")
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                )
              : isToday
                  ? Border.all(
                      color: getColor(context, "textLight").withOpacity(0.5),
                      width: 1,
                    )
                  : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFont(
              text: date.day.toString(),
              fontSize: 13,
              fontWeight:
                  isSelected || isToday ? FontWeight.bold : FontWeight.normal,
              textColor: !isCurrentMonth
                  ? getColor(context, "textLight").withOpacity(0.35)
                  : isSelected
                      ? Theme.of(context).colorScheme.primary
                      : getColor(context, "black"),
            ),
            const SizedBox(height: 2),
            if (hasTxs && isCurrentMonth)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: TextFont(
                    text: convertToMoney(
                      Provider.of<AllWallets>(context),
                      dayTotal,
                      decimals: 0,
                    ),
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    textColor: dayTotal >= 0
                        ? getColor(context, "incomeAmount")
                        : getColor(context, "expenseAmount"),
                  ),
                ),
              )
            else if (hasTxs && !isCurrentMonth)
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: getColor(context, "textLight").withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
