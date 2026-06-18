import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'feed_service.dart';

// ── AuthResult ─────────────────────────────────────────────────────────────────
class AuthResult {
  final bool success;
  final String? errorMessage;
  const AuthResult._({required this.success, this.errorMessage});
  factory AuthResult.ok() => const AuthResult._(success: true);
  factory AuthResult.fail(String msg) =>
      AuthResult._(success: false, errorMessage: msg);
}

// ── Shared Prefs keys ─────────────────────────────────────────────────────────
const _kToken   = 'auth_token';
const _kUserId  = 'auth_user_id';
const _kName    = 'auth_name';
const _kEmail   = 'auth_email';

// ── AuthService ────────────────────────────────────────────────────────────────
class AuthService extends ChangeNotifier {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final ApiService _api = ApiService.instance;

  String? _token;
  String? _userId;
  String? _name;
  String? _email;
  Uint8List? _profilePhotoBytes; // holds downloaded photo bytes for display

  String? get token  => _token;
  String? get userId => _userId;
  String? get name   => _name;
  String? get email  => _email;
  Uint8List? get profilePhotoBytes => _profilePhotoBytes;

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;
  String get currentUserName  => _name  ?? 'User_Scan_01';
  String get currentUserEmail => _email ?? '';

  // ── Init — restore session from disk ──────────────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token  = prefs.getString(_kToken);
    _userId = prefs.getString(_kUserId);
    _name   = prefs.getString(_kName);
    _email  = prefs.getString(_kEmail);

    if (_token != null && _token!.isNotEmpty) {
      FeedService.instance.token = _token;
    }
    // No notifyListeners() here — app hasn't built yet
  }

  // ── Save session to disk ──────────────────────────────────────────────────
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) {
      await prefs.setString(_kToken,  _token!);
      await prefs.setString(_kUserId, _userId ?? '');
      await prefs.setString(_kName,   _name   ?? '');
      await prefs.setString(_kEmail,  _email  ?? '');
    } else {
      await prefs.remove(_kToken);
      await prefs.remove(_kUserId);
      await prefs.remove(_kName);
      await prefs.remove(_kEmail);
    }
  }

  // ── Register ───────────────────────────────────────────────────────────────
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final result =
        await _api.register(name: name, email: email, password: password);
    if (result.success) return AuthResult.ok();
    return AuthResult.fail(result.error!);
  }

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final result = await _api.login(email: email, password: password);
    if (result.success) {
      final data = result.data!;
      _token  = data.token;
      _userId = data.userId;
      _name   = data.name;
      _email  = data.email;
      FeedService.instance.token = data.token;
      await _persist(); // ← save to disk so next restart stays logged in
      notifyListeners();
      return AuthResult.ok();
    }
    return AuthResult.fail(result.error!);
  }

  // ── Fetch fresh profile from backend ──────────────────────────────────────
  Future<void> fetchProfile() async {
    if (_token == null) return;
    final result = await _api.getProfile(_token!);
    if (result.success) {
      final data = result.data!;
      _name  = data.name;
      _email = data.email;
      await _persist();
      notifyListeners();
    }
  }

  // ── Update name ────────────────────────────────────────────────────────────
  Future<AuthResult> updateName(String newName) async {
    if (_token == null || newName.trim().isEmpty) {
      return AuthResult.fail('Not logged in.');
    }
    final result =
        await _api.updateProfile(token: _token!, name: newName.trim());
    if (result.success) {
      _name = result.data; // backend returns the saved name
      await _persist();
      notifyListeners();
      return AuthResult.ok();
    }
    return AuthResult.fail(result.error!);
  }

  // ── Upload profile photo ───────────────────────────────────────────────────
  Future<AuthResult> uploadProfilePhoto(File photo) async {
    if (_token == null) return AuthResult.fail('Not logged in.');
    final result = await _api.uploadProfilePhoto(token: _token!, photo: photo);
    if (result.success) {
      // Read bytes locally so the avatar updates immediately without a round-trip
      _profilePhotoBytes = await photo.readAsBytes();
      notifyListeners();
      return AuthResult.ok();
    }
    return AuthResult.fail(result.error!);
  }

  // ── Forgot password ────────────────────────────────────────────────────────
  Future<AuthResult> sendPasswordReset(String email) async {
    final result = await _api.forgotPassword(email);
    if (result.success) return AuthResult.ok();
    return AuthResult.fail(result.error!);
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    _token  = null;
    _userId = null;
    _name   = null;
    _email  = null;
    _profilePhotoBytes = null;
    FeedService.instance.token = null;
    await _persist(); // ← clear from disk too
    notifyListeners();
  }
}
