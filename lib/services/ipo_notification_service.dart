import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../core/db/app_database.dart';
import '../features/ipo/domain/calc_format.dart';

/// 상장일 로컬 푸시 알림 서비스
class IpoNotificationService {
  IpoNotificationService._();
  static final IpoNotificationService instance = IpoNotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// 알림 플러그인 및 타임존 초기화
  Future<void> initialize({
    void Function(String? payload)? onSelectNotification,
  }) async {
    if (kIsWeb || _isInitialized) return;

    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    } catch (_) {
      // 타임존 로드 실패 시 기본값 사용
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          onSelectNotification?.call(response.payload);
        }
      },
    );

    // 안드로이드 고유 알림 채널 등록
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'ipo_listing_channel',
          '공모주 상장일 알림',
          description: '공모주 상장일 D-1 저녁 및 상장 당일 아침 알림',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      // 알림 권한 요청 (Android 13+)
      await androidImplementation.requestNotificationsPermission();
      // 정확한 알람 권한 요청 (Android 12+)
      await androidImplementation.requestExactAlarmsPermission();
    }

    _isInitialized = true;
    debugPrint('IpoNotificationService 초기화 완료');
  }

  /// 해당 종목의 알림이 현재 활성화되어 있는지 여부 확인
  /// - 사용자가 명시적으로 ON/OFF한 설정이 있으면 그 설정값 우선
  /// - 설정값이 없으면 배정 수량(allotted > 0) 존재 여부에 따라 자동 결정
  Future<bool> isNotificationEnabled(
      int itemId, List<IpoRecordData> records) async {
    final prefs = await SharedPreferences.getInstance();
    final manual = prefs.getBool('notify_override_$itemId');
    if (manual != null) {
      return manual;
    }
    return records.any((r) => (r.allotted ?? 0) > 0);
  }

  /// 사용자가 스위치로 직접 알림 ON/OFF 변경
  Future<void> setNotificationEnabled({
    required IpoItemData item,
    required bool enabled,
    List<IpoRecordData> records = const [],
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notify_override_${item.id}', enabled);

    if (enabled) {
      String? mainUnderwriter;
      int totalAllotted = 0;
      final allottedRecords =
          records.where((r) => (r.allotted ?? 0) > 0).toList();

      if (allottedRecords.isNotEmpty) {
        mainUnderwriter = allottedRecords.first.accountName;
        totalAllotted =
            allottedRecords.fold(0, (sum, r) => sum + (r.allotted ?? 0));
      } else {
        mainUnderwriter = item.underwriter;
      }

      if (item.listOn != null) {
        await scheduleListingNotification(
          itemId: item.id,
          itemName: item.name,
          listOn: item.listOn!,
          underwriter: mainUnderwriter,
          allotted: totalAllotted > 0 ? totalAllotted : null,
          offerPrice: item.offerPrice > 0 ? item.offerPrice : null,
        );
      }
    } else {
      await cancelListingNotification(item.id);
    }
  }

  /// 종목의 배정 내역 저장/삭제 시 알림 상태 자동 갱신
  Future<void> updateNotificationForItem({
    required IpoItemData item,
    List<IpoRecordData> records = const [],
  }) async {
    if (item.listOn == null) return;

    final isEnabled = await isNotificationEnabled(item.id, records);

    if (isEnabled) {
      String? mainUnderwriter;
      int totalAllotted = 0;
      final allottedRecords =
          records.where((r) => (r.allotted ?? 0) > 0).toList();

      if (allottedRecords.isNotEmpty) {
        mainUnderwriter = allottedRecords.first.accountName;
        totalAllotted =
            allottedRecords.fold(0, (sum, r) => sum + (r.allotted ?? 0));
      } else {
        mainUnderwriter = item.underwriter;
      }

      await scheduleListingNotification(
        itemId: item.id,
        itemName: item.name,
        listOn: item.listOn!,
        underwriter: mainUnderwriter,
        allotted: totalAllotted > 0 ? totalAllotted : null,
        offerPrice: item.offerPrice > 0 ? item.offerPrice : null,
      );
    } else {
      await cancelListingNotification(item.id);
    }
  }

  /// 상장일 2단계 알림 예약 (D-1 저녁 20:00 & 당일 아침 08:35)
  Future<void> scheduleListingNotification({
    required int itemId,
    required String itemName,
    required DateTime listOn,
    String? underwriter,
    int? allotted,
    int? offerPrice,
  }) async {
    if (kIsWeb) return;
    if (!_isInitialized) await initialize();

    final now = DateTime.now();

    // 1. D-1 전날 저녁 20:00 알림
    final dMinus1 = listOn.subtract(const Duration(days: 1));
    final dMinus1Time =
        DateTime(dMinus1.year, dMinus1.month, dMinus1.day, 20, 0);

    if (dMinus1Time.isAfter(now)) {
      final id = itemId * 10 + 1;
      final title = '🔔 [상장 D-1] 내일 $itemName 상장일입니다!';
      final body = allotted != null && allotted > 0
          ? '${underwriter ?? "증권사"}에서 배정받은 $allotted주가 내일 입고됩니다. 계좌 로그인을 확인하세요!'
          : '내일 09시 $itemName 상장 예정입니다. (공모가: ${offerPrice != null ? CalcFormat.won(offerPrice) : "미정"})';

      await _scheduleSingle(
        id: id,
        title: title,
        body: body,
        scheduledDate: dMinus1Time,
        payload: '$itemId',
      );
      debugPrint('D-1 알림 예약 완료: $dMinus1Time ($title)');
    }

    // 2. 당일 아침 08:35 알림 (장 시작 25분 전 매도 대기)
    final dDayTime =
        DateTime(listOn.year, listOn.month, listOn.day, 8, 35);

    if (dDayTime.isAfter(now)) {
      final id = itemId * 10 + 2;
      final title = '🚀 [오늘 09:00 상장] $itemName 상장 25분 전!';
      final body = allotted != null && allotted > 0
          ? '${underwriter ?? "증권사"} 앱을 켜고 시초가 호가를 확인하세요! (배정 $allotted주)'
          : '오늘 오전 9시 상장 시작! 호가를 확인하세요. (공모가: ${offerPrice != null ? CalcFormat.won(offerPrice) : "미정"})';

      await _scheduleSingle(
        id: id,
        title: title,
        body: body,
        scheduledDate: dDayTime,
        payload: '$itemId',
      );
      debugPrint('D-Day 아침 알림 예약 완료: $dDayTime ($title)');
    }
  }

  /// 단일 스케줄 알림 등록 헬퍼
  Future<void> _scheduleSingle({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'ipo_listing_channel',
      '공모주 상장일 알림',
      channelDescription: '공모주 상장일 D-1 저녁 및 상장 당일 아침 알림',
      importance: Importance.high,
      priority: Priority.high,
      ticker: '공모주 상장 알림',
      icon: '@mipmap/launcher_icon',
    );

    const details = NotificationDetails(android: androidDetails);

    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzDateTime,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// 특정 종목의 모든 상장 알림 취소
  Future<void> cancelListingNotification(int itemId) async {
    if (kIsWeb) return;
    await _notificationsPlugin.cancel(id: itemId * 10 + 1);
    await _notificationsPlugin.cancel(id: itemId * 10 + 2);
    debugPrint('종목 $itemId 상장 알림 취소 완료');
  }

  /// 즉시 테스트 알림 발송 (기능 작동 검증용)
  Future<void> showTestNotification({
    String title = '🚀 [상장 알림 테스트] 엘리스그룹 상장 25분 전!',
    String body = '삼성증권 앱을 켜고 시초가 호가를 확인하세요! (배정 1주, 공모가 90,500원)',
  }) async {
    if (kIsWeb) return;
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'ipo_listing_channel',
      '공모주 상장일 알림',
      channelDescription: '공모주 상장일 D-1 저녁 및 상장 당일 아침 알림',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );

    const details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id: 9999,
      title: title,
      body: body,
      notificationDetails: details,
    );
    debugPrint('테스트 알림 발송 완료');
  }
}