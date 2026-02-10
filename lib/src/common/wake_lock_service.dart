import 'package:wakelock_plus/wakelock_plus.dart';

/// Service to manage wake lock state for keeping screen on while playing
class WakeLockService {
  WakeLockService._();
  static final instance = WakeLockService._();

  int _activeCount = 0;

  /// Enable wake lock (called when a feature starts playing)
  Future<void> enable() async {
    _activeCount++;
    if (_activeCount == 1) {
      try {
        await WakelockPlus.enable();
      } catch (e) {
        // Silently ignore platform channel errors (e.g., in tests)
      }
    }
  }

  /// Disable wake lock (called when a feature stops playing)
  Future<void> disable() async {
    if (_activeCount > 0) {
      _activeCount--;
    }
    if (_activeCount == 0) {
      try {
        await WakelockPlus.disable();
      } catch (e) {
        // Silently ignore platform channel errors (e.g., in tests)
      }
    }
  }

  /// For testing: reset the counter
  Future<void> reset() async {
    if (_activeCount > 0) {
      try {
        await WakelockPlus.disable();
      } catch (e) {
        // Silently ignore platform channel errors (e.g., in tests)
      }
    }
    _activeCount = 0;
  }
}
