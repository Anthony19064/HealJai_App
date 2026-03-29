import 'dart:async';
import 'dart:math';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/providers/navProvider.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/GameProvider.dart';

// -------------------------------------------------------------------------
// 1. Models
// -------------------------------------------------------------------------
class FloatingCoin {
  final Key id;
  final int amount;
  final double x;
  final double y;
  final Color color;
  FloatingCoin({
    required this.id,
    required this.amount,
    required this.x,
    required this.y,
    required this.color,
  });
}

class LevelConfig {
  final int levelNumber;
  final int targetScore;
  final int maxTime;
  LevelConfig({
    required this.levelNumber,
    required this.targetScore,
    required this.maxTime,
  });
}

class CandyModel {
  final int id;
  int type;
  int row;
  int col;
  CandyModel({
    required this.id,
    required this.type,
    required this.row,
    required this.col,
  });
}

// -------------------------------------------------------------------------
// 2. MainMenuScreen (หน้า Start Game)
// -------------------------------------------------------------------------
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  // ส่วนปุ่ม Home มุมซ้ายบน
  Widget _buildTopBar(BuildContext context) {
    final navInfo = Provider.of<Navprovider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          icon: const Icon(Icons.home_rounded, color: Colors.brown, size: 36),
          onPressed: () {
            navInfo.resetHome();
            context.go('/');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context), // แสดงปุ่ม Home ด้านบนสุด
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInDown(
                    duration: const Duration(seconds: 1),
                    child: Text(
                      'Mood Match',
                      style: GoogleFonts.kanit(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: const Color.fromRGBO(93, 64, 55, 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeInUp(
                    duration: const Duration(seconds: 1),
                    child: FutureBuilder<int>(
                      future: getLevel(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        return Text(
                          'ตอนนี้คุณถึง Level ${snapshot.data} แล้วนะ !!',
                          style: GoogleFonts.kanit(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.brown[500],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ส่วนห่านที่มาร์คอยากให้เล่น Normal ตลอดเวลา
                  SizedBox(
                    height: 250,
                    width: 250,
                    child: RiveAnimation.asset(
                      'assets/animations/rives/goose_login.riv',
                      onInit: (artboard) {
                        // บังคับให้เล่นท่า normal วนลูปตลอดเวลา
                        artboard.addController(SimpleAnimation('normal'));
                      },
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: () => context.go('/gamescreen'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(93, 64, 55, 1),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Text(
                        'START GAME',
                        style: GoogleFonts.kanit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------------
// 3. GameScreen (หน้าเล่นเกม)
// -------------------------------------------------------------------------
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
  bool _hasGameEnded = false;
  Offset? _dragStartPos;

  int _score = 0;
  int _secondsLeft = 0;
  int _maxTime = 0;
  Timer? _gameTimer;

  int _currentLevel = 1;
  late LevelConfig _levelData;

  String? _activeSkill;
  late Map<String, int> _skillCharges;

  bool _isLoading = true;
  late AudioPool _matchPool;
  late AudioPool _swapPool;

  @override
  void initState() {
    super.initState();
    _initLevel();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  Future<void> _initLevel() async {
    _currentLevel = await getLevel();
    _setupLevel(_currentLevel);
    await _loadResources();
    _initGame();
    _startCountdown();
  }

  void _setupLevel(int lv) {
    int calculatedTarget = lv * 300;
    int baseTime = 60;
    int extraTime = (lv - 1) * 5;

    _levelData = LevelConfig(
      levelNumber: lv,
      targetScore: calculatedTarget,
      maxTime: baseTime + extraTime,
    );

    _skillCharges = {'hammer': 2, 'bomb': 1, 'rocket': 1};
    _score = 0;
    _secondsLeft = _levelData.maxTime;
    _maxTime = _secondsLeft;
    _hasGameEnded = false;
  }

  void _startCountdown() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
        if (_score >= _levelData.targetScore && !_hasGameEnded) {
          _checkGameStatus();
        }
      } else if (!_hasGameEnded) {
        _checkGameStatus();
      }
    });
  }

  Future<void> _loadResources() async {
    try {
      _matchPool = await FlameAudio.createPool(
        "choptree.mp3",
        minPlayers: 3,
        maxPlayers: 5,
      );
      _swapPool = await FlameAudio.createPool(
        "criticalSound.WAV",
        minPlayers: 1,
        maxPlayers: 2,
      );
    } catch (e) {
      debugPrint("Audio error: $e");
    }
    setState(() => _isLoading = false);
  }

  void _initGame() {
    candies.clear();
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        _addNewCandy(r, c);
      }
    }
    _ensureNoInitialMatches();
    if (!_hasPossibleMoves()) _shuffleBoard(silent: true);
    setState(() {});
  }

  void _addNewCandy(int r, int c) {
    candies.add(
      CandyModel(id: _nextId++, type: Random().nextInt(7) + 1, row: r, col: c),
    );
  }

  void _swapPos(CandyModel c1, CandyModel c2) {
    setState(() {
      int tr = c1.row, tc = c1.col;
      c1.row = c2.row;
      c1.col = c2.col;
      c2.row = tr;
      c2.col = tc;
    });
  }

  CandyModel? _getCandyAt(int r, int c) {
    try {
      return candies.firstWhere((e) => e.row == r && e.col == c);
    } catch (e) {
      return null;
    }
  }

  void _handleSwipe(CandyModel candy, Offset globalPos, double cellSize) {
    if (_dragStartPos == null ||
        _isProcessing ||
        _secondsLeft <= 0 ||
        _activeSkill != null ||
        _hasGameEnded)
      return;
    final dx = globalPos.dx - _dragStartPos!.dx;
    final dy = globalPos.dy - _dragStartPos!.dy;
    if (dx.abs() > 30 || dy.abs() > 30) {
      int tR = candy.row, tC = candy.col;
      if (dx.abs() > dy.abs()) {
        tC = (dx > 0) ? candy.col + 1 : candy.col - 1;
      } else {
        tR = (dy > 0) ? candy.row + 1 : candy.row - 1;
      }
      if (tR >= 0 && tR < gridSize && tC >= 0 && tC < gridSize)
        _attemptSwap(candy, tR, tC, cellSize);
      _dragStartPos = null;
    }
  }

  Future<void> _attemptSwap(
    CandyModel c1,
    int tR,
    int tC,
    double cellSize,
  ) async {
    _isProcessing = true;
    var c2 = _getCandyAt(tR, tC)!;
    _swapPos(c1, c2);
    _swapPool.start();
    await Future.delayed(const Duration(milliseconds: 350));
    if (_hasAnyMatch()) {
      await _processMatches(cellSize);
      if (!_hasPossibleMoves() && _secondsLeft > 0) _shuffleBoard();
      _checkGameStatus();
    } else {
      _swapPos(c1, c2);
      await Future.delayed(const Duration(milliseconds: 350));
    }
    _isProcessing = false;
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
        count++;
        currR += dr;
        currC += dc;
      } else
        break;
    }
    return count;
  }

  Future<void> _processMatches(double cellSize) async {
    while (_hasAnyMatch()) {
      Set<CandyModel> toRemove = {};
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c < gridSize; c++) {
          var candy = _getCandyAt(r, c);
          if (candy == null) continue;
          var rowMatch = _getMatchList(r, c, 0, 1);
          if (rowMatch.length >= 3) toRemove.addAll(rowMatch);
          var colMatch = _getMatchList(r, c, 1, 0);
          if (colMatch.length >= 3) toRemove.addAll(colMatch);
        }
      }
      setState(() {
        for (var c in toRemove) _rewardPlayer(c, cellSize);
        candies.removeWhere((c) => toRemove.contains(c));
      });
      _matchPool.start();
      await Future.delayed(const Duration(milliseconds: 300));
      _fillGaps();
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  List<CandyModel> _getMatchList(int r, int c, int dr, int dc) {
    var candy = _getCandyAt(r, c);
    if (candy == null) return [];
    List<CandyModel> match = [candy];
    int currR = r + dr, currC = c + dc;
    while (currR >= 0 && currR < gridSize && currC >= 0 && currC < gridSize) {
      var next = _getCandyAt(currR, currC);
      if (next != null && next.type == candy.type) {
        match.add(next);
        currR += dr;
        currC += dc;
      } else
        break;
    }
    return match;
  }

  void _fillGaps() {
    setState(() {
      for (int c = 0; c < gridSize; c++) {
        int empty = 0;
        for (int r = gridSize - 1; r >= 0; r--) {
          var candy = _getCandyAt(r, c);
          if (candy == null)
            empty++;
          else if (empty > 0)
            candy.row += empty;
        }
        for (int i = 0; i < empty; i++) _addNewCandy(i, c);
      }
    });
  }

  void _rewardPlayer(CandyModel candy, double cellSize) {
    _score += 25;
    _showCoinPop(25, candy.type, candy.row, candy.col, cellSize);
  }

  void _checkGameStatus() {
    if (_hasGameEnded) return;

    if (_score >= _levelData.targetScore) {
      _hasGameEnded = true;
      _gameTimer?.cancel();
      _showEndDialog("ยอดเยี่ยม!", "ผ่านด่านที่ $_currentLevel", true);
    } else if (_secondsLeft <= 0) {
      _hasGameEnded = true;
      _gameTimer?.cancel();
      _showEndDialog("หมดเวลา!", "คะแนนยังไม่ถึงเป้าหมาย", false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildTimeStatusPanel(),
            const SizedBox(height: 10),
            Expanded(child: _buildPlayArea()),
            _buildSkillButtons(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final navInfo = Provider.of<Navprovider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(
                Icons.home_rounded,
                color: Colors.brown,
                size: 32,
              ),
              onPressed: () {
                navInfo.resetHome();
                context.go('/');
              },
            ),
          ),
          Text(
            'Level $_currentLevel',
            style: GoogleFonts.kanit(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.brown[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeStatusPanel() {
    double progress = _secondsLeft / _maxTime;
    Color timerColor =
        _secondsLeft <= 10 ? Colors.redAccent : const Color(0xFF78B465);

    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statColumn(
                "TARGET",
                "${_levelData.targetScore}",
                Colors.orange[800]!,
              ),
              _statColumn("SCORE", "$_score", Colors.blue[800]!),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.timer_rounded, color: timerColor, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Container(height: 14, color: Colors.grey[200]),
                      AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        height: 14,
                        width:
                            (MediaQuery.of(context).size.width - 120) *
                            progress,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [timerColor, timerColor.withOpacity(0.6)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "${_secondsLeft}s",
                style: GoogleFonts.kanit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: timerColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String label, String value, Color color) => Column(
    children: [
      Text(
        label,
        style: GoogleFonts.kanit(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
      Text(
        value,
        style: GoogleFonts.kanit(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    ],
  );

  Widget _buildPlayArea() {
    return LayoutBuilder(
      builder: (ctx, box) {
        double cellSize = (box.maxWidth - 40) / gridSize;
        return Center(
          child: Container(
            width: cellSize * gridSize,
            height: cellSize * gridSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                ...candies.map(
                  (c) => AnimatedPositioned(
                    key: ValueKey(c.id),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
                    top: c.row * cellSize,
                    left: c.col * cellSize,
                    child: GestureDetector(
                      onTap: () {
                        if (_activeSkill != null)
                          _useSkill(c.row, c.col, cellSize);
                      },
                      onPanStart: (d) => _dragStartPos = d.globalPosition,
                      onPanUpdate:
                          (d) => _handleSwipe(c, d.globalPosition, cellSize),
                      child: SizedBox(
                        width: cellSize,
                        height: cellSize,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: RiveAnimation.asset(
                            'assets/animations/rives/mood.riv',
                            animations: [_getAnimationName(c.type)],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                ..._floatingCoins.map(
                  (coin) => TweenAnimationBuilder<double>(
                    key: coin.id,
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    builder:
                        (context, value, child) => Positioned(
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
                              ),
                            ),
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _useSkill(int r, int c, double cellSize) async {
    if (_isProcessing ||
        _activeSkill == null ||
        _skillCharges[_activeSkill!]! <= 0 ||
        _hasGameEnded)
      return;
    _isProcessing = true;
    Set<CandyModel> toRemove = {};
    if (_activeSkill == 'hammer') {
      var t = _getCandyAt(r, c);
      if (t != null) toRemove.add(t);
    } else if (_activeSkill == 'bomb') {
      for (int i = r - 1; i <= r + 1; i++) {
        for (int j = c - 1; j <= c + 1; j++) {
          var t = _getCandyAt(i, j);
          if (t != null) toRemove.add(t);
        }
      }
    } else if (_activeSkill == 'rocket') {
      for (int j = 0; j < gridSize; j++) {
        var t = _getCandyAt(r, j);
        if (t != null) toRemove.add(t);
      }
    }

    if (toRemove.isNotEmpty) {
      setState(() {
        _skillCharges[_activeSkill!] = _skillCharges[_activeSkill!]! - 1;
        for (var candy in toRemove) {
          _rewardPlayer(candy, cellSize);
        }
        candies.removeWhere((c) => toRemove.contains(c));
        _activeSkill = null;
      });
      _matchPool.start();
      await Future.delayed(const Duration(milliseconds: 300));
      _fillGaps();
      await _processMatches(cellSize);
      _checkGameStatus();
    }
    _isProcessing = false;
  }

  Widget _buildSkillButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _skillItem('hammer', Icons.build, Colors.blue),
          const SizedBox(width: 10),
          _skillItem('bomb', Icons.wb_iridescent, Colors.orange),
          const SizedBox(width: 10),
          _skillItem('rocket', Icons.straighten, Colors.purple),
        ],
      ),
    );
  }

  Widget _skillItem(String type, IconData icon, Color color) {
    bool isSelected = _activeSkill == type;
    int charges = _skillCharges[type]!;
    bool hasCharges = charges > 0;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (hasCharges && !_isProcessing)
            setState(() => _activeSkill = isSelected ? null : type);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? color.withOpacity(0.4)
                    : (hasCharges ? Colors.white : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: 2.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: hasCharges ? color : Colors.grey, size: 28),
              Text(
                'x$charges',
                style: GoogleFonts.kanit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: hasCharges ? Colors.black87 : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAnimationName(int type) =>
      ['Wow', 'Love', 'Happy', 'Normal', 'Sad', 'Scare', 'Angry'][type - 1];
  Color _getMoodColor(int type) =>
      [
        const Color(0xFFF29C41),
        const Color(0xFFFF9B9B),
        const Color(0xFFFFCC00),
        const Color(0xFF878787),
        const Color(0xFF86AFFC),
        const Color(0xFFCB9DF0),
        const Color(0xFFEB4343),
      ][type - 1];

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

  bool _hasPossibleMoves() {
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (c < gridSize - 1 && _wouldMatchIfSwapped(r, c, r, c + 1))
          return true;
        if (r < gridSize - 1 && _wouldMatchIfSwapped(r, c, r + 1, c))
          return true;
      }
    }
    return false;
  }

  bool _wouldMatchIfSwapped(int r1, int c1, int r2, int c2) {
    var c1Obj = _getCandyAt(r1, c1), c2Obj = _getCandyAt(r2, c2);
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
    if (!silent && mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ทางตัน! สลับตารางใหม่อัตโนมัติ")),
      );
    do {
      for (var candy in candies) {
        candy.type = Random().nextInt(7) + 1;
      }
      _ensureNoInitialMatches();
    } while (!_hasPossibleMoves());
    setState(() {});
  }

  void _showCoinPop(int amount, int type, int row, int col, double cellSize) {
    final id = UniqueKey();
    setState(() {
      _floatingCoins.add(
        FloatingCoin(
          id: id,
          amount: amount,
          x: col * cellSize + (cellSize / 4),
          y: row * cellSize,
          color: _getMoodColor(type),
        ),
      );
    });
    Timer(const Duration(milliseconds: 1000), () {
      if (mounted)
        setState(() => _floatingCoins.removeWhere((coin) => coin.id == id));
    });
  }

  void _showEndDialog(String title, String msg, bool isWin) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, anim1, anim2) => Container(),
      transitionBuilder:
          (ctx, anim1, anim2, child) => Transform.scale(
            scale: anim1.value,
            child: Opacity(
              opacity: anim1.value,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: Colors.transparent,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isWin ? 'ผ่านด่านแล้ว!' : 'พยายามใหม่นะ!',
                            style: GoogleFonts.kanit(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color:
                                  isWin
                                      ? const Color(0xFF78B465)
                                      : Colors.redAccent,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            msg,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.kanit(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'คะแนนด่านนี้',
                                  style: GoogleFonts.kanit(
                                    fontSize: 14,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                                Text(
                                  '$_score',
                                  style: GoogleFonts.kanit(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isWin
                                        ? const Color(0xFF78B465)
                                        : Colors.orangeAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () async {
                                Navigator.pop(ctx);
                                if (isWin) {
                                  int nextLevel = _currentLevel + 1;
                                  await saveLevel(nextLevel);
                                  setState(() {
                                    _currentLevel = nextLevel;
                                  });
                                }
                                _setupLevel(_currentLevel);
                                _initGame();
                                _startCountdown();
                              },
                              child: Text(
                                isWin ? 'ลุยด่านต่อไป!' : 'ลองอีกครั้ง',
                                style: GoogleFonts.kanit(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: -70,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor:
                              isWin
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFFFEBEE),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: RiveAnimation.asset(
                              'assets/animations/rives/mood.riv',
                              animations: [isWin ? 'Happy' : 'Sad'],
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
