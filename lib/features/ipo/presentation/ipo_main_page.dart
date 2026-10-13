import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/ipo_item.dart';
import '../../../services/csv_export_service.dart';
import '../domain/ipo_logic.dart';
import 'providers/ipo_providers.dart';
import 'widgets/ipo_item_card.dart';
import 'widgets/ipo_item_form_sheet.dart';
import 'widgets/ipo_summary_card.dart';

/// 메인 화면 상단 공모주 목록 필터 탭
enum IpoFilterTab {
  all('전체'),
  applied('청약'),
  allotted('배정');

  final String label;
  const IpoFilterTab(this.label);
}

class IpoMainPage extends ConsumerStatefulWidget {
  const IpoMainPage({super.key});

  @override
  ConsumerState<IpoMainPage> createState() => _IpoMainPageState();
}

class _IpoMainPageState extends ConsumerState<IpoMainPage> {
  bool _isSyncing = false;
  String _syncStatus = '';
  IpoFilterTab _selectedFilterTab = IpoFilterTab.all;

  @override
  void initState() {
    super.initState();
    // 시작 시 자동 웹 크롤링 갱신은 실행하지 않음 (로컬 SQLite 데이터 즉시 표시)
  }

  /// 사용자가 상단 동기화(⟳) 버튼이나 당겨서 새로고침(Pull to Refresh)을 눌렀을 때만 실행
  Future<void> _startSync() async {
    if (_isSyncing) return;
    setState(() {
      _isSyncing = true;
      _syncStatus = '38커뮤니케이션에서 최신 일정을 확인하는 중...';
    });

    try {
      final syncService = ref.read(ipoSyncServiceProvider);
      final result = await syncService.syncFromWeb(
        onProgress: (msg) {
          if (mounted) setState(() => _syncStatus = msg);
        },
      );

      if (mounted) {
        if (result.inserted == 0 && result.updated == 0) {
          // 기존 데이터와 완전히 같아서 갱신할 항목이 없는 경우
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '새로운 변경 사항이 없습니다. (총 ${result.total}건 모두 최신 상태)',
              ),
              backgroundColor: Colors.blueGrey.shade700,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          // 기존 데이터와 비교하여 변경된 내용이 있는 경우에만 갱신 안내
          final changes = <String>[];
          if (result.inserted > 0) changes.add('신규 ${result.inserted}건 추가');
          if (result.updated > 0) changes.add('${result.updated}건 정보 갱신');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('동기화 완료: ${changes.join(", ")} (총 ${result.total}건 확인)'),
              backgroundColor: Colors.green.shade700,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('동기화 실패: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _syncStatus = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final monthItems = ref.watch(monthIpoItemsProvider);
    final allItemsAsync = ref.watch(ipoItemsStreamProvider);
    final allRecordsAsync = ref.watch(allIpoRecordsStreamProvider);
    final allRecords = allRecordsAsync.value ?? const [];

    // 청약 종목: 청약 수량(quantity > 0) 기록이 1건 이상 있는 종목
    final appliedItems = monthItems.where((item) {
      return allRecords.any((r) => r.itemId == item.id && r.quantity > 0);
    }).toList();

    // 배정 종목: 배정 수량(allotted > 0) 기록이 1건 이상 있는 종목
    final allottedItems = monthItems.where((item) {
      return allRecords.any((r) => r.itemId == item.id && (r.allotted ?? 0) > 0);
    }).toList();

    // 선택된 탭에 따라 표시할 종목 리스트
    final displayedItems = switch (_selectedFilterTab) {
      IpoFilterTab.all => monthItems,
      IpoFilterTab.applied => appliedItems,
      IpoFilterTab.allotted => allottedItems,
    };

    final now = DateTime.now();
    final isCurrentMonth =
        selectedMonth.year == now.year && selectedMonth.month == now.month;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '공모주 수첩 & 알리미',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '일정 수집 · 배정 수량 · 수익 관리',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          // 동기화 버튼 (스피너 애니메이션)
          if (_isSyncing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.sync),
              tooltip: '최신 공모주 크롤링 동기화',
              onPressed: _startSync,
            ),
          // 수동 종목 추가 버튼
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '종목 직접 추가',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => const IpoItemFormSheet(),
              );
            },
          ),
          // 더보기 메뉴 (CSV 내보내기 등)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) {
              if (val == 'csv') _exportCsv(allItemsAsync.value ?? const []);
              if (val == 'open_folder') CsvExportService.openDownloadsFolder(context);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.file_download_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('CSV 파일로 내보내기'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'open_folder',
                child: Row(
                  children: [
                    Icon(Icons.folder_open_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('다운로드 폴더 열기'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _startSync,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 동기화 진행 알림 배너
            if (_isSyncing)
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.blue.shade50,
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _syncStatus,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 월 네비게이션 컨트롤 바
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                       icon: const Icon(Icons.chevron_left),
                      tooltip: '이전 달',
                      onPressed: () {
                        ref.read(selectedMonthProvider.notifier).prevMonth();
                      },
                    ),
                    Text(
                      IpoLogic.monthLabel(selectedMonth),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      tooltip: '다음 달',
                      onPressed: () {
                        ref.read(selectedMonthProvider.notifier).nextMonth();
                      },
                    ),
                    const Spacer(),
                    if (!isCurrentMonth)
                      ActionChip(
                        label: const Text('오늘로', style: TextStyle(fontSize: 12)),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          ref.read(selectedMonthProvider.notifier).resetToToday();
                        },
                      ),
                  ],
                ),
              ),
            ),

            // 이번 달 수익 요약 카드
            const SliverToBoxAdapter(
              child: IpoSummaryCard(),
            ),

            // 전체 / 청약 / 배정 탭 필터 바 (수량 배지 표시)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEFF5),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: const Color(0xFFD5DFEB),
                      width: 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _buildFilterTabItem(
                        tab: IpoFilterTab.all,
                        count: monthItems.length,
                        isSelected: _selectedFilterTab == IpoFilterTab.all,
                      ),
                      const SizedBox(width: 4),
                      _buildFilterTabItem(
                        tab: IpoFilterTab.applied,
                        count: appliedItems.length,
                        isSelected: _selectedFilterTab == IpoFilterTab.applied,
                      ),
                      const SizedBox(width: 4),
                      _buildFilterTabItem(
                        tab: IpoFilterTab.allotted,
                        count: allottedItems.length,
                        isSelected: _selectedFilterTab == IpoFilterTab.allotted,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 월간 종목 수 표시 헤더
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      switch (_selectedFilterTab) {
                        IpoFilterTab.all =>
                          '${selectedMonth.month}월 전체 종목 (${monthItems.length}개)',
                        IpoFilterTab.applied =>
                          '${selectedMonth.month}월 청약 종목 (${appliedItems.length}개)',
                        IpoFilterTab.allotted =>
                          '${selectedMonth.month}월 배정 종목 (${allottedItems.length}개)',
                      },
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 공모주 종목 리스트
            if (displayedItems.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          switch (_selectedFilterTab) {
                            IpoFilterTab.all => Icons.event_busy_outlined,
                            IpoFilterTab.applied => Icons.assignment_outlined,
                            IpoFilterTab.allotted => Icons.stars_outlined,
                          },
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          switch (_selectedFilterTab) {
                            IpoFilterTab.all =>
                              '${selectedMonth.month}월에 예정된 공모주가 없습니다.',
                            IpoFilterTab.applied =>
                              '${selectedMonth.month}월에 청약 완료한 종목이 없습니다.',
                            IpoFilterTab.allotted =>
                              '${selectedMonth.month}월에 배정받은 종목이 없습니다.',
                          },
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          switch (_selectedFilterTab) {
                            IpoFilterTab.all =>
                              '상단 우측 동기화(⟳) 버튼을 눌러 최신 일정을 확인해보세요.',
                            IpoFilterTab.applied =>
                              '종목 카드를 눌러 청약 수량을 기록해보세요.',
                            IpoFilterTab.allotted =>
                              '청약 결과 발표 후 배정 수량을 입력해보세요.',
                          },
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: Colors.black38),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = displayedItems[index];
                    return IpoItemCard(item: item);
                  },
                  childCount: displayedItems.length,
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabItem({
    required IpoFilterTab tab,
    required int count,
    required bool isSelected,
  }) {
    // 탭별 명확하고 아름다운 시그니처 테마 컬러
    final tabThemeColor = switch (tab) {
      IpoFilterTab.all => const Color(0xFF1E88E5), // 비비드 로열 블루
      IpoFilterTab.applied => const Color(0xFF3949AB), // 프리미엄 딥 인디고
      IpoFilterTab.allotted => const Color(0xFF00897B), // 성공과 성과를 상징하는 딥 틸/에메랄드
    };

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_selectedFilterTab != tab) {
            setState(() {
              _selectedFilterTab = tab;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? tabThemeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: tabThemeColor.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tab.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF5A6E85),
                ),
              ),
              const SizedBox(width: 6),
              // 수량 배지 (Badge)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.28)
                      : const Color(0xFFD9E2EC),
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 0.8,
                        )
                      : null,
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportCsv(List<dynamic> items) async {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내보낼 공모주 데이터가 없습니다.')),
      );
      return;
    }

    final ipoItemList = items.map((i) {
      final start = IpoLogic.dateYmd(i.subscribeStart);
      final end = IpoLogic.dateYmd(i.subscribeEnd);
      return IpoItem(
        name: i.name,
        schedule: '$start~$end',
        confirmedPrice: i.offerPrice > 0 ? '${i.offerPrice}' : '-',
        expectedPrice: '',
        competitionRate: i.competition ?? '-',
        underwriter: i.underwriter ?? '',
        refundDate: i.refundOn != null ? IpoLogic.dateYmd(i.refundOn!) : '',
        listingDate: i.listOn != null ? IpoLogic.dateYmd(i.listOn!) : '',
        memo: i.memo ?? '',
      );
    }).toList();

    await CsvExportService.exportCsvFile(context, ipoItemList);
  }
}
