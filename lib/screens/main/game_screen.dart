import 'dart:async' as async;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'package:go_router/go_router.dart'; // <<< IMPORT GOROUTER
import 'package:intl/intl.dart';
import 'package:healjai_project/Widgets/bottom_nav.dart'; // Assuming you have this file

// Enum to represent the prize types for better readability
enum PrizeType { coin, energy, chest, bonus }

// A class to hold information about each prize on the wheel
class Prize {
  final PrizeType type;
  final String label;
  final int value;

  Prize(this.type, this.label, this.value);
}

// A wrapper class to add "weight" for balanced randomness
class WeightedPrize {
  final Prize prize;
  final int weight; // Higher weight = more common

  WeightedPrize(this.prize, this.weight);
}

// The main screen for the game, managing state and UI
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // --- Game Configuration ---
  final double _wheelSize = 380.0;
  int _energy = 10;
  int _coins = 0;
  // --- End Configuration ---

  bool _isSpinning = false;
  async.Timer? _energyRegenTimer;
  late final WheelGame _game;

  final List<WeightedPrize> _prizes = [
    WeightedPrize(Prize(PrizeType.bonus, "โบนัส", 2), 5),      // 5% chance (Rare)
    WeightedPrize(Prize(PrizeType.energy, "พลังใจ", 1), 20),     // 20% chance (Common)
    WeightedPrize(Prize(PrizeType.chest, "หีบสมบัติ", 1), 3),   // 3% chance (Very Rare)
    WeightedPrize(Prize(PrizeType.coin, "เหรียญ", 100), 30),     // 30% chance (Most Common)
    WeightedPrize(Prize(PrizeType.chest, "หีบสมบัติ", 1), 7),   // 7% chance (Rare)
    WeightedPrize(Prize(PrizeType.energy, "พลังใจ", 2), 10),    // 10% chance (Uncommon)
    WeightedPrize(Prize(PrizeType.bonus, "โบนัส", 0), 10),     // 10% chance (Free Spin)
    WeightedPrize(Prize(PrizeType.coin, "เหรียญ", 1000), 15),   // 15% chance (Uncommon)
  ];

  @override
  void initState() {
    super.initState();
    _game = WheelGame(wheelSize: _wheelSize);
    _startEnergyRegenTimer();
  }

  @override
  void dispose() {
    _energyRegenTimer?.cancel();
    super.dispose();
  }

  void _startEnergyRegenTimer() {
    _energyRegenTimer = async.Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_energy < 10) {
        setState(() {
          _energy++;
        });
      }
    });
  }

  int _getWeightedRandomPrizeIndex() {
    int totalWeight = _prizes.fold(0, (sum, item) => sum + item.weight);
    int randomValue = Random().nextInt(totalWeight);
    int cumulativeWeight = 0;

    for (int i = 0; i < _prizes.length; i++) {
      cumulativeWeight += _prizes[i].weight;
      if (randomValue < cumulativeWeight) {
        return i;
      }
    }
    return 0; // Fallback
  }

  void _spinWheel() {
    if (_energy <= 0) {
      _showResultSnackBar("พลังใจไม่เพียงพอ!", isError: true);
      return;
    }
    if (_isSpinning) return;

    setState(() {
      _energy--;
      _isSpinning = true;
    });

    int resultIndex = _getWeightedRandomPrizeIndex();

    _game.wheel.spin(resultIndex, () {
      final prize = _prizes[resultIndex].prize;
      setState(() {
        _handlePrize(prize);
        _isSpinning = false;
      });
    });
  }

  void _showResultSnackBar(String message,
      {bool isError = false, Color? backgroundColor}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            backgroundColor ?? (isError ? Colors.redAccent : Colors.green),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handlePrize(Prize prize) {
    String resultMessage = "";
    switch (prize.type) {
      case PrizeType.coin:
        _coins += prize.value;
        resultMessage =
            "ยินดีด้วย! คุณได้รับ ${NumberFormat("#,###").format(prize.value)} เหรียญ";
        break;
      case PrizeType.energy:
        _energy += prize.value;
        resultMessage = "คุณได้รับพลังใจเพิ่ม ${prize.value} หน่วย";
        break;
      case PrizeType.chest:
        int randomCoins = Random().nextInt(5000) + 1000;
        _coins += randomCoins;
        resultMessage =
            "สุดยอด! เปิดหีบสมบัติได้ ${NumberFormat("#,###").format(randomCoins)} เหรียญ!";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBar(),
      backgroundColor: const Color(0xFF2A4758),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              buildTopBar(),
              const Spacer(),
              buildWheelWithPointer(),
              const Spacer(),
              buildButtonControls(), // Use the new Row widget for buttons
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // === WIDGET BUILDERS ===

  Widget buildWheelWithPointer() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SizedBox(
          width: _wheelSize,
          height: _wheelSize,
          child: GameWidget(game: _game),
        ),
        Icon(
          Icons.arrow_drop_down,
          size: 70,
          color: Colors.amber,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildStatChip({required Widget icon, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            buildStatChip(
              icon: Image.asset('assets/images/coin.png',
                  width: 24, height: 24),
              value: NumberFormat("#,###").format(_coins),
            ),
            const SizedBox(width: 8),
            buildStatChip(
              icon: const Icon(Icons.favorite, color: Colors.red, size: 24),
              value: '$_energy',
            ),
          ],
        ),
        const CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage('assets/images/avatar.png'),
        ),
      ],
    );
  }

  // Renamed function to be more descriptive
  void _onIslandButtonPressed() {
    // Navigate to the HomeScreen (your "island")
    context.go('/island');
  }

  Widget buildButtonControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 65), // Placeholder to balance the layout
        buildSpinButton(),
        const SizedBox(width: 15),
        buildIslandButton(), // Changed name
      ],
    );
  }

  Widget buildSpinButton() {
    return BounceInUp(
      child: GestureDetector(
        onTap: _isSpinning ? null : _spinWheel,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 150,
              height: 65,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Container(
              width: 150,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: const Center(
                child: Text(
                  "SPIN",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Renamed button widget and changed icon
  Widget buildIslandButton() {
    return GestureDetector(
      onTap: _onIslandButtonPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black54, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 3,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: const Icon(
          Icons.home_filled, // Changed Icon
          color: Colors.black54,
          size: 28,
        ),
      ),
    );
  }
}

// === FLAME GAME CODE (No changes needed) ===

class WheelGame extends FlameGame {
  final double wheelSize;
  late final Wheel wheel;

  WheelGame({required this.wheelSize});

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    wheel = Wheel(wheelSize: wheelSize);
    add(wheel);
  }
}

class Wheel extends SpriteComponent with HasGameRef<WheelGame> {
  final double wheelSize;
  void Function()? onSpinComplete;

  Wheel({required this.wheelSize}) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite('wheel.png');
    position = gameRef.size / 2;
    size = Vector2.all(wheelSize);
  }

  void spin(int targetIndex, void Function() onComplete) {
    onSpinComplete = onComplete;
    const int segments = 8;
    const double anglePerSegment = 2 * pi / segments;

    final double randomOffset =
        (Random().nextDouble() - 0.5) * anglePerSegment * 0.8;
    final double targetAngle =
        (2 * pi * (segments - targetIndex - 0.5) / segments) + randomOffset;

    final int fullRotations = 4 + Random().nextInt(4);
    final double duration = 3.5 + Random().nextDouble() * 2;
    final double finalAngle = targetAngle + (fullRotations * 2 * pi);

    add(
      RotateEffect.to(
        finalAngle,
        EffectController(
          duration: duration,
          curve: Curves.easeOutCubic,
        ),
        onComplete: () {
          angle %= (2 * pi);
          onSpinComplete?.call();
        },
      ),
    );
  }
}

