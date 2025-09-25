// lib/models/minigame_models.dart

import 'package:flutter/material.dart';

// Enums define the types of prizes and upgrades available.
enum PrizeType { coin, energy, chest, bonus }
enum UpgradeType { island, tree, flower }

// Represents a single prize on the wheel.
class Prize {
  final PrizeType type;
  final String label;
  final int value;
  final Color color;
  Prize(this.type, this.label, this.value, this.color);
}

// Associates a Prize with a weight for calculating probabilities.
class WeightedPrize {
  final Prize prize;
  final int weight;
  WeightedPrize(this.prize, this.weight);
}