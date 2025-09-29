// lib/widgets/minigame/island_page_view.dart

import 'package:flutter/material.dart';
import 'package:healjai_project/models/minigame_models.dart';
import 'package:rive/rive.dart' as rive;

class IslandPageView extends StatefulWidget {
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
  State<IslandPageView> createState() => _IslandPageViewState();
}

class _IslandPageViewState extends State<IslandPageView> {
  rive.RiveAnimationController? _islandController;
  rive.RiveAnimationController? _treeController;
  rive.RiveAnimationController? _flowerController;

  // --- ชื่อไฟล์และ Artboard ---
  static const islandFileName = 'assets/animations/rives/island_master.riv';
  static const treeFileName = 'assets/animations/rives/tree_master.riv';
  static const flowerFileName = 'assets/animations/rives/fl_master.riv';

  static const islandArtboard = 'Artboard';
  static const treeArtboard = 'treeartboard';
  static const flowerArtboard = 'flartboard';

  // --- ชื่อแอนิเมชัน (ดึงมาจากไฟล์ที่คุณส่งให้) ---
  static const islandIdle1 = 'Island_lv1', islandIdle2 = 'Island_lv2', islandIdle3 = 'Island_lv3';
  static const islandTransitionTo2 = 'Island_lv1 to lv2', islandTransitionTo3 = 'Island_lv2 to lv3';
  
  static const treeTransitionTo1 = 'treelv0 to lv1', treeIdle1 = 'tree1', treeIdle2 = 'tree2', treeIdle3 = 'tree3';
  static const treeTransitionTo2 = 'treelv1 to lv2', treeTransitionTo3 = 'treelv2 to lv3';

  static const flowerTransitionTo1 = 'flowerlv0 to lv1', flowerIdle1 = 'flower_lv1', flowerIdle2 = 'flower_lv2', flowerIdle3 = 'flower_lv3';
  static const flowerTransitionTo2 = 'flowerlv1 to lv2', flowerTransitionTo3 = 'flowerlv2 to lv3';

  @override
  void initState() {
    super.initState();
    _islandController = rive.SimpleAnimation(_getIdleAnimationName(UpgradeType.island));
    _treeController = rive.SimpleAnimation(_getIdleAnimationName(UpgradeType.tree));
    _flowerController = rive.SimpleAnimation(_getIdleAnimationName(UpgradeType.flower));
  }

  String _getIdleAnimationName(UpgradeType type, {int? level}) {
    final currentLevel = level ?? widget.upgradeLevels[type]!;
    dynamic idle1, idle2, idle3;
    switch (type) {
      case UpgradeType.island: idle1=islandIdle1; idle2=islandIdle2; idle3=islandIdle3; break;
      case UpgradeType.tree: idle1=treeIdle1; idle2=treeIdle2; idle3=treeIdle3; break;
      case UpgradeType.flower: idle1=flowerIdle1; idle2=flowerIdle2; idle3=flowerIdle3; break;
    }
    if (currentLevel >= 3) return idle3;
    if (currentLevel >= 2) return idle2;
    if (currentLevel >= 1) return idle1;
    return 'idle';
  }
  
  void _handleUpgrade(UpgradeType type, int oldLevel, int newLevel) {
    String transitionName = '', idleName = _getIdleAnimationName(type, level: newLevel);
    dynamic t1, t2, t3;
    switch(type) {
      case UpgradeType.island: t2=islandTransitionTo2; t3=islandTransitionTo3; break;
      case UpgradeType.tree: t1=treeTransitionTo1; t2=treeTransitionTo2; t3=treeTransitionTo3; break;
      case UpgradeType.flower: t1=flowerTransitionTo1; t2=flowerTransitionTo2; t3=flowerTransitionTo3; break;
    }

    if (oldLevel == 0 && newLevel == 1) transitionName = t1;
    else if (oldLevel == 1 && newLevel == 2) transitionName = t2;
    else if (oldLevel == 2 && newLevel == 3) transitionName = t3;

    if (transitionName.isNotEmpty) {
      _setController(type, rive.OneShotAnimation(transitionName, autoplay: true, onStop: () => _setController(type, rive.SimpleAnimation(idleName))));
    } else if (newLevel > oldLevel) {
      _setController(type, rive.SimpleAnimation(idleName));
    }
  }
  
  void _setController(UpgradeType type, rive.RiveAnimationController controller) {
    setState(() {
      switch (type) {
        case UpgradeType.island: _islandController = controller; break;
        case UpgradeType.tree: _treeController = controller; break;
        case UpgradeType.flower: _flowerController = controller; break;
      }
    });
  }

  @override
  void didUpdateWidget(covariant IslandPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (var type in UpgradeType.values) {
      final oldLevel = oldWidget.upgradeLevels[type]!;
      final newLevel = widget.upgradeLevels[type]!;
      if (newLevel > oldLevel) _handleUpgrade(type, oldLevel, newLevel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(color: const Color(0xFF162642)),
      SafeArea(child: Column(children: [
        IconButton(onPressed: widget.onScrollUp, icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 40)),
        Expanded(child: _buildIslandSection()),
        _buildUpgradeSection(),
      ])),
    ]);
  }

  Widget _buildIslandSection() {
    return Stack(alignment: Alignment.center, children: [
      if (widget.upgradeLevels[UpgradeType.island]! > 0)
        rive.RiveAnimation.asset(islandFileName, artboard: islandArtboard, controllers: [_islandController!]),
      if (widget.upgradeLevels[UpgradeType.tree]! > 0)
        rive.RiveAnimation.asset(treeFileName, artboard: treeArtboard, controllers: [_treeController!]),
      if (widget.upgradeLevels[UpgradeType.flower]! > 0)
        Positioned.fill(child: rive.RiveAnimation.asset(flowerFileName, artboard: flowerArtboard, controllers: [_flowerController!])),
    ]);
  }

  Widget _buildUpgradeSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ElevatedButton.icon(
        onPressed: widget.onShowUpgradeModal,
        icon: const Icon(Icons.store),
        label: const Text('ร้านค้าตกแต่ง'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black, backgroundColor: Colors.amber,
          minimumSize: const Size(double.infinity, 50),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }
}