import 'package:budget/database/tables.dart';
import 'package:budget/struct/settings.dart';

enum CategoryType {
  both, // Blank / Default: can be used as expense or income
  expense, // Used only as expense
  income, // Used only as income
  transfer, // For transfer transactions (linked expense/income, excluded from summary)
  balanceCorrection, // For balance changes in account (toggleable to count in summary)
}

CategoryType getCategoryType(TransactionCategory category) {
  if (category.categoryPk == "0") return CategoryType.balanceCorrection;
  Map? types = appStateSettings["categoryTypes"] as Map?;
  String? typeStr = types?[category.categoryPk];
  if (typeStr == "both") return CategoryType.both;
  if (typeStr == "expense") return CategoryType.expense;
  if (typeStr == "income") return CategoryType.income;
  if (typeStr == "transfer") return CategoryType.transfer;
  if (typeStr == "balanceCorrection") return CategoryType.balanceCorrection;

  // If not explicitly saved in categoryTypes setting:
  if (category.income == true) {
    return CategoryType.income;
  }
  // Default type is blank/both (can be used as expense or income)
  return CategoryType.both;
}

Future<void> setCategoryType(String categoryPk, CategoryType type) async {
  Map<String, dynamic> types =
      Map<String, dynamic>.from(appStateSettings["categoryTypes"] ?? {});
  String typeStr;
  switch (type) {
    case CategoryType.both:
      typeStr = "both";
      break;
    case CategoryType.expense:
      typeStr = "expense";
      break;
    case CategoryType.income:
      typeStr = "income";
      break;
    case CategoryType.transfer:
      typeStr = "transfer";
      break;
    case CategoryType.balanceCorrection:
      typeStr = "balanceCorrection";
      break;
  }
  types[categoryPk] = typeStr;
  await updateSettings("categoryTypes", types, updateGlobalState: true);
}

bool isCategoryTypeTransfer(TransactionCategory? category) {
  if (category == null) return false;
  return getCategoryType(category) == CategoryType.transfer;
}

bool isCategoryTypeBalanceCorrection(TransactionCategory? category) {
  if (category == null) return false;
  return getCategoryType(category) == CategoryType.balanceCorrection ||
      category.categoryPk == "0";
}

bool isCategoryAllowedForIncome(
    TransactionCategory category, bool? selectedIncome) {
  if (selectedIncome == null) return true;
  if (category.categoryPk == "0") return false;

  CategoryType type = getCategoryType(category);
  switch (type) {
    case CategoryType.both:
      return true;
    case CategoryType.expense:
      return selectedIncome == false;
    case CategoryType.income:
      return selectedIncome == true;
    case CategoryType.transfer:
    case CategoryType.balanceCorrection:
      return false;
  }
}
