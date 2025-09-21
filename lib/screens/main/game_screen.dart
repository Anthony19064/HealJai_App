import 'dart:async' as async;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:healjai_project/Widgets/bottom_nav.dart';
import 'package:rive/rive.dart' hide Image; // Import Rive and hide conflicting Image class

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

  // --- Rive State Controllers ---
  StateMachineController? _riveController;
  SMIInput<double>? _spinInput;

  // IMPORTANT: The order of this list now EXACTLY matches your Rive input numbers (0-7)
  final List<WeightedPrize> _prizes = [
    // Rive Input: 0
    WeightedPrize(Prize(PrizeType.coin, "เหรียญ", 100), 30),     // stop_coin1
    // Rive Input: 1
    WeightedPrize(Prize(PrizeType.coin, "เหรียญ", 1000), 15),   // stop_coin2
    // Rive Input: 2
    WeightedPrize(Prize(PrizeType.energy, "พลังใจ", 1), 20),     // stop_eng1
    // Rive Input: 3
    WeightedPrize(Prize(PrizeType.energy, "พลังใจ", 2), 10),    // stop_eng2
    // Rive Input: 4
    WeightedPrize(Prize(PrizeType.bonus, "โบนัส", 2), 5),      // stop_bonus1 (Multiplier)
    // Rive Input: 5
    WeightedPrize(Prize(PrizeType.bonus, "โบนัส", 0), 10),     // stop_bonus2 (Free Spin)
    // Rive Input: 6
    WeightedPrize(Prize(PrizeType.chest, "หีบสมบัติ", 1), 3),   // stop_he1 (Very Rare Chest)
    // Rive Input: 7
    WeightedPrize(Prize(PrizeType.chest, "หีบสมบัติ", 1), 7),   // stop_he2 (Rare Chest)
  ];

  @override
  void initState() {
    super.initState();
    _startEnergyRegenTimer();
  }

  @override
  void dispose() {
    _energyRegenTimer?.cancel();
    _riveController?.dispose();
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
  
  void _onRiveInit(Artboard artboard) {
    _riveController = StateMachineController.fromArtboard(artboard, 'State Machine 1');
    if (_riveController != null) {
      artboard.addController(_riveController!);
      debugPrint("✅ Rive Controller 'State Machine 1' found!");
      _spinInput = _riveController!.findInput<double>('spin');
      if (_spinInput != null) {
          debugPrint("✅ Number Input 'spin' found!");
          _spinInput?.value = -1; // Set initial state to idle (-1)
      } else {
          debugPrint("❌ ERROR: Rive input named 'spin' NOT FOUND or is NOT a NUMBER.");
      }
    } else {
        debugPrint("❌ ERROR: Rive State Machine named 'State Machine 1' NOT FOUND.");
    }
  }

  void _spinWheel() {
    if (_spinInput == null) {
      debugPrint("Cannot spin because the Rive input was not found. Check _onRiveInit logs.");
      return;
    }
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
    
    // 1. Trigger the animation START
    _spinInput!.value = resultIndex.toDouble();

    // 2. Wait for the animation to visually complete
    // You can adjust this duration to match your Rive animation's length
    Future.delayed(const Duration(seconds: 5), () {
       if (mounted) {
        // 3. Handle the prize logic
        final prize = _prizes[resultIndex].prize;
        _handlePrize(prize);

        // 4. Reset the UI state
        setState(() {
          _isSpinning = false;
        });

        // 5. Reset the Rive state machine for the next spin
        _spinInput?.value = -1;
       }
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
      
      body: Container( // 1. ห่อด้วย Container
      decoration: const BoxDecoration( // 2. ตกแต่งพื้นหลัง
        image: DecorationImage(
          image: AssetImage("assets/images/wagu1.jpg"), 
          fit: BoxFit.cover, // ทำให้ภาพเต็มหน้าจอ
        ),
      ),
      child: SafeArea( // SafeArea และ Column ยังอยู่เหมือนเดิม
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              buildTopBar(),
              const Spacer(),
              buildWheelWithPointer(), // วงล้อจะลอยอยู่บนพื้นหลัง
              const Spacer(),
              buildButtonControls(),
              const SizedBox(height: 20),
            ],
          ),
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
          child: RiveAnimation.asset(
            'assets/animations/rives/wheelspin_new.riv',
            onInit: _onRiveInit,
            fit: BoxFit.contain,
          ),
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

  void _onIslandButtonPressed() {
    context.go('/');
  }

  Widget buildButtonControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
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
          Icons.home_filled,
          color: Colors.black54,
          size: 28,
        ),
      ),
    );
  }
}

