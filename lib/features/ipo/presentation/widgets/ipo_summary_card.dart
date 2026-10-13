import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/calc_format.dart';
import '../providers/ipo_providers.dart';
import 'account_profits_sheet.dart';

/// 이번 달 실현 손익 및 누적 현황을 보여주는 요약 카드
class IpoSummaryCard extends ConsumerWidget {
  const IpoSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(monthSummaryProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final theme = Theme.of(context);

    final monthProfitStr = CalcFormat.signedWon(summary.month);
    final isPositive = summary.month > 0;
    final isNegative = summary.month < 0;

    final profitColor = isPositive
        ? Colors.redAccent.shade700
        : (isNegative ? Colors.blue.shade700 : Colors.black87);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => const AccountProfitsSheet(),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.monetization_on_outlined,
                          size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        '${selectedMonth.month}월 실현 손익',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '증권사별 손익',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.chevron_right,
                            size: 14, color: theme.colorScheme.primary),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    monthProfitStr,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: profitColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (summary.monthRate != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isPositive
                            ? Colors.red.withValues(alpha: 0.1)
                            : (isNegative
                                ? Colors.blue.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        CalcFormat.signedPercent(summary.monthRate!),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: profitColor,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, thickness: 0.8),
              const SizedBox(height: 12),
              Row(
                children: [
                  _SummaryItem(
                    label: '올해 누적',
                    value: CalcFormat.signedWon(summary.year),
                    color: summary.year > 0
                        ? Colors.redAccent.shade700
                        : (summary.year < 0 ? Colors.blue.shade700 : Colors.black87),
                  ),
                  _dividerVertical(),
                  _SummaryItem(
                    label: '전체 누적',
                    value: CalcFormat.signedWon(summary.all),
                    color: summary.all > 0
                        ? Colors.redAccent.shade700
                        : (summary.all < 0 ? Colors.blue.shade700 : Colors.black87),
                  ),
                  _dividerVertical(),
                  _SummaryItem(
                    label: '매도 완료',
                    value: '${summary.sold}건',
                    color: Colors.black87,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dividerVertical() {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.grey.shade300,
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
