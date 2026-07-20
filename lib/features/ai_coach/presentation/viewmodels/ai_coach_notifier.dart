import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/ai_message_model.dart';
import '../../domain/services/ai_coach_service.dart';
import '../../../focus/presentation/viewmodels/focus_timer_notifier.dart';
import '../../../recovery/presentation/viewmodels/recovery_notifier.dart';
import '../../../wellbeing/presentation/viewmodels/wellbeing_notifier.dart';

class AiCoachState {
  final List<AiMessage> messages;
  final bool isSending;

  const AiCoachState({required this.messages, required this.isSending});

  AiCoachState copyWith({List<AiMessage>? messages, bool? isSending}) {
    return AiCoachState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }
}

class AiCoachNotifier extends StateNotifier<AiCoachState> {
  final Ref _ref;
  static const _storageKey = 'ai_coach_chat_history';

  AiCoachNotifier(this._ref)
    : super(const AiCoachState(messages: [], isSending: false)) {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr != null) {
      try {
        final decoded = json.decode(jsonStr) as List;
        final list = decoded
            .map((e) => AiMessage.fromJson(e as Map<String, dynamic>))
            .toList();
        state = state.copyWith(messages: list);
      } catch (e) {
        _loadDefaultMessage();
      }
    } else {
      _loadDefaultMessage();
    }
  }

  void _loadDefaultMessage() {
    state = state.copyWith(
      messages: [
        AiMessage(
          id: const Uuid().v4(),
          content:
              "Welcome, Guardian. I am Antigravity, your digital wellbeing assistant. "
              "Whether you are working to stay focused, build habits, or overcome a craving, "
              "I am here to guide you. What are you facing today?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  Future<void> _saveMessages(List<AiMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final list = messages.map((m) => m.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(list));
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isSending) return;

    final userMsg = AiMessage(
      id: const Uuid().v4(),
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...state.messages, userMsg];
    state = state.copyWith(messages: updatedMessages, isSending: true);
    await _saveMessages(updatedMessages);

    // 1. Gather all wellbeing / recovery / focus context from providers
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('user_profile_name') ?? 'Cyber Guardian';

    // Sobriety streak
    final streakDays =
        _ref.read(recoveryNotifierProvider).sobriety?.currentStreakDays ?? 0;

    // Focus minutes today
    final sessions = _ref.read(focusSessionListProvider).value ?? [];
    final today = DateTime.now();
    final todaySessions = sessions.where((s) {
      return s.startTime.year == today.year &&
          s.startTime.month == today.month &&
          s.startTime.day == today.day &&
          s.isCompleted;
    }).toList();
    final focusMinutes = todaySessions.fold(
      0,
      (sum, s) => sum + s.durationMinutes,
    );

    // Focus Score calculation logic (matches DashboardView)
    final focusScore = (60 + (todaySessions.length * 10) + (streakDays * 2))
        .clamp(0, 100);

    // Wellbeing metrics
    final wellbeingLog = _ref.read(todayWellbeingLogProvider).value;
    final sleepHours = wellbeingLog?.sleepDurationHours ?? 0.0;
    final waterIntake = wellbeingLog?.waterIntakeLiters ?? 0.0;
    final moodRating = wellbeingLog?.moodRating ?? 3;

    try {
      final reply = await AiCoachService.generateCoachingResponse(
        userMessage: text,
        streakDays: streakDays,
        focusScore: focusScore,
        focusMinutes: focusMinutes,
        sleepHours: sleepHours,
        waterIntake: waterIntake,
        moodRating: moodRating,
        username: username,
      );

      final coachMsg = AiMessage(
        id: const Uuid().v4(),
        content: reply,
        isUser: false,
        timestamp: DateTime.now(),
      );

      final newMessagesList = [...state.messages, coachMsg];
      state = state.copyWith(messages: newMessagesList, isSending: false);
      await _saveMessages(newMessagesList);
    } catch (e) {
      final errorMsg = AiMessage(
        id: const Uuid().v4(),
        content:
            "I ran into a connection glitch. Let's take a deep breath and try again in a moment.",
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isSending: false,
      );
    }
  }

  Future<void> clearHistory() async {
    state = state.copyWith(messages: []);
    _loadDefaultMessage();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

final aiCoachProvider = StateNotifierProvider<AiCoachNotifier, AiCoachState>((
  ref,
) {
  return AiCoachNotifier(ref);
});
