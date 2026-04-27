// lib/models/dashboard_stats_model.dart
class DashboardStats {
  final int totalMembers;
  final int totalProjects;
  final int pendingProjects;
  final int inProgressProjects;
  final int completedProjects;
  final int unassignedProjects;
  final double overallProgress;
  final List<ActivityLog> recentActivities;

  DashboardStats({
    required this.totalMembers,
    required this.totalProjects,
    required this.pendingProjects,
    required this.inProgressProjects,
    required this.completedProjects,
    required this.unassignedProjects,
    required this.overallProgress,
    required this.recentActivities,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalMembers: json['total_members'] ?? 0,
      totalProjects: json['total_projects'] ?? 0,
      pendingProjects: json['pending_projects'] ?? 0,
      inProgressProjects: json['in_progress_projects'] ?? 0,
      completedProjects: json['completed_projects'] ?? 0,
      unassignedProjects: json['unassigned_projects'] ?? 0,
      overallProgress: (json['overall_progress'] ?? 0).toDouble(),
      recentActivities: (json['recent_activities'] as List? ?? [])
          .map((activity) => ActivityLog.fromJson(activity))
          .toList(),
    );
  }
}

class ActivityLog {
  final int logId;
  final int userId;
  final String userType;
  final String action;
  final String? description;
  final String userName;
  final DateTime createdAt;

  ActivityLog({
    required this.logId,
    required this.userId,
    required this.userType,
    required this.action,
    this.description,
    required this.userName,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      logId: int.parse(json['log_id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      userType: json['user_type'] ?? 'member',
      action: json['action'] ?? '',
      description: json['description'],
      userName: json['user_name'] ?? 'Utilisateur',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) return 'À l\'instant';
    if (difference.inHours < 1) return 'Il y a ${difference.inMinutes} min';
    if (difference.inDays < 1) return 'Il y a ${difference.inHours} h';
    return 'Il y a ${difference.inDays} j';
  }
}