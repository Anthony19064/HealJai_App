import 'dart:async';
import 'dart:math';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rive/rive.dart';
import 'package:go_router/go_router.dart'; 

// --- Models ---
class FloatingCoin {
  final Key id;
  final int amount;
  final double x;
  final double y;
  final Color color;
  FloatingCoin({required this.id, required this.amount, required this.x, required this.y, required this.color});
}

class LevelConfig {
  final int levelNumber;
  final int targetScore;
  final int maxMoves;
  LevelConfig({required this.levelNumber, required this.targetScore, required this.maxMoves});
}

class CandyModel {
  final int id;
  int type; 
  int row;
  int col;
  CandyModel({required this.id, required this.type, required this.row, required this.col});
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final int gridSize = 6; 
  List<CandyModel> candies = [];
  List<FloatingCoin> _floatingCoins = [];
  int _nextId = 0;
  bool _isProcessing = false;
  Offset? _dragStartPos;
  
  int _score = 0;
  int _starCoins = 100; 
  int _movesLeft = 0;
  int _currentLevel = 1;
  late LevelConfig _levelData;

  String? _activeSkill;
  final Map<String, int> _skillPrices = {'hammer': 50, 'bomb': 100, 'rocket': 80};

  bool _isLoading = true;
  late AudioPool _matchPool;
  late AudioPool _swapPool;

  @override
  void initState() {
    super.initState();
    _setupLevel(_currentLevel);
    _loadResources().then((_) => _initGame());
  }

  // --- ระบบด่านไม่สิ้นสุด: เริ่มต้น 20 รอบ เพิ่ม 10 ทุก 5 ด่าน ---
  void _setupLevel(int lv) {
    int calculatedTarget = lv * 300; 
    int baseMoves = 20; 
    int extraMoves = ((lv - 1) ~/ 5) * 10; 
    
    _levelData = LevelConfig(
      levelNumber: lv, 
      targetScore: calculatedTarget, 
      maxMoves: baseMoves + extraMoves
    );
    
    _score = 0;
    _movesLeft = _levelData.maxMoves;
  }

  Future<void> _loadResources() async {
    try {
      _matchPool = await FlameAudio.createPool("choptree.mp3", minPlayers: 3, maxPlayers: 5);
      _swapPool = await FlameAudio.createPool("criticalSound.WAV", minPlayers: 1, maxPlayers: 2);
    } catch(e) { debugPrint("Audio error: $e"); }
    setState(() => _isLoading = false);
  }

  void _initGame() {
    candies.clear();
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) { _addNewCandy(r, c); }
    }
    _ensureNoInitialMatches();
    if (!_hasPossibleMoves()) _shuffleBoard(silent: true);
    setState(() {});
  }

  void _addNewCandy(int r, int c) {
    candies.add(CandyModel(id: _nextId++, type: Random().nextInt(7) + 1, row: r, col: c));
  }

  bool _hasAnyMatch() {
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (_checkMatchAt(r, c)) return true;
      }
    }
    return false;
  }

  bool _checkMatchAt(int r, int c) {
    var candy = _getCandyAt(r, c);
    if (candy == null) return false;
    int hCount = 1 + _countSameType(r, c, 0, 1) + _countSameType(r, c, 0, -1);
    int vCount = 1 + _countSameType(r, c, 1, 0) + _countSameType(r, c, -1, 0);
    return hCount >= 3 || vCount >= 3;
  }

  int _countSameType(int r, int c, int dr, int dc) {
    var base = _getCandyAt(r, c);
    if (base == null) return 0;
    int count = 0, currR = r + dr, currC = c + dc;
    while (currR >= 0 && currR < gridSize && currC >= 0 && currC < gridSize) {
      var next = _getCandyAt(currR, currC);
      if (next != null && next.type == base.type) {
        count++; currR += dr; currC += dc;
      } else break;
    }
    return count;
  }

  // --- คะแนนคงที่ 50 แต้ม ---
  void _rewardPlayer(CandyModel candy, double cellSize) {
    int scoreAmount = 20; 
    int coinAmount = 10;
    
    _score += scoreAmount;
    _starCoins += coinAmount;
    _showCoinPop(scoreAmount, candy.type, candy.row, candy.col, cellSize);
  }

  void _showCoinPop(int amount, int type, int row, int col, double cellSize) {
    final id = UniqueKey();
    setState(() {
      _floatingCoins.add(FloatingCoin(
        id: id,
        amount: amount,
        x: col * cellSize + (cellSize / 4),
        y: row * cellSize,
        color: _getMoodColor(type),
      ));
    });
    Timer(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _floatingCoins.removeWhere((coin) => coin.id == id));
    });
  }

  String _getAnimationName(int type) {
    switch (type) {
      case 1: return 'Wow'; case 2: return 'Love'; case 3: return 'Happy'; 
      case 4: return 'Normal'; case 5: return 'Sad'; case 6: return 'Scare'; case 7: return 'Angry';
      default: return 'Normal';
    }
  }

  Color _getMoodColor(int type) {
    switch (type) {
      case 1: return const Color(0xFFF29C41);
      case 2: return const Color(0xFFFF9B9B);
      case 3: return const Color(0xFFFFCC00);
      case 4: return const Color(0xFF878787);
      case 5: return const Color(0xFF86AFFC);
      case 6: return const Color(0xFFCB9DF0);
      case 7: return const Color(0xFFEB4343);
      default: return Colors.black;
    }
  }

  void _ensureNoInitialMatches() {
    bool hasMatch;
    do {
      hasMatch = false;
      for (var candy in candies) {
        if (_checkMatchAt(candy.row, candy.col)) {
          candy.type = Random().nextInt(7) + 1;
          hasMatch = true;
        }
      }
    } while (hasMatch);
  }

  CandyModel? _getCandyAt(int r, int c) {
    try { return candies.firstWhere((e) => e.row == r && e.col == c); } catch (e) { return null; }
  }

  bool _hasPossibleMoves() {
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (c < gridSize - 1 && _wouldMatchIfSwapped(r, c, r, c + 1)) return true;
        if (r < gridSize - 1 && _wouldMatchIfSwapped(r, c, r + 1, c)) return true;
      }
    }
    return false;
  }

  bool _wouldMatchIfSwapped(int r1, int c1, int r2, int c2) {
    var c1Obj = _getCandyAt(r1, c1);
    var c2Obj = _getCandyAt(r2, c2);
    if (c1Obj == null || c2Obj == null) return false;
    int temp = c1Obj.type;
    c1Obj.type = c2Obj.type;
    c2Obj.type = temp;
    bool match = _checkMatchAt(r1, c1) || _checkMatchAt(r2, c2);
    c2Obj.type = c1Obj.type;
    c1Obj.type = temp;
    return match;
  }

  void _shuffleBoard({bool silent = false}) {
    if (!silent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ทางตัน! สลับตารางใหม่อัตโนมัติ")));
    }
    do {
      for (var candy in candies) { candy.type = Random().nextInt(7) + 1; }
      _ensureNoInitialMatches();
    } while (!_hasPossibleMoves());
    setState(() {});
  }

  // --- แก้บัค: เพิ่มการเช็คสถานะหลังใช้ Skill ---
  void _useSkill(int r, int c, double cellSize) async {
    if (_isProcessing || _activeSkill == null) return;
    _isProcessing = true;
    int price = _skillPrices[_activeSkill!]!;
    if (_starCoins < price) { _activeSkill = null; _isProcessing = false; setState(() {}); return; }

    Set<CandyModel> toRemove = {};
    if (_activeSkill == 'hammer') {
      var target = _getCandyAt(r, c); if (target != null) toRemove.add(target);
    } else if (_activeSkill == 'bomb') {
      for (int i = r - 1; i <= r + 1; i++) {
        for (int j = c - 1; j <= c + 1; j++) {
          var target = _getCandyAt(i, j); if (target != null) toRemove.add(target);
        }
      }
    } else if (_activeSkill == 'rocket') {
      for (int j = 0; j < gridSize; j++) {
        var target = _getCandyAt(r, j); if (target != null) toRemove.add(target);
      }
    }

    if (toRemove.isNotEmpty) {
      setState(() {
        _starCoins -= price;
        for (var candy in toRemove) { _rewardPlayer(candy, cellSize); }
        candies.removeWhere((c) => toRemove.contains(c));
        _activeSkill = null; 
      });
      _matchPool.start();
      await Future.delayed(const Duration(milliseconds: 300));
      _fillGaps();
      await _processMatches(cellSize); 
      _checkGameStatus(); // <--- จุดที่แก้บัค: เช็คว่าแต้มถึงหรือยัง
    }
    _isProcessing = false;
  }

  void _handleSwipe(CandyModel candy, Offset globalPos, double cellSize) {
    if (_dragStartPos == null || _isProcessing || _movesLeft <= 0 || _activeSkill != null) return;
    final dx = globalPos.dx - _dragStartPos!.dx;
    final dy = globalPos.dy - _dragStartPos!.dy;
    if (dx.abs() > 30 || dy.abs() > 30) {
      int tR = candy.row, tC = candy.col;
      if (dx.abs() > dy.abs()) { tC = (dx > 0) ? candy.col + 1 : candy.col - 1; }
      else { tR = (dy > 0) ? candy.row + 1 : candy.row - 1; }
      if (tR >= 0 && tR < gridSize && tC >= 0 && tC < gridSize) _attemptSwap(candy, tR, tC, cellSize);
      _dragStartPos = null;
    }
  }

  Future<void> _attemptSwap(CandyModel c1, int tR, int tC, double cellSize) async {
    _isProcessing = true;
    var c2 = _getCandyAt(tR, tC)!;
    _swapPos(c1, c2); _swapPool.start();
    await Future.delayed(const Duration(milliseconds: 350));
    if (_hasAnyMatch()) {
      setState(() { _movesLeft--; });
      await _processMatches(cellSize);
      if (!_hasPossibleMoves() && _movesLeft > 0) _shuffleBoard();
      _checkGameStatus(); 
    } else {
      _swapPos(c1, c2);
      await Future.delayed(const Duration(milliseconds: 350));
    }
    _isProcessing = false;
  }

  void _swapPos(CandyModel c1, CandyModel c2) {
    setState(() {
      int tr = c1.row, tc = c1.col;
      c1.row = c2.row; c1.col = c2.col;
      c2.row = tr; c2.col = tc;
    });
  }

  Future<void> _processMatches(double cellSize) async {
    while (_hasAnyMatch()) {
      Set<CandyModel> toRemove = {};
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c < gridSize; c++) {
          var candy = _getCandyAt(r, c); if (candy == null) continue;
          var rowMatch = _getMatchList(r, c, 0, 1); if (rowMatch.length >= 3) toRemove.addAll(rowMatch);
          var colMatch = _getMatchList(r, c, 1, 0); if (colMatch.length >= 3) toRemove.addAll(colMatch);
        }
      }
      setState(() {
        for (var c in toRemove) { _rewardPlayer(c, cellSize); }
        candies.removeWhere((c) => toRemove.contains(c));
      });
      _matchPool.start();
      await Future.delayed(const Duration(milliseconds: 300));
      _fillGaps();
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  List<CandyModel> _getMatchList(int r, int c, int dr, int dc) {
    var candy = _getCandyAt(r, c); if (candy == null) return [];
    List<CandyModel> match = [candy];
    int currR = r + dr, currC = c + dc;
    while (currR < gridSize && currC < gridSize) {
      var next = _getCandyAt(currR, currC);
      if (next != null && next.type == candy.type) { match.add(next); currR += dr; currC += dc; }
      else break;
    }
    return match;
  }

  void _fillGaps() {
    setState(() {
      for (int c = 0; c < gridSize; c++) {
        int empty = 0;
        for (int r = gridSize - 1; r >= 0; r--) {
          var candy = _getCandyAt(r, c);
          if (candy == null) empty++;
          else if (empty > 0) candy.row += empty;
        }
        for (int i = 0; i < empty; i++) _addNewCandy(i, c);
      }
    });
  }

  void _checkGameStatus() {
    if (_score >= _levelData.targetScore) {
      _showEndDialog("ยอดเยี่ยม!", "ผ่านด่านที่ $_currentLevel", true);
    } else if (_movesLeft <= 0) {
      _showEndDialog("เสียดายจัง", "จำนวนครั้งที่เดินหมดแล้ว", false);
    }
  }

  void _showEndDialog(String title, String msg, bool isWin) {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
      title: Text(title, style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
      content: Text(msg, style: GoogleFonts.kanit()),
      actions: [
        TextButton(onPressed: () => context.go('/'), child: const Text("หน้าหลัก", style: TextStyle(color: Colors.grey))),
        TextButton(onPressed: () {
          Navigator.pop(ctx);
          if (isWin) setState(() => _currentLevel++);
          _setupLevel(_currentLevel); _initGame();
        }, child: Text(isWin ? "ด่านต่อไป" : "ลองใหม่")),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      body: SafeArea(child: Column(children: [
        _buildTopBar(), 
        _buildStatusPanel(),
        _buildSkillButtons(),
        const SizedBox(height: 10),
        Expanded(child: _buildPlayArea()),
        const SizedBox(height: 20),
      ])),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.home_rounded, color: Colors.brown, size: 32),
              onPressed: () => context.go('/'), 
            ),
          ),
          Text(
            'Level $_currentLevel',
            style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.brown[700]),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.shade700),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text('$_starCoins', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        _skillItem('hammer', Icons.build, _skillPrices['hammer']!, Colors.blue),
        const SizedBox(width: 10),
        _skillItem('bomb', Icons.wb_iridescent, _skillPrices['bomb']!, Colors.orange),
        const SizedBox(width: 10),
        _skillItem('rocket', Icons.straighten, _skillPrices['rocket']!, Colors.purple),
      ]),
    );
  }

  Widget _skillItem(String type, IconData icon, int price, Color color) {
    bool isSelected = _activeSkill == type;
    bool canAfford = _starCoins >= price;
    return Expanded(
      child: GestureDetector(
        onTap: () { if (canAfford && !_isProcessing) setState(() => _activeSkill = isSelected ? null : type); },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.4) : (canAfford ? Colors.white : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(15), border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: 2.5),
          ),
          child: Column(children: [
            Icon(icon, color: canAfford ? color : Colors.grey, size: 28),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.stars, size: 12, color: Colors.amber),
              Text(' $price', style: GoogleFonts.kanit(fontSize: 14, color: canAfford ? Colors.black87 : Colors.grey)),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildStatusPanel() {
    return Container(
      padding: const EdgeInsets.all(12), margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _statBox("เป้าหมาย", "${_levelData.targetScore}", Colors.orange[800]!),
        _statBox("คะแนน", "$_score", Colors.blue[800]!),
        _statBox("เหลือ", "$_movesLeft", Colors.red[800]!),
      ]),
    );
  }

  Widget _statBox(String t, String v, Color c) => Column(children: [Text(t, style: GoogleFonts.kanit(fontSize: 12)), Text(v, style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: c))]);

  Widget _buildPlayArea() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return LayoutBuilder(builder: (ctx, box) {
      double cellSize = (box.maxWidth - 40) / gridSize; 
      return Center(child: Container(
        width: cellSize * gridSize, height: cellSize * gridSize,
        decoration: BoxDecoration(color: Colors.brown[50], borderRadius: BorderRadius.circular(12)),
        child: Stack(children: [
          ...candies.map((c) => AnimatedPositioned(
            key: ValueKey(c.id), duration: const Duration(milliseconds: 400), curve: Curves.easeOutBack,
            top: c.row * cellSize, left: c.col * cellSize,
            child: GestureDetector(
              onTap: () { if (_activeSkill != null) _useSkill(c.row, c.col, cellSize); },
              onPanStart: (d) => _dragStartPos = d.globalPosition,
              onPanUpdate: (d) => _handleSwipe(c, d.globalPosition, cellSize),
              child: SizedBox(width: cellSize, height: cellSize, child: Padding(
                padding: const EdgeInsets.all(4),
                child: RiveAnimation.asset('assets/animations/rives/mood.riv', animations: [_getAnimationName(c.type)], fit: BoxFit.contain),
              )),
            ),
          )),
          ..._floatingCoins.map((coin) => TweenAnimationBuilder<double>(
            key: coin.id,
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Positioned(
                left: coin.x,
                top: coin.y - (value * 50),
                child: Opacity(
                  opacity: 1.0 - value,
                  child: Text(
                    '+${coin.amount}',
                    style: GoogleFonts.kanit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: coin.color,
                      shadows: [Shadow(color: Colors.white.withOpacity(0.8), blurRadius: 4)],
                    ),
                  ),
                ),
              );
            },
          )),
        ]),
      ));
    });
  }
}