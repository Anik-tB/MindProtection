import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../focus/presentation/viewmodels/focus_timer_notifier.dart';
import '../../../recovery/presentation/viewmodels/recovery_notifier.dart';
import '../../../gamification/presentation/viewmodels/gamification_notifier.dart';

// ──── Models ────

class LeaderboardUser {
  final String userId;
  final String username;
  final String avatarUrl;
  final int streakDays;
  final int focusScore;
  final int level;

  const LeaderboardUser({
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.streakDays,
    required this.focusScore,
    required this.level,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      userId: json['id'] as String? ?? '',
      username: json['username'] as String? ?? 'Cyber Guardian',
      avatarUrl: json['avatar_url'] as String? ?? '🛡️',
      streakDays: (json['streak_days'] as num?)?.toInt() ?? 0,
      focusScore: (json['focus_score'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
    );
  }
}

class ActiveBuddy {
  final String username;
  final String avatar;
  final String status;
  final int streak;
  final int focusMinutes;

  const ActiveBuddy({
    required this.username,
    required this.avatar,
    required this.status,
    required this.streak,
    required this.focusMinutes,
  });
}

class CommunityState {
  final List<LeaderboardUser> leaderboard;
  final List<Map<String, dynamic>> activeRoomUsers;
  final String? activeRoomName;
  final bool isLoading;
  final String? error;

  const CommunityState({
    required this.leaderboard,
    required this.activeRoomUsers,
    this.activeRoomName,
    required this.isLoading,
    this.error,
  });

  CommunityState copyWith({
    List<LeaderboardUser>? leaderboard,
    List<Map<String, dynamic>>? activeRoomUsers,
    String? activeRoomName,
    bool? isLoading,
    String? error,
  }) {
    return CommunityState(
      leaderboard: leaderboard ?? this.leaderboard,
      activeRoomUsers: activeRoomUsers ?? this.activeRoomUsers,
      activeRoomName: activeRoomName,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ──── Database Service Layer ────

class CommunitySupabaseService {
  final SupabaseClient _client;

  CommunitySupabaseService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<void> upsertProfile(Map<String, dynamic> data) async {
    await _client.from('profiles').upsert(data);
  }

  Future<List<Map<String, dynamic>>> fetchLeaderboard() async {
    final res = await _client
        .from('profiles')
        .select()
        .order('streak_days', ascending: false)
        .limit(25);
    return List<Map<String, dynamic>>.from(res as List);
  }

  Future<void> joinRoom(String roomName, int durationMinutes) async {
    final userId = currentUserId;
    if (userId == null) return;

    await _client.from('active_study_sessions').upsert({
      'user_id': userId,
      'room_name': roomName,
      'ends_at': DateTime.now().add(Duration(minutes: durationMinutes)).toIso8601String(),
      'joined_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> leaveRoom() async {
    final userId = currentUserId;
    if (userId == null) return;

    await _client.from('active_study_sessions').delete().eq('user_id', userId);
  }

  Future<List<Map<String, dynamic>>> fetchRoomUsers(String roomName) async {
    final res = await _client
        .from('active_study_sessions')
        .select('joined_at, ends_at, profiles(username, avatar_url, level)')
        .eq('room_name', roomName);
    return List<Map<String, dynamic>>.from(res as List);
  }
}

// Service provider
final communitySupabaseServiceProvider = Provider<CommunitySupabaseService>((ref) {
  return CommunitySupabaseService();
});

// ──── State Notifier ────

class CommunityNotifier extends StateNotifier<CommunityState> {
  final Ref _ref;
  Timer? _roomPollingTimer;

  CommunityNotifier(this._ref)
      : super(const CommunityState(
          leaderboard: [],
          activeRoomUsers: [],
          isLoading: false,
        )) {
    syncMyPublicProfile();
    fetchLeaderboard();
  }

  CommunitySupabaseService get _service => _ref.read(communitySupabaseServiceProvider);

  @override
  void dispose() {
    _roomPollingTimer?.cancel();
    super.dispose();
  }

  // 1. Sync current user's local metrics to public Supabase profiles table
  Future<void> syncMyPublicProfile() async {
    final userId = _service.currentUserId;
    if (userId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('user_profile_name') ?? 'Cyber Guardian';
      final avatar = prefs.getString('user_profile_avatar') ?? '🛡️';

      final streakDays = _ref.read(recoveryNotifierProvider).sobriety?.currentStreakDays ?? 0;
      final level = _ref.read(gamificationProvider).level;

      final sessions = _ref.read(focusSessionListProvider).value ?? [];
      final today = DateTime.now();
      final todaySessions = sessions.where((s) =>
          s.startTime.year == today.year &&
          s.startTime.month == today.month &&
          s.startTime.day == today.day &&
          s.isCompleted).toList();
      final focusScore = (60 + (todaySessions.length * 10) + (streakDays * 2)).clamp(0, 100);

      await _service.upsertProfile({
        'id': userId,
        'username': username,
        'avatar_url': avatar,
        'streak_days': streakDays,
        'focus_score': focusScore,
        'level': level,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Sync public profile failed: $e');
    }
  }

  // 2. Query other users for the leaderboard
  Future<void> fetchLeaderboard() async {
    final userId = _service.currentUserId;
    if (userId == null) return;

    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      await syncMyPublicProfile();
      final listData = await _service.fetchLeaderboard();
      final list = listData.map((e) => LeaderboardUser.fromJson(e)).toList();
      if (!mounted) return;
      state = state.copyWith(leaderboard: list, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 3. Join a virtual study room
  Future<bool> joinStudyRoom(String roomName, int durationMinutes) async {
    final userId = _service.currentUserId;
    if (userId == null) return false;

    try {
      await _service.joinRoom(roomName, durationMinutes);
      if (!mounted) return false;
      state = state.copyWith(activeRoomName: roomName);
      _startRoomUsersPolling(roomName);
      return true;
    } catch (e) {
      debugPrint('Join study room failed: $e');
      return false;
    }
  }

  // 4. Leave study room
  Future<void> leaveStudyRoom() async {
    _roomPollingTimer?.cancel();
    try {
      await _service.leaveRoom();
    } catch (e) {
      debugPrint('Leave study room failed: $e');
    }
    if (!mounted) return;
    state = state.copyWith(activeRoomName: null, activeRoomUsers: []);
  }

  void _startRoomUsersPolling(String roomName) {
    _roomPollingTimer?.cancel();
    _fetchRoomUsers(roomName);

    // Poll every 8 seconds for active users in the room
    _roomPollingTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _fetchRoomUsers(roomName);
    });
  }

  Future<void> _fetchRoomUsers(String roomName) async {
    try {
      final res = await _service.fetchRoomUsers(roomName);
      final List<Map<String, dynamic>> users = [];
      for (final row in res) {
        final profile = row['profiles'] as Map<String, dynamic>?;
        if (profile != null) {
          users.add({
            'username': profile['username'] ?? 'Cyber Guardian',
            'avatar_url': profile['avatar_url'] ?? '🛡️',
            'level': profile['level'] ?? 1,
            'joined_at': row['joined_at'],
            'ends_at': row['ends_at'],
          });
        }
      }
      if (!mounted) return;
      state = state.copyWith(activeRoomUsers: users);
    } catch (e) {
      debugPrint('Fetch room users failed: $e');
    }
  }

  // 5. Send check-in accountability nudge
  Future<bool> sendNudge(String targetUsername) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      return true;
    } catch (e) {
      return false;
    }
  }
}

final communityProvider =
    StateNotifierProvider<CommunityNotifier, CommunityState>((ref) {
  return CommunityNotifier(ref);
});

// Buddy list provider
final accountabilityBuddiesProvider = Provider<List<ActiveBuddy>>((ref) {
  return const [
    ActiveBuddy(
      username: 'Alex Vanguard',
      avatar: '⚔️',
      status: 'Studying',
      streak: 12,
      focusMinutes: 120,
    ),
    ActiveBuddy(
      username: 'Serena Shield',
      avatar: '🌌',
      status: 'Resting',
      streak: 28,
      focusMinutes: 45,
    ),
    ActiveBuddy(
      username: 'Leo Paladin',
      avatar: '⚡',
      status: 'Active Focus',
      streak: 5,
      focusMinutes: 25,
    ),
  ];
});
