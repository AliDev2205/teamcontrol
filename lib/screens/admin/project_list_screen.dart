import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../services/api_service.dart';
import '../../models/project_model.dart';
import '../../widgets/project_card.dart';
import '../member/project_detail_screen.dart';
import 'edit_project_screen.dart';

/// Liste de tous les projets (Admin)
class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  List<Project> _projects = [];
  List<Project> _filteredProjects = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);

    try {
      final projects = await ApiService.getAllProjects();
      setState(() {
        _projects = projects;
        _applyFilter();
      });
    } catch (e) {
      _showErrorSnackBar('Erreur lors du chargement: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    String searchTerm = _searchController.text.toLowerCase();
    
    List<Project> filtered = _projects;
    
    // Appliquer le filtre de statut
    if (_selectedFilter != 'all') {
      filtered = filtered.where((p) => p.status == _selectedFilter).toList();
    }
    
    // Appliquer la recherche
    if (searchTerm.isNotEmpty) {
      filtered = filtered.where((project) =>
        project.title.toLowerCase().contains(searchTerm) ||
        (project.description?.toLowerCase().contains(searchTerm) ?? false)
      ).toList();
    }
    
    setState(() {
      _filteredProjects = filtered;
    });
  }

  void _onSearchChanged() {
    _applyFilter();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _navigateToEdit(Project project) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProjectScreen(project: project),
      ),
    );
    
    // Rafraîchir la liste si une modification a été effectuée
    if (result == true && mounted) {
      await _loadProjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des projets'),
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.textPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppConstants.primaryColor),
            onPressed: _loadProjects,
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
                    'Chargement des projets...',
                    style: AppConstants.captionStyle,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Barre de recherche
                _buildSearchBar(),

                // Filtres
                _buildFilterSection(),

                // Compteur et stats
                _buildStatsBar(),

                // Liste des projets
                Expanded(
                  child: _filteredProjects.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadProjects,
                          backgroundColor: Colors.white,
                          color: AppConstants.primaryColor,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(AppConstants.paddingMedium),
                            itemCount: _filteredProjects.length,
                            itemBuilder: (context, index) {
                              final project = _filteredProjects[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ProjectCard(
                                  project: project,
                                  onTap: () {
                                    _navigateToEdit(project);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Rechercher un projet...',
            hintStyle: TextStyle(color: AppConstants.textSecondaryColor),
            prefixIcon: Icon(Icons.search_rounded, color: AppConstants.primaryColor),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, color: AppConstants.errorColor),
                    onPressed: () {
                      _searchController.clear();
                      _applyFilter();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildModernFilterChip('Tous', 'all', Icons.all_inclusive_rounded),
            const SizedBox(width: 8),
            _buildModernFilterChip('En attente', 'pending', Icons.pending_actions_rounded),
            const SizedBox(width: 8),
            _buildModernFilterChip('En cours', 'in_progress', Icons.play_arrow_rounded),
            const SizedBox(width: 8),
            _buildModernFilterChip('En test', 'testing', Icons.bug_report_rounded),
            const SizedBox(width: 8),
            _buildModernFilterChip('Mise à jour', 'revision', Icons.update_rounded),
            const SizedBox(width: 8),
            _buildModernFilterChip('Terminés', 'completed', Icons.check_circle_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFilterChip(String label, String value, IconData icon) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
          _applyFilter();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppConstants.primaryColor : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppConstants.primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppConstants.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_filteredProjects.length} projet(s)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          if (_selectedFilter != 'all')
            Text(
              'Filtré: ${_getFilterLabel()}',
              style: AppConstants.captionStyle,
            ),
        ],
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
              Icons.folder_open_rounded,
              size: 80,
              color: AppConstants.textSecondaryColor.withOpacity(0.4),
            ),
            const SizedBox(height: 20),
            Text(
              _getEmptyStateTitle(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppConstants.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStateSubtitle(),
              style: AppConstants.captionStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_searchController.text.isNotEmpty || _selectedFilter != 'all')
              ElevatedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _selectedFilter = 'all';
                    _applyFilter();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text('Réinitialiser les filtres'),
              ),
          ],
        ),
      ),
    );
  }

  String _getEmptyStateTitle() {
    if (_searchController.text.isNotEmpty) {
      return 'Aucun projet trouvé';
    }
    switch (_selectedFilter) {
      case 'all':
        return 'Aucun projet';
      case 'pending':
        return 'Aucun projet en attente';
      case 'in_progress':
        return 'Aucun projet en cours';
      case 'testing':
        return 'Aucun projet en test';
      case 'revision':
        return 'Aucune mise à jour en cours';
      case 'completed':
        return 'Aucun projet terminé';
      default:
        return 'Aucun projet';
    }
  }

  String _getEmptyStateSubtitle() {
    if (_searchController.text.isNotEmpty) {
      return 'Aucun projet ne correspond à "${_searchController.text}"';
    }
    switch (_selectedFilter) {
      case 'all':
        return 'Commencez par créer votre premier projet';
      case 'pending':
        return 'Tous les projets sont en cours ou terminés';
      case 'in_progress':
        return 'Les projets sont en attente ou terminés';
      case 'testing':
        return 'Aucun projet n\'est actuellement en phase de test';
      case 'revision':
        return 'Aucun projet ne nécessite de mise à jour';
      case 'completed':
        return 'Aucun projet n\'a été marqué comme terminé';
      default:
        return 'Commencez par créer votre premier projet';
    }
  }

  String _getFilterLabel() {
    switch (_selectedFilter) {
      case 'pending':
        return 'En attente';
      case 'in_progress':
        return 'En cours';
      case 'testing':
        return 'En test';
      case 'revision':
        return 'Mise à jour';
      case 'completed':
        return 'Terminés';
      default:
        return 'Tous';
    }
  }
}