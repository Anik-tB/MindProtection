import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mind_protection/features/ai_coach/domain/services/ai_coach_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AI Coach Service local rule-based response tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Correctly responds to urge query and prompts emergency de-escalation', () async {
      final response = await AiCoachService.generateCoachingResponse(
        userMessage: 'I am having a strong urge to scroll social media',
        streakDays: 5,
        focusScore: 70,
        focusMinutes: 45,
        sleepHours: 7.5,
        waterIntake: 2.0,
        moodRating: 3,
        username: 'Test Guardian',
      );

      expect(response, contains('5-day sobriety streak'));
      expect(response, contains('Emergency Shield'));
      expect(response, contains('Box Breathing'));
    });

    test('Correctly responds to low focus time and suggests Pomodoro', () async {
      final response = await AiCoachService.generateCoachingResponse(
        userMessage: 'Can you check my study status?',
        streakDays: 2,
        focusScore: 60,
        focusMinutes: 10, // low focus minutes
        sleepHours: 8.0,
        waterIntake: 2.0,
        moodRating: 4,
        username: 'Test Guardian',
      );

      expect(response, contains('10 minutes'));
      expect(response, contains('Pomodoro'));
      expect(response, contains('Deep Focus Mode'));
    });

    test('Correctly alerts user on low sleep duration', () async {
      final response = await AiCoachService.generateCoachingResponse(
        userMessage: 'I feel extremely tired today',
        streakDays: 4,
        focusScore: 65,
        focusMinutes: 20,
        sleepHours: 5.0, // sleep is under 6.5 hours
        waterIntake: 1.5,
        moodRating: 2,
        username: 'Test Guardian',
      );

      expect(response, contains('5.0 hours'));
      expect(response, contains('Sleep deprivation'));
      expect(response, contains('outside the bedroom'));
    });

    test('Correctly prompts user to hydrate on low water logs', () async {
      final response = await AiCoachService.generateCoachingResponse(
        userMessage: 'How is my water intake looking?',
        streakDays: 3,
        focusScore: 70,
        focusMinutes: 30,
        sleepHours: 8.0,
        waterIntake: 0.5, // low water intake
        moodRating: 3,
        username: 'Test Guardian',
      );

      expect(response, contains('0.5L'));
      expect(response, contains('Dehydration reduces cognitive performance'));
      expect(response, contains('drink a full glass'));
    });
  });
}
