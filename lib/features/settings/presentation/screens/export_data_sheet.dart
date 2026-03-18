import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> exportData(BuildContext context, WidgetRef ref) async {
  try {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Veriler hazırlanıyor...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
        margin: const EdgeInsets.all(AppSpacing.base),
        duration: const Duration(seconds: 1),
      ),
    );

    final incomes = ref.read(allIncomesProvider).value ?? [];
    final expenses = ref.read(allExpensesProvider).value ?? [];
    final savings = ref.read(allSavingsProvider).value ?? [];

    final rows = <List<String>>[
      ['Tür', 'Tutar', 'Kategori', 'Tarih', 'Not'],
    ];

    for (final i in incomes) {
      rows.add([
        'Gelir',
        i.amount.toStringAsFixed(2),
        i.category.label,
        '${i.date.day.toString().padLeft(2, '0')}.${i.date.month.toString().padLeft(2, '0')}.${i.date.year}',
        i.note ?? '',
      ]);
    }

    for (final e in expenses) {
      rows.add([
        'Gider',
        e.amount.toStringAsFixed(2),
        e.category.label,
        '${e.date.day.toString().padLeft(2, '0')}.${e.date.month.toString().padLeft(2, '0')}.${e.date.year}',
        e.note ?? '',
      ]);
    }

    for (final s in savings) {
      rows.add([
        'Birikim',
        s.amount.toStringAsFixed(2),
        s.category.label,
        '${s.date.day.toString().padLeft(2, '0')}.${s.date.month.toString().padLeft(2, '0')}.${s.date.year}',
        s.note ?? '',
      ]);
    }

    final csvData = const CsvEncoder().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/savvy_veriler.csv');
    await file.writeAsString(csvData);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Savvy - Finansal Verilerim',
      ),
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dışa aktarma başarısız: $e'),
          backgroundColor: AppColors.expense,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
          margin: const EdgeInsets.all(AppSpacing.base),
        ),
      );
    }
  }
}
