
class ProjectMember {
  final int assignmentId;
  final int projectId;
  final int memberId;
  final int assignedBy;
  final DateTime assignedDate;
  final bool isActive;
  final String? memberName;
  final String? memberEmail;
  final String? memberPhoto;

  ProjectMember({
    required this.assignmentId,
    required this.projectId,
    required this.memberId,
    required this.assignedBy,
    required this.assignedDate,
    required this.isActive,
    this.memberName,
    this.memberEmail,
    this.memberPhoto,
  });

  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    return ProjectMember(
      assignmentId: int.parse(json['assignment_id'].toString()),
      projectId: int.parse(json['project_id'].toString()),
      memberId: int.parse(json['member_id'].toString()),
      assignedBy: int.parse(json['assigned_by'].toString()),
      assignedDate: DateTime.parse(json['assigned_date']),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      memberName: json['member_name'],
      memberEmail: json['member_email'],
      memberPhoto: json['member_photo'],
    );
  }

  String get formattedAssignedDate {
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${assignedDate.day} ${months[assignedDate.month - 1]} ${assignedDate.year}';
  }
}