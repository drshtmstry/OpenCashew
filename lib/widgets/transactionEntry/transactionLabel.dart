import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';

class TransactionLabel extends StatelessWidget {
  const TransactionLabel({
    required this.transaction,
    this.category,
    required this.fontSize,
    super.key,
  });
  final Transaction transaction;
  final TransactionCategory? category;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    if (transaction.name.trim() != "") {
      return TransactionTitleNameLabel(
          transaction: transaction, fontSize: fontSize);
    } else if (transaction.payee != null && transaction.payee!.trim() != "") {
      return TextFont(
        text: transaction.payee!,
        fontSize: fontSize,
        maxLines: appStateSettings["fadeTransactionNameOverflows"] == false ? null : 1,
        overflow: appStateSettings["fadeTransactionNameOverflows"] == false
            ? null
            : TextOverflow.fade,
      );
    } else {
      return TransactionCategoryNameLabel(
          transaction: transaction, fontSize: fontSize);
    }
  }
}

class TransactionTitleNameLabel extends StatelessWidget {
  const TransactionTitleNameLabel(
      {required this.transaction, required this.fontSize, super.key});
  final Transaction transaction;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return TextFont(
      text: transaction.name,
      fontSize: fontSize,
      maxLines:
          appStateSettings["fadeTransactionNameOverflows"] == false ? null : 1,
      overflow: appStateSettings["fadeTransactionNameOverflows"] == false
          ? null
          : TextOverflow.fade,
      softWrap: appStateSettings["fadeTransactionNameOverflows"] == false
          ? null
          : false,
    );
  }
}

class TransactionCategoryNameLabel extends StatelessWidget {
  const TransactionCategoryNameLabel({
    required this.transaction,
    this.category,
    required this.fontSize,
    super.key,
  });
  final Transaction transaction;
  final TransactionCategory? category;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    String formatSubtitle(String catName) {
      if (transaction.name.trim() != "" &&
          transaction.payee != null &&
          transaction.payee!.trim() != "") {
        return "${transaction.payee!} • $catName";
      }
      return catName;
    }

    return category == null
        ? StreamBuilder<TransactionCategory>(
            stream: database.getCategory(transaction.categoryFk).$1,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return TextFont(
                  text: formatSubtitle(snapshot.data!.name),
                  fontSize: fontSize,
                  maxLines:
                      appStateSettings["fadeTransactionNameOverflows"] == false
                          ? null
                          : 1,
                  overflow:
                      appStateSettings["fadeTransactionNameOverflows"] == false
                          ? null
                          : TextOverflow.fade,
                  softWrap:
                      appStateSettings["fadeTransactionNameOverflows"] == false
                          ? null
                          : false,
                );
              }
              return SizedBox.shrink();
            },
          )
        : TextFont(
            text: formatSubtitle(category!.name),
            fontSize: fontSize,
            maxLines: appStateSettings["fadeTransactionNameOverflows"] == false
                ? null
                : 1,
            overflow: appStateSettings["fadeTransactionNameOverflows"] == false
                ? null
                : TextOverflow.fade,
            softWrap: appStateSettings["fadeTransactionNameOverflows"] == false
                ? null
                : false,
          );
  }
}

Future<String> getTransactionLabel(Transaction transaction,
    {TransactionCategory? category}) async {
  if (transaction.name.trim() != "") {
    return transaction.name.capitalizeFirst;
  } else if (transaction.payee != null && transaction.payee!.trim() != "") {
    return transaction.payee!.capitalizeFirst;
  } else {
    if (category == null) {
      TransactionCategory categorySearch =
          await database.getCategory(transaction.categoryFk).$2;
      return categorySearch.name.capitalizeFirst;
    } else {
      return category.name.capitalizeFirst;
    }
  }
}

String getTransactionLabelSync(
    Transaction transaction, TransactionCategory? category) {
  if (transaction.name.trim() != "") {
    return transaction.name.capitalizeFirst;
  } else if (transaction.payee != null && transaction.payee!.trim() != "") {
    return transaction.payee!.capitalizeFirst;
  } else {
    return category?.name.capitalizeFirst ?? transaction.name.capitalizeFirst;
  }
}
