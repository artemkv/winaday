import 'package:shared_preferences/shared_preferences.dart';

const reviewFlowCompletedKey = "REVIEW_COMPLETED";

abstract class LocalData {
  static Future<bool> reviewFlowCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(reviewFlowCompletedKey) ?? false;
  }

  static Future<bool> setReviewFlowCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(reviewFlowCompletedKey, true);
  }

  static Future<bool> resetReviewFlowCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(reviewFlowCompletedKey, false);
  }
}
