// =============================================================================
// strings.dart — All User-Facing Text
// =============================================================================
// No hardcoded strings anywhere else in the app.
// To translate the app, create a strings_fil.dart with the same structure.
// =============================================================================

class AppStrings {
  AppStrings._();

  // ── Auth ───────────────────────────────────────────────────────────────────
  static const String splashTagline = 'Master the art of the messenger.';
  static const String welcomeTitle = 'Welcome to Eloqua';
  static const String welcomeSubtitle = 'Practice today. Command tomorrow.';
  static const String welcomeGetStarted = 'Get Started';
  static const String welcomeLogin = 'Already have an account? Log in';

  static const String loginTitle = 'Log In';
  static const String loginEmail = 'Email address';
  static const String loginPassword = 'Password';
  static const String loginBtn = 'Log In';
  static const String loginForgot = 'Forgot password?';
  static const String loginNoAccount = "Don't have an account? Sign up";
  static const String loginError = 'Invalid email or password.';

  static const String registerTitle = 'Create Account';
  static const String registerName = 'Full name';
  static const String registerEmail = 'Email address';
  static const String registerPass = 'Password';
  static const String registerConfirm = 'Confirm password';
  static const String registerBtn = 'Create Account';
  static const String registerHasAccount = 'Already have an account?';
  static const String registerPassMismatch = 'Passwords do not match.';
  static const String registerSuccess = 'Account created! Please log in.';

  static const String forgotTitle = 'Reset Password';
  static const String forgotSubtitle =
      'Enter your email and we will send a reset link.';
  static const String forgotEmail = 'Email address';
  static const String forgotBtn = 'Send Reset Link';
  static const String forgotSuccess = 'Reset link sent. Check your email.';
  static const String forgotBack = 'Back to login';

  // ── Onboarding ─────────────────────────────────────────────────────────────
  static const String ob1Title = 'Speak Without Limits';
  static const String ob1Body =
      'Record in a private, pressure-free space. Review your transcripts to master every word.';
  static const String ob2Title = 'Unscripted Growth';
  static const String ob2Body =
      'Face the random. Sharpen your wit with the Spont Screen’s unexpected practice topics.';
  static const String ob3Title = 'Consult the Mind';
  static const String ob3Body =
      'Brainstorm with AI or connect with the community. Refine your message and find your tribe.';
  static const String obSkip = 'Skip';
  static const String obNext = 'Advance';
  static const String obGetStarted = 'Take the Mic';

  // ── Navigation ─────────────────────────────────────────────────────────────
  static const String navHome = 'Home';
  static const String navSocial = 'Social';
  static const String navAnalytics = 'Analytics';
  static const String navProfile = 'Profile';

  // ── Home ───────────────────────────────────────────────────────────────────
  static const String homeSubtitle = 'Choose a mode to get started.';
  static const String homeStreak = 'Streak';
  static const String homeSessions = 'Sessions';
  static const String homeAvgScore = 'Avg Score';
  static const String cardPrepTitle = 'Preparation Mode';
  static const String cardPrepSub =
      'Upload your document. Get AI talking points.';
  static const String cardSpontTitle = 'Spontaneous Mode';
  static const String cardSpontSub =
      'Get a random academic topic and think fast.';
  static const String tipTitle = 'Quick Tip';
  static const List<String> tips = [
    'Speak at 120 to 160 words per minute for best audience engagement.',
    'Pause after key points — silence creates emphasis.',
    'Look up, not down. Eye contact builds credibility.',
    'Avoid filler words by pausing instead of saying um.',
    'Breathe before you speak. It calms nerves instantly.',
    'Vary your pitch — a monotone voice loses the audience.',
    'Use the rule of three: present ideas in groups of three.',
  ];

  // ── Prep Mode ──────────────────────────────────────────────────────────────
  static const String prepTitle = 'Preparation Mode';
  static const String prepUploadTitle = 'Upload Your Document';
  static const String prepUploadBody = 'PDF files supported. Max 10 MB.';
  static const String prepChooseFile = 'Choose File';
  static const String prepChangeFile = 'Change File';
  static const String prepGenerateBtn = 'Generate Talking Points';
  static const String prepGenerating = 'Analyzing document...';
  static const String prepPointsTitle = 'Your Talking Points';
  static const String prepPointsHint =
      'These are concepts, not a script. Explain each in your own words.';
  static const String prepStartBtn = 'Start Practice';

  // ── Spontaneous Mode ───────────────────────────────────────────────────────
  static const String spontTitle = 'Spontaneous Mode';
  static const String spontDiffLabel = 'Difficulty';
  static const String spontNewTopic = 'New Topic';
  static const String spontStartBtn = 'Start Session';
  static const String spontBefore = 'Before you start';
  static const String spontBeforeBody =
      'Take 10 seconds to organize your thoughts. Aim for a 1 to 2 minute response.';

  // ── Practice ───────────────────────────────────────────────────────────────
  static const String practiceCountdown = 'Starting in...';
  static const String practiceGesture =
      'Peace Sign to start  |  Open Palm to pause';
  static const String practiceStop = 'Stop Recording';
  static const String practiceResume = 'Resume';
  static const String practiceFinish = 'Finish Session';
  static const String practiceEndTitle = 'End Session?';
  static const String practiceEndBody = 'Your recording will be lost.';
  static const String practiceEndYes = 'End Session';
  static const String practiceEndNo = 'Keep Going';
  static const String postureGood = 'Good posture!';
  static const String postureWarn = 'Straighten up — shoulders back.';
  static const String postureAlert = 'Posture check — you are slouching.';
  static const String cameraUnavailable =
      'Camera unavailable. Posture tracking disabled.';

  // ── Filler Jar ─────────────────────────────────────────────────────────────
  static const String fillerJarTitle = 'Filler Word Jar';
  static const String fillerJarEmpty = 'No fillers yet — great start!';
  static const String fillerJarSubtitle =
      'Each pebble represents one filler word detected.';
  static const String fillerJarReset = 'Reset Jar';
  static const List<String> fillerWords = [
    'um',
    'uh',
    'like',
    'you know',
    'basically',
    'literally',
    'actually',
    'right',
    'so',
    'okay so'
  ];

  // ── Feedback ───────────────────────────────────────────────────────────────
  static const String feedbackTitle = 'Session Complete';
  static const String feedbackOverall = 'Overall Score';
  static const String feedbackClarity = 'Clarity';
  static const String feedbackPacing = 'Pacing';
  static const String feedbackGrammar = 'Grammar';
  static const String feedbackConfidence = 'Confidence';
  static const String feedbackStrengths = 'What You Did Well';
  static const String feedbackImprove = 'Areas to Improve';
  static const String feedbackCoachNote = 'Coach Note';
  static const String feedbackRetry = 'Try Again';
  static const String feedbackHome = 'Back to Home';
  static const String feedbackChat = 'Talk to Coach';
  static const String feedbackSaved = 'Session saved to history.';

  // ── AI Coach Chat ──────────────────────────────────────────────────────────
  static const String chatTitle = 'AI Coach';
  static const String chatPlaceholder = 'Ask your coach anything...';
  static const String chatSend = 'Send';
  static const String chatGreeting =
      'Hi! I am your Eloqua coach. What would you like to work on today?';
  static const String chatThinking = 'Coach is thinking...';
  static const String chatError =
      'Could not reach coach. Check your connection.';

  // ── Analytics ──────────────────────────────────────────────────────────────
  static const String analyticsTitle = 'Analytics';
  static const String analyticsTrend = 'Score Trend';
  static const String analyticsBreakdown = 'Dimension Breakdown';
  static const String analyticsBest = 'Best Score';
  static const String analyticsAvg = 'Avg Score';
  static const String analyticsTotal = 'Sessions';
  static const String analyticsTotalTime = 'Total Time';
  static const String analyticsNoData =
      'Complete your first session to see analytics.';

  // ── History ────────────────────────────────────────────────────────────────
  static const String historyTitle = 'Session History';
  static const String historyEmpty = 'No sessions yet. Start practicing!';
  static const String historyPrep = 'Preparation';
  static const String historySpont = 'Spontaneous';

  // ── Leaderboard ────────────────────────────────────────────────────────────
  static const String leaderTitle = 'Leaderboard';
  static const String leaderSubtitle = 'Top performers this week';
  static const String leaderYou = 'You';

  // ── Profile ────────────────────────────────────────────────────────────────
  static const String profileTitle = 'Profile';
  static const String profileEdit = 'Edit Profile';
  static const String profileSave = 'Save Changes';
  static const String profileLogout = 'Log Out';
  static const String profileSessions = 'Sessions';
  static const String profileStreak = 'Day Streak';
  static const String profileBest = 'Best Score';
  static const String profileSettings = 'Settings';
  static const String profileHistory = 'Session History';
  static const String profileAnalytics = 'Analytics';

  // ── Social ─────────────────────────────────────────────────────────────────
  static const String socialTitle = 'Community';
  static const String socialSubtitle = 'See how your classmates are practicing';
  static const String socialLike = 'Like';
  static const String socialComment = 'Comment';
  static const String socialShare = 'Share';
  static const String socialScore = 'scored';
  static const String socialPracticed = 'practiced';
  static const String socialEmpty = 'No posts yet. Be the first to share!';

  // ── Settings ───────────────────────────────────────────────────────────────
  static const String settingsTitle = 'Settings';
  static const String settingsTheme = 'App Theme';
  static const String settingsHaptics = 'Haptic Feedback';
  static const String settingsGaze = 'Gaze-to-Scroll';
  static const String settingsGestures = 'Gesture Controls';
  static const String settingsPosture = 'Posture Coaching';
  static const String settingsTts = 'Read Feedback Aloud';
  static const String settingsVersion = 'Version';
  static const String settingsAbout = 'About';

  // ── Errors ─────────────────────────────────────────────────────────────────
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNoInternet = 'No internet connection.';
  static const String errorFileTooBig = 'File exceeds 10 MB.';
  static const String errorCamera = 'Camera permission denied.';
  static const String errorMic = 'Microphone permission denied.';
  static const String errorApiKey =
      'AI features require an API key. See app_config.dart.';
}
