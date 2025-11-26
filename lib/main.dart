import 'package:flutter/material.dart';

void main() => runApp(const BrainTongTongApp());

class BrainTongTongApp extends StatelessWidget {
  const BrainTongTongApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '뇌통통',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFDFAFF),
        cardTheme: const CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  double brainHealth = 100.0;
  String brainState = 'healthy';
  int todaySteps = 2500;
  int waterGlasses = 0;
  bool stepMissionDone = false;
  bool waterMissionDone = false;

  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  final Map<String, int> appUsage = {
    'Instagram': 30,
    'YouTube': 45,
    'Netflix': 20,
    'TikTok': 35,
  };

  final Map<String, double> badWeight = {
    'Instagram': 1.8,
    'YouTube': 1.5,
    'Netflix': 2.0,
    'TikTok': 2.2,
  };

  final Map<String, Color> appColors = {
    'Instagram': Color(0xFFE4405F),
    'YouTube': Color(0xFFFF0000),
    'Netflix': Color(0xFFE50914),
    'TikTok': Color(0xFF000000),
  };

  @override
  void initState() {
    super.initState();
    _calculateHealth();
    _simulateTimePassing();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  void _simulateTimePassing() {
    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted || (stepMissionDone && waterMissionDone)) return;
      setState(() {
        brainHealth = (brainHealth - 3.0).clamp(0.0, 100.0);
        _updateBrainState();
      });
      _simulateTimePassing();
    });
  }

  void _calculateHealth() {
    double penalty = 0.0;
    appUsage.forEach((app, minutes) {
      double weight = badWeight[app] ?? 1.0;
      penalty += minutes * weight * 0.5;
    });
    brainHealth = (100 - penalty).clamp(0.0, 100.0);
    _updateBrainState();
  }

  void _updateBrainState() {
    if (brainHealth > 80) {
      brainState = 'healthy';
    } else if (brainHealth > 60) {
      brainState = 'tired';
    } else if (brainHealth > 40) {
      brainState = 'wrinkled';
    } else if (brainHealth > 20) {
      brainState = 'very_wrinkled';
    } else {
      brainState = 'zombie';
    }
  }

  void _completeStepMission() {
    setState(() {
      stepMissionDone = true;
      brainHealth = (brainHealth + 50).clamp(0.0, 100.0);
      _updateBrainState();
    });
    _showSuccessSnackBar('걷기 미션 완료! 🎉 뇌 +50%');
  }

  void _drinkWater() {
    setState(() {
      waterGlasses++;
      brainHealth = (brainHealth + 10).clamp(0.0, 100.0);
      if (waterGlasses >= 5) {
        waterMissionDone = true;
        _showSuccessSnackBar('수분 미션 완료! 💧 뇌 +50%');
      } else {
        _showInfoSnackBar('물 한 잔! 뇌 +10% (${5 - waterGlasses}잔 남음)');
      }
      _updateBrainState();
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFB5EAD7),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF88BDBC),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  List<MapEntry<String, int>> getTopApps() {
    var entries = appUsage.entries.toList();
    entries.sort((a, b) {
      double scoreA = a.value * (badWeight[a.key] ?? 1);
      double scoreB = b.value * (badWeight[b.key] ?? 1);
      return scoreB.compareTo(scoreA);
    });
    return entries;
  }

  Color _getBrainColor() {
    switch (brainState) {
      case 'healthy':
        return const Color(0xFFB5EAD7);
      case 'tired':
        return const Color(0xFFFFD1DC);
      case 'wrinkled':
        return const Color(0xFFFFB6C1);
      case 'very_wrinkled':
        return const Color(0xFFE8DAEF);
      default:
        return const Color(0xFF9B9B9B);
    }
  }

  IconData _getBrainIcon() {
    switch (brainState) {
      case 'healthy':
        return Icons.favorite;
      case 'tired':
        return Icons.sentiment_neutral;
      case 'wrinkled':
        return Icons.sentiment_dissatisfied;
      case 'very_wrinkled':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sick;
    }
  }

  String _getBrainMessage() {
    switch (brainState) {
      case 'healthy':
        return '통통! 완벽해요!';
      case 'tired':
        return '피곤해요...';
      case 'wrinkled':
        return '쭈글쭈글...';
      case 'very_wrinkled':
        return '도와주세요!';
      default:
        return '좀비 뇌...';
    }
  }

  Widget _buildBrainCharacter() {
    return AnimatedBuilder(
      animation: _pulseAnimation ?? const AlwaysStoppedAnimation(1.0),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation?.value ?? 1.0,
          child: Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _getBrainColor(),
                  _getBrainColor(),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _getBrainColor(),
                  blurRadius: 30,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getBrainIcon(),
                    size: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getBrainMessage(),
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppCard(MapEntry<String, int> entry) {
    double damageScore = entry.value * (badWeight[entry.key] ?? 1);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        color: const Color(0xFFE8DAEF),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: appColors[entry.key] ?? Colors.grey,
            child: Text(
              entry.key[0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            entry.key,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '가중치: ${badWeight[entry.key]}x',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.value}분',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '피해 ${damageScore.toStringAsFixed(1)}',
                style: TextStyle(fontSize: 11, color: Colors.red[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // 타이틀
              const Text(
                '뇌통통',
                style: TextStyle(
                  fontSize: 48,
                  color: Color(0xFF88BDBC),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              
              const SizedBox(height: 10),
              Text(
                '스마트폰 디톡스 도우미',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              
              const SizedBox(height: 30),

              // 뇌 캐릭터
              _buildBrainCharacter(),

              const SizedBox(height: 30),
              
              // 뇌 건강 수치
              Text(
                '오늘 뇌 건강',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${brainHealth.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 48,
                  color: Color(0xFF6B5B95),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              
              // 프로그레스바
              Container(
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: brainHealth / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          _getBrainColor(),
                          _getBrainColor().withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 뇌 쭈글 Top 4 앱
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange[700],
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '뇌 쭈글 Top 4 앱',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF88BDBC),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...getTopApps().take(4).map(_buildAppCard),

              const SizedBox(height: 40),
              
              // 회복 미션 섹션
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.amber[700], size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    '뇌 회복 미션',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF88BDBC),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              // 걷기 미션
              Card(
                color: stepMissionDone
                    ? const Color(0xFFB5EAD7)
                    : const Color(0xFFFFD1DC),
                child: ListTile(
                  leading: Icon(
                    stepMissionDone ? Icons.check_circle : Icons.directions_walk,
                    color: Colors.white,
                    size: 40,
                  ),
                  title: Text(
                    stepMissionDone ? '걷기 미션 완료! 🎉' : '4,000보 걷기',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    '$todaySteps / 4,000 보',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  trailing: stepMissionDone
                      ? null
                      : ElevatedButton(
                          onPressed: _completeStepMission,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFFFD1DC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            '완료',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 10),
              
              // 물 마시기 미션
              Card(
                color: waterMissionDone
                    ? const Color(0xFFB5EAD7)
                    : const Color(0xFF88BDBC),
                child: ListTile(
                  leading: Icon(
                    waterMissionDone ? Icons.check_circle : Icons.local_drink,
                    color: Colors.white,
                    size: 40,
                  ),
                  title: Text(
                    waterMissionDone ? '수분 미션 완료! 💧' : '물 5잔 마시기',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    '$waterGlasses / 5 잔',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  trailing: waterMissionDone
                      ? null
                      : ElevatedButton(
                          onPressed: _drinkWater,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF88BDBC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            '+1잔',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 40),
              
              // 오늘의 팁
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD1DC)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.amber[700], size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '💡 Tip: 스마트폰을 20분 사용했다면\n20초 동안 6미터 이상 먼 곳을 보세요!',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
