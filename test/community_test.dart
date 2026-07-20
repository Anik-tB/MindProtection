import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mind_protection/features/community/presentation/viewmodels/community_provider.dart';

// ──── Mock Service Implementation ────

class MockCommunitySupabaseService extends Fake
    implements CommunitySupabaseService {
  final List<Map<String, dynamic>> mockProfilesList;
  bool joinRoomCalled = false;
  bool leaveRoomCalled = false;

  MockCommunitySupabaseService({required this.mockProfilesList});

  @override
  String get currentUserId => 'test-user-uuid';

  @override
  Future<void> upsertProfile(Map<String, dynamic> data) async {
    // Mock write
  }

  @override
  Future<List<Map<String, dynamic>>> fetchLeaderboard() async {
    return mockProfilesList;
  }

  @override
  Future<void> joinRoom(String roomName, int durationMinutes) async {
    joinRoomCalled = true;
  }

  @override
  Future<void> leaveRoom() async {
    leaveRoomCalled = true;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRoomUsers(String roomName) async {
    return [
      {
        'joined_at': '2026-07-20T10:00:00Z',
        'ends_at': '2026-07-20T10:45:00Z',
        'profiles': {
          'username': 'Alpha Guardian',
          'avatar_url': '🛡️',
          'level': 4,
        },
      },
    ];
  }
}

// ──── Test Cases ────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Community & Leaderboard Unit Tests', () {
    late ProviderContainer container;
    late MockCommunitySupabaseService mockService;

    final mockProfilesList = [
      {
        'id': 'user-1',
        'username': 'Alpha Guardian',
        'avatar_url': '🛡️',
        'streak_days': 15,
        'focus_score': 85,
        'level': 4,
      },
      {
        'id': 'user-2',
        'username': 'Omega Vanguard',
        'avatar_url': '⚔️',
        'streak_days': 8,
        'focus_score': 70,
        'level': 2,
      },
    ];

    setUp(() {
      SharedPreferences.setMockInitialValues({
        'user_profile_name': 'Test Guardian',
        'user_profile_avatar': '⚡',
      });

      mockService = MockCommunitySupabaseService(
        mockProfilesList: mockProfilesList,
      );

      container = ProviderContainer(
        overrides: [
          communitySupabaseServiceProvider.overrideWithValue(mockService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('LeaderboardUser parsing from JSON is correct', () {
      final json = {
        'id': 'test-id',
        'username': 'Cyber Sentinel',
        'avatar_url': '🌌',
        'streak_days': 10,
        'focus_score': 90,
        'level': 5,
      };

      final user = LeaderboardUser.fromJson(json);
      expect(user.userId, equals('test-id'));
      expect(user.username, equals('Cyber Sentinel'));
      expect(user.avatarUrl, equals('🌌'));
      expect(user.streakDays, equals(10));
      expect(user.focusScore, equals(90));
      expect(user.level, equals(5));
    });

    test('Initial notifier state handles default fields', () {
      final notifier = container.read(communityProvider.notifier);
      expect(notifier.state.leaderboard, isEmpty);
      expect(notifier.state.activeRoomName, isNull);
      expect(notifier.state.activeRoomUsers, isEmpty);
    });

    test('fetchLeaderboard successfully pulls and ranks profiles', () async {
      final notifier = container.read(communityProvider.notifier);
      await notifier.fetchLeaderboard();

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.leaderboard, isNotEmpty);
      expect(notifier.state.leaderboard.length, equals(2));
      expect(notifier.state.leaderboard[0].username, equals('Alpha Guardian'));
      expect(notifier.state.leaderboard[0].streakDays, equals(15));
      expect(notifier.state.leaderboard[1].username, equals('Omega Vanguard'));
    });

    test(
      'joinStudyRoom and leaveStudyRoom transitions rooms active state',
      () async {
        final notifier = container.read(communityProvider.notifier);
        expect(notifier.state.activeRoomName, isNull);

        final joined = await notifier.joinStudyRoom('Zen Oasis 🧘', 45);
        expect(joined, isTrue);
        expect(notifier.state.activeRoomName, equals('Zen Oasis 🧘'));
        expect(mockService.joinRoomCalled, isTrue);

        await notifier.leaveStudyRoom();
        expect(notifier.state.activeRoomName, isNull);
        expect(mockService.leaveRoomCalled, isTrue);
      },
    );
  });
}
