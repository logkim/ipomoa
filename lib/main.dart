import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/ipo/presentation/ipo_detail_page.dart';
import 'models/ipo_item.dart';
import 'screens/splash_screen.dart';
import 'services/csv_export_service.dart';
import 'services/ipo_crawler_service.dart';
import 'services/ipo_notification_service.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 상장일 로컬 푸시 알림 초기화
  await IpoNotificationService.instance.initialize(
    onSelectNotification: (payload) {
      if (payload != null) {
        final itemId = int.tryParse(payload);
        if (itemId != null) {
          rootNavigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => IpoDetailPage(itemId: itemId),
            ),
          );
        }
      }
    },
  );

  runApp(
    const ProviderScope(
      child: IpoCrawlerApp(),
    ),
  );
}

class IpoCrawlerApp extends StatelessWidget {
  final bool autoPreload;

  const IpoCrawlerApp({
    super.key,
    this.autoPreload = true,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: '공모주 청약 알리미',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F8FA),
      ),
      home: SplashScreen(autoPreload: autoPreload),
    );
  }
}

class IpoListPage extends StatefulWidget {
  final List<IpoItem>? initialItems;
  final String? initialError;

  const IpoListPage({
    super.key,
    this.initialItems,
    this.initialError,
  });

  @override
  State<IpoListPage> createState() => _IpoListPageState();
}

class _IpoListPageState extends State<IpoListPage> {
  final IpoCrawlerService _crawlerService = IpoCrawlerService();
  List<IpoItem> _allIpoList = [];
  bool _isLoading = true;
  String? _errorMessage;

  // 상세 정보 수집 진행 상태
  bool _isFetchingDetails = false;
  int _detailCurrent = 0;
  int _detailTotal = 0;

  // 필터 및 검색
  String _selectedFilter = '당월'; // 전체, 당월, 차월, 마감
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialItems != null && widget.initialItems!.isNotEmpty) {
      _allIpoList = widget.initialItems!;
      _isLoading = false;
      _errorMessage = widget.initialError;
    } else {
      _loadIpoData();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadIpoData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isFetchingDetails = true;
      _detailCurrent = 0;
      _detailTotal = 0;
    });

    try {
      final items = await _crawlerService.fetchIpoList(
        fetchDetails: true,
        onProgress: (current, total) {
          if (mounted) {
            setState(() {
              _detailCurrent = current;
              _detailTotal = total;
            });
          }
        },
      );
      setState(() {
        _allIpoList = items;
        _isLoading = false;
        _isFetchingDetails = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
        _isFetchingDetails = false;
      });
    }
  }

  List<IpoItem> get _filteredList {
    return _allIpoList.where((item) {
      // 1. 검색어 필터
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchName = item.name.toLowerCase().contains(query);
        final matchUnderwriter = item.underwriter.toLowerCase().contains(query);
        if (!matchName && !matchUnderwriter) return false;
      }

      // 2. 상태 필터
      if (_selectedFilter == '당월') {
        return item.isCurrentMonth;
      } else if (_selectedFilter == '차월') {
        return item.isNextMonth;
      } else if (_selectedFilter == '마감') {
        return item.status == '청약마감';
      }

      return true;
    }).toList();
  }

  void _showMemoDialog(IpoItem item) {
    final memoController = TextEditingController(text: item.memo);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${item.name} 메모'),
        content: TextField(
          controller: memoController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: '공모주 관련 메모를 입력하세요 (예: 비례배정, 최소청약수량 등)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                item.memo = memoController.text.trim();
              });
              Navigator.pop(ctx);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.candlestick_chart, color: Color(0xFF1E88E5)),
            SizedBox(width: 8),
            Text(
              '공모주 청약 일정',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
          ],
        ),
        actions: [
          // CSV 저장 팝업 메뉴
          PopupMenuButton<String>(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'CSV 내보내기 / 저장',
            onSelected: (value) async {
              if (_filteredList.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('내보낼 데이터가 없습니다.')),
                );
                return;
              }
              if (value == 'file') {
                await CsvExportService.exportCsvFile(context, _filteredList);
              } else if (value == 'copy') {
                await CsvExportService.copyToClipboard(context, _filteredList);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'file',
                child: Row(
                  children: [
                    Icon(Icons.save_alt, color: Color(0xFF1E88E5)),
                    SizedBox(width: 8),
                    Text('CSV 파일로 저장 (Excel 호환)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy, color: Color(0xFF43A047)),
                    SizedBox(width: 8),
                    Text('엑셀에 붙여넣기용 복사'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
            onPressed: _loadIpoData,
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 상단 검색 바
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '종목명 또는 주간사 검색',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF1F3F5),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
            ),
          ),

          // 필터 칩 & 건수 & CSV 버튼
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('전체'),
                        const SizedBox(width: 8),
                        _buildFilterChip('당월'),
                        const SizedBox(width: 8),
                        _buildFilterChip('차월'),
                        const SizedBox(width: 8),
                        _buildFilterChip('마감'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (!_isLoading && _errorMessage == null)
                  Text(
                    '총 ${_filteredList.length}건',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),

          // 진행 표시줄 (상세 정보 수집 중일 때)
          if (_isFetchingDetails && _detailTotal > 0)
            LinearProgressIndicator(
              value: _detailCurrent / _detailTotal,
              backgroundColor: const Color(0xFFE3F2FD),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
            ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFE9ECEF)),

          // 본문 영역
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      bottomNavigationBar: _filteredList.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE9ECEF))),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('엑셀 복사 (클립보드)'),
                        onPressed: () => CsvExportService.copyToClipboard(context, _filteredList),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save_alt, size: 18),
                        label: const Text('CSV 파일 저장'),
                        onPressed: () => CsvExportService.exportCsvFile(context, _filteredList),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : Colors.black87,
      ),
      selectedColor: const Color(0xFF1E88E5),
      backgroundColor: const Color(0xFFF1F3F5),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = label;
          });
        }
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              _detailTotal > 0
                  ? '상세 일정(환불일/상장일) 수집 중... ($_detailCurrent / $_detailTotal)'
                  : '38커뮤니케이션 공모주 정보를 수집하는 중...',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadIpoData,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    final list = _filteredList;
    if (list.isEmpty) {
      return const Center(
        child: Text(
          '해당 조건에 맞는 공모주가 없습니다.',
          style: TextStyle(color: Colors.grey, fontSize: 15),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadIpoData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return _buildIpoCard(item);
        },
      ),
    );
  }

  Widget _buildIpoCard(IpoItem item) {
    final isClosed = item.status == '청약마감';
    final isActive = item.isActive;

    Color badgeColor;
    Color badgeTextColor;

    if (isActive) {
      badgeColor = const Color(0xFFFFEBEE);
      badgeTextColor = const Color(0xFFD32F2F);
    } else if (item.status.startsWith('D-')) {
      badgeColor = const Color(0xFFE3F2FD);
      badgeTextColor = const Color(0xFF1976D2);
    } else {
      badgeColor = const Color(0xFFEEEEEE);
      badgeTextColor = const Color(0xFF757575);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0.8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isActive ? Colors.redAccent.withValues(alpha: 0.4) : const Color(0xFFE5E7EB),
          width: isActive ? 1.5 : 1,
        ),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showMemoDialog(item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 종목명 + 상태 뱃지
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isClosed ? Colors.grey.shade700 : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.status,
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

              // 청약일정, 환불일, 상장일 정보
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    '청약: ${item.startDateFormatted} ~ ${item.endDateFormatted}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '환불일: ${item.refundDateFormatted.isEmpty ? '미정' : item.refundDateFormatted}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '상장일: ${item.listingDateFormatted.isEmpty ? '미정' : item.listingDateFormatted}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F3F5)),
              const SizedBox(height: 10),

              // 가격 및 주간사
              Row(
                children: [
                  Expanded(
                    child: _buildInfoColumn(
                      label: '공모가',
                      value: item.numericPrice.isEmpty ? '미확정' : '${item.numericPrice}원',
                      isHighlight: item.numericPrice.isNotEmpty,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                      label: '주간사',
                      value: item.underwriter,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                      label: '경쟁률',
                      value: item.competitionRate == '-' ? '-' : item.competitionRate,
                    ),
                  ),
                ],
              ),

              if (item.memo.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9C4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.note, size: 14, color: Colors.amber),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.memo,
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn({
    required String label,
    required String value,
    bool isHighlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            color: isHighlight ? const Color(0xFF1E88E5) : Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
