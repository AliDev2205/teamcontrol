import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/progress_model.dart';
import '../../models/project_model.dart';
import 'progress_update_screen.dart';

class ProgressUpdatesScreen extends StatefulWidget {
  final Project project;

  const ProgressUpdatesScreen({super.key, required this.project});

  @override
  State<ProgressUpdatesScreen> createState() => _ProgressUpdatesScreenState();
}

class _ProgressUpdatesScreenState extends State<ProgressUpdatesScreen> {
  List<Progress> _progressList = [];
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
    _checkUserRole();
  }

  Future<void> _loadProgress() async {
    setState(() => _isLoading = true);
    try {
      final progress = await ApiService.getProgress(widget.project.id);
      setState(() {
        _progressList = progress;
      });
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkUserRole() async {
    final user = await AuthService.getCurrentUser();
    setState(() {
      _isAdmin = user?.isAdmin ?? false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mises à jour',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.textPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: AppConstants.primaryColor,
            ),
            onPressed: _loadProgress,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppConstants.primaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Chargement des mises à jour...',
                    style: AppConstants.captionStyle,
                  ),
                ],
              ),
            )
          : _progressList.isEmpty
              ? _buildEmptyState()
              : _buildProgressList(),
      floatingActionButton: _isAdmin || widget.project.status == 'completed' 
          ? null 
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProgressUpdateScreen(
                      projectId: widget.project.id,
                      projectTitle: widget.project.title,
                    ),
                  ),
                ).then((_) => _loadProgress());
              },
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add_rounded, size: 28),
              elevation: 4,
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.update_rounded,
              size: 80,
              color: AppConstants.textSecondaryColor.withOpacity(0.4),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucune mise à jour',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Soyez le premier à partager l\'avancement du projet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppConstants.textSecondaryColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            if (!_isAdmin && widget.project.status != 'completed')
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProgressUpdateScreen(
                        projectId: widget.project.id,
                        projectTitle: widget.project.title,
                      ),
                    ),
                  ).then((_) => _loadProgress());
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Ajouter une mise à jour'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressList() {
    return Column(
      children: [
        // En-tête avec compteur
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_progressList.length} mise(s) à jour',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              if (_progressList.any((p) => p.isFinal))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppConstants.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: AppConstants.successColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Projet clôturé',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.successColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Liste des mises à jour
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadProgress,
            backgroundColor: Colors.white,
            color: AppConstants.primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _progressList.length,
              itemBuilder: (context, index) {
                final progress = _progressList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _buildProgressCard(progress),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(Progress progress) {
    final isFinalUpdate = progress.isFinal;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isFinalUpdate ? AppConstants.successColor.withOpacity(0.03) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec infos membre
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isFinalUpdate 
                        ? AppConstants.successColor.withOpacity(0.1)
                        : AppConstants.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isFinalUpdate 
                          ? AppConstants.successColor.withOpacity(0.3)
                          : AppConstants.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: progress.memberPhoto != null
                      ? ClipOval(
                          child: Image.network(
                            progress.memberPhoto!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                                _buildMemberInitial(progress),
                          ),
                        )
                      : _buildMemberInitial(progress),
                ),
                
                const SizedBox(width: 12),
                
                // Infos membre et date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        progress.memberName ?? 'Membre',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: AppConstants.textSecondaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            progress.formattedDateTime,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppConstants.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Badge final
                if (isFinalUpdate)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppConstants.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppConstants.successColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flag_rounded,
                          size: 14,
                          color: AppConstants.successColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Clôture',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppConstants.successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Contenu de la mise à jour
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Text(
                progress.updateText,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),

            // Indicateur visuel pour les mises à jour finales
            if (isFinalUpdate) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.successColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppConstants.successColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: AppConstants.successColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cette mise à jour a marqué la clôture du projet',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppConstants.successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMemberInitial(Progress progress) {
    return Center(
      child: Text(
        progress.memberName?[0].toUpperCase() ?? 'M',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: progress.isFinal ? AppConstants.successColor : AppConstants.primaryColor,
        ),
      ),
    );
  }
}