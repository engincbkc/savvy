import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

/// Service to enable/disable screenshot protection.
/// Uses flutter_windowmanager for Android and method channel for iOS.
class ScreenshotProtectionService {
  static const _channel = MethodChannel('com.savvy.savvy/screenshot');

  /// Enable screenshot protection
  static Future<void> enable() async {
    try {
      if (Platform.isAndroid) {
        await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      } else if (Platform.isIOS) {
        // iOS uses a different approach - we'll make the screen secure
        // This requires native code, but for now we use a workaround
        await _channel.invokeMethod('enableProtection');
      }
    } catch (e) {
      // Silently fail - screenshot protection is a nice-to-have
    }
  }

  /// Disable screenshot protection
  static Future<void> disable() async {
    try {
      if (Platform.isAndroid) {
        await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      } else if (Platform.isIOS) {
        await _channel.invokeMethod('disableProtection');
      }
    } catch (e) {
      // Silently fail
    }
  }
}
