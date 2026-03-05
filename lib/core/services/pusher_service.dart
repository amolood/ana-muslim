import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../notifications/notifications_service.dart';

/// خدمة Pusher للاتصال الفوري (Real-time)
/// تستخدم فقط للإشعارات المخصصة من الإدارة
/// ملاحظة: جميع إشعارات الصلوات ورمضان تتم محلياً في التطبيق
class PusherService {
  static PusherChannelsFlutter? _pusher;
  static bool _initialized = false;

  static const Set<String> _ignoredInternalEvents = {
    'pusher:subscription_succeeded',
    'pusher_internal:subscription_succeeded',
    'pusher:ping',
    'pusher:pong',
  };

  static const Set<String> _noisyConnectionErrors = {
    'UnknownHostException',
    'Unable to resolve host',
    'ENOTFOUND',
  };

  /// تهيئة Pusher
  static Future<void> init() async {
    if (_initialized) return;

    try {
      // قراءة المفاتيح من .env
      final appKey = dotenv.env['PUSHER_KEY'] ?? '';
      final cluster = dotenv.env['PUSHER_CLUSTER'] ?? 'ap2';

      if (appKey.isEmpty) {
        throw Exception('Pusher key not found in .env');
      }

      _pusher = PusherChannelsFlutter.getInstance();

      await _pusher!.init(
        apiKey: appKey,
        cluster: cluster,
        onEvent: _onEvent,
        onSubscriptionSucceeded: _onSubscriptionSucceeded,
        onError: _onError,
        onSubscriptionError: _onSubscriptionError,
        onDecryptionFailure: _onDecryptionFailure,
        onMemberAdded: _onMemberAdded,
        onMemberRemoved: _onMemberRemoved,
        onConnectionStateChange: _onConnectionStateChange,
      );

      await _pusher!.connect();
      await _pusher!.subscribe(channelName: 'ana-muslim-channel');
      _initialized = true;

      debugPrint('✅ Pusher initialized and subscribed to ana-muslim-channel');
    } catch (e) {
      debugPrint('❌ Pusher initialization failed: $e');
      rethrow;
    }
  }

  /// الاشتراك في قناة
  static Future<void> subscribe(String channelName) async {
    if (!_initialized) {
      await init();
    }

    try {
      await _pusher!.subscribe(channelName: channelName);
      debugPrint('✅ Subscribed to channel: $channelName');
    } catch (e) {
      debugPrint('❌ Failed to subscribe to channel $channelName: $e');
    }
  }

  /// إلغاء الاشتراك من قناة
  static Future<void> unsubscribe(String channelName) async {
    try {
      await _pusher!.unsubscribe(channelName: channelName);
      debugPrint('✅ Unsubscribed from channel: $channelName');
    } catch (e) {
      debugPrint('❌ Failed to unsubscribe from channel $channelName: $e');
    }
  }

  /// فصل الاتصال
  static Future<void> disconnect() async {
    try {
      await _pusher?.disconnect();
      _initialized = false;
      debugPrint('✅ Pusher disconnected');
    } catch (e) {
      debugPrint('❌ Failed to disconnect Pusher: $e');
    }
  }

  // ─── Event Handlers ──────────────────────────────────────────────────────

  static void _onEvent(PusherEvent event) {
    if (_isInternalEvent(event.eventName)) {
      if (kDebugMode) {
        debugPrint('ℹ️ Pusher internal event ignored: ${event.eventName}');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('📨 Pusher Event:');
      debugPrint('  Channel: ${event.channelName}');
      debugPrint('  Event: ${event.eventName}');
      debugPrint('  Data: ${event.data}');
    }

    _handleEvent(event);
  }

  static void _onSubscriptionSucceeded(String channelName, dynamic data) {
    debugPrint('✅ Subscription succeeded: $channelName');
    debugPrint('  Data: $data');
  }

  static void _onSubscriptionError(String message, dynamic e) {
    debugPrint('❌ Subscription error: $message');
    debugPrint('  Error: $e');
  }

  static void _onDecryptionFailure(String event, String reason) {
    debugPrint('❌ Decryption failure: $event');
    debugPrint('  Reason: $reason');
  }

  static void _onMemberAdded(String channelName, PusherMember member) {
    debugPrint('👤 Member added to $channelName: ${member.userId}');
  }

  static void _onMemberRemoved(String channelName, PusherMember member) {
    debugPrint('👤 Member removed from $channelName: ${member.userId}');
  }

  static void _onError(String message, int? code, dynamic e) {
    final errorText = '$message ${e ?? ''}';

    if (_isNoisyConnectionError(errorText)) {
      if (kDebugMode) {
        debugPrint('ℹ️ Pusher transient network issue: $message');
      }
      return;
    }

    debugPrint('❌ Pusher error: $message (code: $code)');
    debugPrint('  Error: $e');
  }

  static void _onConnectionStateChange(
    String currentState,
    String previousState,
  ) {
    debugPrint('🔄 Connection state changed:');
    debugPrint('  From: $previousState');
    debugPrint('  To: $currentState');
  }

  // ─── Event Processing ────────────────────────────────────────────────────

  /// معالجة الأحداث الواردة من Pusher
  /// يتم استخدام Pusher فقط للإشعارات المخصصة من الإدارة
  /// جميع إشعارات الصلوات ورمضان تتم محلياً
  static Future<void> _handleEvent(PusherEvent event) async {
    switch (event.eventName) {
      case 'admin-notification':
        await _handleAdminNotification(event.data);
        break;

      default:
        if (kDebugMode) {
          debugPrint('⚠️ Unknown event type: ${event.eventName}');
        }
    }
  }

  static bool _isInternalEvent(String? eventName) {
    if (eventName == null || eventName.isEmpty) {
      return false;
    }

    return _ignoredInternalEvents.contains(eventName) ||
        eventName.startsWith('pusher_internal:');
  }

  static bool _isNoisyConnectionError(String errorText) {
    final lower = errorText.toLowerCase();

    for (final pattern in _noisyConnectionErrors) {
      if (lower.contains(pattern.toLowerCase())) {
        return true;
      }
    }

    return false;
  }

  /// معالجة الإشعارات المخصصة من الإدارة
  /// هذا النوع الوحيد من الإشعارات الذي يتم إرساله عبر Pusher
  static Future<void> _handleAdminNotification(String data) async {
    try {
      debugPrint('🔔 Admin notification received: $data');

      final json = jsonDecode(data) as Map<String, dynamic>;
      final title = (json['title'] as String?) ?? 'إشعار';
      final body = (json['body'] as String?) ?? '';
      final type = (json['type'] as String?) ?? 'general';

      await NotificationsService.showImmediate(
        title: title,
        body: body,
        payload: type,
      );
    } catch (e) {
      debugPrint('❌ Error handling admin notification: $e');
    }
  }
}
