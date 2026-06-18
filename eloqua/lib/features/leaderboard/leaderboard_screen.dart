import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/strings.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/session_service.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  static const _mock = [
    _Player(
        rank: 1,
        name: 'Maria Santos',
        score: 94,
        sessions: 18,
        badge: 'Elite Speaker'),
    _Player(
        rank: 2,
        name: 'Carlo Reyes',
        score: 91,
        sessions: 22,
        badge: 'Fluency Pro'),
    _Player(
        rank: 3,
        name: 'Ana Dela Cruz',
        score: 88,
        sessions: 15,
        badge: 'Pacing Master'),
    _Player(
        rank: 4,
        name: 'Miguel Torres',
        score: 85,
        sessions: 11,
        badge: 'Grammar Ace'),
    _Player(
        rank: 5,
        name: 'Sofia Lim',
        score: 82,
        sessions: 9,
        badge: 'Rising Star'),
    _Player(
        rank: 6,
        name: 'Diego Ramos',
        score: 79,
        sessions: 14,
        badge: 'Consistent'),
    _Player(
        rank: 7,
        name: 'Isabella Cruz',
        score: 77,
        sessions: 7,
        badge: 'Improving'),
    _Player(
        rank: 8,
        name: 'Lucas Mendoza',
        score: 74,
        sessions: 10,
        badge: 'Practitioner'),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final session = context.watch<SessionService>();

    // fixed: averageScore (double) rounded, currentUserName, totalSessions
    final myScore =
        session.averageScore > 0 ? session.averageScore.round() : 76;

    final myPlayer = _Player(
      rank: 6,
      name: '${auth.currentUserName} (You)',
      score: myScore,
      sessions: session.totalSessions,
      badge: myScore >= 80 ? 'Rising Star' : 'Practitioner',
      isMe: true,
    );

    final board = [..._mock];
    final insertAt = board.indexWhere((p) => p.score <= myScore);
    if (insertAt >= 0) {
      board.insert(insertAt, myPlayer);
    } else {
      board.add(myPlayer);
    }

    final ranked = board
        .asMap()
        .entries
        .map((e) => _Player(
              rank: e.key + 1,
              name: e.value.name,
              score: e.value.score,
              sessions: e.value.sessions,
              badge: e.value.badge,
              isMe: e.value.isMe,
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.leaderTitle)),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Row(children: [
            const Text(AppStrings.leaderSubtitle,
                style: TextStyle(fontSize: 13, color: Colors.black45)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(children: [
                Icon(Icons.people_outline, size: 13, color: Colors.black45),
                SizedBox(width: 4),
                Text('Classroom',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (ranked.length > 1) _Podium(player: ranked[1], height: 80),
              const SizedBox(width: 8),
              if (ranked.isNotEmpty) _Podium(player: ranked[0], height: 100),
              const SizedBox(width: 8),
              if (ranked.length > 2) _Podium(player: ranked[2], height: 64),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: ranked.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (_, i) => _Row(player: ranked[i]),
          ),
        ),
      ]),
    );
  }
}

class _Player {
  final int rank, score, sessions;
  final String name, badge;
  final bool isMe;
  const _Player({
    required this.rank,
    required this.name,
    required this.score,
    required this.sessions,
    required this.badge,
    this.isMe = false,
  });
}

class _Podium extends StatelessWidget {
  final _Player player;
  final double height;
  const _Podium({required this.player, required this.height});

  @override
  Widget build(BuildContext context) {
    final isFirst = player.rank == 1;
    return Expanded(
      child: Column(children: [
        if (isFirst) const Text('🏆', style: TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        CircleAvatar(
          radius: isFirst ? 26 : 20,
          backgroundColor: player.isMe ? Colors.black : const Color(0xFFEEEEEE),
          child: Text(
            player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: player.isMe ? Colors.white : Colors.black,
              fontSize: isFirst ? 20 : 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          player.name.replaceAll(' (You)', ''),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        Text('${player.score}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: player.rank == 1
                ? Colors.black
                : player.rank == 2
                    ? const Color(0xFF444444)
                    : const Color(0xFF888888),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
          child: Center(
            child: Text('#${player.rank}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
          ),
        ),
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  final _Player player;
  const _Row({required this.player});

  @override
  Widget build(BuildContext context) {
    final isTop3 = player.rank <= 3;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: player.isMe ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: player.isMe ? Colors.black : const Color(0x15000000)),
      ),
      child: Row(children: [
        SizedBox(
          width: 28,
          child: Text('#${player.rank}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: player.isMe
                    ? Colors.white
                    : (isTop3 ? Colors.black : Colors.black45),
              )),
        ),
        CircleAvatar(
          radius: 16,
          backgroundColor: player.isMe ? Colors.white : const Color(0xFFEEEEEE),
          child: Text(player.name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: player.isMe ? Colors.black : Colors.black54,
              )),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(player.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: player.isMe ? Colors.white : Colors.black,
                )),
            Text(player.badge,
                style: TextStyle(
                  fontSize: 11,
                  color: player.isMe ? Colors.white54 : Colors.black38,
                )),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${player.score}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: player.isMe ? Colors.white : Colors.black,
              )),
          Text('${player.sessions} sessions',
              style: TextStyle(
                fontSize: 10,
                color: player.isMe ? Colors.white54 : Colors.black38,
              )),
        ]),
      ]),
    );
  }
}
