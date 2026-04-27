/// Modèle Progress
/// Représente une mise à jour de progrès sur un projet
class Progress {
  final int id;
  final int projectId;
  final int memberId;
  final String? memberName;
  final String? memberPhoto;
  final String updateText;
  final DateTime dateAdded;
  final bool isFinal;
  final String? projectTitle;

  Progress({
    required this.id,
    required this.projectId,
    required this.memberId,
    this.memberName,
    this.memberPhoto,
    required this.updateText,
    required this.dateAdded,
    required this.isFinal,
    this.projectTitle,
  });

  /// Date formatée (ex: "21 Oct 2025")
  String get formattedDate {
    final months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc'
    ];
    return '${dateAdded.day} ${months[dateAdded.month - 1]} ${dateAdded.year}';
  }

  /// Heure formatée (ex: "14:30")
  String get formattedTime {
    return '${dateAdded.hour.toString().padLeft(2, '0')}:${dateAdded.minute.toString().padLeft(2, '0')}';
  }

  /// Date et heure complètes
  String get formattedDateTime => '$formattedDate à $formattedTime';

  /// C'est la mise à jour finale ?
  bool get isLastUpdate => isFinal;

  /// Créer un Progress depuis JSON
  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      id: int.parse(json['id'].toString()),
      projectId: int.parse(json['project_id'].toString()),
      memberId: int.parse(json['member_id'].toString()),
      memberName: json['member_name'],
      memberPhoto: json['member_photo'],
      updateText: json['update_text'] ?? '',
      dateAdded: json['date_added'] != null
          ? DateTime.parse(json['date_added'])
          : DateTime.now(),
      isFinal: json['is_final'] == 1 || json['is_final'] == true,
      projectTitle: json['project_title'],
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'member_id': memberId,
      'member_name': memberName,
      'member_photo': memberPhoto,
      'update_text': updateText,
      'date_added': dateAdded.toIso8601String(),
      'is_final': isFinal ? 1 : 0,
      'project_title': projectTitle,
    };
  }

  /// Copier avec modifications
  Progress copyWith({
    int? id,
    int? projectId,
    int? memberId,
    String? memberName,
    String? memberPhoto,
    String? updateText,
    DateTime? dateAdded,
    bool? isFinal,
    String? projectTitle,
  }) {
    return Progress(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      memberPhoto: memberPhoto ?? this.memberPhoto,
      updateText: updateText ?? this.updateText,
      dateAdded: dateAdded ?? this.dateAdded,
      isFinal: isFinal ?? this.isFinal,
      projectTitle: projectTitle ?? this.projectTitle,
    );
  }
}