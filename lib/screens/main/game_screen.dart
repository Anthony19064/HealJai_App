// lib/screens/play_screen.dart

import 'dart:async' as async;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:intl/intl.dart';

// Import the new separated files
import 'package:healjai_project/models/minigame_models.dart';
import 'package:healjai_project/widgets/minigame/game_top_bar.dart';
import 'package:healjai_project/widgets/minigame/wheel_component.dart';
import 'package:healjai_project/widgets/minigame/game_page_view.dart';
import 'package:healjai_project/widgets/minigame/island_page_view.dart';
import 'package:healjai_project/widgets/minigame/upgrade_shop_modal.dart';


class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  // --- State Variables ---
  final PageController _pageController = PageController();
  final double _wheelSize = 380.0;
  bool _isSpinning = false;
  async.Timer? _energyRegenTimer;
  int _lastResultIndex = 0;
  Color _pointerColor = Colors.amber;
  late final WheelGame _wheelGame;
  int _energy = 10;
  int _coins = 10000;

  Map<UpgradeType, int> _upgradeLevels = {
    UpgradeType.island: 0,
    UpgradeType.tree: 0,
    UpgradeType.flower: 0,
  };

  final Map<UpgradeType, List<int>> _upgradeCosts = {
    UpgradeType.island: [199, 299, 399],
    UpgradeType.tree: [199, 299, 399],
    UpgradeType.flower: [199, 299, 399],
  };

  final List<WeightedPrize> _prizes = [
    WeightedPrize(Prize(PrizeType.coin, "เหรียญ", 100, Colors.white), 60),
    WeightedPrize(Prize(PrizeType.bonus, "โบนัส", 2, Colors.yellow.shade600),5,),
    WeightedPrize(Prize(PrizeType.energy, "หัวใจ", 1, Colors.red.shade400), 10),
    WeightedPrize(Prize(PrizeType.chest, "หีบสมบัติ", 1, Colors.grey.shade800),2,),
    WeightedPrize(Prize(PrizeType.coin, "เหรียญ", 1000, Colors.white), 10),
    WeightedPrize(Prize(PrizeType.chest, "หีบสมบัติ", 2, Colors.grey.shade800),3,),
    WeightedPrize(Prize(PrizeType.energy, "หัวใจ", 2, Colors.red.shade400), 5),
    WeightedPrize(Prize(PrizeType.bonus, "โบนัส", 0, Colors.yellow.shade600),5,),
  ];

  @override
  void initState() {
    super.initState();
    _wheelGame = WheelGame(
      onSpinComplete: _onSpinComplete,
      onAngleChanged: _updatePointerColorFromAngle,
    );
    _startEnergyRegenTimer();
    FlameAudio.bgm.initialize();
    FlameAudio.audioCache.load('spinning.mp3');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _energyRegenTimer?.cancel();
    FlameAudio.bgm.stop();
    FlameAudio.bgm.dispose();
    super.dispose();
  }

  // --- Logic Functions ---
  void _updatePointerColorFromAngle(double angle) {
    double degrees = (angle * 180 / pi) % 360;
    if (degrees < 0) degrees += 360;
    final int currentIndex = (degrees / (360 / _prizes.length)).floor();
    final Color newColor = _prizes[currentIndex].prize.color;
    if (_pointerColor != newColor) {
      setState(() => _pointerColor = newColor);
    }
  }

  void _onSpinComplete() {
    if (!mounted) return;
    FlameAudio.bgm.stop();
    final prize = _prizes[_lastResultIndex].prize;
    _handlePrize(prize);
    setState(() => _isSpinning = false);
  }

  void _spinWheel() {
    if (_energy <= 0) {
      _showResultSnackBar("พลังใจไม่เพียงพอ!", isError: true);
      return;
    }
    if (_isSpinning) return;
    FlameAudio.play('spinning.mp3');
    setState(() {
      _energy--;
      _isSpinning = true;
    });
    _lastResultIndex = _getWeightedRandomPrizeIndex();
    final double singlePieceDegrees = 360 / _prizes.length;
    final double targetDegrees =
        (_lastResultIndex * singlePieceDegrees) + (singlePieceDegrees / 2);
    _wheelGame.wheel.startSpin(targetDegrees);
  }

  void _startEnergyRegenTimer() {
    _energyRegenTimer = async.Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_energy < 10) setState(() => _energy++);
    });
  }

  int _getWeightedRandomPrizeIndex() {
    int totalWeight = _prizes.fold(0, (sum, item) => sum + item.weight);
    if (totalWeight <= 0) return 0;
    int randomValue = Random().nextInt(totalWeight);
    int cumulativeWeight = 0;
    for (int i = 0; i < _prizes.length; i++) {
      cumulativeWeight += _prizes[i].weight;
      if (randomValue < cumulativeWeight) return i;
    }
    return 0;
  }

  void _handlePrize(Prize prize) {
    String resultMessage = "";
    switch (prize.type) {
      case PrizeType.coin:
        _coins += prize.value;
        resultMessage = "ยินดีด้วย! คุณได้รับ ${NumberFormat("#,###").format(prize.value)} เหรียญ";
        break;
      case PrizeType.energy:
        _energy += prize.value;
        resultMessage = "คุณได้รับพลังใจเพิ่ม ${prize.value} หน่วย";
        break;
      case PrizeType.chest:
        int randomCoins = Random().nextInt(5000) + 1000;
        _coins += randomCoins;
        resultMessage = "สุดยอด! เปิดหีบสมบัติได้ ${NumberFormat("#,###").format(randomCoins)} เหรียญ!";
        break;
      case PrizeType.bonus:
        if (prize.value == 0) {
          _energy++;
          resultMessage = "โบนัส! คุณได้หมุนฟรีในรอบถัดไป!";
        } else {
          int lastCoinWin = 500;
          _coins += lastCoinWin * (prize.value - 1);
          resultMessage = "โบนัส! เหรียญ x${prize.value}!";
        }
        break;
    }
    _showResultSnackBar(resultMessage);
  }

  void _showResultSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _upgradeItem(UpgradeType type) {
    int currentLevel = _upgradeLevels[type]!;
    List<int> costs = _upgradeCosts[type]!;
    if (currentLevel < costs.length) {
      int cost = costs[currentLevel];
      if (_coins >= cost) {
        setState(() {
          _coins -= cost;
          _upgradeLevels[type] = currentLevel + 1;
        });
      }
    }
  }

  void _showUpgradeModal() {
    // Now just a simple call to the function in the new file.
    showUpgradeShopModal(
      context: context,
      currentCoins: _coins,
      upgradeLevels: _upgradeLevels,
      upgradeCosts: _upgradeCosts,
      onUpgrade: (type) {
        _upgradeItem(type);
        // We call setState here to rebuild PlayScreen, which will pass the new
        // state down to IslandPageView, updating the visuals.
        setState(() {});
      },
    );
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            children: [
              // Use the new, clean GamePageView widget
              GamePageView(
                wheelSize: _wheelSize,
                wheelGame: _wheelGame,
                pointerColor: _pointerColor,
                isSpinning: _isSpinning,
                onSpin: _spinWheel,
                onScrollDown: () => _pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                ),
              ),
              // Use the new, clean IslandPageView widget
              IslandPageView(
                upgradeLevels: _upgradeLevels,
                onShowUpgradeModal: _showUpgradeModal,
                onScrollUp: () => _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                ),
              ),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: GameTopBar(coins: _coins, energy: _energy),
              ),
            ),
          ),
        ],
      ),
    );
  }
}