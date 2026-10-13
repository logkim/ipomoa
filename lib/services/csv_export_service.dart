import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../models/ipo_item.dart';

class CsvExportService {
  static const List<String> csvHeaders = [
    '분류',
    '종목명',
    '청약 시작',
    '청약 마감',
    '환불일',
    '상장일',
    '공모가',
    '주간사',
    '경쟁률',
    '메모',
  ];

  /// CSV 텍스트 생성 (Excel 한글 깨짐 방지를 위해 UTF-8 BOM '\uFEFF' 포함)
  static String generateCsv(List<IpoItem> items, {bool includeBom = true}) {
    final rows = <List<dynamic>>[
      csvHeaders,
      ...items.map((item) => item.toCsvRow()),
    ];

    const converter = ListToCsvConverter();
    final csvContent = converter.convert(rows);

    return includeBom ? '\uFEFF$csvContent' : csvContent;
  }

  /// 클립보드에 CSV 텍스트 복사 (엑셀에 바로 붙여넣기 가능)
  static Future<void> copyToClipboard(BuildContext context, List<IpoItem> items) async {
    final csv = generateCsv(items, includeBom: false);
    await Clipboard.setData(ClipboardData(text: csv));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CSV 데이터가 클립보드에 복사되었습니다. (엑셀에 Ctrl+V로 붙여넣기 가능)'),
          backgroundColor: Color(0xFF1E88E5),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// CSV 파일 저장 및 다운로드
  static Future<String?> exportCsvFile(BuildContext context, List<IpoItem> items) async {
    try {
      final now = DateTime.now();
      final dateStr =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final fileName = '공모주일정_당월_$dateStr';
      final fullFileName = '$fileName.csv';

      final csvString = generateCsv(items, includeBom: true);
      final bytes = Uint8List.fromList(utf8.encode(csvString));

      String finalSavedPath = '';

      if (kIsWeb) {
        finalSavedPath = await FileSaver.instance.saveFile(
          name: fileName,
          bytes: bytes,
          fileExtension: 'csv',
          mimeType: MimeType.csv,
        );
      } else if (Platform.isAndroid) {
        // 안드로이드 공용 다운로드(Download) 폴더에 직접 저장
        try {
          final downloadDir = Directory('/storage/emulated/0/Download');
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
          final file = File('${downloadDir.path}/$fullFileName');
          await file.writeAsBytes(bytes);
          finalSavedPath = file.path;
        } catch (_) {
          // FileSaver fallback
          finalSavedPath = await FileSaver.instance.saveFile(
            name: fileName,
            bytes: bytes,
            fileExtension: 'csv',
            mimeType: MimeType.csv,
          );
        }
      } else {
        // Windows / Desktop
        try {
          final downloadsDir = await getDownloadsDirectory();
          if (downloadsDir != null) {
            final file = File('${downloadsDir.path}/$fullFileName');
            await file.writeAsBytes(bytes);
            finalSavedPath = file.path;
          } else {
            finalSavedPath = await FileSaver.instance.saveFile(
              name: fileName,
              bytes: bytes,
              fileExtension: 'csv',
              mimeType: MimeType.csv,
            );
          }
        } catch (_) {
          finalSavedPath = await FileSaver.instance.saveFile(
            name: fileName,
            bytes: bytes,
            fileExtension: 'csv',
            mimeType: MimeType.csv,
          );
        }
      }

      if (context.mounted) {
        _showSaveCompleteDialog(context, finalSavedPath.isNotEmpty ? finalSavedPath : fullFileName);
      }
      return finalSavedPath;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('파일 저장 중 오류가 발생하여 클립보드로 복사합니다: $e'),
            backgroundColor: Colors.orange,
          ),
        );
        await copyToClipboard(context, items);
      }
      return null;
    }
  }

  /// 저장 완료 안내 및 바로 열기 다이얼로그 표시
  static void _showSaveCompleteDialog(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 28),
            SizedBox(width: 8),
            Text('CSV 저장 완료', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '공모주 목록이 CSV 파일로 안전하게 저장되었습니다.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '저장 위치:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    filePath,
                    style: const TextStyle(fontSize: 12.5, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('경로 복사'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: filePath));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('저장 경로가 복사되었습니다.')),
              );
            },
          ),
          if (!kIsWeb && filePath.isNotEmpty)
            ElevatedButton.icon(
              icon: const Icon(Icons.folder_open, size: 18),
              label: const Text('파일 / 폴더 열기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  final result = await OpenFilex.open(filePath);
                  if (result.type != ResultType.done && context.mounted) {
                    // 파일 열기에 실패하면 부모 디렉터리 시도
                    final file = File(filePath);
                    if (await file.exists()) {
                      await OpenFilex.open(file.parent.path);
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('열기 중 오류가 발생했습니다: $e')),
                    );
                  }
                }
              },
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  /// 다운로드 폴더 직접 열기
  static Future<void> openDownloadsFolder([BuildContext? context]) async {
    try {
      if (Platform.isAndroid) {
        await OpenFilex.open('/storage/emulated/0/Download');
      } else {
        final dir = await getDownloadsDirectory();
        if (dir != null) {
          await OpenFilex.open(dir.path);
        }
      }
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('폴더 열기 중 오류: $e')),
        );
      }
    }
  }
}
