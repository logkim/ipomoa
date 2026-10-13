import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../services/ipo_notification_service.dart';
import '../domain/calc_format.dart';
import '../domain/ipo_logic.dart';
import '../domain/ipo_math.dart';
import 'providers/ipo_providers.dart';
import 'widgets/ipo_item_form_sheet.dart';
import 'widgets/ipo_record_form_sheet.dart';
import 'widgets/ipo_record_inline_form.dart';

class IpoDetailPage extends ConsumerWidget {
  const IpoDetailPage({
    super.key,
    required this.itemId,
  });

  final int itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allItems = ref.watch(ipoItemsStreamProvider).value ?? const [];
    final item = allItems.where((i) => i.id == itemId).firstOrNull;

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('공모주 상세')),
        body: const Center(child: Text('종목을 찾을 수 없습니다.')),
      );
    }

    final recordsAsync = ref.watch(ipoRecordsForItemProvider(itemId));
    final records = recordsAsync.value ?? const [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final stageText = IpoLogic.stage(item, today);

    final totalApplied = IpoMath.totalApplied(records);
    final totalDeposit = IpoMath.totalDeposit(records);
    final totalAllotted = IpoMath.totalAllotted(records);
    final totalProfit = IpoMath.total(records, item.offerPrice);
    final totalRate = IpoMath.totalRate(records, item.offerPrice);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: '종목 정보 수정',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => IpoItemFormSheet(item: item),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: '종목 삭제',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('종목 삭제'),
                  content: Text('\'${item.name}\' 종목과 모든 청약 기록을 삭제할까요?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('취소'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('삭제'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await ref.read(ipoRepositoryProvider).deleteItem(item.id);
                await IpoNotificationService.instance
                    .cancelListingNotification(item.id);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 종목 핵심 스펙 및 타임라인 카드
            Card(
              elevation: 1.5,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            stageText,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              item.offerPrice > 0
                                  ? '공모가 ${CalcFormat.won(item.offerPrice)}'
                                  : '공모가 미정',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (item.offerPrice > 0) ...[
                              const SizedBox(height: 2),
                              Text(
                                '최소 ${CalcFormat.minDepositLabel(item.offerPrice)} (증거금 50%)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 일정 상세 타임라인
                    _InfoRow(
                      icon: Icons.date_range,
                      label: '청약 기간',
                      value: IpoLogic.period(item),
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.replay_outlined,
                      label: '환불일',
                      value: item.refundOn != null
                          ? IpoLogic.day(item.refundOn!)
                          : '미정',
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.trending_up_outlined,
                      label: '상장일',
                      value: item.listOn != null
                          ? IpoLogic.day(item.listOn!)
                          : '미정',
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.account_balance_outlined,
                      label: '주관사',
                      value: item.underwriter ?? '미정',
                    ),
                    if (item.competition != null &&
                        item.competition!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.analytics_outlined,
                        label: '청약 경쟁률',
                        value: item.competition!,
                        valueColor: Colors.blue.shade800,
                      ),
                    ],
                    if (item.memo != null && item.memo!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      Text(
                        '메모: ${item.memo}',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // 2. 상장일 푸시 알림 설정 카드 (자동/수동 통합)
            _ListingNotificationCard(
              item: item,
              records: records,
            ),
            const SizedBox(height: 16),

            // 3. 투자 현황 요약 카드
            Card(
              elevation: 1.5,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '내 청약 현황 요약',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatBox(
                          label: '총 청약 수량',
                          value: '$totalApplied주',
                        ),
                        _StatBox(
                          label: '총 증거금',
                          value: CalcFormat.won(totalDeposit),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _StatBox(
                          label: '총 배정 수량',
                          value: '$totalAllotted주',
                          highlight: totalAllotted > 0,
                        ),
                        _StatBox(
                          label: '총 실현 손익',
                          value: totalProfit != null
                              ? CalcFormat.signedWon(totalProfit)
                              : '-',
                          subValue: totalRate != null
                              ? CalcFormat.signedPercent(totalRate)
                              : null,
                          profitColor: totalProfit != null
                              ? (totalProfit > 0
                                  ? Colors.redAccent.shade700
                                  : (totalProfit < 0
                                      ? Colors.blue.shade700
                                      : Colors.black87))
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 3. 계좌별 청약 기록 리스트
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '청약 기록 (${records.length}건)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => _openRecordSheet(context, item),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('기록 추가'),
                  ),
                ],
              ),
            ),

            if (records.length <= 1)
              IpoRecordInlineForm(
                item: item,
                record: records.firstOrNull,
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  final profit = IpoMath.profit(record, item.offerPrice);
                  final rate = IpoMath.rate(record, item.offerPrice);

                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.account_balance,
                                        size: 16, color: Colors.blue.shade700),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    record.accountName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 18),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _openRecordSheet(
                                      context,
                                      item,
                                      record: record,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        size: 18, color: Colors.red),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () async {
                                      final del = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('기록 삭제'),
                                          content: const Text(
                                              '이 청약 기록을 삭제할까요?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: const Text('취소'),
                                            ),
                                            FilledButton(
                                              style: FilledButton.styleFrom(
                                                  backgroundColor: Colors.red),
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: const Text('삭제'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (del == true) {
                                        await ref
                                            .read(ipoRepositoryProvider)
                                            .deleteRecord(record.id);
                                        final remaining = records
                                            .where((r) => r.id != record.id)
                                            .toList();
                                        await IpoNotificationService.instance
                                            .updateNotificationForItem(
                                          item: item,
                                          records: remaining,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _RecordCol(
                                label: '청약 / 증거금',
                                value:
                                    '${record.quantity}주 (${CalcFormat.number(record.deposit)}원)',
                              ),
                              _RecordCol(
                                label: '배정 수량',
                                value: record.allotted != null
                                    ? '${record.allotted}주'
                                    : '발표 전',
                                isHighlight: record.allotted != null &&
                                    record.allotted! > 0,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _RecordCol(
                                label: '매도가 / 수수료',
                                value: record.soldPrice != null
                                    ? '${CalcFormat.won(record.soldPrice!)} (수수료 ${CalcFormat.won(record.fee)})'
                                    : '매도 전',
                              ),
                              _RecordCol(
                                label: '실현 손익',
                                value: profit != null
                                    ? '${CalcFormat.signedWon(profit)} (${CalcFormat.signedPercent(rate!)})'
                                    : '-',
                                textColor: profit != null
                                    ? (profit > 0
                                        ? Colors.redAccent.shade700
                                        : (profit < 0
                                            ? Colors.blue.shade700
                                            : Colors.black87))
                                    : Colors.black54,
                              ),
                            ],
                          ),
                          if (record.soldOn != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.event_available,
                                    size: 14, color: Colors.blue.shade700),
                                const SizedBox(width: 4),
                                Text(
                                  '매도일: ${IpoLogic.dateYmd(record.soldOn!)}'
                                  '${item.listOn != null && record.soldOn!.year == item.listOn!.year && record.soldOn!.month == item.listOn!.month && record.soldOn!.day == item.listOn!.day ? " (상장일 당일)" : ""}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (record.memo != null &&
                              record.memo!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              '메모: ${record.memo}',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: records.length >= 2
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: () => _openRecordSheet(context, item),
                    icon: const Icon(Icons.add),
                    label: const Text(
                      '청약 기록 추가',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  void _openRecordSheet(
    BuildContext context,
    IpoItemData item, {
    IpoRecordData? record,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => IpoRecordFormSheet(
        item: item,
        record: record,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    this.subValue,
    this.highlight = false,
    this.profitColor,
  });

  final String label;
  final String value;
  final String? subValue;
  final bool highlight;
  final Color? profitColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.black45)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: profitColor ??
                        (highlight ? Colors.green.shade800 : Colors.black87),
                  ),
                ),
                if (subValue != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    '($subValue)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: profitColor ?? Colors.black87,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordCol extends StatelessWidget {
  const _RecordCol({
    required this.label,
    required this.value,
    this.isHighlight = false,
    this.textColor,
  });

  final String label;
  final String value;
  final bool isHighlight;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black45)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor ??
                  (isHighlight ? Colors.green.shade700 : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

/// 상장일 푸시 알림 설정 카드 (자동 예약 및 수동 스위치)
class _ListingNotificationCard extends StatefulWidget {
  const _ListingNotificationCard({
    required this.item,
    required this.records,
  });

  final IpoItemData item;
  final List<IpoRecordData> records;

  @override
  State<_ListingNotificationCard> createState() =>
      _ListingNotificationCardState();
}

class _ListingNotificationCardState extends State<_ListingNotificationCard> {
  bool? _isEnabled;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  @override
  void didUpdateWidget(covariant _ListingNotificationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.records != widget.records ||
        oldWidget.item.id != widget.item.id) {
      _loadStatus();
    }
  }

  Future<void> _loadStatus() async {
    final status = await IpoNotificationService.instance.isNotificationEnabled(
      widget.item.id,
      widget.records,
    );
    if (mounted) {
      setState(() => _isEnabled = status);
    }
  }

  Future<void> _onToggle(bool value) async {
    setState(() => _isLoading = true);
    await IpoNotificationService.instance.setNotificationEnabled(
      item: widget.item,
      enabled: value,
      records: widget.records,
    );
    if (mounted) {
      setState(() {
        _isEnabled = value;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? '🔔 상장일 알림이 설정되었습니다. (D-1 20:00 & 당일 08:35)'
                : '🔕 상장일 알림이 해제되었습니다.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hasListDate = item.listOn != null;
    final allottedCount =
        widget.records.fold(0, (sum, r) => sum + (r.allotted ?? 0));
    final isAuto = allottedCount > 0;
    final enabled = _isEnabled ?? isAuto;

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: enabled && hasListDate
          ? Colors.blue.shade50.withValues(alpha: 0.5)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  enabled && hasListDate
                      ? Icons.notifications_active
                      : Icons.notifications_off_outlined,
                  color:
                      enabled && hasListDate ? Colors.blue.shade700 : Colors.grey,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      const Text(
                        '상장일 푸시 알림',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      if (!hasListDate)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('상장일 미정',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.black54)),
                        )
                      else if (enabled)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isAuto
                                ? Colors.indigo.shade100
                                : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isAuto ? '자동 예약(배정 $allottedCount주)' : '수동 예약',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isAuto
                                  ? Colors.indigo.shade900
                                  : Colors.blue.shade900,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('알림 꺼짐',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.black54)),
                        ),
                    ],
                  ),
                ),
                if (_isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Switch(
                    value: enabled && hasListDate,
                    onChanged: hasListDate ? _onToggle : null,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              hasListDate
                  ? '상장 전날(D-1) 20:00 주식 입고 확인 및 상장 당일 08:35 시초가 호가 알림을 휴대폰 푸시로 보내드립니다.'
                  : '상장일이 정해지면 자동으로 알림 스케줄을 설정할 수 있습니다.',
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade700, height: 1.3),
            ),
            if (hasListDate) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                  ),
                  icon: const Icon(Icons.send_outlined, size: 15),
                  label:
                      const Text('알림 테스트 발송', style: TextStyle(fontSize: 12)),
                  onPressed: () async {
                    await IpoNotificationService.instance.showTestNotification(
                      title: '🚀 [상장 알림 테스트] ${item.name} 상장 25분 전!',
                      body: allottedCount > 0
                          ? '배정받은 $allottedCount주를 확인하고 시초가 호가를 확인하세요! (공모가 ${CalcFormat.won(item.offerPrice)})'
                          : '오늘 오전 9시 ${item.name} 상장 시작! 호가를 확인하세요.',
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('📱 휴대폰 상단 알림바로 테스트 알림이 발송되었습니다!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
