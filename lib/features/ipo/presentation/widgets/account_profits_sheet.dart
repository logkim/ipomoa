import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/calc_format.dart';
import '../providers/ipo_providers.dart';

/// 계좌별 실현 손익 목록을 보여주는 바텀시트
class AccountProfitsSheet extends ConsumerWidget {
  const AccountProfitsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountProfits = ref.watch(accountProfitsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.account_balance, size: 22, color: Color(0xFF1565C0)),
                  SizedBox(width: 8),
                  Text(
                    '증권사별 실현 손익',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                '청약 후 매도 완료된 기록 기준 누적 손익입니다.',
                style: TextStyle(fontSize: 12, color: Colors.black45),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: accountProfits.isEmpty
                    ? const Center(
                        child: Text(
                          '아직 매도 완료된 청약 기록이 없습니다.',
                          style: TextStyle(color: Colors.black45),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: accountProfits.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = accountProfits[index];
                          final isPos = item.profit > 0;
                          final isNeg = item.profit < 0;
                          final profitColor = isPos
                              ? Colors.redAccent.shade700
                              : (isNeg ? Colors.blue.shade700 : Colors.black87);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.person_outline,
                                        size: 18,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      item.accountName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  CalcFormat.signedWon(item.profit),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: profitColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
