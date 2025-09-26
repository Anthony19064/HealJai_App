// lib/widgets/minigame/upgrade_shop_modal.dart

import 'package:flutter/material.dart';
import 'package:healjai_project/models/minigame_models.dart';
import 'package:intl/intl.dart';

// This function shows the modal bottom sheet for upgrades.
void showUpgradeShopModal({
  required BuildContext context,
  required int currentCoins,
  required Map<UpgradeType, int> upgradeLevels,
  required Map<UpgradeType, List<int>> upgradeCosts,
  required Function(UpgradeType) onUpgrade, // Callback to perform the upgrade
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E3A5F),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (BuildContext context) {
      // StatefulBuilder allows the modal content to be updated independently.
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter modalSetState) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ร้านค้าอัปเกรด',
                  style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildUpgradeButton(
                  type: UpgradeType.tree,
                  label: 'เพิ่มต้นไม้',
                  icon: Icons.park,
                  currentCoins: currentCoins,
                  upgradeLevels: upgradeLevels,
                  upgradeCosts: upgradeCosts,
                  onPressed: () {
                    onUpgrade(UpgradeType.tree);
                    modalSetState(() {}); // Rebuild modal to reflect changes
                  },
                ),
                const SizedBox(height: 12),
                _buildUpgradeButton(
                  type: UpgradeType.flower,
                  label: 'เพิ่มดอกไม้',
                  icon: Icons.waves,
                  currentCoins: currentCoins,
                  upgradeLevels: upgradeLevels,
                  upgradeCosts: upgradeCosts,
                  onPressed: () {
                    onUpgrade(UpgradeType.flower);
                    modalSetState(() {});
                  },
                ),
                 const SizedBox(height: 12),
                _buildUpgradeButton(
                  type: UpgradeType.island,
                  label: 'ขยายเกาะ',
                  icon: Icons.landscape,
                  currentCoins: currentCoins,
                  upgradeLevels: upgradeLevels,
                  upgradeCosts: upgradeCosts,
                  onPressed: () {
                    onUpgrade(UpgradeType.island);
                    modalSetState(() {});
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// Helper widget for building each upgrade button within the modal.
Widget _buildUpgradeButton({
  required UpgradeType type,
  required String label,
  required IconData icon,
  required int currentCoins,
  required Map<UpgradeType, int> upgradeLevels,
  required Map<UpgradeType, List<int>> upgradeCosts,
  required VoidCallback onPressed,
}) {
  final int currentLevel = upgradeLevels[type]!;
  final List<int> costs = upgradeCosts[type]!;
  final bool isMaxLevel = currentLevel >= costs.length;
  final String levelText = isMaxLevel ? 'สูงสุด' : 'Lv.${currentLevel + 1}';

  String buttonText = 'อัปเกรดสูงสุดแล้ว';
  int? cost;
  if (!isMaxLevel) {
    cost = costs[currentLevel];
    buttonText = 'อัปเกรด (${NumberFormat("#,###").format(cost)})';
  }

  final bool canAfford = cost != null && currentCoins >= cost;
  final bool canUpgrade = !isMaxLevel && canAfford;

  return ElevatedButton.icon(
    onPressed: canUpgrade ? onPressed : null,
    icon: Icon(icon),
    label: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label ($levelText)'),
        if (!isMaxLevel) Text(buttonText),
      ],
    ),
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.green,
      minimumSize: const Size(double.infinity, 50),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      disabledBackgroundColor: isMaxLevel ? Colors.amber.shade800 : Colors.grey.shade800,
      disabledForegroundColor: Colors.white70,
    ),
  );
}