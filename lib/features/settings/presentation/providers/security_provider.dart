import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'security_provider.g.dart';

/// Security settings state.
@immutable
class SecuritySettings {
  final bool appLockEnabled;
  final int autoLockMinutes; // 0 = immediately, 1, 5, 15
  final bool screenshotProtection;

  const SecuritySettings({
    this.appLockEnabled = false,
    this.autoLockMinutes = 1,
    this.screenshotProtection = false,
  });

  SecuritySettings copyWith({
    bool? appLockEnabled,
    int? autoLockMinutes,
    bool? screenshotProtection,
  }) {
    return SecuritySettings(
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
      screenshotProtection: screenshotProtection ?? this.screenshotProtection,
    );
  }
}

@Riverpod(keepAlive: true)
class SecuritySettingsNotifier extends _$SecuritySettingsNotifier {
  static const _keyAppLock = 'security_app_lock';
  static const _keyAutoLock = 'security_auto_lock_minutes';
  static const _keyScreenshot = 'security_screenshot_protection';

  @override
  SecuritySettings build() {
    _loadFromPrefs();
    return const SecuritySettings();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = SecuritySettings(
      appLockEnabled: prefs.getBool(_keyAppLock) ?? false,
      autoLockMinutes: prefs.getInt(_keyAutoLock) ?? 1,
      screenshotProtection: prefs.getBool(_keyScreenshot) ?? false,
    );
  }

  Future<void> setAppLock(bool enabled) async {
    state = state.copyWith(appLockEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAppLock, enabled);
  }

  Future<void> setAutoLockMinutes(int minutes) async {
    state = state.copyWith(autoLockMinutes: minutes);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAutoLock, minutes);
  }

  Future<void> setScreenshotProtection(bool enabled) async {
    state = state.copyWith(screenshotProtection: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyScreenshot, enabled);
  }
}
