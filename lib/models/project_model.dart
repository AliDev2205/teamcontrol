import 'package:flutter/material.dart';
import '../config/constants.dart';
import 'project_member_model.dart';
import 'project_phase_model.dart';

class Project {
  final int id;
  final String title;
  final String? description;
  final int createdBy; // Nouveau: admin qui a créé le projet
  final String status; // 'pending', 'in_progress', 'completed'
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Champs calculés/relations
  final List<ProjectMember>? assignedMembers; // Nouveau: liste des membres assignés
  final List<ProjectPhase>? phases; // Nouveau: phases du projet
  final String? createdByName; // Nom de l'admin créateur

  Project({
    required this.id,
    required this.title,
    this.description,
    required this.createdBy,
    required this.status,
    this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
    this.assignedMembers,
    this.phases,
    this.createdByName,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: int.parse(json['project_id']?.toString() ?? json['id']?.toString() ?? '0'),
      title: json['title'] ?? '',
      description: json['description'],
      createdBy: int.parse(json['created_by']?.toString() ?? '0'),
      status: json['status'] ?? 'pending',
      startDate: json['start_date'] != null 
          ? DateTime.tryParse(json['start_date']) 
          : null,
      endDate: json['end_date'] != null 
          ? DateTime.tryParse(json['end_date']) 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
      createdByName: json['created_by_name'],
    );
  }

  String get statusLabel {
    switch (status) {
      case 'completed': return 'Terminé';
      case 'in_progress': return 'En cours';
      case 'pending': return 'En attente';
      default: return 'Inconnu';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'completed': return AppConstants.successColor;
      case 'in_progress': return AppConstants.primaryColor;
      case 'pending': return Colors.orange;
      default: return Colors.grey;
    }
  }

  bool get isCompleted => status == 'completed';
  bool get isInProgress => status == 'in_progress';
  bool get isPending => status == 'pending';

  // Nouveau: Projet a-t-il des membres assignés ?
  bool get hasAssignedMembers => assignedMembers != null && assignedMembers!.isNotEmpty;

  // Nouveau: Pourcentage d'avancement basé sur les phases
  double get progressPercentage {
    if (phases == null || phases!.isEmpty) return 0.0;
    
    final completedPhases = phases!.where((phase) => phase.isCompleted).length;
    return (completedPhases / phases!.length) * 100;
  }
}