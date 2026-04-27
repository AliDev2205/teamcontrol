import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../models/project_model.dart';

/// Carte de projet réutilisable - Version sans progression
class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final bool showMemberCount;
  final bool showPriority;
  final EdgeInsetsGeometry? margin;
  final String? priority;
  final String Function(DateTime)? dateFormatter;
  final String Function(DateTime)? dueDateFormatter;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.showMemberCount = false,
    this.showPriority = false,
    this.margin,
    this.priority,
    this.dateFormatter,
    this.dueDateFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec titre et statut
              _buildHeader(),
              
              const SizedBox(height: 12),

              // Description
              if (project.description != null && project.description!.isNotEmpty)
                _buildDescription(),

              // Indicateurs (dates, membres)
              _buildIndicators(),

              // Priorité (optionnelle)
              if (showPriority && priority != null)
                _buildPriorityIndicator(priority!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icône du projet
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getProjectColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getProjectIcon(),
            color: _getProjectColor(),
            size: 20,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Titre et statut
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppConstants.textPrimaryColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              _buildStatusBadge(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      children: [
        Text(
          project.description!,
          style: TextStyle(
            fontSize: 14,
            color: AppConstants.textSecondaryColor,
            height: 1.4,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildIndicators() {
    return Column(
      children: [
        // Date de création
        if (project.createdAt != null)
          _buildDateIndicator(
            icon: Icons.calendar_today_rounded,
            text: 'Créé ${_formatDate(project.createdAt!)}',
          ),

        // Date d'échéance
        if (project.endDate != null)
          _buildDateIndicator(
            icon: Icons.flag_rounded,
            text: _formatDueDate(project.endDate!),
            isDueDate: true,
          ),

      
        // Membres assignés - À réactiver quand disponible
        // if (showMemberCount && project.hasAssignedMembers)
        //   Row(
        //     children: [
        //       Icon(
        //         Icons.people_rounded,
        //         size: 16,
        //         color: AppConstants.textSecondaryColor,
        //       ),
        //       const SizedBox(width: 6),
        //       Text(
        //         '${project.assignedMembers!.length} membre(s)',
        //         style: AppConstants.captionStyle,
        //       ),
        //     ],
        //   ),
      ],
    );
  }

  Widget _buildDateIndicator({
    required IconData icon,
    required String text,
    bool isDueDate = false,
  }) {
    Color textColor = AppConstants.textSecondaryColor;
    
    // Changer la couleur pour les échéances dépassées
    if (isDueDate && project.endDate != null) {
      final now = DateTime.now();
      if (project.endDate!.isBefore(now)) {
        textColor = AppConstants.errorColor;
      } else if (project.endDate!.difference(now).inDays <= 3) {
        textColor = Colors.orange;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppConstants.captionStyle.copyWith(color: textColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityIndicator(String priority) {
    Color priorityColor;
    String priorityText;
    IconData priorityIcon;

    switch (priority.toLowerCase()) {
      case 'high':
        priorityColor = AppConstants.errorColor;
        priorityText = 'Haute priorité';
        priorityIcon = Icons.warning_amber_rounded;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        priorityText = 'Priorité moyenne';
        priorityIcon = Icons.info_rounded;
        break;
      case 'low':
        priorityColor = AppConstants.successColor;
        priorityText = 'Basse priorité';
        priorityIcon = Icons.arrow_downward_rounded;
        break;
      default:
        priorityColor = Colors.grey;
        priorityText = 'Priorité non définie';
        priorityIcon = Icons.help_rounded;
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: priorityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: priorityColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                priorityIcon,
                size: 14,
                color: priorityColor,
              ),
              const SizedBox(width: 6),
              Text(
                priorityText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: priorityColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Badge de statut amélioré
  Widget _buildStatusBadge() {
    final statusConfig = _getStatusConfig();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusConfig.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusConfig.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusConfig.icon,
            size: 12,
            color: statusConfig.color,
          ),
          const SizedBox(width: 4),
          Text(
            statusConfig.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: statusConfig.color,
            ),
          ),
        ],
      ),
    );
  }

  /// Configuration du statut
  _StatusConfig _getStatusConfig() {
    switch (project.status) {
      case 'completed':
        return _StatusConfig(
          color: AppConstants.successColor,
          label: 'Terminé',
          icon: Icons.check_circle_rounded,
        );
      case 'in_progress':
        return _StatusConfig(
          color: AppConstants.primaryColor,
          label: 'En cours',
          icon: Icons.play_arrow_rounded,
        );
      case 'testing':
        return _StatusConfig(
          color: Colors.orange,
          label: 'En test',
          icon: Icons.bug_report_rounded,
        );
      case 'revision':
        return _StatusConfig(
          color: Colors.purple,
          label: 'Révision',
          icon: Icons.update_rounded,
        );
      case 'pending':
      default:
        return _StatusConfig(
          color: Colors.grey,
          label: 'En attente',
          icon: Icons.schedule_rounded,
        );
    }
  }

  /// Couleur du projet basée sur le statut
  Color _getProjectColor() {
    switch (project.status) {
      case 'completed':
        return AppConstants.successColor;
      case 'in_progress':
        return AppConstants.primaryColor;
      case 'testing':
        return Colors.orange;
      case 'revision':
        return Colors.purple;
      case 'pending':
      default:
        return Colors.grey;
    }
  }

  /// Icône du projet basée sur le statut
  IconData _getProjectIcon() {
    switch (project.status) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'in_progress':
        return Icons.rocket_launch_rounded;
      case 'testing':
        return Icons.bug_report_rounded;
      case 'revision':
        return Icons.architecture_rounded;
      case 'pending':
      default:
        return Icons.folder_rounded;
    }
  }

  /// Formater une date avec le formateur personnalisé ou par défaut
  String _formatDate(DateTime date) {
    if (dateFormatter != null) {
      return dateFormatter!(date);
    }
    
    // Format par défaut si aucun formateur n'est fourni
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'hier';
    } else if (difference.inDays < 7) {
      return 'il y a ${difference.inDays} jours';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? 'il y a 1 semaine' : 'il y a $weeks semaines';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'il y a 1 mois' : 'il y a $months mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? 'il y a 1 an' : 'il y a $years ans';
    }
  }

  /// Formater une date d'échéance avec le formateur personnalisé ou par défaut
  String _formatDueDate(DateTime dueDate) {
    if (dueDateFormatter != null) {
      return dueDateFormatter!(dueDate);
    }
    
    // Format par défaut si aucun formateur n'est fourni
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    
    if (difference.inDays == 0) {
      return 'Échéance aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Échéance demain';
    } else if (difference.inDays > 0 && difference.inDays < 7) {
      return 'Échéance dans ${difference.inDays} jours';
    } else if (difference.inDays > 0 && difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? 'Échéance dans 1 semaine' : 'Échéance dans $weeks semaines';
    } else if (difference.inDays > 0) {
      return 'Échéance le ${_formatExactDate(dueDate)}';
    } else {
      final daysOverdue = -difference.inDays;
      if (daysOverdue == 1) {
        return 'En retard depuis 1 jour';
      } else if (daysOverdue < 7) {
        return 'En retard depuis $daysOverdue jours';
      } else {
        final weeksOverdue = (daysOverdue / 7).floor();
        return weeksOverdue == 1 ? 'En retard depuis 1 semaine' : 'En retard depuis $weeksOverdue semaines';
      }
    }
  }

  /// Formater une date exacte
  String _formatExactDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

/// Configuration pour les statuts
class _StatusConfig {
  final Color color;
  final String label;
  final IconData icon;

  _StatusConfig({
    required this.color,
    required this.label,
    required this.icon,
  });
}