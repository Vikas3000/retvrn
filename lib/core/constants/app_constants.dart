class AppConstants {
  // App-wide constants
  static const String appName = 'Reflection MVP';
  static const Duration recordingMaxDuration = Duration(minutes: 10);
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Route names
  static const String homeRoute = '/';
  static const String recordingRoute = '/recording';
  static const String reflectionRoute = '/reflection';
  static const String timelineRoute = '/timeline';

  // Storage keys
  static const String voiceEntriesKey = 'voice_entries';
  static const String reflectionEntriesKey = 'reflection_entries';
}
