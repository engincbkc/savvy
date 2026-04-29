import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:savvy/features/settings/presentation/providers/security_provider.dart';

part 'app_lock_provider.g.dart';

/// App lock state - tracks whether the app is currently locked
@immutable
class AppLockState {
  final bool isLocked;
  final bool isAuthenticating;
  final DateTime? lastActiveTime;

  const AppLockState({
    this.isLocked = true,
    this.isAuthenticating = false,
    this.lastActiveTime,
  });

  AppLockState copyWith({
    bool? isLocked,
    bool? isAuthenticating,
    DateTime? lastActiveTime,
  }) {
    return AppLockState(
      isLocked: isLocked ?? this.isLocked,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
      lastActiveTime: lastActiveTime ?? this.lastActiveTime,
    );
  }
}

@Riverpod(keepAlive: true)
class AppLockNotifier extends _$AppLockNotifier with WidgetsBindingObserver {
  final _localAuth = LocalAuthentication();
  bool _observerAdded = false;

  @override
  AppLockState build() {
    // Add lifecycle observer
    if (!_observerAdded) {
      WidgetsBinding.instance.addObserver(this);
      _observerAdded = true;
    }

    // Check if app lock is enabled
    final security = ref.watch(securitySettingsProvider);
    if (!security.appLockEnabled) {
      return const AppLockState(isLocked: false);
    }

    return const AppLockState(isLocked: true);
  }

  @override
  // ignore: avoid_renaming_method_parameters
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    final security = ref.read(securitySettingsProvider);
    if (!security.appLockEnabled) return;

    if (lifecycleState == AppLifecycleState.paused) {
      // App went to background - record time
      state = state.copyWith(lastActiveTime: DateTime.now());
    } else if (lifecycleState == AppLifecycleState.resumed) {
      // App came back - check if we need to lock
      _checkAutoLock();
    }
  }

  void _checkAutoLock() {
    final security = ref.read(securitySettingsProvider);
    if (!security.appLockEnabled) return;

    final lastActive = state.lastActiveTime;
    if (lastActive == null) {
      // First launch or no recorded time - lock it
      state = state.copyWith(isLocked: true);
      return;
    }

    final elapsed = DateTime.now().difference(lastActive);
    final autoLockMinutes = security.autoLockMinutes;

    // autoLockMinutes == 0 means "immediately"
    if (autoLockMinutes == 0 || elapsed.inMinutes >= autoLockMinutes) {
      state = state.copyWith(isLocked: true);
    }
  }

  /// Attempt biometric/device auth
  Future<bool> authenticate() async {
    if (state.isAuthenticating) return false;

    state = state.copyWith(isAuthenticating: true);

    try {
      // Check available biometrics
      final canAuth = await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();

      if (!canAuth) {
        // Device doesn't support biometrics - just unlock
        state = state.copyWith(isLocked: false, isAuthenticating: false);
        return true;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Savvy\'ye erişmek için kimliğinizi doğrulayın',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN/pattern fallback
        ),
      );

      if (authenticated) {
        state = state.copyWith(
          isLocked: false,
          isAuthenticating: false,
          lastActiveTime: DateTime.now(),
        );
        HapticFeedback.mediumImpact();
        return true;
      } else {
        state = state.copyWith(isAuthenticating: false);
        return false;
      }
    } on PlatformException catch (_) {
      // Auth failed or cancelled
      state = state.copyWith(isAuthenticating: false);
      return false;
    }
  }

  /// Lock the app manually
  void lock() {
    final security = ref.read(securitySettingsProvider);
    if (security.appLockEnabled) {
      state = state.copyWith(isLocked: true);
    }
  }

  /// Called when app lock setting is toggled
  void onAppLockSettingChanged(bool enabled) {
    if (enabled) {
      // Just enabled - don't lock immediately, user is in settings
      state = state.copyWith(
        isLocked: false,
        lastActiveTime: DateTime.now(),
      );
    } else {
      // Disabled - unlock
      state = state.copyWith(isLocked: false);
    }
  }
}
