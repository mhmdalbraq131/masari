import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService extends ChangeNotifier {
  static const _pinHashKey = 'security_pin_hash';
  static const _pinSaltKey = 'security_pin_salt';
  static const _biometricsEnabledKey = 'security_biometrics_enabled';

  final LocalAuthentication _localAuth = LocalAuthentication();

  String? _pinHash;
  String? _pinSalt;
  bool _biometricsEnabled = false;
  bool _loaded = false;

  bool get hasPin => _pinHash != null && _pinSalt != null;
  bool get biometricsEnabled => _biometricsEnabled;

  Future<bool> isPinSet() async {
    await _ensureLoaded();
    return hasPin;
  }

  Future<void> setPin(String pin) async {
    await _ensureLoaded();
    _validatePin(pin);
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinHashKey, hash);
    await prefs.setString(_pinSaltKey, salt);
    _pinHash = hash;
    _pinSalt = salt;
    notifyListeners();
  }

  Future<bool> verifyPin(String pin) async {
    await _ensureLoaded();
    if (!hasPin) return false;
    final candidate = _hashPin(pin, _pinSalt!);
    return candidate == _pinHash;
  }

  Future<bool> canUseBiometrics() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      if (!supported) return false;
      return await _localAuth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    await _ensureLoaded();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricsEnabledKey, enabled);
    _biometricsEnabled = enabled;
    notifyListeners();
  }

  Future<bool> authenticateBiometric() async {
    await _ensureLoaded();
    if (!_biometricsEnabled) return false;
    final canUse = await canUseBiometrics();
    if (!canUse) return false;
    try {
      return await _localAuth.authenticate(
        localizedReason: 'يرجى التحقق لإتمام الحجز',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    _pinHash = prefs.getString(_pinHashKey);
    _pinSalt = prefs.getString(_pinSaltKey);
    _biometricsEnabled = prefs.getBool(_biometricsEnabledKey) ?? false;
  }

  void _validatePin(String pin) {
    final normalized = pin.trim();
    if (normalized.length != 4 || int.tryParse(normalized) == null) {
      throw const FormatException('INVALID_PIN');
    }
  }

  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$salt::$pin');
    return sha256.convert(bytes).toString();
  }

  String _generateSalt() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    return base64UrlEncode(bytes);
  }
}
