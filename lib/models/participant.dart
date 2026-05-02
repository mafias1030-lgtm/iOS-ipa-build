class Participant {
  final String id;
  final String name;
  final bool isActive;
  final String? photoPath;
  final bool isCreator;

  const Participant({
    required this.id,
    required this.name,
    this.isActive = false,
    this.photoPath,
    this.isCreator = false,
  });

  Participant copyWith({
    bool? isActive,
    String? name,
    String? photoPath,
  }) {
    return Participant(
      id: id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      photoPath: photoPath ?? this.photoPath,
      isCreator: isCreator,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isActive': isActive,
        'photoPath': photoPath,
        'isCreator': isCreator,
      };

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        id: json['id'] as String,
        name: json['name'] as String,
        isActive: json['isActive'] as bool? ?? false,
        photoPath: json['photoPath'] as String?,
        isCreator: json['isCreator'] as bool? ?? false,
      );
}
