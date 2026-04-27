import 'package:arnos_tech/main.dart';
import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/member_model.dart';
import '../../models/project_model.dart';
import '../../widgets/project_card.dart';
import '../../widgets/admin_drawer.dart'; 
import 'project_detail_screen.dart';
import '../../widgets/notification_bell.dart';

/// Dashboard Membre - Version compacte
class MemberDashboard extends StatefulWidget {
  const MemberDashboard({super.key});

  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  Member? _currentUser;
  List<Project> _projects = [];
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      _currentUser = await AuthService.getCurrentUser();
      if (_currentUser != null) {
        final projects = await ApiService.getMemberProjects(_currentUser!.id);
        setState(() => _projects = projects);
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors du chargement: $e');
    } finally {
      setState(() => _isLoading = false);
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

  // Méthode pour formater les dates de manière plus explicite
  String _formatProjectDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? 'Il y a 1 semaine' : 'Il y a $weeks semaines';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'Il y a 1 mois' : 'Il y a $months mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? 'Il y a 1 an' : 'Il y a $years ans';
    }
  }

  // Méthode pour formater les dates d'échéance
  String _formatDueDate(DateTime dueDate) {
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

  // Méthode pour formater une date exacte
  String _formatExactDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Tableau de Bord'),
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.textPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.menu_rounded,
            color: AppConstants.primaryColor,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          if (_currentUser != null)
            NotificationBell(
              memberId: _currentUser!.id,
              onNotificationsUpdated: _loadData,
            ),
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: AppConstants.primaryColor,
            ),
            onPressed: _loadData,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      drawer: AdminDrawer(
        currentUser: _currentUser,
        navigatorKey: ArnosTechApp.navigatorKey,
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
                    'Chargement de vos projets...',
                    style: AppConstants.captionStyle,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              backgroundColor: Colors.white,
              color: AppConstants.primaryColor,
              child: _projects.isEmpty
                  ? _buildEmptyState()
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Message de bienvenue
                          _buildWelcomeCard(),

                          const SizedBox(height: 20),

                          // Statistiques rapides - COMPACT
                          _buildQuickStats(),

                          const SizedBox(height: 20),

                          // Liste des projets
                          _buildProjectsSection(),
                        ],
                      ),
                    ),
            ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.primaryColor,
            AppConstants.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar compact
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: _currentUser?.photo != null
                ? ClipOval(
                    child: Image.network(
                      _currentUser!.photo!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          _buildInitialAvatar(),
                    ),
                  )
                : _buildInitialAvatar(),
          ),
          
          const SizedBox(width: 12),
          
          // Texte de bienvenue compact
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, ${_currentUser?.firstName ?? ''} 👋',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currentUser?.position ?? 'Membre de l\'équipe',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_projects.length} projet(s) assigné(s)',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialAvatar() {
    return Center(
      child: Text(
        _currentUser?.firstName[0].toUpperCase() ?? 'M',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppConstants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final totalProjects = _projects.length;
    final activeProjects = _projects.where((p) => p.status == 'in_progress').length;
    final completedProjects = _projects.where((p) => p.status == 'completed').length;
    final pendingProjects = _projects.where((p) => p.status == 'pending').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vue d\'ensemble',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4, // 4 colonnes au lieu de 2
          crossAxisSpacing: 8, // Espacement réduit
          mainAxisSpacing: 8,
          childAspectRatio: 0.7, // Plus compact
          children: [
            _buildCompactStatCard(
              icon: Icons.folder_rounded,
              value: totalProjects.toString(),
              label: 'Total',
              color: AppConstants.primaryColor,
            ),
            _buildCompactStatCard(
              icon: Icons.trending_up_rounded,
              value: activeProjects.toString(),
              label: 'En cours',
              color: AppConstants.accentColor,
            ),
            _buildCompactStatCard(
              icon: Icons.check_circle_rounded,
              value: completedProjects.toString(),
              label: 'Terminés',
              color: AppConstants.successColor,
            ),
            _buildCompactStatCard(
              icon: Icons.pending_actions_rounded,
              value: pendingProjects.toString(),
              label: 'En attente',
              color: Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10), // Padding réduit
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône plus petite
            Container(
              padding: const EdgeInsets.all(6), // Padding réduit
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color), // Icône plus petite
            ),
            const SizedBox(height: 6), // Espacement réduit
            // Valeur
            Text(
              value,
              style: TextStyle(
                fontSize: 16, // Taille réduite
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2), // Espacement réduit
            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 10, // Taille réduite
                fontWeight: FontWeight.w500,
                color: AppConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mes projets',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_projects.length}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: _projects.map((project) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8), // Marge réduit
              child: ProjectCard(
                project: project,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProjectDetailScreen(project: project),
                    ),
                  ).then((_) => _loadData());
                },
                // Passage des méthodes de formatage au ProjectCard
                dateFormatter: _formatProjectDate,
                dueDateFormatter: _formatDueDate,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 60,
              color: AppConstants.textSecondaryColor.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun projet assigné',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous n\'avez pas encore de projet assigné.\nContactez votre administrateur.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppConstants.textSecondaryColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Actualiser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}