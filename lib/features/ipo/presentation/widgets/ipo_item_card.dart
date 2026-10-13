import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database.dart';
import '../../domain/calc_format.dart';
import '../../domain/ipo_logic.dart';
import '../../domain/ipo_math.dart';
import '../ipo_detail_page.dart';
import '../providers/ipo_providers.dart';
import 'ipo_item_form_sheet.dart';
import '../../../../services/ipo_notification_service.dart';
import '../../domain/ipo_underwriters.dart';

class IpoItemCard extends ConsumerWidget {
  const IpoItemCard({
    super.key,
    required this.item,
  });

  final IpoItemData item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final badgeInfo = IpoLogic.badge(item, today);
    final isUrgent = IpoLogic.urgent(item, today);
    final isSubscriptionOpen = IpoLogic.isSubscriptionOpen(item, today);

    // 종목의 청약 기록 스트림 조회
    final recordsAsync = ref.watch(ipoRecordsForItemProvider(item.id));
    final records = recordsAsync.value ?? const [];

    final totalAllotted = IpoMath.totalAllotted(records);
    final totalProfit = IpoMath.total(records, item.offerPrice);
    final totalRate = IpoMath.totalRate(records, item.offerPrice);
    final hasRecords = records.isNotEmpty;

    // 배지 색상 결정
    Color badgeBgColor;
    Color badgeTextColor;
    switch (badgeInfo.tone) {
      case IpoTone.soon:
        badgeBgColor = Colors.orange.shade50;
        badgeTextColor = Colors.orange.shade800;
        break;
      case IpoTone.open:
        badgeBgColor = Colors.red.shade50;
        badgeTextColor = Colors.red.shade700;
        break;
      case IpoTone.done:
        badgeBgColor = Colors.grey.shade100;
        badgeTextColor = Colors.grey.shade600;
        break;
    }

    return Card(
      elevation: isUrgent ? 2 : 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isUrgent
            ? BorderSide(color: Colors.red.shade400, width: 1.5)
            : BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => IpoDetailPage(itemId: item.id),
            ),
          );
        },
        onLongPress: () => _showItemActions(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1열: 종목명 + 상태 배지 + 단계 안내
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: badgeTextColor.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      badgeInfo.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: badgeTextColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 2열: 청약 일정 및 공모가 정보
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 13, color: Colors.blueGrey.shade700),
                  const SizedBox(width: 4),
                  Text(
                    '청약 ${IpoLogic.period(item)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    item.offerPrice > 0
                        ? CalcFormat.won(item.offerPrice)
                        : '공모가 미정',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: item.offerPrice > 0
                          ? Colors.black87
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),

              // 2-1열: 환불/상장일 정보 & 최소 10주 증거금 표시 (예: 10주/3.9만원)
              Row(
                children: [
                  Icon(Icons.replay_outlined,
                      size: 13, color: Colors.teal.shade700),
                  const SizedBox(width: 4),
                  Text(
                    '환불 ${item.refundOn != null ? IpoLogic.day(item.refundOn!) : "미정"}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: item.refundOn != null
                          ? Colors.teal.shade800
                          : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.rocket_launch_outlined,
                      size: 13, color: Colors.blue.shade700),
                  const SizedBox(width: 4),
                  Text(
                    '상장 ${item.listOn != null ? IpoLogic.day(item.listOn!) : "미정"}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: item.listOn != null
                          ? Colors.blue.shade800
                          : Colors.grey.shade500,
                    ),
                  ),
                  const Spacer(),
                  if (item.offerPrice > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        CalcFormat.minDepositLabel(item.offerPrice),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),

              // 3열: 주관사 & 경쟁률
              Row(
                children: [
                  if (item.underwriter != null &&
                      item.underwriter!.isNotEmpty) ...[
                    Icon(Icons.account_balance_outlined,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.underwriter!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else
                    const Spacer(),
                  if (item.competition != null &&
                      item.competition!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '경쟁률 ${item.competition}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // 4열: 청약 신청 체크 버튼 (청약 기간에만) 또는 청약/배정 상태 표시 (기록이 있을 때)
              if (hasRecords || isSubscriptionOpen) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, thickness: 0.8),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (!hasRecords) ...[
                    // 아직 청약 전 -> 원터치 청약 신청 체크 버튼
                    Expanded(
                      child: InkWell(
                        onTap: () => _quickSubscribe(context, ref),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 7, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.shade300,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline,
                                  size: 15, color: Colors.blue.shade800),
                              const SizedBox(width: 6),
                              Text(
                                item.offerPrice > 0
                                    ? '청약 신청 체크 (10주 · ${CalcFormat.minDepositLabel(item.offerPrice)})'
                                    : '청약 신청 체크 (10주)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // 청약 완료 상태 -> 청약 완료 뱃지 버튼 (탭 시 취소 가능)
                    InkWell(
                      onTap: () => _cancelSubscription(context, ref, records),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF81C784)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle,
                                size: 14, color: Color(0xFF2E7D32)),
                            const SizedBox(width: 4),
                            Text(
                              '청약 완료 (${IpoMath.totalApplied(records)}주)',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (totalAllotted > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.teal.shade200),
                        ),
                        child: Text(
                          '배정 $totalAllotted주',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade900,
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (totalProfit != null) ...[
                      Text(
                        CalcFormat.signedWon(totalProfit),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: totalProfit > 0
                              ? Colors.redAccent.shade700
                              : (totalProfit < 0
                                  ? Colors.blue.shade700
                                  : Colors.black87),
                        ),
                      ),
                      if (totalRate != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(${CalcFormat.signedPercent(totalRate)})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: totalProfit > 0
                                ? Colors.redAccent.shade700
                                : (totalProfit < 0
                                    ? Colors.blue.shade700
                                    : Colors.black87),
                          ),
                        ),
                      ],
                    ],
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }

  Future<void> _quickSubscribe(BuildContext context, WidgetRef ref) async {
    final itemUnderwriters =
        IpoUnderwriters.parseItemUnderwriters(item.underwriter);
    final accountName = itemUnderwriters.isNotEmpty
        ? itemUnderwriters.first
        : (item.underwriter?.split(',').firstOrNull?.trim() ?? '기본계좌');
    const quantity = 10;
    final deposit = (item.offerPrice * quantity * 0.5).round();

    final repo = ref.read(ipoRepositoryProvider);
    await repo.saveRecord(
      itemId: item.id,
      accountName: accountName,
      quantity: quantity,
      deposit: deposit,
    );

    final updatedRecords = await repo.getRecords(item.id);
    await IpoNotificationService.instance.updateNotificationForItem(
      item: item,
      records: updatedRecords,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('\'\' 10주 청약이 체크(등록)되었습니다.'),
          backgroundColor: const Color(0xFF1565C0),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _cancelSubscription(
    BuildContext context,
    WidgetRef ref,
    List<IpoRecordData> records,
  ) async {
    if (records.isEmpty) return;

    if (records.length == 1) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('청약 취소'),
          content: Text(
              '\'\'의 청약 기록(주)을 취소(삭제)할까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('닫기'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('청약 취소'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final repo = ref.read(ipoRepositoryProvider);
        await repo.deleteRecord(records.first.id);
        final remaining = await repo.getRecords(item.id);
        await IpoNotificationService.instance.updateNotificationForItem(
          item: item,
          records: remaining,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('청약 기록이 취소되었습니다.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } else {
      final goDetail = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('청약 기록 확인'),
          content: Text(
              '등록된 청약 기록이 건 있습니다.\n상세 화면으로 이동하여 관리하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('상세 화면 이동'),
            ),
          ],
        ),
      );

      if (goDetail == true && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => IpoDetailPage(itemId: item.id)),
        );
      }
    }
  }

  void _showItemActions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('종목 정보 수정'),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => IpoItemFormSheet(item: item),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('종목 삭제', style: TextStyle(color: Colors.red)),
                subtitle: const Text('청약 기록도 함께 영구 삭제됩니다.'),
                onTap: () async {
                  Navigator.pop(context);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('종목 삭제'),
                      content: Text('\'${item.name}\' 종목과 관련된 모든 청약 기록을 삭제할까요?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('취소'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('삭제'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await ref
                        .read(ipoRepositoryProvider)
                        .deleteItem(item.id);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
