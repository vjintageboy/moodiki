import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:math';
import 'package:n04_app/services/rag_service.dart';

// ===========================================================================
// Manual Test Examples for RAG & Personalization Context
//
// These are NOT automated unit tests. They are runnable examples that
// demonstrate the RAG system's behavior with real user data.
//
// To run: Copy/paste into a test file or run interactively in the app.
// ===========================================================================

void main() {
  group('RAG Personalization — Manual Test Scenarios', () {
    // -----------------------------------------------------------------------
    // SCENARIO 1: User with stress/anxiety — should find calming meditations
    // -----------------------------------------------------------------------
    testWidgets(
      'User reports stress → RAG finds calming meditation + references mood',
      (WidgetTester tester) async {
        // This test requires:
        // 1. Real GEMINI_API_KEY in .env
        // 2. Supabase connected with meditation data
        // 3. Active Supabase session (user logged in)
        //
        // Expected behavior:
        // - generateEmbedding("Em đang cảm thấy rất lo lắng") → 3072d vector
        // - searchRelevantMeditations → returns stress/anxiety meditations (similarity > 0.7)
        // - buildUserContext → includes user goals, mood history, relevant meditations
        // - toPromptContext() → formatted string with all context sections

        debugPrint('\n=== SCENARIO 1: Stress/Anxiety User ===');
        debugPrint('Input message: "Em đang cảm thấy rất lo lắng"');
        debugPrint('Expected: Find stress/anxiety meditation, reference mood history');

        // In real app, this would be:
        // final rag = RAGService();
        // final context = await rag.buildUserContext(
        //   userId: currentUser.id,
        //   lastMessage: "Em đang cảm thấy rất lo lắng",
        // );
        //
        // debugPrint(context.toPromptContext());
        //
        // Assertions:
        // - context.relevantMeditations.isNotEmpty (or fallback)
        // - context.recentMoodEntries reflects last 7 days
        // - context.goals contains user's actual goals
        // - toPromptContext() contains "USER PROFILE", "MOOD HISTORY", "RELEVANT MEDITATIONS"

        expect(true, isTrue, reason: 'Manual test — verify in app console');
      },
      skip: true, // Requires real API keys and logged-in user
    );

    // -----------------------------------------------------------------------
    // SCENARIO 2: User with sleep issues — should find sleep meditation
    // -----------------------------------------------------------------------
    testWidgets(
      'User reports insomnia → RAG finds sleep meditation',
      (WidgetTester tester) async {
        debugPrint('\n=== SCENARIO 2: Sleep Issues ===');
        debugPrint('Input message: "Dạo này em khó ngủ lắm, mất ngủ mấy hôm nay"');
        debugPrint('Expected: Find sleep/insomnia meditation with high similarity');

        // final rag = RAGService();
        // final embedding = await rag.generateEmbedding(
        //   "Dạo này em khó ngủ lắm, mất ngủ mấy hôm nay",
        // );
        // debugPrint('Embedding dimensions: ${embedding.length}');
        // expect(embedding.length, 3072);
        //
        // final results = await rag.searchRelevantMeditations(embedding);
        // for (final r in results) {
        //   debugPrint('  ${r.title} [${r.category}] similarity: ${r.similarity}');
        // }
        // expect(results.any((r) => r.category?.toLowerCase() == 'sleep'), isTrue);

        expect(true, isTrue, reason: 'Manual test — verify in app console');
      },
      skip: true, // Requires real API keys and logged-in user
    );

    // -----------------------------------------------------------------------
    // SCENARIO 3: Positive user — should get appropriate response
    // -----------------------------------------------------------------------
    testWidgets(
      'User reports happiness → RAG acknowledges positive mood',
      (WidgetTester tester) async {
        debugPrint('\n=== SCENARIO 3: Positive User ===');
        debugPrint('Input message: "Hôm nay em thấy rất vui và tràn đầy năng lượng!"');
        debugPrint('Expected: Mood history shows high scores, context reflects positivity');

        // final rag = RAGService();
        // final context = await rag.buildUserContext(
        //   userId: currentUser.id,
        //   lastMessage: "Hôm nay em thấy rất vui và tràn đầy năng lượng!",
        // );
        //
        // // Check mood history
        // if (context.hasMoodData) {
        //   final avgMood = context.recentMoodEntries
        //       .map((e) => e.moodScore)
        //       .reduce((a, b) => a + b) / context.recentMoodEntries.length;
        //   debugPrint('Average mood: $avgMood/5');
        // }
        //
        // debugPrint(context.toPromptContext());

        expect(true, isTrue, reason: 'Manual test — verify in app console');
      },
      skip: true, // Requires real API keys and logged-in user
    );

    // -----------------------------------------------------------------------
    // SCENARIO 4: New user with no data — graceful fallback
    // -----------------------------------------------------------------------
    testWidgets(
      'New user (no mood, no goals) → graceful fallback context',
      (WidgetTester tester) async {
        debugPrint('\n=== SCENARIO 4: New User (No Data) ===');
        debugPrint('Input message: "Chào bạn, mình mới dùng app này"');
        debugPrint('Expected: Empty context with helpful tips in toPromptContext()');

        // final rag = RAGService();
        // final context = await rag.buildUserContext(
        //   userId: newUserId,
        //   lastMessage: "Chào bạn, mình mới dùng app này",
        // );
        //
        // expect(context.isEmpty, isTrue);
        // expect(context.hasMoodData, isFalse);
        // expect(context.hasMeditationData, isFalse);
        //
        // final promptText = context.toPromptContext();
        // expect(promptText.contains('No mood entries recorded yet'), isTrue);
        // expect(promptText.contains('No highly relevant meditations found'), isTrue);
        // expect(promptText.contains('Tip:'), isTrue);

        expect(true, isTrue, reason: 'Manual test — verify in app console');
      },
      skip: true, // Requires real API keys and logged-in user
    );

    // -----------------------------------------------------------------------
    // SCENARIO 5: Focus/productivity request
    // -----------------------------------------------------------------------
    testWidgets(
      'User wants focus → RAG finds focus/concentration meditation',
      (WidgetTester tester) async {
        debugPrint('\n=== SCENARIO 5: Focus/Productivity ===');
        debugPrint('Input message: "Em cần tập trung để làm bài thi, gợi ý em với"');
        debugPrint('Expected: Find focus/concentration meditation');

        // final rag = RAGService();
        // final embedding = await rag.generateEmbedding(
        //   "Em cần tập trung để làm bài thi, gợi ý em với",
        // );
        // final results = await rag.searchRelevantMeditations(embedding);
        //
        // for (final r in results) {
        //   debugPrint('  ${r.title} [${r.category}] ${r.durationMinutes}min — sim: ${r.similarity}');
        // }

        expect(true, isTrue, reason: 'Manual test — verify in app console');
      },
      skip: true, // Requires real API keys and logged-in user
    );

    // -----------------------------------------------------------------------
    // SCENARIO 6: Context performance — should build in < 200ms
    // -----------------------------------------------------------------------
    testWidgets(
      'Context build time should be fast (< 200ms target)',
      (WidgetTester tester) async {
        debugPrint('\n=== SCENARIO 6: Performance ===');
        debugPrint('Target: Context built in < 200ms');

        // final rag = RAGService();
        // final sw = Stopwatch()..start();
        // final context = await rag.buildUserContext(
        //   userId: currentUser.id,
        //   lastMessage: "Em đang stress",
        // );
        // sw.stop();
        //
        // debugPrint('Context built in ${sw.elapsedMilliseconds}ms');
        // expect(sw.elapsedMilliseconds, lessThan(5000),
        //     reason: 'Should complete within 5 seconds (200ms ideal)');

        expect(true, isTrue, reason: 'Manual test — verify in app console');
      },
      skip: true, // Requires real API keys and logged-in user
    );

    // -----------------------------------------------------------------------
    // SCENARIO 7: Embedding consistency — similar inputs → similar vectors
    // -----------------------------------------------------------------------
    testWidgets(
      'Similar inputs produce similar embeddings (cosine similarity > 0.8)',
      (WidgetTester tester) async {
        debugPrint('\n=== SCENARIO 7: Embedding Consistency ===');

        final rag = RAGService();

        // final text1 = "Em đang cảm thấy lo lắng và căng thẳng";
        // final text2 = "Tôi thấy stress và áp lực lắm";
        //
        // final embedding1 = await rag.generateEmbedding(text1);
        // final embedding2 = await rag.generateEmbedding(text2);
        //
        // expect(embedding1.length, 3072);
        // expect(embedding2.length, 3072);
        //
        // // Calculate cosine similarity
        // double dotProduct = 0, norm1 = 0, norm2 = 0;
        // for (int i = 0; i < 3072; i++) {
        //   dotProduct += embedding1[i] * embedding2[i];
        //   norm1 += embedding1[i] * embedding1[i];
        //   norm2 += embedding2[i] * embedding2[i];
        // }
        // final cosineSim = dotProduct / (sqrt(norm1) * sqrt(norm2));
        // debugPrint('Cosine similarity between similar Vietnamese phrases: $cosineSim');
        // expect(cosineSim, greaterThan(0.8),
        //     reason: 'Semantically similar inputs should have high cosine similarity');

        expect(true, isTrue, reason: 'Manual test — verify in app console');
      },
      skip: true, // Requires real API keys and logged-in user
    );

    // -----------------------------------------------------------------------
    // SCENARIO 8: Seed meditation embeddings (after migration)
    // -----------------------------------------------------------------------
    testWidgets(
      'Seed meditation embeddings for all meditations without embeddings',
      (WidgetTester tester) async {
        debugPrint('\n=== SCENARIO 8: Seed Embeddings ===');

        final rag = RAGService();

        // final count = await rag.seedMeditationEmbeddings();
        // debugPrint('Successfully seeded $count meditation embeddings');
        // expect(count, greaterThan(0),
        //     reason: 'At least some meditations should be seeded');

        expect(true, isTrue, reason: 'Manual test — run seed script instead');
      },
      skip: true, // Requires real API keys — use seed_meditation_embeddings.dart script
    );

    // -----------------------------------------------------------------------
    // SCENARIO 9: Context prompt format verification
    // -----------------------------------------------------------------------
    test('Context prompt format contains all required sections', () {
      final context = UserContext(
        userName: 'Nguyen Van A',
        goals: ['Giảm stress', 'Cải thiện giấc ngủ'],
        recentMoodEntries: [
          MoodEntrySnapshot(
            moodScore: 2,
            note: 'Hôm nay rất mệt',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          MoodEntrySnapshot(
            moodScore: 3,
            note: 'Bình thường',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
        relevantMeditations: [
          MeditationSearchResult(
            id: 'med-1',
            title: 'Thiền buổi sáng',
            description: 'Bài thiền nhẹ nhàng cho buổi sáng tươi mới',
            category: 'stress',
            durationMinutes: 10,
            similarity: 0.85,
          ),
          MeditationSearchResult(
            id: 'med-2',
            title: 'Ngủ ngon',
            description: 'Giúp bạn đi vào giấc ngủ sâu và yên bình',
            category: 'sleep',
            durationMinutes: 20,
            similarity: 0.78,
          ),
        ],
        lastUserMessage: 'Em đang stress lắm',
        hasMoodData: true,
        hasMeditationData: true,
      );

      final promptText = context.toPromptContext();

      debugPrint('\n=== SCENARIO 9: Context Prompt Format ===');
      debugPrint(promptText);

      expect(promptText.contains('=== USER PROFILE ==='), isTrue);
      expect(promptText.contains('Nguyen Van A'), isTrue);
      expect(promptText.contains('Giảm stress'), isTrue);
      expect(promptText.contains('=== MOOD HISTORY (Last 7 days) ==='), isTrue);
      expect(promptText.contains('2/5'), isTrue);
      expect(promptText.contains('Hôm nay rất mệt'), isTrue);
      expect(promptText.contains('Average mood:'), isTrue);
      expect(promptText.contains('=== RELEVANT MEDITATIONS ==='), isTrue);
      expect(promptText.contains('Thiền buổi sáng'), isTrue);
      expect(promptText.contains('[stress]'), isTrue);
      expect(promptText.contains('(10min)'), isTrue);
      expect(promptText.contains('85%'), isTrue);
      expect(promptText.contains('=== END CONTEXT ==='), isTrue);
    });

    // -----------------------------------------------------------------------
    // SCENARIO 10: Empty context format (new user fallback)
    // -----------------------------------------------------------------------
    test('Empty context prompt shows helpful tips for new users', () {
      final context = UserContext(
        lastUserMessage: 'Chào bạn',
      );

      final promptText = context.toPromptContext();

      debugPrint('\n=== SCENARIO 10: Empty Context (New User) ===');
      debugPrint(promptText);

      expect(context.isEmpty, isTrue);
      expect(promptText.contains('Goals: Not set'), isTrue);
      expect(promptText.contains('No mood entries recorded yet'), isTrue);
      expect(promptText.contains('Tip: Encourage the user'), isTrue);
      expect(promptText.contains('No highly relevant meditations found'), isTrue);
      expect(promptText.contains('Tip: Suggest general meditation'), isTrue);
    });
  });
}
