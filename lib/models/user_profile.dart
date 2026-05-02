import 'package:uuid/uuid.dart';

class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String? photoPath;

  const UserProfile({
    required this.id,
    this.firstName = '',
    this.lastName = '',
    this.photoPath,
  });

  factory UserProfile.initial() => UserProfile(id: const Uuid().v4());

  String get displayName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? 'Moi' : name;
  }

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    if (f.isEmpty && l.isEmpty) return '?';
    return '$f$l';
  }

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? photoPath,
    bool clearPhoto = false,
  }) {
    return UserProfile(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'photoPath': photoPath,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        photoPath: json['photoPath'] as String?,
      );
}
