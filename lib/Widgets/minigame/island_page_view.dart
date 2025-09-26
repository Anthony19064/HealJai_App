// lib/widgets/minigame/island_page_view.dart

import 'package:flutter/material.dart';
import 'package:healjai_project/models/minigame_models.dart';
import 'package:rive/rive.dart' as rive;

class IslandPageView extends StatelessWidget {
  final Map<UpgradeType, int> upgradeLevels;
  final VoidCallback onShowUpgradeModal;
  final VoidCallback onScrollUp;

  const IslandPageView({
    super.key,
    required this.upgradeLevels,
    required this.onShowUpgradeModal,
    required this.onScrollUp,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: const Color(0xFF162642)),
        SafeArea(
          child: Column(
            children: [
              IconButton(
                onPressed: onScrollUp,
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
      ],
    );
  }

  Widget _buildIslandSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Base Island
        rive.RiveAnimation.asset(
          'assets/animations/rives/island_1.riv',
          animations: ['Timeline 1'],
        ),
        // Island Upgrades
        if (upgradeLevels[UpgradeType.island]! >= 2)
          rive.RiveAnimation.asset('assets/animations/rives/island_2.riv', animations: ['Timeline 1']),
        if (upgradeLevels[UpgradeType.island]! >= 3)
          rive.RiveAnimation.asset('assets/animations/rives/island_3.riv', animations: ['Timeline 1']),
        // Tree Upgrades
        if (upgradeLevels[UpgradeType.tree]! >= 1)
          rive.RiveAnimation.asset('assets/animations/rives/tree_1.riv', animations: ['Timeline 1']),
        if (upgradeLevels[UpgradeType.tree]! >= 2)
          rive.RiveAnimation.asset('assets/animations/rives/tree_2.riv', animations: ['Timeline 1']),
        if (upgradeLevels[UpgradeType.tree]! >= 3)
          rive.RiveAnimation.asset('assets/animations/rives/tree_3.riv', animations: ['Timeline 1']),
        // Flower Upgrades
        if (upgradeLevels[UpgradeType.flower]! >= 1)
          _buildFlowerAnimation('flower_1'),
        if (upgradeLevels[UpgradeType.flower]! >= 2)
          _buildFlowerAnimation('flower_2'),
        if (upgradeLevels[UpgradeType.flower]! >= 3)
          _buildFlowerAnimation('flower_3'),
      ],
    );
  }

  Widget _buildFlowerAnimation(String assetName) {
    return Positioned(
      top: 150,
      left: 35,
      child: SizedBox(
        width: 400,
        height: 400,
        child: rive.RiveAnimation.asset(
          'assets/animations/rives/$assetName.riv',
          animations: ['Timeline 1'],
        ),
      ),
    );
  }

  Widget _buildUpgradeSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ElevatedButton.icon(
        onPressed: onShowUpgradeModal,
        icon: const Icon(Icons.store),
        label: const Text('ร้านค้าตกแต่ง'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.amber,
          minimumSize: const Size(double.infinity, 50),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }
}