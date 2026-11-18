import 'dart:math';
import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/util/keepAliveClientMixin.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

enum StackedBarTimeframe { days7, weeks4, months6 }

class HomePageStackedBar extends StatefulWidget {
  const HomePageStackedBar({super.key});

  @override
  State<HomePageStackedBar> createState() => _HomePageStackedBarState();
}

class _HomePageStackedBarState extends State<HomePageStackedBar> {
  late StackedBarTimeframe _timeframe;
  late int _mode; // 0: Categories, 1: Income vs Expense

  @override
  void initState() {
    super.initState();
    int tfIndex = appStateSettings["stackedBarTimeframe"] ?? 0;
    _timeframe = StackedBarTimeframe.values[tfIndex.clamp(0, 2)];
    _mode = (appStateSettings["stackedBarMode"] ?? 0).clamp(0, 1);
  }

  void _setTimeframe(StackedBarTimeframe tf) {
    setState(() {
      _timeframe = tf;
    });
    updateSettings("stackedBarTimeframe", tf.index, updateGlobalState: false);
  }

  void _setMode(int mode) {
    setState(() {
      _mode = mode;
    });
    updateSettings("stackedBarMode", mode, updateGlobalState: false);
  }

  DateTime get _startDate {
    DateTime now = DateTime.now();
    switch (_timeframe) {
      case StackedBarTimeframe.days7:
        return DateTime(now.year, now.month, now.day - 6);
      case StackedBarTimeframe.weeks4:
        return DateTime(now.year, now.month, now.day - 27);
      case StackedBarTimeframe.months6:
        return DateTime(now.year, now.month - 5, 1);
    }
  }

  DateTime get _endDate {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  List<DateTimeRange> _generateBuckets() {
    DateTime now = DateTime.now();
    List<DateTimeRange> buckets = [];
    switch (_timeframe) {
      case StackedBarTimeframe.days7:
        for (int i = 6; i >= 0; i--) {
          DateTime dayStart =
              DateTime(now.year, now.month, now.day - i, 0, 0, 0);
          DateTime dayEnd =
              DateTime(now.year, now.month, now.day - i, 23, 59, 59);
          buckets.add(DateTimeRange(start: dayStart, end: dayEnd));
        }
        break;
      case StackedBarTimeframe.weeks4:
        for (int i = 3; i >= 0; i--) {
          DateTime weekStart =
              DateTime(now.year, now.month, now.day - (i * 7 + 6), 0, 0, 0);
          DateTime weekEnd =
              DateTime(now.year, now.month, now.day - (i * 7), 23, 59, 59);
          buckets.add(DateTimeRange(start: weekStart, end: weekEnd));
        }
        break;
      case StackedBarTimeframe.months6:
        for (int i = 5; i >= 0; i--) {
          DateTime mStart = DateTime(now.year, now.month - i, 1);
          DateTime mEnd =
              DateTime(now.year, now.month - i + 1, 0, 23, 59, 59);
          buckets.add(DateTimeRange(start: mStart, end: mEnd));
        }
        break;
    }
    return buckets;
  }

  String _getBucketLabel(DateTimeRange range, int index) {
    switch (_timeframe) {
      case StackedBarTimeframe.days7:
        return DateFormat('E').format(range.start);
      case StackedBarTimeframe.weeks4:
        return "W${index + 1}";
      case StackedBarTimeframe.months6:
        return DateFormat('MMM').format(range.start);
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime start = _startDate;
    DateTime end = _endDate;

    return KeepAliveClientMixin(
      child: StreamBuilder<List<Transaction>>(
        stream: database.watchAllTransactions(
          startDate: start,
          endDate: end,
          limit: 1000,
        ),
        builder: (context, snapshot) {
          List<Transaction> transactions = snapshot.data ?? [];
          return FutureBuilder<List<TransactionCategory>>(
            future: database.getAllCategories(),
            builder: (context, catSnapshot) {
              Map<String, TransactionCategory> categoryMap = {};
              for (var c in catSnapshot.data ?? []) {
                categoryMap[c.categoryPk] = c;
              }

              return _buildCard(context, transactions, categoryMap);
            },
          );
        },
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    List<Transaction> transactions,
    Map<String, TransactionCategory> categoryMap,
  ) {
    List<DateTimeRange> buckets = _generateBuckets();
    AllWallets allWallets = Provider.of<AllWallets>(context);

    // Calculate total spend across period
    double totalSpentPeriod = 0;
    for (var t in transactions) {
      if (!t.income && t.paid) {
        totalSpentPeriod += t.amount.abs();
      }
    }

    // Identify top categories across the period
    Map<String, double> categoryTotalsAll = {};
    for (var t in transactions) {
      if (!t.income && t.paid) {
        categoryTotalsAll[t.categoryFk] =
            (categoryTotalsAll[t.categoryFk] ?? 0) + t.amount.abs();
      }
    }

    List<MapEntry<String, double>> sortedCategories =
        categoryTotalsAll.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    List<String> topCatPks =
        sortedCategories.take(4).map((e) => e.key).toList();

    // Palette for top categories + other
    Map<String, Color> categoryColors = {};
    for (String catPk in topCatPks) {
      TransactionCategory? cat = categoryMap[catPk];
      if (cat != null) {
        categoryColors[catPk] = HexColor(cat.colour,
            defaultColor: Theme.of(context).colorScheme.primary);
      } else {
        categoryColors[catPk] = Theme.of(context).colorScheme.primary;
      }
    }
    Color otherColor = getColor(context, "textLight").withOpacity(0.4);
    Color incomeColor = getColor(context, "incomeAmount");
    Color expenseColor = getColor(context, "expenseAmount");

    // Build bar groups
    double maxTotalY = 0;
    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < buckets.length; i++) {
      DateTimeRange bucket = buckets[i];
      List<Transaction> bucketTxs = transactions.where((t) {
        return t.dateCreated.isAfter(bucket.start) &&
            t.dateCreated.isBefore(bucket.end);
      }).toList();

      List<BarChartRodStackItem> stackItems = [];
      double currentY = 0;

      if (_mode == 0) {
        // Category mode (Expenses only)
        Map<String, double> catSpentInBucket = {};
        double otherSpent = 0;

        for (var t in bucketTxs) {
          if (!t.income && t.paid) {
            double amt = t.amount.abs();
            if (topCatPks.contains(t.categoryFk)) {
              catSpentInBucket[t.categoryFk] =
                  (catSpentInBucket[t.categoryFk] ?? 0) + amt;
            } else {
              otherSpent += amt;
            }
          }
        }

        for (String catPk in topCatPks) {
          double amt = catSpentInBucket[catPk] ?? 0;
          if (amt > 0) {
            stackItems.add(BarChartRodStackItem(
              currentY,
              currentY + amt,
              categoryColors[catPk] ?? Theme.of(context).colorScheme.primary,
            ));
            currentY += amt;
          }
        }

        if (otherSpent > 0) {
          stackItems.add(BarChartRodStackItem(
            currentY,
            currentY + otherSpent,
            otherColor,
          ));
          currentY += otherSpent;
        }
      } else {
        // Income vs Expense mode
        double expenseSum = 0;
        double incomeSum = 0;
        for (var t in bucketTxs) {
          if (t.paid) {
            if (t.income) {
              incomeSum += t.amount.abs();
            } else {
              expenseSum += t.amount.abs();
            }
          }
        }

        if (expenseSum > 0) {
          stackItems.add(BarChartRodStackItem(
            currentY,
            currentY + expenseSum,
            expenseColor,
          ));
          currentY += expenseSum;
        }
        if (incomeSum > 0) {
          stackItems.add(BarChartRodStackItem(
            currentY,
            currentY + incomeSum,
            incomeColor,
          ));
          currentY += incomeSum;
        }
      }

      if (currentY > maxTotalY) maxTotalY = currentY;

      double barWidth = _timeframe == StackedBarTimeframe.weeks4 ? 26 : 18;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: currentY,
              rodStackItems: stackItems,
              width: barWidth,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
              color: stackItems.isEmpty
                  ? getColor(context, "border").withOpacity(0.2)
                  : null,
            ),
          ],
        ),
      );
    }

    double chartMaxY = maxTotalY > 0 ? (maxTotalY * 1.2) : 100;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 13),
      child: Container(
        margin: const EdgeInsetsDirectional.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: getColor(context, "lightDarkAccentHeavyLight"),
          border: Border.all(
            color: getColor(context, "border").withOpacity(0.12),
            width: 1,
          ),
          boxShadow: boxShadowCheck(boxShadowGeneral(context)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        appStateSettings["outlinedIcons"]
                            ? Icons.bar_chart_outlined
                            : Icons.bar_chart_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      TextFont(
                        text: "comparative-spending".tr() != "comparative-spending"
                            ? "comparative-spending".tr()
                            : "Spending Breakdown",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  // Timeframe pills
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondaryContainer
                          .withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        _buildTimeframePill("7D", StackedBarTimeframe.days7),
                        _buildTimeframePill("4W", StackedBarTimeframe.weeks4),
                        _buildTimeframePill("6M", StackedBarTimeframe.months6),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Total amount row with mode switcher
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFont(
                        text: convertToMoney(allWallets, totalSpentPeriod),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      TextFont(
                        text: _mode == 0
                            ? ("total-expenses".tr() != "total-expenses"
                                ? "Total Expenses"
                                : "total-expenses".tr())
                            : ("income-and-expenses".tr() != "income-and-expenses"
                                ? "Income & Expenses"
                                : "income-and-expenses".tr()),
                        fontSize: 12,
                        textColor: getColor(context, "textLight"),
                      ),
                    ],
                  ),
                  Tappable(
                    borderRadius: 8,
                    color: Colors.transparent,
                    onTap: () {
                      _setMode(_mode == 0 ? 1 : 0);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: getColor(context, "border").withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _mode == 0
                                ? Icons.pie_chart_outline
                                : Icons.swap_vert,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          TextFont(
                            text: _mode == 0
                                ? ("by-category".tr() != "by-category"
                                    ? "By Category"
                                    : "by-category".tr())
                                : ("by-type".tr() != "by-type"
                                    ? "By Type"
                                    : "by-type".tr()),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            textColor: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Bar Chart
              SizedBox(
                height: 175,
                child: BarChart(
                  BarChartData(
                    maxY: chartMaxY,
                    minY: 0,
                    alignment: BarChartAlignment.spaceAround,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: chartMaxY / 3,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: getColor(context, "border").withOpacity(0.08),
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            int idx = value.toInt();
                            if (idx < 0 || idx >= buckets.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: TextFont(
                                text: _getBucketLabel(buckets[idx], idx),
                                fontSize: 11,
                                textColor: getColor(context, "textLight"),
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) =>
                            Theme.of(context).colorScheme.surfaceVariant,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          DateTimeRange b = buckets[group.x.toInt()];
                          String dateTitle =
                              _timeframe == StackedBarTimeframe.days7
                                  ? getWordedDateShort(b.start)
                                  : "${getWordedDateShort(b.start)} - ${getWordedDateShort(b.end)}";
                          String amt = convertToMoney(allWallets, rod.toY);
                          return BarTooltipItem(
                            "$dateTitle\n$amt",
                            TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                    barGroups: barGroups,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Category Legend
              if (_mode == 0 && topCatPks.isNotEmpty)
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    for (String catPk in topCatPks)
                      if (categoryTotalsAll[catPk] != null &&
                          categoryTotalsAll[catPk]! > 0)
                        _buildLegendItem(
                          color: categoryColors[catPk] ??
                              Theme.of(context).colorScheme.primary,
                          name: categoryMap[catPk]?.name ?? "Category",
                          amount: convertToMoney(
                              allWallets, categoryTotalsAll[catPk]!),
                        ),
                  ],
                )
              else if (_mode == 1)
                Row(
                  children: [
                    _buildLegendItem(
                      color: expenseColor,
                      name: "expense".tr(),
                      amount: null,
                    ),
                    const SizedBox(width: 14),
                    _buildLegendItem(
                      color: incomeColor,
                      name: "income".tr(),
                      amount: null,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeframePill(String label, StackedBarTimeframe tf) {
    bool isSelected = _timeframe == tf;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _setTimeframe(tf);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextFont(
          text: label,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          textColor: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String name,
    required String? amount,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        TextFont(
          text: name,
          fontSize: 11,
          textColor: getColor(context, "textLight"),
          fontWeight: FontWeight.bold,
        ),
        if (amount != null) ...[
          const SizedBox(width: 3),
          TextFont(
            text: "($amount)",
            fontSize: 10,
            textColor: getColor(context, "textLight").withOpacity(0.8),
          ),
        ],
      ],
    );
  }
}
