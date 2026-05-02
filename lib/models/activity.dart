import 'package:uuid/uuid.dart';
import 'participant.dart';

enum ActivityType {
  foot,
  tennis,
  autre;

  String get label {
    switch (this) {
      case ActivityType.foot:
        return 'Football';
      case ActivityType.tennis:
        return 'Tennis';
      case ActivityType.autre:
        return 'Autre';
    }
  }
}

class Activity {
  final String id;
  final String name;
  final String location;
  final DateTime dateTime;
  final int maxParticipants;
  final ActivityType type;
  final List<Participant> participants;
  final String creatorId;
  final DateTime createdAt;

  const Activity({
    required this.id,
    required this.name,
    required this.location,
    required this.dateTime,
    required this.maxParticipants,
    required this.type,
    required this.participants,
    required this.creatorId,
    required this.createdAt,
  });

  factory Activity.create({
    required String name,
    required String location,
    required DateTime dateTime,
    required int maxParticipants,
    required ActivityType type,
    required String creatorId,
    required String creatorName,
    String? creatorPhotoPath,
  }) {
    final creator = Participant(
      id: creatorId,
      name: creatorName,
      isActive: true,
      photoPath: creatorPhotoPath,
      isCreator: true,
    );
    return Activity(
      id: const Uuid().v4(),
      name: name,
      location: location,
      dateTime: dateTime,
      maxParticipants: maxParticipants,
      type: type,
      participants: [creator],
      creatorId: creatorId,
      createdAt: DateTime.now(),
    );
  }

  int get activeCount => participants.where((p) => p.isActive).length;

  bool isUserActive(String userId) {
    final p = participants.where((p) => p.id == userId).firstOrNull;
    return p?.isActive ?? false;
  }

  bool hasUser(String userId) => participants.any((p) => p.id == userId);

  Activity copyWith({
    String? name,
    String? location,
    DateTime? dateTime,
    int? maxParticipants,
    ActivityType? type,
    List<Participant>? participants,
  }) {
    return Activity(
      id: id,
      name: name ?? this.name,
      location: location ?? this.location,
      dateTime: dateTime ?? this.dateTime,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      type: type ?? this.type,
      participants: participants ?? this.participants,
      creatorId: creatorId,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'dateTime': dateTime.toIso8601String(),
        'maxParticipants': maxParticipants,
        'type': type.name,
        'participants': participants.map((p) => p.toJson()).toList(),
        'creatorId': creatorId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json['id'] as String,
        name: json['name'] as String,
        location: json['location'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        maxParticipants: json['maxParticipants'] as int,
        type: ActivityType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => ActivityType.autre,
        ),
        participants: (json['participants'] as List<dynamic>)
            .map((p) => Participant.fromJson(p as Map<String, dynamic>))
            .toList(),
        creatorId: json['creatorId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
