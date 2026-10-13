import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database.dart';
import '../../data/ipo_repository.dart';
import '../../data/ipo_sync_service.dart';
import '../../domain/ipo_logic.dart';
import '../../domain/ipo_math.dart';

/// 앱 전체에서 공유하는 Drift DB 싱글톤 프로바이더
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(() => db.close());
  return db;
});

/// 공모주 저장소 프로바이더
final ipoRepositoryProvider = Provider<IpoRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftIpoRepository(db);
});

/// 웹 크롤링 동기화 서비스 프로바이더
final ipoSyncServiceProvider = Provider<IpoSyncService>((ref) {
  final repo = ref.watch(ipoRepositoryProvider);
  return IpoSyncService(repository: repo);
});

/// 현재 사용자가 선택한 조회 월 관리 Notifier (Riverpod 3 호환)
class SelectedMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void setMonth(DateTime month) {
    state = month;
  }

  void prevMonth() {
    state = DateTime(state.year, state.month - 1);
  }

  void nextMonth() {
    state = DateTime(state.year, state.month + 1);
  }

  void resetToToday() {
    final now = DateTime.now();
    state = DateTime(now.year, now.month);
  }
}

final selectedMonthProvider =
    NotifierProvider<SelectedMonthNotifier, DateTime>(SelectedMonthNotifier.new);

/// DB의 모든 공모주 종목 스트림
final ipoItemsStreamProvider = StreamProvider<List<IpoItemData>>((ref) {
  final repo = ref.watch(ipoRepositoryProvider);
  return repo.watchItems();
});

/// DB의 모든 청약 기록 스트림
final allIpoRecordsStreamProvider = StreamProvider<List<IpoRecordData>>((ref) {
  final repo = ref.watch(ipoRepositoryProvider);
  return repo.watchAllRecords();
});

/// 특정 종목의 청약 기록 스트림
final ipoRecordsForItemProvider =
    StreamProvider.family<List<IpoRecordData>, int>((ref, itemId) {
  final repo = ref.watch(ipoRepositoryProvider);
  return repo.watchRecords(itemId);
});

/// 선택된 월의 공모주 목록
final monthIpoItemsProvider = Provider<List<IpoItemData>>((ref) {
  final items = ref.watch(ipoItemsStreamProvider).value ?? const [];
  final selectedMonth = ref.watch(selectedMonthProvider);
  return IpoLogic.inMonth(items, selectedMonth);
});

/// 선택된 월의 실현 손익 요약
final monthSummaryProvider = Provider<IpoSummary>((ref) {
  final items = ref.watch(ipoItemsStreamProvider).value ?? const [];
  final records = ref.watch(allIpoRecordsStreamProvider).value ?? const [];
  final selectedMonth = ref.watch(selectedMonthProvider);
  return IpoMath.summary(items, records, selectedMonth);
});

/// 계좌별 실현 손익 목록 (손익 높은 순)
final accountProfitsProvider = Provider<List<IpoAccountProfit>>((ref) {
  final items = ref.watch(ipoItemsStreamProvider).value ?? const [];
  final records = ref.watch(allIpoRecordsStreamProvider).value ?? const [];
  return IpoMath.byAccount(items, records);
});
