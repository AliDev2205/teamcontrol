import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/member_model.dart';
import '../../models/project_model.dart';

class AssignMultipleMembersScreen extends StatefulWidget {
  const AssignMultipleMembersScreen({super.key});

  @override
  State<AssignMultipleMembersScreen> createState() => _AssignMultipleMembersScreenState();
}

class _AssignMultipleMembersScreenState extends State<AssignMultipleMembersScreen> {
  List<Project> _projects = [];
  List<Member> _members = [];
  final List<int> _selectedMembers = [];
  int? _selectedProjectId;
  bool _isLoading = true;
  bool _isSubmitting = false;
  Member? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      _currentUser = await AuthService.getCurrentUser();
      final projects = await ApiService.getAllProjects();
      final members = await ApiService.getAllMembers();

      setState(() {
        _projects = projects;
        _members = members.where((member) => member.role == 'member' && member.isActive).toList();
      });
      
      print('✅ Projets chargés: ${_projects.length}');
      print('✅ Membres chargés: ${_members.length}');
    } catch (e) {
      print('❌ Erreur lors du chargement: $e');
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _assignMembers() async {
    if (_selectedProjectId == null) {
      _showErrorSnackBar('Veuillez sélectionner un projet');
      return;
    }
    if (_selectedMembers.isEmpty) {
      _showErrorSnackBar('Veuillez sélectionner au moins un membre');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final assignData = {
        'project_id': _selectedProjectId,
        'members': _selectedMembers,
        'assigned_by': _currentUser?.id,
      };

      print('🔄 Données envoyées: $assignData');

      final result = await ApiService.assignMultipleMembers(assignData);

      if (result['success'] == true) {
        _showSuccessSnackBar(result['message'] ?? 'Membres assignés avec succès');
        Navigator.pop(context, true);
      } else {
        _showErrorSnackBar(result['message'] ?? 'Erreur lors de l\'assignation');
      }
    } catch (e) {
      print('❌ Erreur lors de l\'assignation: $e');
      _showErrorSnackBar('Erreur: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _toggleMemberSelection(int memberId) {
    setState(() {
      if (_selectedMembers.contains(memberId)) {
        _selectedMembers.remove(memberId);
      } else {
        _selectedMembers.add(memberId);
      }
    });
    print('✅ Membres sélectionnés: $_selectedMembers');
  }

  void _selectAllMembers() {
    setState(() {
      if (_selectedMembers.length == _members.length) {
        _selectedMembers.clear();
      } else {
        _selectedMembers.clear();
        _selectedMembers.addAll(_members.map((member) => member.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigner des membres'),
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
              Icons.save_rounded,
              color: _isSubmitting ? Colors.grey : AppConstants.primaryColor,
            ),
            onPressed: _isSubmitting ? null : _assignMembers,
            tooltip: 'Sauvegarder l\'assignation',
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
                    'Chargement des données...',
                    style: AppConstants.captionStyle,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sélection du projet
                  _buildProjectSelector(),
                  
                  const SizedBox(height: 24),
                  
                  // Sélection des membres
                  _buildMembersSelector(),
                  
                  const SizedBox(height: 24),
                  
                  // Résumé et bouton
                  _buildSummaryAndButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildProjectSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.folder_rounded,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Projet à assigner',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: DropdownButton<int>(
              value: _selectedProjectId,
              hint: Text(
                'Choisir un projet',
                style: TextStyle(color: AppConstants.textSecondaryColor),
              ),
              isExpanded: true,
              underline: const SizedBox(),
              icon: Icon(Icons.arrow_drop_down_rounded, color: AppConstants.primaryColor),
              items: _projects.map((project) {
                return DropdownMenuItem<int>(
                  value: project.id,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        project.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (project.description != null && project.description!.isNotEmpty)
                        Text(
                          project.description!,
                          style: AppConstants.captionStyle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProjectId = value;
                });
                print('✅ Projet sélectionné: $value');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.accentColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.people_rounded,
                      color: AppConstants.accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Membres disponibles',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                ],
              ),
              if (_members.isNotEmpty)
                TextButton.icon(
                  onPressed: _selectAllMembers,
                  icon: Icon(
                    _selectedMembers.length == _members.length 
                        ? Icons.check_box_rounded 
                        : Icons.check_box_outline_blank_rounded,
                    size: 20,
                  ),
                  label: Text(
                    _selectedMembers.length == _members.length ? 'Tout désélectionner' : 'Tout sélectionner',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          Text(
            'Sélectionnez les membres à assigner au projet',
            style: AppConstants.captionStyle,
          ),
          
          const SizedBox(height: 16),
          
          if (_members.isEmpty)
            _buildEmptyMembersState()
          else
            Column(
              children: _members.map((member) => _buildMemberCard(member)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyMembersState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 50,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Aucun membre disponible',
            style: TextStyle(
              color: AppConstants.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tous les membres sont peut-être déjà assignés\nou inactifs',
            style: AppConstants.captionStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(Member member) {
    final isSelected = _selectedMembers.contains(member.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppConstants.primaryColor.withOpacity(0.05) : Colors.grey.shade50,
        border: Border.all(
          color: isSelected ? AppConstants.primaryColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? AppConstants.primaryColor : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppConstants.primaryColor : Colors.grey.shade300,
            ),
          ),
          child: member.photo != null 
              ? ClipOval(
                  child: Image.network(
                    member.photo!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildMemberInitial(member, isSelected),
                  ),
                )
              : _buildMemberInitial(member, isSelected),
        ),
        title: Text(
          member.fullName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? AppConstants.primaryColor : AppConstants.textPrimaryColor,
          ),
        ),
        subtitle: Text(
          member.position ?? 'Membre',
          style: TextStyle(
            color: isSelected ? AppConstants.primaryColor.withOpacity(0.8) : AppConstants.textSecondaryColor,
          ),
        ),
        trailing: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isSelected ? AppConstants.primaryColor : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppConstants.primaryColor : Colors.grey.shade400,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: isSelected
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : null,
        ),
        onTap: () => _toggleMemberSelection(member.id),
      ),
    );
  }

  Widget _buildMemberInitial(Member member, bool isSelected) {
    return Center(
      child: Text(
        member.firstName[0].toUpperCase(),
        style: TextStyle(
          color: isSelected ? Colors.white : AppConstants.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildSummaryAndButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Résumé
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Résumé',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_selectedMembers.length} membre(s) sélectionné(s)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Bouton d'assignation
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedProjectId != null && _selectedMembers.isNotEmpty && !_isSubmitting) 
                  ? _assignMembers 
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: AppConstants.primaryColor.withOpacity(0.3),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_turned_in_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'ASSIGNER LES MEMBRES',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}