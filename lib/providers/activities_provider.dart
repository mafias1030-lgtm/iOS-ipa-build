import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../models/participant.dart';
import '../services/storage_service.dart';

class ActivitiesProvider extends ChangeNotifier {
  final StorageService _storage;
  late List<Activity> _activities;

  ActivitiesProvider(this._storage) {
    _activities = _storage.loadActivities();
  }

  List<Activity> get activities {
    final list = List<Activity>.from(_activities);
    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  Activity? getById(String id) =>
      _activities.where((a) => a.id == id).firstOrNull;

  Future<void> addActivity(Activity activity) async {
    _activities.add(activity);
    await _save();
    notifyListeners();
  }

  Future<void> deleteActivity(String id) async {
    _activities.removeWhere((a) => a.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> toggleParticipantStatus(
      String activityId, String participantId) async {
    final index = _activities.indexWhere((a) => a.id == activityId);
    if (index == -1) return;

    final activity = _activities[index];
    final participants = activity.participants.map((p) {
      if (p.id == participantId) return p.copyWith(isActive: !p.isActive);
      return p;
    }).toList();

    _activities[index] = activity.copyWith(participants: participants);
    await _save();
    notifyListeners();
  }

  Future<bool> addParticipant(
      String activityId, Participant participant) async {
    final index = _activities.indexWhere((a) => a.id == activityId);
    if (index == -1) return false;

    final activity = _activities[index];
    if (activity.participants.length >= activity.maxParticipants) return false;

    final participants = [...activity.participants, participant];
    _activities[index] = activity.copyWith(participants: participants);
    await _save();
    notifyListeners();
    return true;
  }

  Future<void> removeParticipant(
      String activityId, String participantId) async {
    final index = _activities.indexWhere((a) => a.id == activityId);
    if (index == -1) return;

    final activity = _activities[index];
    // Cannot remove creator
    final target =
        activity.participants.where((p) => p.id == participantId).firstOrNull;
    if (target?.isCreator == true) return;

    final participants =
        activity.participants.where((p) => p.id != participantId).toList();
    _activities[index] = activity.copyWith(participants: participants);
    await _save();
    notifyListeners();
  }

  Future<void> _save() => _storage.saveActivities(_activities);
}
