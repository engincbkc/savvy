import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:savvy/features/notifications/domain/notification_preferences.dart';

part 'notification_provider.g.dart';

const _kPrefsKey = 'notification_preferences';

@Riverpod(keepAlive: true)
class NotificationPreferencesNotifier
    extends _$NotificationPreferencesNotifier {
  @override
  Future<NotificationPreferences> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPrefsKey);
    if (raw == null) return const NotificationPreferences();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return NotificationPreferences.fromJson(json);
    } catch (_) {
      return const NotificationPreferences();
    }
  }

  Future<void> save(NotificationPreferences preferences) async {
    state = AsyncData(preferences);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefsKey, jsonEncode(preferences.toJson()));
  }
}
