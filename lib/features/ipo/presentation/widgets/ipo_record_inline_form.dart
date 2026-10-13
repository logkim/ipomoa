import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database.dart';
import '../../../../services/ipo_notification_service.dart';
import '../../domain/calc_format.dart';
import '../../domain/ipo_logic.dart';
import '../../domain/ipo_math.dart';
import '../../domain/ipo_underwriters.dart';
import '../providers/ipo_providers.dart';

/// 상세화면 본문에 통으로 펼쳐져 나오는 청약 기록 인라인 폼 (0건 등록 / 1건 수정)
class IpoRecordInlineForm extends ConsumerStatefulWidget {
  const IpoRecordInlineForm({
    super.key,
    required this.item,
    this.record,
    this.onSaved,
  });

  final IpoItemData item;
  final IpoRecordData? record;
  final VoidCallback? onSaved;

  @override
  ConsumerState<IpoRecordInlineForm> createState() => _IpoRecordInlineFormState();
}

class _IpoRecordInlineFormState extends ConsumerState<IpoRecordInlineForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _accountController;
  late TextEditingController _quantityController;
  late TextEditingController _depositController;
  late TextEditingController _allottedController;
  late TextEditingController _soldPriceController;
  late TextEditingController _feeController;
  late TextEditingController _memoController;

  DateTime? _soldOn;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(covariant IpoRecordInlineForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.record?.id != widget.record?.id ||
        oldWidget.item.id != widget.item.id) {
      _initControllers();
    }
  }

  void _initControllers() {
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
    setState(() {});
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

    final isAllottedInvalid = allotted != null && allotted > quantity;
    final previewProfit =
        IpoMath.profitOf(allotted, soldPrice, fee, item.offerPrice);
    final previewRate =
        IpoMath.rateOf(allotted, soldPrice, fee, item.offerPrice);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isEdit ? Colors.blue.shade200 : Colors.indigo.shade100,
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더: 등록 상태 뱃지 및 액션
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: isEdit ? Colors.blue.shade50 : Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isEdit
                                ? Colors.blue.shade300
                                : Colors.indigo.shade300,
                          ),
                        ),
                        child: Text(
                          isEdit ? '청약 기록 (1건 수정)' : '기본 청약 입력 (1번째 계좌)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isEdit
                                ? Colors.blue.shade900
                                : Colors.indigo.shade900,
                          ),
                        ),
                      ),
                      if (isEdit && widget.record != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${widget.record!.quantity}주 청약완료',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isEdit)
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 20, color: Colors.red),
                      tooltip: '기록 삭제',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _confirmDelete,
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // 배정수량 초과 경고
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
                      const Icon(Icons.error_outline, size: 16, color: Colors.red),
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

              // 실시간 손익 미리보기
              if (previewProfit != null && !isAllottedInvalid) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                              fontSize: 15,
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

              TextFormField(
                controller: _accountController,
                decoration: const InputDecoration(
                  labelText: '청약 증권사 / 계좌명',
                  hintText: '예: KB증권, 미래에셋증권',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance_outlined),
                  isDense: true,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? '청약한 증권사를 입력해주세요.' : null,
              ),
              const SizedBox(height: 8),

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
                        isDense: true,
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
                        isDense: true,
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

              // 3. 배정 수량 & 매도 단가
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
                        isDense: true,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final a = int.tryParse(v);
                        if (a == null || a < 0) return '올바른 수량 필요';
                        final q = int.tryParse(_quantityController.text) ?? 0;
                        if (a > q) return '청약($q주) 초과 불가';
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
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 4. 수수료 & 매도일
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
                        isDense: true,
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
                          isDense: true,
                          suffixIcon: _soldOn != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () => setState(() => _soldOn = null),
                                )
                              : const Icon(Icons.calendar_today, size: 18),
                        ),
                        child: Text(
                          _soldOn != null ? IpoLogic.dateYmd(_soldOn!) : '선택 안 됨',
                          style: TextStyle(
                            fontSize: 13,
                            color: _soldOn != null ? Colors.black87 : Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 상장일 당일 매도 칩 & 수수료 칩
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
                        label: Text(f == 0 ? '0원' : '${CalcFormat.number(f)}원',
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
              const SizedBox(height: 12),

              // 5. 메모
              TextFormField(
                controller: _memoController,
                decoration: const InputDecoration(
                  labelText: '메모 (선택)',
                  hintText: '비례배정, 이체계좌 등 기록',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 18),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: isEdit
                        ? const Color(0xFF1565C0)
                        : const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveRecord,
                  icon: Icon(isEdit ? Icons.check : Icons.add_task),
                  label: Text(
                    isEdit ? '청약 기록 수정 저장' : '이 정보로 청약 기록 저장',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
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

    if (allotted != null && allotted > quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('배정 수량($allotted주)은 청약 수량($quantity주)보다 클 수 없습니다.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

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

    final updatedRecords = await repo.getRecords(widget.item.id);
    await IpoNotificationService.instance.updateNotificationForItem(
      item: widget.item,
      records: updatedRecords,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.record != null
                ? '\'${widget.item.name}\' 청약 기록이 수정되었습니다.'
                : '\'${widget.item.name}\' 청약 기록이 저장되었습니다.',
          ),
          backgroundColor: Colors.teal.shade800,
          duration: const Duration(seconds: 2),
        ),
      );
      widget.onSaved?.call();
    }
  }

  Future<void> _confirmDelete() async {
    if (widget.record == null) return;
    final del = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('이 청약 기록을 삭제할까요?'),
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

    if (del == true && mounted) {
      final repo = ref.read(ipoRepositoryProvider);
      await repo.deleteRecord(widget.record!.id);
      final remaining = await repo.getRecords(widget.item.id);
      await IpoNotificationService.instance.updateNotificationForItem(
        item: widget.item,
        records: remaining,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('청약 기록이 삭제되었습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}