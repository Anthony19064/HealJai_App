import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart';

class CatGameScreen extends StatefulWidget {
  const CatGameScreen({super.key});

  @override
  State<CatGameScreen> createState() => _CatGameScreenState();
}

class _CatGameScreenState extends State<CatGameScreen> {
  // --- Page Controller to manage PageView ---
  late final PageController _pageController;

  // --- Game State ---
  int _score = 0;
  int _coins = 0;

  // --- Rive Animation Controller ---
  SMITrigger? _gameAnimationTrigger;
  StateMachineController? _gameController;
  bool _isAnimating = false;

  Key _riveKey = UniqueKey();

  // --- Leaderboard Position State ---
  double _xOffset = 0.64;
  double _yOffset = 0.49;
  double _widthRatio = 0.48;
  double _heightRatio = 0.28;

  final List<Map<String, dynamic>> _leaderboardData = List.generate(
    50,
    (index) => {
      "name": "Player ${index + 1}",
      "score": Random().nextInt(5000) + (50 - index) * 100,
    },
  )..sort((a, b) => b['score'].compareTo(a['score']));

  @override
  void initState() {
    super.initState();
    _pageController = PageController(); // Initialize the controller
  }

  /// Called when the Rive widget is initialized.
  void _onGameRiveInit(Artboard artboard) {
    _gameController = StateMachineController.fromArtboard(
      artboard,
      'GameMachine',
    );

    if (_gameController != null) {
      artboard.addController(_gameController!);
      _gameAnimationTrigger =
          _gameController!.findInput<bool>('play') as SMITrigger?;
    }
  }

  /// Called when the user taps the game screen.
  void _onTapGameScreen() {
    if (_isAnimating || _gameAnimationTrigger == null) return;

    const animationDuration = Duration(milliseconds: 1000);

    setState(() {
      _isAnimating = true;
    });

    _gameAnimationTrigger!.fire();

    Future.delayed(animationDuration, () {
      if (!mounted) return;
      _addScore();
      setState(() {
        _isAnimating = false;
        _riveKey = UniqueKey();
      });
    });
  }

  /// Adds points to the score.
  void _addScore() {
    setState(() {
      _score++;
      if (Random().nextInt(10) == 0) {
        _coins += Random().nextInt(5) + 1;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose the controller
    _gameController?.dispose();
    super.dispose();
  }

  // --- UI Widgets ---

  Widget _buildLeaderboardPage() {
    final screenSize = MediaQuery.of(context).size;
    final leaderboardContent = Container(
      // ... (Content is the same)
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _leaderboardData.length,
        itemBuilder: (context, index) {
          final player = _leaderboardData[index];
          final rank = index + 1;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Text(
                  "$rank.",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    player["name"],
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                Text(
                  "${player["score"]}",
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: screenSize.width,
            height: screenSize.height,
            child: RiveAnimation.asset(
              'assets/animations/rives/leaderboard.riv',
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: (_xOffset - (_widthRatio / 2)) * screenSize.width,
            top: (_yOffset - (_heightRatio / 2)) * screenSize.height,
            width: _widthRatio * screenSize.width,
            height: _heightRatio * screenSize.height,
            child: leaderboardContent,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              title: const Text("Leaderboard"),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.go('/'),
              ),
            ),
          ),
          // --- REPLACED SWIPE TEXT WITH A BUTTON ---
          Positioned(
            bottom: 40,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.brown.shade800,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                _pageController.animateToPage(
                  1, // Go to page 1 (Game Page)
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              icon: const Icon(Icons.arrow_forward_ios),
              label: const Text("ไปตัดไม้กันเถอะ"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamePage() {
    Widget buildStatDisplay(IconData icon, String value) {
      // ... (This helper widget is the same)
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.brown, size: 24),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF5C94FC),
      body: GestureDetector(
        onTap: _onTapGameScreen,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: RiveAnimation.asset(
                'assets/animations/rives/minigame_cuttingnew.riv',
                key: _riveKey,
                onInit: _onGameRiveInit,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 60,
              child: Row(
                children: [
                  buildStatDisplay(Icons.star, '$_score'),
                  const SizedBox(width: 12),
                  buildStatDisplay(Icons.monetization_on, '$_coins'),
                ],
              ),
            ),
            // --- REPLACED SWIPE TEXT WITH A BUTTON ---
            Positioned(
              bottom: 40,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  _pageController.animateToPage(
                    0, // Go to page 0 (Leaderboard Page)
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
                icon: const Icon(Icons.leaderboard),
                label: const Text("Leaderboard"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      // This disables manual swiping
      physics: const NeverScrollableScrollPhysics(),
      children: [_buildLeaderboardPage(), _buildGamePage()],
    );
  }
}
