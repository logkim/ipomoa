import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database.dart';
import '../../domain/calc_format.dart';
import '../../domain/ipo_logic.dart';
import '../../domain/ipo_math.dart';
import '../../domain/ipo_underwriters.dart';
import '../../../../services/ipo_notification_service.dart';
import '../providers/ipo_providers.dart';

/// 청약 기록 추가 및 수정 바텀시트
class IpoRecordFormSheet extends ConsumerStatefulWidget {
  const IpoRecordFormSheet({
    super.key,
    required this.item,
    this.record,
  });

  final IpoItemData item;
  final IpoRecordData? record;

  @override
  ConsumerState<IpoRecordFormSheet> createState() => _IpoRecordFormSheetState();
}

class _IpoRecordFormSheetState extends ConsumerState<IpoRecordFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _accountController;
  late final TextEditingController _quantityController;
  late final TextEditingController _depositController;
  late final TextEditingController _allottedController;
  late final TextEditingController _soldPriceController;
  late final TextEditingController _feeController;
  late final TextEditingController _memoController;

  DateTime? _soldOn;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    final item = widget.item;
    final itemUnderwriters =
        IpoUnderwriters.parseItemUnderwriters(item.underwriter);
    final initialAccount = r?.accountName ??
        (itemUnderwriters.isNotEmpty ? itemUnderwriters.first : '');

    _accountController = TextEditingController(text: initialAccount);
    _quantityController =
        TextEditingController(text: r != null ? '${r.quantity}' : '10');
    _depositController =
        TextEditingController(text: r != null ? '${r.deposit}' : '');
    _allottedController =
        TextEditingController(text: r?.allotted != null ? '${r!.allotted}' : '');
    _soldPriceController =
        TextEditingController(text: r?.soldPrice != null ? '${r!.soldPrice}' : '');
    _feeController =
        TextEditingController(text: r != null ? '${r.fee}' : '0');
    _memoController = TextEditingController(text: r?.memo ?? '');
    
    // 매도일 초기값: 기존 기록 매도일, 없으면 상장일이 지난 경우 상장일 기본 추천 가능
    _soldOn = r?.soldOn;

    // 신규 생성 시 증거금 50% 자동 계산
    if (r == null && item.offerPrice > 0) {
      final qty = int.tryParse(_quantityController.text) ?? 10;
      _depositController.text = '${(item.offerPrice * qty * 0.5).round()}';
    }

    _quantityController.addListener(_onQuantityChanged);
    _allottedController.addListener(() => setState(() {}));
    _soldPriceController.addListener(() => setState(() {}));
    _feeController.addListener(() => setState(() {}));
  }

  void _onQuantityChanged() {
    final offerPrice = widget.item.offerPrice;
    if (offerPrice <= 0) return;
    final qty = int.tryParse(_quantityController.text);
    if (qty != null && qty > 0) {
      _depositController.text = '${(offerPrice * qty * 0.5).round()}';
    }
    setState(() {}); // 배정수량 비교 유효성 상태 업데이트
  }

  @override
  void dispose() {
    _accountController.dispose();
    _quantityController.dispose();
    _depositController.dispose();
    _allottedController.dispose();
    _soldPriceController.dispose();
    _feeController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.record != null;
    final item = widget.item;
    final allRecords = ref.watch(allIpoRecordsStreamProvider).value ?? const [];
    final suggestedAccounts = IpoUnderwriters.suggestAccounts(allRecords);
    final itemUnderwriters =
        IpoUnderwriters.parseItemUnderwriters(item.underwriter);

    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final allotted = int.tryParse(_allottedController.text);
    final soldPrice = int.tryParse(_soldPriceController.text);
    final fee = int.tryParse(_feeController.text) ?? 0;

    // 배정수량이 청약수량보다 큰지 검사
    final isAllottedInvalid = allotted != null && allotted > quantity;

    // 실시간 예상 수익 및 수익률 계산
    final previewProfit =
        IpoMath.profitOf(allotted, soldPrice, fee, item.offerPrice);
    final previewRate =
        IpoMath.rateOf(allotted, soldPrice, fee, item.offerPrice);

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 상단 제목 및 공모가
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.name} · ${isEdit ? "기록 수정" : "청약 기록"}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.offerPrice > 0)
                      Text(
                        '공모가 ${CalcFormat.won(item.offerPrice)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // 핵심 일정 안내 카드 (청약일자 -> 환불일자 -> 상장일자 순)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueGrey.shade100),
                  ),
                  child: Column(
                    children: [
                      // 1. 청약일자
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_month_outlined,
                                  size: 15, color: Colors.blueGrey.shade700),
                              const SizedBox(width: 6),
                              Text(
                                '청약일자',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blueGrey.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            IpoLogic.period(item),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // 2. 환불일자
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.replay_outlined,
                                  size: 15, color: Colors.teal.shade700),
                              const SizedBox(width: 6),
                              Text(
                                '환불일자',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.teal.shade900,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            item.refundOn != null
                                ? IpoLogic.day(item.refundOn!)
                                : '미정',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: item.refundOn != null
                                  ? Colors.teal.shade800
                                  : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // 3. 상장일자
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.rocket_launch_outlined,
                                  size: 15, color: Colors.blue.shade700),
                              const SizedBox(width: 6),
                              Text(
                                '상장일자',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            item.listOn != null
                                ? IpoLogic.day(item.listOn!)
                                : '미정',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: item.listOn != null
                                  ? Colors.blue.shade800
                                  : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 배정수량 초과 경고 배너
                if (isAllottedInvalid) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '배정 수량($allotted주)은 청약 수량($quantity주)보다 클 수 없습니다.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // 실시간 미리보기 배너 (배정과 매도가 입력 시)
                if (previewProfit != null && !isAllottedInvalid) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: previewProfit >= 0
                          ? Colors.red.shade50
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: previewProfit >= 0
                            ? Colors.red.shade200
                            : Colors.blue.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '실현 손익 미리보기',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Row(
                          children: [
                            Text(
                              CalcFormat.signedWon(previewProfit),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: previewProfit >= 0
                                    ? Colors.red.shade700
                                    : Colors.blue.shade700,
                              ),
                            ),
                            if (previewRate != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                '(${CalcFormat.signedPercent(previewRate)})',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: previewProfit >= 0
                                      ? Colors.red.shade700
                                      : Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // 1. 청약 증권사 선택
                Row(
                  children: [
                    const Icon(Icons.account_balance, size: 16, color: Colors.blueGrey),
                    const SizedBox(width: 6),
                    const Text(
                      '청약 증권사 (주관사)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    if (itemUnderwriters.length > 1) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '주관사 ${itemUnderwriters.length}곳 중 선택',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                // 종목의 주관사(기관사)가 있는 경우 전용 선택 칩 표시
                if (itemUnderwriters.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: itemUnderwriters.map((uw) {
                      final isSelected =
                          _accountController.text.trim() == uw ||
                              _accountController.text.startsWith(uw);
                      return ChoiceChip(
                        avatar: Icon(
                          isSelected ? Icons.check_circle : Icons.account_balance,
                          size: 16,
                          color: isSelected ? Colors.white : Colors.blue.shade700,
                        ),
                        label: Text(
                          uw,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF1565C0),
                        backgroundColor: Colors.blue.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF0D47A1)
                                : Colors.blue.shade200,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _accountController.text = uw;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],

                // 직접 입력 또는 상세 명칭 필드
                TextFormField(
                  controller: _accountController,
                  decoration: const InputDecoration(
                    labelText: '청약 증권사 / 계좌명',
                    hintText: '예: 미래에셋증권, 한국투자증권',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance_outlined),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? '청약한 증권사를 입력해주세요.' : null,
                ),
                const SizedBox(height: 8),

                // 기타 주요 증권사 추천 칩 (종목 주관사 외 타사 이용 시)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: suggestedAccounts
                        .where((name) => !itemUnderwriters.contains(name))
                        .take(6)
                        .map((name) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          avatar: const Icon(Icons.account_balance_outlined,
                              size: 13, color: Colors.black54),
                          label: Text(name, style: const TextStyle(fontSize: 12)),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() {
                              _accountController.text = name;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),

                // 2. 청약 수량 & 증거금
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '청약 수량 (주)',
                          border: OutlineInputBorder(),
                          suffixText: '주',
                        ),
                        validator: (v) {
                          if (v == null || int.tryParse(v) == null || int.parse(v) <= 0) {
                            return '올바른 수량을 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _depositController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '증거금 (원)',
                          border: OutlineInputBorder(),
                          suffixText: '원',
                        ),
                        validator: (v) =>
                            v == null || int.tryParse(v) == null || int.parse(v) < 0
                                ? '올바른 증거금을 입력해주세요.'
                                : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 3. 배정 수량 & 매도 단가 (배정수량 <= 청약수량 검증)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _allottedController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '배정 수량 (주)',
                          hintText: '발표 전 비움',
                          border: OutlineInputBorder(),
                          suffixText: '주',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          final a = int.tryParse(v);
                          if (a == null || a < 0) return '올바른 수량을 입력해주세요.';
                          final q = int.tryParse(_quantityController.text) ?? 0;
                          if (a > q) {
                            return '청약($q주) 초과 불가';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _soldPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '매도 단가 (원)',
                          hintText: '매도 전 비움',
                          border: OutlineInputBorder(),
                          suffixText: '원',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 4. 수수료 & 매도일 (상장일 기준 매도 추천 칩)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _feeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '수수료 (원)',
                          border: OutlineInputBorder(),
                          suffixText: '원',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _soldOn ?? item.listOn ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setState(() => _soldOn = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: '매도일',
                            border: const OutlineInputBorder(),
                            suffixIcon: _soldOn != null
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () =>
                                        setState(() => _soldOn = null),
                                  )
                                : const Icon(Icons.calendar_today, size: 18),
                          ),
                          child: Text(
                            _soldOn != null
                                ? IpoLogic.dateYmd(_soldOn!)
                                : '선택 안 됨',
                            style: TextStyle(
                              fontSize: 14,
                              color: _soldOn != null
                                  ? Colors.black87
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 매도일 추천 칩 (상장일 당일 매도 설정) 및 수수료 칩
                Row(
                  children: [
                    if (item.listOn != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          avatar: const Icon(Icons.trending_up, size: 14),
                          label: Text(
                            '상장일(${IpoLogic.day(item.listOn!)}) 매도',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Colors.blue.shade50,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() => _soldOn = item.listOn);
                          },
                        ),
                      ),
                    ],
                    ...[0, 1000, 2000, 3000].map((f) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          label: Text(
                              f == 0 ? '0원' : '${CalcFormat.number(f)}원',
                              style: const TextStyle(fontSize: 11)),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            _feeController.text = '$f';
                          },
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 14),

                // 5. 메모
                TextFormField(
                  controller: _memoController,
                  decoration: const InputDecoration(
                    labelText: '메모 (선택)',
                    hintText: '비례배정, 이체계좌 등 기록',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // 저장 버튼
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _saveRecord,
                    child: Text(
                      isEdit ? '수정 완료' : '청약 기록 저장',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    final quantity = int.parse(_quantityController.text);
    final deposit = int.parse(_depositController.text);
    final allotted = int.tryParse(_allottedController.text);
    final soldPrice = int.tryParse(_soldPriceController.text);
    final fee = int.tryParse(_feeController.text) ?? 0;
    final account = _accountController.text.trim();
    final memo = _memoController.text.trim().isEmpty ? null : _memoController.text.trim();

    // 배정수량이 청약수량보다 클 수 없음 (이중 검증)
    if (allotted != null && allotted > quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('배정 수량($allotted주)은 청약 수량($quantity주)보다 클 수 없습니다.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    // 매도가를 입력했는데 매도일이 비어있으면 상장일 또는 오늘 날짜로 자동 설정
    var soldDate = _soldOn;
    if (soldPrice != null && soldDate == null) {
      soldDate = widget.item.listOn ?? DateTime.now();
    }

    final repo = ref.read(ipoRepositoryProvider);

    await repo.saveRecord(
      id: widget.record?.id,
      itemId: widget.item.id,
      accountName: account,
      quantity: quantity,
      deposit: deposit,
      allotted: allotted,
      soldPrice: soldPrice,
      fee: fee,
      soldOn: soldDate,
      memo: memo,
    );

    // 배정 수량 변경 시 상장일 알림 스케줄 자동 갱신
    final updatedRecords = await repo.getRecords(widget.item.id);
    await IpoNotificationService.instance.updateNotificationForItem(
      item: widget.item,
      records: updatedRecords,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
