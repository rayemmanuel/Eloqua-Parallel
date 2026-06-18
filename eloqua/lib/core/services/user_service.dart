import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Why: SharedPreferences is local key-value storage — no internet needed.
// Foundation: the app reads the name once on startup and displays it everywhere.

class UserService extends ChangeNotifier {
  static const String _keyName     = 'user_name';
  static const String _keySessions = 'session_count';
  static const String _keyStreak   = 'streak_days';
  static const String _keyAvgScore = 'avg_score';
  static const String _keyLoggedIn = 'is_logged_in';

  String _name      = '';
  int    _sessions  = 0;
  int    _streak    = 0;
  int    _avgScore  = 0;
  bool   _loggedIn  = false;

  String get name      => _name.isEmpty ? 'Student' : _name;
  int    get sessions  => _sessions;
  int    get streak    => _streak;
  int    get avgScore  => _avgScore;
  bool   get loggedIn  => _loggedIn;
  bool   get hasName   => _name.isNotEmpty;

  // Dynamic greeting based on time of day
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  // Load all user data from local storage on app start
  Future<void> load() async {
    final prefs  = await SharedPreferences.getInstance();
    _name      = prefs.getString(_keyName)     ?? '';
    _sessions  = prefs.getInt(_keySessions)    ?? 0;
    _streak    = prefs.getInt(_keyStreak)      ?? 0;
    _avgScore  = prefs.getInt(_keyAvgScore)    ?? 0;
    _loggedIn  = prefs.getBool(_keyLoggedIn)   ?? false;
    notifyListeners();
  }

  // Save the user's name
  Future<void> setName(String name) async {
    _name = name.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, _name);
    await prefs.setBool(_keyLoggedIn, true);
    _loggedIn = true;
    notifyListeners();
  }

  // Called after each practice session completes
  Future<void> recordSession(int score) async {
    _sessions++;
    // Rolling average formula
    _avgScore = ((_avgScore * (_sessions - 1)) + score) ~/ _sessions;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySessions, _sessions);
    await prefs.setInt(_keyAvgScore, _avgScore);
    notifyListeners();
  }

  // Increment streak (call once per day on app open)
  Future<void> incrementStreak() async {
    _streak++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyStreak, _streak);
    notifyListeners();
  }

  // Logout: clears session state but keeps the name
  // Why: we don't want users to re-enter their name every time
  Future<void> logout() async {
    _loggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
    notifyListeners();
  }

  // Full reset: clears everything including name
  Future<void> fullReset() async {
    _name     = '';
    _sessions = 0;
    _streak   = 0;
    _avgScore = 0;
    _loggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}