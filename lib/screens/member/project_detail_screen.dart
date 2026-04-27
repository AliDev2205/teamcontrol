import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../models/project_model.dart';
import '../../models/member_model.dart';
import '../../models/project_phase_model.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../member/progress_update_screen.dart';
import '../admin/edit_project_screen.dart';
import '../member/progress_updates_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late Member? _currentUser;
  bool _isLoading = true;
  bool _isAdmin = false;
  List<Map<String, dynamic>> _progressHistory = [];
  List<ProjectPhase> _phases = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _currentUser = await AuthService.getCurrentUser();
      _isAdmin = _currentUser?.isAdmin ?? false;
      final progressList = await ApiService.getProgress(widget.project.id);
      _progressHistory = progressList.map((progress) {
        return {
          'member_name': progress.memberName ?? 'Membre inconnu',
          'update_text': progress.updateText,
          'date_added': progress.dateAdded,
          'is_final': progress.isFinal,
        };
      }).toList();
      await _loadProjectPhases();
    } catch (e) {
      _showErrorSnackBar('Erreur lors du chargement: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProjectPhases() async {
    try {
      final phases = await ApiService.getProjectPhases(widget.project.id);
      setState(() => _phases = phases);
    } catch (e) {
      print('Erreur chargement phases: $e');
      setState(() => _phases = []);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  int? get _durationInDays {
    if (widget.project.startDate != null && widget.project.endDate != null) {
      return widget.project.endDate!
          .difference(widget.project.startDate!)
          .inDays;
    }
    return null;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Non définie';
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  double get _phasesCompletion {
    if (_phases.isEmpty) return 0.0;
    final completedPhases = _phases.where((phase) => phase.isCompleted).length;
    return (completedPhases / _phases.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.project.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppConstants.primaryColor,
          labelColor: const Color.fromARGB(255, 1, 8, 15),
          unselectedLabelColor: const Color.fromARGB(255, 0, 7, 12),
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Aperçu'),
            Tab(icon: Icon(Icons.assignment_turned_in), text: 'Phases'),
            Tab(icon: Icon(Icons.update), text: 'Activité'),
          ],
        ),
        actions: [
          if (!_isAdmin && widget.project.status != 'completed')
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppConstants.accentColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 18),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProgressUpdateScreen(
                      projectId: widget.project.id,
                      projectTitle: widget.project.title,
                    ),
                  ),
                ).then((_) => _loadData());
              },
              tooltip: 'Ajouter une mise à jour',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildPhasesTab(),
                ProgressUpdatesScreen(project: widget.project),
              ],
            ),
    );
  }

  // === ONGLET APERÇU ===
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        children: [
          // En-tête du projet
          _buildProjectHeader(),
          const SizedBox(height: 20),

          // Statistiques rapides
          _buildQuickStats(),
          const SizedBox(height: 20),

          // Informations détaillées
          _buildProjectInfo(),
          const SizedBox(height: 20),

          // Actions admin
          if (_isAdmin) _buildAdminActions(),
        ],
      ),
    );
  }

  Widget _buildProjectHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.primaryColor.withOpacity(0.8),
            AppConstants.accentColor.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.project.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.project.description != null && widget.project.description!.isNotEmpty)
                      Text(
                        widget.project.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progression globale',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${_phasesCompletion.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _phasesCompletion / 100,
          backgroundColor: Colors.white.withOpacity(0.3),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String statusText;

    switch (widget.project.status) {
      case 'completed':
        bgColor = Colors.white;
        textColor = AppConstants.successColor;
        statusText = 'Terminé';
        break;
      case 'in_progress':
        bgColor = Colors.white;
        textColor = AppConstants.primaryColor;
        statusText = 'En cours';
        break;
      case 'pending':
      default:
        bgColor = Colors.white;
        textColor = Colors.orange;
        statusText = 'En attente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Phases',
            '${_phases.length}',
            Icons.assignment,
            AppConstants.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Terminées',
            '${_phases.where((phase) => phase.isCompleted).length}',
            Icons.check_circle,
            AppConstants.successColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Jours',
            _durationInDays?.toString() ?? 'N/A',
            Icons.calendar_today,
            AppConstants.accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppConstants.captionStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectInfo() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.info, size: 18, color: AppConstants.primaryColor),
              ),
              const SizedBox(width: 8),
              const Text(
                'Détails du projet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoItem(Icons.calendar_today, 'Début', _formatDate(widget.project.startDate)),
          _buildInfoItem(Icons.event_available, 'Fin', _formatDate(widget.project.endDate)),
          if (_durationInDays != null)
            _buildInfoItem(Icons.schedule, 'Durée totale', '$_durationInDays jours'),
          _buildInfoItem(Icons.person, 'Créateur', widget.project.createdByName ?? 'Non spécifié'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppConstants.textSecondaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppConstants.captionStyle.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppConstants.bodyStyle.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === ONGLET PHASES ===
  Widget _buildPhasesTab() {
    return Column(
      children: [
        // En-tête de progression
        Container(
          margin: const EdgeInsets.all(AppConstants.paddingMedium),
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          decoration: BoxDecoration(
            color: AppConstants.cardColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progression des phases',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_phasesCompletion.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: _phasesCompletion / 100,
                backgroundColor: AppConstants.backgroundColor,
                valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                '${_phases.where((phase) => phase.isCompleted).length}/${_phases.length} phases terminées',
                style: AppConstants.captionStyle,
              ),
            ],
          ),
        ),

        // Liste des phases
        Expanded(
          child: _phases.isEmpty
              ? _buildEmptyPhasesState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                  itemCount: _phases.length,
                  itemBuilder: (context, index) => _buildPhaseItem(_phases[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyPhasesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: AppConstants.textSecondaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Text(
            'Aucune phase définie',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Ce projet ne contient pas encore de phases de travail',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppConstants.textSecondaryColor.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseItem(ProjectPhase phase) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: phase.isCompleted
            ? Border.all(color: AppConstants.successColor.withOpacity(0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: phase.statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  phase.isCompleted ? Icons.check : Icons.radio_button_unchecked,
                  size: 16,
                  color: phase.statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Phase ${phase.orderNumber}',
                                style: AppConstants.captionStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                phase.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildPhaseStatusBadge(phase),
                      ],
                    ),
                    if (phase.description != null && phase.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        phase.description!,
                        style: AppConstants.bodyStyle.copyWith(
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: AppConstants.textSecondaryColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${_formatDate(phase.startDate)} - ${_formatDate(phase.endDate)}',
                  style: AppConstants.captionStyle,
                ),
              ),
            ],
          ),
          if (!_isAdmin && !phase.isCompleted) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showPhaseUpdateDialog(phase),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Marquer comme terminée'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.successColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhaseStatusBadge(ProjectPhase phase) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: phase.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        phase.statusLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: phase.statusColor,
        ),
      ),
    );
  }

  void _showPhaseUpdateDialog(ProjectPhase phase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la phase'),
        content: Text('Voulez-vous marquer la phase "${phase.title}" comme terminée ?'),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppConstants.textSecondaryColor.withOpacity(0.5)),
                    foregroundColor: AppConstants.textPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _updatePhaseStatus(phase, 'completed');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.successColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Confirmer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updatePhaseStatus(ProjectPhase phase, String status) async {
    try {
      // DEBUG TEMPORAIRE
    final currentUser = await AuthService.getCurrentUser();
    print('🔄 Membre connecté: ${currentUser?.fullName}');
    print('🆔 ID du membre: ${currentUser?.id}');
    
      final result = await ApiService.updatePhaseStatus(phase.phaseId, status);
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Phase "${phase.title}" marquée comme terminée'),
            backgroundColor: AppConstants.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        await _loadProjectPhases();
      } else {
        _showErrorSnackBar(result['message'] ?? 'Erreur lors de la mise à jour');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    }
  }

  // === ACTIONS ADMIN ===
  Widget _buildAdminActions() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.admin_panel_settings, size: 18, color: AppConstants.primaryColor),
              ),
              const SizedBox(width: 8),
              const Text(
                'Actions Administration',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAdminActionButton(
                icon: Icons.edit,
                label: 'Modifier',
                color: AppConstants.primaryColor,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProjectScreen(project: widget.project),
                    ),
                  ).then((_) => _loadData());
                },
              ),
              _buildAdminActionButton(
                icon: Icons.people,
                label: 'Membres',
                color: AppConstants.accentColor,
              ),
              _buildAdminActionButton(
                icon: Icons.assignment_add,
                label: 'Nouvelle phase',
                color: AppConstants.successColor,
              ),
              if (widget.project.status != 'completed')
                _buildAdminActionButton(
                  icon: Icons.check_circle,
                  label: 'Terminer',
                  color: AppConstants.successColor,
                  onPressed: _showNotImplementedSnackBar,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed ?? () => _showNotImplementedSnackBar(),
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _showNotImplementedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Fonctionnalité en cours de développement'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}