import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiCoachService {
  static Future<String> generateCoachingResponse({
    required String userMessage,
    required int streakDays,
    required int focusScore,
    required int focusMinutes,
    required double sleepHours,
    required double waterIntake,
    required int moodRating,
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('gemini_api_key') ?? '';

    if (apiKey.trim().isNotEmpty) {
      try {
        final model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.7,
            maxOutputTokens: 250,
          ),
        );

        final systemInstruction =
            "You are Antigravity, the premium AI Digital Wellbeing & Addiction Recovery Coach inside the 'MindProtection' app. "
            "Your user is '$username'. Today's user metrics are:\n"
            "- Sobriety Streak: $streakDays days\n"
            "- Daily Focus Score: $focusScore/100\n"
            "- Focus Time: $focusMinutes minutes\n"
            "- Sleep Duration: ${sleepHours.toStringAsFixed(1)} hours\n"
            "- Hydration: ${waterIntake.toStringAsFixed(1)}L\n"
            "- Mood Rating: $moodRating/5\n\n"
            "Guidelines:\n"
            "1. Be empathetic, motivational, and concise (keep replies to 2-4 sentences max).\n"
            "2. Avoid generic answers. Use their exact metrics to offer customized, actionable guidance.\n"
            "3. If they mention an urge or relapse, provide a supportive CBT-based de-escalation technique immediately.\n"
            "4. Format your response cleanly using bullet points or bold text in markdown.";

        final content = [
          Content.text("$systemInstruction\n\nUser: $userMessage\nCoach:"),
        ];
        final response = await model.generateContent(content);
        return response.text ?? "I'm here for you. Let's keep standing strong.";
      } catch (e) {
        return "*(AI Connection Notice: Failed to connect to Gemini API. Falling back to local coach engine...)*\n\n${_getLocalResponse(userMessage, streakDays, focusScore, focusMinutes, sleepHours, waterIntake, moodRating, username)}";
      }
    }

    return _getLocalResponse(
      userMessage,
      streakDays,
      focusScore,
      focusMinutes,
      sleepHours,
      waterIntake,
      moodRating,
      username,
    );
  }

  static String _getLocalResponse(
    String msg,
    int streakDays,
    int focusScore,
    int focusMinutes,
    double sleepHours,
    double waterIntake,
    int moodRating,
    String username,
  ) {
    final query = msg.toLowerCase();

    // 1. Urge / Relapse de-escalation
    if (query.contains('urge') ||
        query.contains('relapse') ||
        query.contains('slip') ||
        query.contains('porn') ||
        query.contains('trigger') ||
        query.contains('scroll') ||
        query.contains('crave')) {
      return "Stay calm, **$username**. Urges are like waves: they peak and then dissolve if you don't fight them. "
          "Since you have a **$streakDays-day sobriety streak**, protect it. "
          "Use the **Emergency Shield** (15-minute device lock) if you feel overwhelmed, or try a 3-minute **Box Breathing** session in the Health tab right now. You are stronger than a temporary craving.";
    }

    // 2. Focus & Productivity
    if (query.contains('focus') ||
        query.contains('study') ||
        query.contains('work') ||
        query.contains('productive') ||
        query.contains('distract')) {
      if (focusMinutes < 15) {
        return "It looks like you've logged only **$focusMinutes minutes** of deep focus today, **$username**. "
            "Start with just a single 25-minute Pomodoro session in the Focus tab. "
            "Turn on **Deep Focus Mode** to auto-silence notifications. One step is all it takes.";
      } else {
        return "Excellent work today! You've logged **$focusMinutes focus minutes** with a Focus Score of **$focusScore/100**. "
            "Make sure to take brief breaks to protect your eyes (using our **Eye Care 20-20-20 rule**). What's your next priority task?";
      }
    }

    // 3. Sleep & Energy
    if (query.contains('sleep') ||
        query.contains('tired') ||
        query.contains('fatigue') ||
        query.contains('rest')) {
      if (sleepHours > 0 && sleepHours < 6.5) {
        return "You logged **${sleepHours.toStringAsFixed(1)} hours** of sleep last night. "
            "Sleep deprivation directly impairs prefrontal cortex function, making cravings harder to resist. "
            "Set a routine alarm in your Planner and try charging your phone outside the bedroom tonight.";
      }
      return "Rest is essential for discipline, **$username**. "
          "Aim for 7-9 hours of sleep. Try to wind down 30 minutes before bed by logging off all screens.";
    }

    // 4. Water & Hydration
    if (query.contains('water') ||
        query.contains('drink') ||
        query.contains('hydrate') ||
        query.contains('hydration')) {
      if (waterIntake < 1.0) {
        return "Your hydration is low today at **${waterIntake.toStringAsFixed(1)}L** of your 2.0L goal. "
            "Dehydration reduces cognitive performance and focus capacity. Go drink a full glass of water right now and log it!";
      }
      return "Fantastic job staying hydrated at **${waterIntake.toStringAsFixed(1)}L**! "
          "Keeping your body fueled keeps your focus levels high. Keep it up!";
    }

    // 5. Mood check-in
    if (query.contains('mood') ||
        query.contains('feel') ||
        query.contains('sad') ||
        query.contains('depress') ||
        query.contains('anxious') ||
        query.contains('angry')) {
      final moodText = [
        'low',
        'vulnerable',
        'neutral',
        'steady',
        'excellent',
      ][moodRating - 1];
      return "You reported your mood as **$moodText** ($moodRating/5) today. "
          "Acknowledge how you feel without judgement. If you are anxious or stressed, "
          "take a 5-minute outdoor walk without headphones or complete a breathing ritual. Your mind needs space to recover.";
    }

    // 6. Stats and general overview
    if (query.contains('status') ||
        query.contains('stats') ||
        query.contains('progress') ||
        query.contains('how am i') ||
        query.contains('report')) {
      return "Here is your Guardian Status, **$username**:\n"
          "* **Sobriety Streak:** $streakDays days\n"
          "* **Focus time:** $focusMinutes min ($focusScore Score)\n"
          "* **Sleep:** ${sleepHours.toStringAsFixed(1)} hours\n"
          "* **Hydration:** ${waterIntake.toStringAsFixed(1)}L / 2L\n"
          "Overall, your protection system is active and steady. Keep guarding your mind!";
    }

    // 7. General welcome / fallthrough
    return "Hello, **$username**! I am your AI wellbeing coach. "
        "You can ask me about focus advice, urge de-escalation, hydration metrics, sleep hygiene, or request a full status report of your day. "
        "How can I help you protect your mind right now?";
  }
}
