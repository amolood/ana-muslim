import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

/// خدمة Pusher للاتصال الفوري (Real-time)
/// تستخدم فقط للإشعارات المخصصة من الإدارة
/// ملاحظة: جميع إشعارات الصلوات ورمضان تتم محلياً في التطبيق
class PusherService {
  static PusherChannelsFlutter? _pusher;
  static bool _initialized = false;

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
      _initialized = true;

      print('✅ Pusher initialized successfully');
    } catch (e) {
      print('❌ Pusher initialization failed: $e');
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
      print('✅ Subscribed to channel: $channelName');
    } catch (e) {
      print('❌ Failed to subscribe to channel $channelName: $e');
    }
  }

  /// إلغاء الاشتراك من قناة
  static Future<void> unsubscribe(String channelName) async {
    try {
      await _pusher!.unsubscribe(channelName: channelName);
      print('✅ Unsubscribed from channel: $channelName');
    } catch (e) {
      print('❌ Failed to unsubscribe from channel $channelName: $e');
    }
  }

  /// فصل الاتصال
  static Future<void> disconnect() async {
    try {
      await _pusher?.disconnect();
      _initialized = false;
      print('✅ Pusher disconnected');
    } catch (e) {
      print('❌ Failed to disconnect Pusher: $e');
    }
  }

  // ─── Event Handlers ──────────────────────────────────────────────────────

  static void _onEvent(PusherEvent event) {
    print('📨 Pusher Event:');
    print('  Channel: ${event.channelName}');
    print('  Event: ${event.eventName}');
    print('  Data: ${event.data}');

    // يمكنك معالجة الأحداث هنا
    // مثال: إرسال إشعار محلي عند استقبال حدث معين
    _handleEvent(event);
  }

  static void _onSubscriptionSucceeded(String channelName, dynamic data) {
    print('✅ Subscription succeeded: $channelName');
    print('  Data: $data');
  }

  static void _onSubscriptionError(String message, dynamic e) {
    print('❌ Subscription error: $message');
    print('  Error: $e');
  }

  static void _onDecryptionFailure(String event, String reason) {
    print('❌ Decryption failure: $event');
    print('  Reason: $reason');
  }

  static void _onMemberAdded(String channelName, PusherMember member) {
    print('👤 Member added to $channelName: ${member.userId}');
  }

  static void _onMemberRemoved(String channelName, PusherMember member) {
    print('👤 Member removed from $channelName: ${member.userId}');
  }

  static void _onError(String message, int? code, dynamic e) {
    print('❌ Pusher error: $message (code: $code)');
    print('  Error: $e');
  }

  static void _onConnectionStateChange(
    String currentState,
    String previousState,
  ) {
    print('🔄 Connection state changed:');
    print('  From: $previousState');
    print('  To: $currentState');
  }

  // ─── Event Processing ────────────────────────────────────────────────────

  /// معالجة الأحداث الواردة من Pusher
  /// يتم استخدام Pusher فقط للإشعارات المخصصة من الإدارة
  /// جميع إشعارات الصلوات ورمضان تتم محلياً
  static void _handleEvent(PusherEvent event) {
    switch (event.eventName) {
      case 'admin-notification':
        _handleAdminNotification(event.data);
        break;

      default:
        print('⚠️ Unknown event type: ${event.eventName}');
    }
  }

  /// معالجة الإشعارات المخصصة من الإدارة
  /// هذا النوع الوحيد من الإشعارات الذي يتم إرساله عبر Pusher
  static void _handleAdminNotification(String data) {
    try {
      print('🔔 Admin notification received: $data');

      final json = jsonDecode(data);
      final title = json['title'] ?? 'إشعار';
      final body = json['body'] ?? '';
      final type = json['type'] ?? 'general';

      // TODO: عرض إشعار محلي
      // NotificationsService.showNotification(
      //   title: title,
      //   body: body,
      //   payload: type,
      // );

      print('  Title: $title');
      print('  Body: $body');
      print('  Type: $type');
    } catch (e) {
      print('❌ Error handling admin notification: $e');
    }
  }
}
