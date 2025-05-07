import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
// Core
import 'core/providers/audio_provider.dart';
import 'core/providers/reflection_provider.dart';
import 'features/reflection/screens/reflection_screen.dart';
import 'features/timeline/screens/timeline_screen.dart';
// Features
import 'features/voice_recording/screens/voice_recording_screen.dart';
// Shared
import 'shared/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => ReflectionProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    RecordingScreen(),
    const ReflectionScreen(),
    const TimelineScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load saved entries when app starts
    Future.microtask(() {
      context.read<AudioProvider>().loadVoiceEntries();
      context.read<ReflectionProvider>().loadReflectionEntries();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: AppConstants.animationDuration,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages.map((page) => page.animate().fadeIn()).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.mic),
            label: 'Record',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note),
            label: 'Reflect',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline),
            label: 'Timeline',
          ),
        ],
      ).animate().slideY(
            begin: 1,
            end: 0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
          ),
    );
  }
}

// Add this extension for responsive sizing
extension ResponsiveSize on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  // Responsive padding based on screen size
  EdgeInsets get defaultPadding => EdgeInsets.all(screenWidth * 0.04);

  // Responsive sizes
  double get spacing => screenWidth * 0.02;
  double get largeSpacing => screenWidth * 0.04;

  // Text sizes
  double get h1 => screenWidth * 0.06;
  double get h2 => screenWidth * 0.05;
  double get h3 => screenWidth * 0.04;
  double get body => screenWidth * 0.035;
}
