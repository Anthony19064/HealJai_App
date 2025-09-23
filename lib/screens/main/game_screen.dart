import 'dart:async' as async;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flame/game.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// ตรวจสอบ Path ไปยังไฟล์ wheel_component.dart ให้ถูกต้อง
import 'package:healjai_project/Widgets/minigame/wheel_component.dart';

// --- โครงสร้าง Prize และ WeightedPrize ---
enum PrizeType { coin, energy, chest, bonus }

class Prize {
  final PrizeType type;
  final String label;
  final int value;
  Prize(this.type, this.label, this.value);
}

class WeightedPrize {
  final Prize prize;
  final int weight;
  WeightedPrize(this.prize, this.weight);
}
// ----------------------------------------------------

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // --- Game State Variables ---
  final double _wheelSize = 380.0;
  int _energy = 10;
  int _coins = 0;
  bool _isSpinning = false;
  async.Timer? _energyRegenTimer;
  int _lastResultIndex = 0;

  late final WheelGame _wheelGame;

final List<WeightedPrize> _prizes = [
  
  WeightedPrize(Prize(PrizeType.coin, "เหรียญ", 100), 60),

  WeightedPrize(Prize(PrizeType.bonus, "โบนัส", 2), 5),

  WeightedPrize(Prize(PrizeType.energy, "หัวใจ", 1), 10),

  WeightedPrize(Prize(PrizeType.chest, "หีบสมบัติ", 1), 2),

  WeightedPrize(Prize(PrizeType.coin, "เหรียญ", 1000), 10),

  WeightedPrize(Prize(PrizeType.chest, "หีบสมบัติ", 2), 3),

  WeightedPrize(Prize(PrizeType.energy, "หัวใจ", 2), 5),

  WeightedPrize(Prize(PrizeType.bonus, "โบนัส", 2), 5),
];

  @override
  void initState() {
    super.initState();
    _wheelGame = WheelGame(onSpinComplete: _onSpinComplete);
    _startEnergyRegenTimer();
  }

  @override
  void dispose() {
    _energyRegenTimer?.cancel();
    super.dispose();
  }

  void _onSpinComplete() {
    if (!mounted) return;

    final prize = _prizes[_lastResultIndex].prize;
    _handlePrize(prize);

    setState(() {
      _isSpinning = false;
    });
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
  _lastResultIndex = _getWeightedRandomPrizeIndex();
  final double singlePieceDegrees = 360 / _prizes.length;
  final double targetDegrees = (_lastResultIndex * singlePieceDegrees) + (singlePieceDegrees / 2);
  _wheelGame.wheel.startSpin(targetDegrees);
}
  void _startEnergyRegenTimer() {
    _energyRegenTimer =
        async.Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_energy < 10) {
        setState(() => _energy++);
      }
    });
  }

  int _getWeightedRandomPrizeIndex() {
    int totalWeight = _prizes.fold(0, (sum, item) => sum + item.weight);
    if (totalWeight <= 0) return 0;
    int randomValue = Random().nextInt(totalWeight);
    int cumulativeWeight = 0;
    for (int i = 0; i < _prizes.length; i++) {
      cumulativeWeight += _prizes[i].weight;
      if (randomValue < cumulativeWeight) {
        return i;
      }
    }
    return 0;
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

  void _showResultSnackBar(String message,
      {bool isError = false, Color? backgroundColor}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor:
          backgroundColor ?? (isError ? Colors.redAccent : Colors.green),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // พื้นหลัง (ถ้ามี)
          // Container(decoration: BoxDecoration(image: DecorationImage(image: AssetImage("..."), fit: BoxFit.cover))),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  buildTopBar(),
                  const Spacer(flex: 2),
                  buildWheelWithPointer(),
                  const Spacer(flex: 1),
                  buildButtonControls(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---
  Widget buildWheelWithPointer() {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: _wheelSize,
          height: _wheelSize,
          child: GameWidget(game: _wheelGame),
        ),
        Positioned(
          top: -15,
          child: Icon(
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
        ),
      ],
    );
  }

  Widget buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 28),
          onPressed: () => context.go('/'),
        ),
        Row(
          children: [
            buildStatChip(
              icon: SizedBox(
                width: 24,
                height: 24,
                child: Image.asset('assets/images/coin.png'),
              ),
              value: NumberFormat("#,###").format(_coins),
            ),
            const SizedBox(width: 8),
            buildStatChip(
              icon: const Icon(Icons.favorite, color: Colors.red, size: 24),
              value: '$_energy',
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
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget buildButtonControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 65),
        buildSpinButton(),
        const SizedBox(width: 15),
        buildIslandButton(),
      ],
    );
  }

  Widget buildSpinButton() {
    return BounceInUp(
      child: GestureDetector(
        onTap: _isSpinning ? null : _spinWheel,
        child: Image.asset(
          'assets/images/spin_1.png',
          width: 150,
        ),
      ),
    );
  }

  Widget buildIslandButton() {
    return GestureDetector(
      onTap: () => context.go('/island'),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black54, width: 2),
        ),
        child: const Icon(Icons.home_filled, color: Colors.black54, size: 28),
      ),
    );
  }
}