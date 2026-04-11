import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'system_prompt.dart';

/// Gemini AI Configuration
///
/// API key được load từ file .env
/// Để setup:
/// 1. Lấy API key: https://aistudio.google.com/app/apikey
/// 2. Tạo file .env (copy từ .env.example)
/// 3. Thêm: GEMINI_API_KEY=your_key_here
class GeminiConfig {
  // Load API key từ .env file
  static String get apiKey =>
      dotenv.get('GEMINI_API_KEY', fallback: 'YOUR_API_KEY_HERE');

  // Model configuration
  static const String modelName = 'gemini-2.5-flash'; // Free tier model

  // Generation config
  static const double temperature = 0.5;
  static const int maxOutputTokens = 512;

  // ─── Safety Settings (STRICT) ───────────────────────────────────
  // Use `low` threshold = block when medium or high probability of unsafe.
  // This is the strictest available threshold in google_generative_ai 0.4.x.
  static final List<SafetySetting> safetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.low),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.low),
    SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.low),
    SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.low),
  ];

  // System prompt — delegates to dynamic template
  static String get systemPrompt =>
      SystemPromptTemplate.build();

  // Check if API key is configured
  static bool get isConfigured =>
      apiKey != 'YOUR_API_KEY_HERE' && apiKey.isNotEmpty;
}
