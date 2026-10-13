import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database.dart';
import '../../domain/ipo_logic.dart';
import '../../domain/ipo_underwriters.dart';
import '../providers/ipo_providers.dart';

/// 공모주 종목 추가 및 수정 바텀시트
class IpoItemFormSheet extends ConsumerStatefulWidget {
  const IpoItemFormSheet({
    super.key,
    this.item,
  });

  final IpoItemData? item;

  @override
  ConsumerState<IpoItemFormSheet> createState() => _IpoItemFormSheetState();
}

class _IpoItemFormSheetState extends ConsumerState<IpoItemFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _offerPriceController;
  late final TextEditingController _underwriterController;
  late final TextEditingController _competitionController;
  late final TextEditingController _memoController;

  late DateTime _subscribeStart;
  late DateTime _subscribeEnd;
  DateTime? _refundOn;
  DateTime? _listOn;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    final now = DateTime.now();
    _subscribeStart = item?.subscribeStart ?? DateTime(now.year, now.month, now.day);
    _subscribeEnd = item?.subscribeEnd ?? DateTime(now.year, now.month, now.day + 1);
    _refundOn = item?.refundOn;
    _listOn = item?.listOn;

    _nameController = TextEditingController(text: item?.name ?? '');
    _offerPriceController = TextEditingController(
        text: item != null && item.offerPrice > 0 ? '${item.offerPrice}' : '');
    _underwriterController = TextEditingController(text: item?.underwriter ?? '');
    _competitionController = TextEditingController(text: item?.competition ?? '');
    _memoController = TextEditingController(text: item?.memo ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _offerPriceController.dispose();
    _underwriterController.dispose();
    _competitionController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    final allItems = ref.watch(ipoItemsStreamProvider).value ?? const [];
    final suggestedUnderwriters = IpoUnderwriters.suggestUnderwriters(allItems);
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
                Text(
                  isEdit ? '종목 정보 수정' : '새 공모주 종목 추가',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // 1. 종목명
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '종목명',
                    hintText: '예: 모아전자',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? '종목명을 입력해주세요.' : null,
                ),
                const SizedBox(height: 14),

                // 2. 청약 일정 (시작일 ~ 마감일)
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _subscribeStart,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setState(() {
                              _subscribeStart = picked;
                              if (_subscribeEnd.isBefore(_subscribeStart)) {
                                _subscribeEnd = _subscribeStart;
                              }
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '청약 시작일',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today, size: 16),
                          ),
                          child: Text(
                            IpoLogic.dateYmd(_subscribeStart),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _subscribeEnd,
                            firstDate: _subscribeStart,
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setState(() => _subscribeEnd = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '청약 마감일',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today, size: 16),
                          ),
                          child: Text(
                            IpoLogic.dateYmd(_subscribeEnd),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 3. 환불일 & 상장일
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _refundOn ?? _subscribeEnd.add(const Duration(days: 2)),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setState(() => _refundOn = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: '환불일',
                            border: const OutlineInputBorder(),
                            suffixIcon: _refundOn != null
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 16),
                                    onPressed: () => setState(() => _refundOn = null),
                                  )
                                : const Icon(Icons.calendar_today, size: 16),
                          ),
                          child: Text(
                            _refundOn != null ? IpoLogic.dateYmd(_refundOn!) : '미정',
                            style: TextStyle(
                              fontSize: 13,
                              color: _refundOn != null ? Colors.black87 : Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _listOn ?? _subscribeEnd.add(const Duration(days: 10)),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setState(() => _listOn = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: '상장일',
                            border: const OutlineInputBorder(),
                            suffixIcon: _listOn != null
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 16),
                                    onPressed: () => setState(() => _listOn = null),
                                  )
                                : const Icon(Icons.calendar_today, size: 16),
                          ),
                          child: Text(
                            _listOn != null ? IpoLogic.dateYmd(_listOn!) : '미정',
                            style: TextStyle(
                              fontSize: 13,
                              color: _listOn != null ? Colors.black87 : Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 4. 공모가 & 경쟁률
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _offerPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '공모가 (원)',
                          hintText: '0이면 미정',
                          border: OutlineInputBorder(),
                          suffixText: '원',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _competitionController,
                        decoration: const InputDecoration(
                          labelText: '청약 경쟁률',
                          hintText: '예: 1500:1',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 5. 주관사 + 추천 칩
                TextFormField(
                  controller: _underwriterController,
                  decoration: const InputDecoration(
                    labelText: '주관사 (증권사)',
                    hintText: '예: 한국투자증권, 미래에셋증권',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: suggestedUnderwriters.take(6).map((u) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          label: Text(u, style: const TextStyle(fontSize: 11)),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            final current = _underwriterController.text.trim();
                            if (current.isEmpty) {
                              _underwriterController.text = u;
                            } else if (!current.contains(u)) {
                              _underwriterController.text = '$current, $u';
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),

                // 6. 메모
                TextFormField(
                  controller: _memoController,
                  decoration: const InputDecoration(
                    labelText: '메모 (선택)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // 저장 버튼
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _saveItem,
                    child: Text(
                      isEdit ? '수정 완료' : '종목 저장',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final offerPrice = int.tryParse(_offerPriceController.text) ?? 0;
    final underwriter = _underwriterController.text.trim().isEmpty
        ? null
        : _underwriterController.text.trim();
    final competition = _competitionController.text.trim().isEmpty
        ? null
        : _competitionController.text.trim();
    final memo = _memoController.text.trim().isEmpty ? null : _memoController.text.trim();

    final repo = ref.read(ipoRepositoryProvider);

    await repo.saveItem(
      id: widget.item?.id,
      name: name,
      subscribeStart: _subscribeStart,
      subscribeEnd: _subscribeEnd,
      refundOn: _refundOn,
      listOn: _listOn,
      offerPrice: offerPrice,
      underwriter: underwriter,
      memo: memo,
      competition: competition,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
