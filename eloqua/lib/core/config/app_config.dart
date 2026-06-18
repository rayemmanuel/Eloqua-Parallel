class AppConfig {
  AppConfig._();
  static const String appName = 'Eloqua';
  static const String appTagline = 'Your Personal Speech Coach';
  static const String version = '1.0.0';
  static const String teamName = 'Eloqua Team — TIP';
  static const String logoPath = 'assets/images/logo.png';
  static const bool useLogoImage = true;
  static const double logoSize = 72.0;
  static const String displayFont = 'SpaceGrotesk';
  static const String bodyFont = 'SpaceGrotesk';

  // ── Backend URLs ────────────────────────────────────────────────────────────
  // 10.0.2.2 = localhost as seen from the Android emulator.
  // Switch to your machine's WiFi IP (e.g. 192.168.1.x) for physical devices.
  static const String mainApiBase =
      'https://eloqua-parallel.onrender.com';
  static const String bodyApiBase = 'http://10.0.2.2:8001'; // venv 2

  // ── Feature flags ───────────────────────────────────────────────────────────
  static const String openAiKey = ''; // unused — AI runs on backend
  static const bool enableCamera = true;
  static const bool enableVoiceCommands = true;
  static const bool enableTts = true;
  static const bool enableHaptics = true;
  static const bool enableSocial = true;
  static const bool enableLeaderboard = true;
  static const bool enableAiChat = true;

  // Set to false once real sessions are coming in from the backend.
  static const bool showMockData = true;
}
