import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity.dart';
import '../models/user_profile.dart';

class StorageService {
  static const String _activitiesKey = 'activities_v1';
  static const String _profileKey = 'user_profile_v1';
  static const String _darkModeKey = 'dark_mode';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  List<Activity> loadActivities() {
    final data = _prefs.getString(_activitiesKey);
    if (data == null) return [];
    try {
      final list = jsonDecode(data) as List<dynamic>;
      return list
          .map((json) => Activity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveActivities(List<Activity> activities) async {
    final data = jsonEncode(activities.map((a) => a.toJson()).toList());
    await _prefs.setString(_activitiesKey, data);
  }

  UserProfile? loadProfile() {
    final data = _prefs.getString(_profileKey);
    if (data == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  bool loadDarkMode() => _prefs.getBool(_darkModeKey) ?? false;

  Future<void> saveDarkMode(bool value) async {
    await _prefs.setBool(_darkModeKey, value);
  }
}
