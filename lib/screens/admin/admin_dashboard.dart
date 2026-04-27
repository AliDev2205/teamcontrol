import 'package:flutter/material.dart';
import 'package:arnos_tech/main.dart';
import '../../config/constants.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart'; 
import '../../models/member_model.dart';
import '../../models/dashboard_stats_model.dart'; 
import '../../widgets/admin_drawer.dart';
import 'add_member_screen.dart';
import 'project_list_screen.dart';
import 'create_project_screen.dart';
import 'assign_multiple_members_screen.dart';
import '../../widgets/notification_bell.dart';
import 'validation_screen.dart';
import 'manage_members_screen.dart';

/// Dashboard Admin - Version améliorée avec nouvelles statistiques
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Member? _currentUser;
  bool _isLoading = true;
  DashboardStats? _dashboardStats; // Remplace les anciennes variables
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Récupérer l'utilisateur connecté
      _currentUser = await AuthService.getCurrentUser();

      // Récupérer les nouvelles statistiques
      _dashboardStats = await DashboardService.getDashboardStats();
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
  if (_currentUser != null)
    NotificationBell(
      memberId: _currentUser!.id,
      onNotificationsUpdated: _loadData,
    ),
  IconButton(
    icon: const Icon(Icons.refresh),
    onPressed: _loadData,
  ),
],
      ),
      drawer: AdminDrawer(currentUser: _currentUser, navigatorKey: ArnosTechApp.navigatorKey),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message de bienvenue
              _buildWelcomeCard(),

              const SizedBox(height: 20),

              // Statistiques principales
              const Text(
                'Vue d\'ensemble',
                style: AppConstants.headingStyle,
              ),

              const SizedBox(height: 15),

              _buildMainStatsCards(),

              const SizedBox(height: 20),

              // Avancement global
              _buildOverallProgress(),

              const SizedBox(height: 30),

              // Actions rapides
              const Text(
                'Actions rapides',
                style: AppConstants.headingStyle,
              ),

              const SizedBox(height: 15),

              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      color: AppConstants.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              backgroundImage: _currentUser?.photo != null
                  ? NetworkImage(_currentUser!.photo!)
                  : null,
              child: _currentUser?.photo == null
                  ? Text(
                _currentUser?.firstName[0].toUpperCase() ?? 'A',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              )
                  : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bienvenue,',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    _currentUser?.fullName ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _currentUser?.position ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStatsCards() {
    final stats = _dashboardStats!;
    return Column(
      children: [
        // Première ligne
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.people,
                title: 'Membres',
                value: stats.totalMembers.toString(),
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.folder,
                title: 'Projets',
                value: stats.totalProjects.toString(),
                color: AppConstants.accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Deuxième ligne
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.pending_actions,
                title: 'En attente',
                value: stats.pendingProjects.toString(),
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                title: 'En cours',
                value: stats.inProgressProjects.toString(),
                color: AppConstants.successColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Troisième ligne
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle,
                title: 'Terminés',
                value: stats.completedProjects.toString(),
                color: AppConstants.successColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.assignment_late,
                title: 'Non attribués',
                value: stats.unassignedProjects.toString(),
                color: AppConstants.errorColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: AppConstants.captionStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallProgress() {
    final progress = _dashboardStats!.overallProgress;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Avancement Global',
                  style: AppConstants.subHeadingStyle,
                ),
                Text(
                  '${progress.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progression moyenne de tous les projets',
                  style: AppConstants.captionStyle,
                ),
                Text(
                  '${progress.toStringAsFixed(1)}%',
                  style: AppConstants.captionStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

Widget _buildQuickActions() {
  return Column(
    children: [
      // NOUVEAU : Bouton pour créer un projet avec phases
      _buildActionButton(
        icon: Icons.add_circle,
        title: 'Créer un projet',
        subtitle: 'Nouveau projet avec phases intégrées',
        color: AppConstants.accentColor,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateProjectScreen()),
          ).then((_) => _loadData());
        },
      ),
      const SizedBox(height: 12),
      _buildActionButton(
        icon: Icons.person_add,
        title: 'Ajouter un membre',
        subtitle: 'Créer un nouveau compte membre',
        color: AppConstants.primaryColor,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMemberScreen()),
          ).then((_) => _loadData());
        },
      ),
      const SizedBox(height: 12),
      _buildActionButton(
        icon: Icons.manage_accounts,
        title: 'Gérer les membres',
        subtitle: 'Modifier, supprimer, activer/désactiver',
        color: Colors.indigo,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManageMembersScreen()),
          );
        },
      ),
      const SizedBox(height: 12),
      _buildActionButton(
  icon: Icons.people_alt,
  title: 'Assigner multiple',
  subtitle: 'Assigner plusieurs membres à un projet',
  color: Colors.purple,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AssignMultipleMembersScreen()),
    ).then((_) => _loadData());
  },
),
      const SizedBox(height: 12),
      _buildActionButton(
        icon: Icons.list,
        title: 'Voir tous les projets',
        subtitle: 'Consulter la liste complète',
        color: AppConstants.successColor,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProjectListScreen()),
          );
        },
      ),
     /* _buildActionButton(
  icon: Icons.verified_user,
  title: 'Validations en attente',
  subtitle: 'Valider les mises à jour des membres',
  color: Colors.orange,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ValidationScreen()),
    );
  },
),*/
    ],
  );
}

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppConstants.captionStyle,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppConstants.textSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}