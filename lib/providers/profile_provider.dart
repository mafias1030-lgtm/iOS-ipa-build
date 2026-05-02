import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class ProfileProvider extends ChangeNotifier {
  final StorageService _storage;

  late UserProfile _profile;
  late bool _isDarkMode;

  ProfileProvider(this._storage) {
    _profile = _storage.loadProfile() ?? UserProfile.initial();
    _isDarkMode = _storage.loadDarkMode();
  }

  UserProfile get profile => _profile;
  bool get isDarkMode => _isDarkMode;

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? photoPath,
    bool clearPhoto = false,
  }) async {
    _profile = _profile.copyWith(
      firstName: firstName,
      lastName: lastName,
      photoPath: photoPath,
      clearPhoto: clearPhoto,
    );
    await _storage.saveProfile(_profile);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _storage.saveDarkMode(_isDarkMode);
    notifyListeners();
  }
}
