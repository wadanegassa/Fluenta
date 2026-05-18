import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineCacheService {
  static const String _lessonCachePrefix = "lesson_cache_";

  Future<void> cacheLesson(String lessonId, Map<String, dynamic> lessonData, Map<String, dynamic> generatedJson) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> cacheMap = {
        'lessonData': lessonData,
        'generatedJson': generatedJson,
        'cachedAt': DateTime.now().toIso8601String(),
      };
      await prefs.setString('$_lessonCachePrefix$lessonId', jsonEncode(cacheMap));
    } catch (e) {
      print('DEBUG: Offline cache write failure: $e');
    }
  }

  Future<Map<String, dynamic>?> getCachedLesson(String lessonId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('$_lessonCachePrefix$lessonId');
      if (jsonStr == null) return null;
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      print('DEBUG: Offline cache read failure: $e');
      return null;
    }
  }
}
