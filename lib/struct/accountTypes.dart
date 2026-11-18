import 'package:budget/database/tables.dart';
import 'package:budget/struct/settings.dart';
import 'package:flutter/material.dart';

enum AccountType {
  bank,
  cash,
  card,
  prepaid,
  savings,
  other,
}

String getAccountTypeName(AccountType type) {
  switch (type) {
    case AccountType.bank:
      return "Bank Account";
    case AccountType.cash:
      return "Cash";
    case AccountType.card:
      return "Card (Credit / Debit)";
    case AccountType.prepaid:
      return "Online Wallet / Prepaid";
    case AccountType.savings:
      return "Savings & Investments";
    case AccountType.other:
      return "Other";
  }
}

String getAccountTypeDescription(AccountType type) {
  switch (type) {
    case AccountType.bank:
      return "Checking, current, or daily banking account";
    case AccountType.cash:
      return "Physical cash, petty cash, or in-hand money";
    case AccountType.card:
      return "Credit card, debit card, or charge card";
    case AccountType.prepaid:
      return "Online wallet, digital wallet, UPI, transit, or prepaid card";
    case AccountType.savings:
      return "Savings, fixed deposit, stocks, or retirement";
    case AccountType.other:
      return "Other specialized or custom account";
  }
}

IconData getAccountTypeIcon(AccountType type, {bool outlined = false}) {
  switch (type) {
    case AccountType.bank:
      return outlined
          ? Icons.account_balance_outlined
          : Icons.account_balance_rounded;
    case AccountType.cash:
      return outlined ? Icons.payments_outlined : Icons.payments_rounded;
    case AccountType.card:
      return outlined ? Icons.credit_card_outlined : Icons.credit_card_rounded;
    case AccountType.prepaid:
      return outlined ? Icons.language_outlined : Icons.language_rounded;
    case AccountType.savings:
      return outlined ? Icons.savings_outlined : Icons.savings_rounded;
    case AccountType.other:
      return outlined ? Icons.wallet_outlined : Icons.wallet_rounded;
  }
}

AccountType getAccountTypeFromWallet(TransactionWallet? wallet) {
  if (wallet == null) return AccountType.bank;
  return getAccountTypeFromPk(wallet.walletPk, name: wallet.name);
}

AccountType getAccountTypeFromPk(String walletPk, {String? name}) {
  Map<String, dynamic> walletTypes =
      Map<String, dynamic>.from(appStateSettings["walletTypes"] ?? {});
  String? typeString = walletTypes[walletPk];
  if (typeString != null) {
    for (AccountType t in AccountType.values) {
      if (t.name == typeString) return t;
    }
  }

  // Fallback to name heuristic for intelligent initial defaulting
  if (name != null) {
    String lower = name.toLowerCase();
    if (lower.contains("cash")) return AccountType.cash;
    if (lower.contains("card") ||
        lower.contains("credit") ||
        lower.contains("debit")) {
      return AccountType.card;
    }
    if (lower.contains("online") ||
        lower.contains("digital") ||
        lower.contains("upi") ||
        lower.contains("gpay") ||
        lower.contains("phonepe") ||
        lower.contains("paypal") ||
        lower.contains("lite") ||
        lower.contains("prepaid") ||
        lower.contains("wallet") ||
        lower.contains("paytm") ||
        lower.contains("topup") ||
        lower.contains("top-up")) {
      return AccountType.prepaid;
    }
    if (lower.contains("save") ||
        lower.contains("saving") ||
        lower.contains("invest") ||
        lower.contains("stock") ||
        lower.contains("fd")) {
      return AccountType.savings;
    }
  }

  return AccountType.bank;
}

Future<void> setAccountTypeForWallet(String walletPk, AccountType type) async {
  Map<String, dynamic> walletTypes =
      Map<String, dynamic>.from(appStateSettings["walletTypes"] ?? {});
  walletTypes[walletPk] = type.name;
  await updateSettings("walletTypes", walletTypes, updateGlobalState: true);
}
