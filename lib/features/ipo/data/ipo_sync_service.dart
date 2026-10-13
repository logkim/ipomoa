import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import '../../../models/ipo_item.dart';
import '../../../services/ipo_crawler_service.dart';
import 'ipo_repository.dart';

/// 크롤링 데이터를 로컬 SQLite DB(Drift)와 동기화하는 서비스
class IpoSyncService {
  IpoSyncService({
    required IpoRepository repository,
    IpoCrawlerService? crawlerService,
  })  : _repository = repository,
        _crawlerService = crawlerService ?? IpoCrawlerService();

  final IpoRepository _repository;
  final IpoCrawlerService _crawlerService;

  /// 웹 크롤링을 수행하고 로컬 DB와 비교하여 달라진 경우에만 Upsert
  /// 반환값: ({int inserted, int updated, int unchanged, int total})
  Future<({int inserted, int updated, int unchanged, int total})> syncFromWeb({
    void Function(String message)? onProgress,
  }) async {
    if (kIsWeb) {
      onProgress?.call('웹 버전: 최신 공모주 데이터를 로드하는 중...');
      try {
        final jsonString = await rootBundle.loadString('assets/data/ipo_items.json');
        final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
        final items = jsonList
            .map((e) => IpoItem.fromJson(e as Map<String, dynamic>))
            .toList();
        return await syncItems(items);
      } catch (e) {
        debugPrint('웹 공모주 데이터 로드 에러: $e');
        return (inserted: 0, updated: 0, unchanged: 0, total: 0);
      }
    }

    onProgress?.call('38커뮤니케이션에서 공모주 일정을 수집하는 중...');
    final crawledItems = await _crawlerService.fetchIpoList(
      fetchDetails: true,
      onProgress: (current, total) {
        onProgress?.call('상세 정보 수집 중 ($current / $total)...');
      },
    );

    return syncItems(crawledItems);
  }

  /// 수집된 IpoItem 목록을 기존 로컬 DB와 비교하여 다른 경우에만 업데이트
  Future<({int inserted, int updated, int unchanged, int total})> syncItems(
    List<IpoItem> items,
  ) async {
    var inserted = 0;
    var updated = 0;
    var unchanged = 0;

    for (final item in items) {
      final name = item.name.trim();
      if (name.isEmpty) continue;

      // 청약 시작일 / 마감일 파싱
      final start = _parseDate(item.startDateFormatted);
      final end = _parseDate(item.endDateFormatted);

      // 일정 날짜가 최소한 파싱되지 않으면 스킵 (안전장치)
      if (start == null || end == null) {
        continue;
      }

      final refund = _parseDate(item.refundDateFormatted);
      final list = _parseDate(item.listingDateFormatted);

      final offerPrice = int.tryParse(item.numericPrice) ?? 0;
      final underwriter = item.underwriter.trim().isEmpty ? null : item.underwriter.trim();
      final competition =
          (item.competitionRate.isEmpty || item.competitionRate == '-')
              ? null
              : item.competitionRate.trim();

      // 기존 DB에 동일 이름 종목이 있는지 확인
      final existing = await _repository.getItemByName(name);

      if (existing == null) {
        // 1. 신규 종목 추가
        await _repository.saveItem(
          name: name,
          subscribeStart: start,
          subscribeEnd: end,
          refundOn: refund,
          listOn: list,
          offerPrice: offerPrice,
          underwriter: underwriter,
          memo: item.memo.trim().isEmpty ? null : item.memo.trim(),
          competition: competition,
        );
        inserted++;
      } else {
        // 2. 기존 종목과 실제 데이터 변경 여부 비교 (다를 때만 DB 갱신)
        final newRefund = refund ?? existing.refundOn;
        final newList = list ?? existing.listOn;
        final newOffer = offerPrice > 0 ? offerPrice : existing.offerPrice;
        final newUnderwriter = underwriter ?? existing.underwriter;
        final newCompetition = competition ?? existing.competition;

        final bool isDateChanged = existing.subscribeStart != start ||
            existing.subscribeEnd != end ||
            existing.refundOn != newRefund ||
            existing.listOn != newList;

        final bool isSpecChanged = existing.offerPrice != newOffer ||
            existing.underwriter != newUnderwriter ||
            existing.competition != newCompetition;

        if (isDateChanged || isSpecChanged) {
          // 사용자가 직접 적은 메모가 있다면 우선 보존
          final preservedMemo = (existing.memo != null && existing.memo!.isNotEmpty)
              ? existing.memo
              : (item.memo.trim().isEmpty ? null : item.memo.trim());

          await _repository.saveItem(
            id: existing.id,
            name: name,
            subscribeStart: start,
            subscribeEnd: end,
            refundOn: newRefund,
            listOn: newList,
            offerPrice: newOffer,
            underwriter: newUnderwriter,
            memo: preservedMemo,
            competition: newCompetition,
          );
          updated++;
        } else {
          unchanged++;
        }
      }
    }

    debugPrint(
        'IPO Sync 결과: 총 ${items.length}건 중 신규 $inserted건, 갱신 $updated건, 변경없음 $unchanged건');
    return (
      inserted: inserted,
      updated: updated,
      unchanged: unchanged,
      total: items.length,
    );
  }

  static DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    } catch (_) {}
    return null;
  }
}
