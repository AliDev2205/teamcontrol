// lib/models/project_phase_model.dart
import 'package:flutter/material.dart';
import '../config/constants.dart';

class ProjectPhase {
  final int phaseId;
  final int projectId;
  final String title;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status; // 'pending', 'in_progress', 'completed'
  final int orderNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectPhase({
    required this.phaseId,
    required this.projectId,
    required this.title,
    this.description,
    this.startDate,
    this.endDate,
    required this.status,
    required this.orderNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectPhase.fromJson(Map<String, dynamic> json) {
  return ProjectPhase(
    phaseId: int.parse(json['phase_id']?.toString() ?? '0'),
    projectId: int.parse(json['project_id']?.toString() ?? '0'),
    title: json['titre'] ?? json['title'] ?? '',
    description: json['description'],
    startDate: json['start_date'] != null 
        ? DateTime.tryParse(json['start_date']) 
        : null,
    endDate: json['end_date'] != null 
        ? DateTime.tryParse(json['end_date']) 
        : null,
    // CORRECTION: Utiliser le statut de l'API
    status: json['status'] ?? 'pending',
    orderNumber: int.parse(json['order_number']?.toString() ?? '0'),
    createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : DateTime.now(),
    updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : DateTime.now(),
  );
}

  String get statusLabel {
    switch (status) {
      case 'completed': return 'Terminée';
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
}