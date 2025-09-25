import 'dart:async' as async;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:intl/intl.dart';
import 'package:rive/rive.dart' as rive;

// ตรวจสอบ Path ไปยังไฟล์ Widget ที่แยกออกไปให้ถูกต้อง
import 'package:healjai_project/Widgets/minigame/game_top_bar.dart';
import 'package:healjai_project/Widgets/minigame/wheel_component.dart';

// --- โครงสร้าง Prize ---
enum PrizeType { coin, energy, chest, bonus }

class Prize {
  final PrizeType type;
  final String label;
  final int value;
  final Color color;
  Prize(this.type, this.label, this.value, this.color);
}

class WeightedPrize {
  final Prize prize;
  final int weight;
  WeightedPrize(this.prize, this.weight);
}

// --- Widget หลักที่รวมทุกอย่างไว้ด้วยกัน ---
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
  int _upgradeLevel = 0;
  final List<int> _upgradeCosts = [199, 299, 399];
  int _energy = 10;
  int _coins = 10000;

  final List<WeightedPrize> _prizes = [
    // Index 0: (ภาพคือ Coin สีขาว)
    WeightedPrize(Prize(PrizeType.coin, "เหรียญ", 100, Colors.white), 60),
    // Index 1: (ภาพคือ Bonus สีเหลือง)
    WeightedPrize(
      Prize(PrizeType.bonus, "โบนัส", 2, Colors.yellow.shade600),
      5,
    ),
    // Index 2: (ภาพคือ Energy สีแดง)
    WeightedPrize(Prize(PrizeType.energy, "หัวใจ", 1, Colors.red.shade400), 10),
    // Index 3: (ภาพคือ Chest สีดำ)
    WeightedPrize(
      Prize(PrizeType.chest, "หีบสมบัติ", 1, Colors.grey.shade800),
      2,
    ),
    // Index 4: (ภาพคือ Coin สีขาว)
    WeightedPrize(Prize(PrizeType.coin, "เหรียญ", 1000, Colors.white), 10),
    // Index 5: (ภาพคือ Chest สีดำ)
    WeightedPrize(
      Prize(PrizeType.chest, "หีบสมบัติ", 2, Colors.grey.shade800),
      3,
    ),
    // Index 6: (ภาพคือ Energy สีแดง)
    WeightedPrize(Prize(PrizeType.energy, "หัวใจ", 2, Colors.red.shade400), 5),
    // Index 7: (ภาพคือ Bonus สีเหลือง)
    WeightedPrize(
      Prize(PrizeType.bonus, "โบนัส", 0, Colors.yellow.shade600),
      5,
    ),
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

    FlameAudio.loop('spinning.mp3');

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
    _energyRegenTimer = async.Timer.periodic(const Duration(minutes: 5), (
      timer,
    ) {
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

  void _upgradeIsland() {
    if (_upgradeLevel < _upgradeCosts.length) {
      final int cost = _upgradeCosts[_upgradeLevel];
      if (_coins >= cost) {
        setState(() {
          _coins -= cost;
          _upgradeLevel++;
        });
      }
    }
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
            children: [_buildGamePage(), _buildIslandPage()],
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

  Widget _buildGamePage() {
    return Stack(
      children: [
        SizedBox.expand(
          child: rive.RiveAnimation.asset(
            'assets/animations/rives/backgroud_ani.riv',
            fit: BoxFit.cover,
          ),
        ),
        SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: _buildWheelWithPointer(),
                ),
                _buildSpinButton(),

                const Spacer(flex: 2),

                IconButton(
                  onPressed:
                      () => _pageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIslandPage() {
    return Stack(
      children: [
        Container(color: const Color(0xFF162642)),
        SafeArea(
          child: Center(
            child: Column(
              children: [
                IconButton(
                  onPressed:
                      () => _pageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      ),
                  icon: const Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                Expanded(child: _buildIslandSection()),
                _buildUpgradeSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWheelWithPointer() {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: _wheelSize,
          height: _wheelSize,
          child: ClipOval(child: GameWidget(game: _wheelGame)),
        ),
        Positioned(
          top: -20,
          child: Icon(
            Icons.arrow_drop_down,
            size: 100,
            color: _pointerColor,
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

  Widget _buildSpinButton() {
    return BounceInUp(
      child: GestureDetector(
        onTap: _isSpinning ? null : _spinWheel,
        child: Image.asset('assets/images/spin_1.png', width: 200),
      ),
    );
  }

  Widget _buildIslandSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        rive.RiveAnimation.asset(
          'assets/animations/rives/koh.riv',
          animations: ['Timeline 1'],
        ),
        if (_upgradeLevel >= 1)
          rive.RiveAnimation.asset(
            'assets/animations/rives/tree_1.riv',
            animations: ['Timeline 1'],
          ),
      ],
    );
  }

  Widget _buildUpgradeSection() {
    final bool isMaxLevel = _upgradeLevel >= _upgradeCosts.length;
    int nextUpgradeCost = isMaxLevel ? 0 : _upgradeCosts[_upgradeLevel];
    final bool canAffordUpgrade = _coins >= nextUpgradeCost;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child:
          isMaxLevel
              ? Container(
                height: 50,
                alignment: Alignment.center,
                child: const Text(
                  '✨ อัปเกรดสูงสุดแล้ว ✨',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : ElevatedButton.icon(
                onPressed: canAffordUpgrade ? _upgradeIsland : null,
                icon: const Icon(Icons.upgrade),
                label: Text(
                  'อัปเกรด (${NumberFormat("#,###").format(nextUpgradeCost)})',
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      canAffordUpgrade ? Colors.green : Colors.grey,
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
    );
  }
}
