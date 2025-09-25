import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healjai_project/Widgets/minigame/game_top_bar.dart';
import 'package:rive/rive.dart' as rive;
import 'package:intl/intl.dart';

class Island extends StatefulWidget {
  final int coins;
  final int energy;

  const Island({super.key, required this.coins, required this.energy});

  @override
  State<Island> createState() => _IslandState();
}

class _IslandState extends State<Island> {
  // --- State Variables ---
  late int _currentCoins;
  late int _currentEnergy;

  // ✨ 1. เปลี่ยนจาก bool มาใช้ int เพื่อเก็บ Level
  int _upgradeLevel = 0;

  // ✨ 2. สร้าง List สำหรับเก็บราคาอัปเกรดในแต่ละขั้น
  // ราคาอัปไป lv.1, lv.2, lv.3, ... (คุณสามารถเพิ่มได้เรื่อยๆ)
  final List<int> _upgradeCosts = [100, 100, 100];

  @override
  void initState() {
    super.initState();
    _currentCoins = widget.coins;
    _currentEnergy = widget.energy;
  }

  // --- Logic Functions ---
  void _upgradeIsland() {
    // เช็คว่ายังอัปเกรดต่อได้อีกหรือไม่
    if (_upgradeLevel < _upgradeCosts.length) {
      final int cost = _upgradeCosts[_upgradeLevel]; // ดึงราคาของเลเวลถัดไป
      if (_currentCoins >= cost) {
        setState(() {
          _currentCoins -= cost;
          _upgradeLevel++; // เพิ่มเลเวล
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMaxLevel = _upgradeLevel >= _upgradeCosts.length;
    int nextUpgradeCost = 0;
    if (!isMaxLevel) {
      nextUpgradeCost = _upgradeCosts[_upgradeLevel];
    }
    final bool canAffordUpgrade = _currentCoins >= nextUpgradeCost;

    return Scaffold(
      backgroundColor: const Color(0xFF162642),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: GameTopBar(coins: _currentCoins, energy: _currentEnergy),
            ),

            // ✨ 3. ส่วนแสดงผลที่เปลี่ยนตาม Level
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // เกาะ (พื้นฐาน)
                  rive.RiveAnimation.asset('assets/animations/rives/koh.riv'),

                  if (_upgradeLevel >= 1)
                    rive.RiveAnimation.asset(
                      'assets/animations/rives/tree_1.riv',
                    ),

                  // if (_upgradeLevel >= 2)
                  //   Positioned(
                  //     top: 40,
                  //     left: 5, 
                  //     child: SizedBox(
                  //       width: 500,  // ✨ เพิ่ม width (ปรับขนาดตามต้องการ)
                  //       height: 500, // ✨ เพิ่ม height (ปรับขนาดตามต้องการ)
                  //       child: rive.RiveAnimation.asset(
                  //         'assets/animations/rives/waterfell_1.riv',
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // ถ้ายังไม่ถึงเลเวลสูงสุด ให้แสดงปุ่มอัปเกรด
                  if (!isMaxLevel)
                    ElevatedButton.icon(
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
                    )
                  // ถ้าเลเวลสูงสุดแล้ว ให้แสดงข้อความ
                  else
                    Container(
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
                    ),

                  const SizedBox(height: 12),

                  
                 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
