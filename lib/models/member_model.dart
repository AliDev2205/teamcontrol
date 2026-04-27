/// Modèle Member
/// Représente un membre de l'équipe Team Control
class Member {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? position;
  final String? department;
  final String employeeId;
  final String? photo;
  final DateTime? dateJoined;
  final String role; // 'admin' ou 'member'
  final String status; // 'active' ou 'inactive'

  Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.position,
    this.department,
    required this.employeeId,
    this.photo,
    this.dateJoined,
    required this.role,
    required this.status,
  });

  /// Nom complet
  String get fullName => '$firstName $lastName';

  /// Est admin ?
  bool get isAdmin => role == 'admin';

  /// Est actif ?
  bool get isActive => status == 'active';

  /// Créer un Member depuis JSON
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: int.parse(json['id'].toString()),
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      position: json['position'],
      department: json['department'],
      employeeId: json['employee_id'] ?? '',
      photo: json['photo'],
      dateJoined: json['date_joined'] != null
          ? DateTime.tryParse(json['date_joined'])
          : null,
      role: json['role'] ?? 'member',
      status: json['status'] ?? 'active',
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'position': position,
      'department': department,
      'employee_id': employeeId,
      'photo': photo,
      'date_joined': dateJoined?.toIso8601String(),
      'role': role,
      'status': status,
    };
  }

  /// Copier avec modifications
  Member copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? position,
    String? department,
    String? employeeId,
    String? photo,
    DateTime? dateJoined,
    String? role,
    String? status,
  }) {
    return Member(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      position: position ?? this.position,
      department: department ?? this.department,
      employeeId: employeeId ?? this.employeeId,
      photo: photo ?? this.photo,
      dateJoined: dateJoined ?? this.dateJoined,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }
}