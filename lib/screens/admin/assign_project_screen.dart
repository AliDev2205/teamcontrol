import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../services/api_service.dart';
import '../../models/member_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

/// Écran d'assignation de projet
class AssignProjectScreen extends StatefulWidget {
  const AssignProjectScreen({super.key});

  @override
  State<AssignProjectScreen> createState() => _AssignProjectScreenState();
}

class _AssignProjectScreenState extends State<AssignProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingMembers = true;
  List<Member> _members = [];
  Member? _selectedMember;
  String _selectedStatus = 'pending';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoadingMembers = true);

    try {
      final members = await ApiService.getAllMembers();
      setState(() {
        _members = members.where((m) => m.role == 'member').toList();
        if (_members.isNotEmpty) {
          _selectedMember = _members.first;
        }
      });
    } catch (e) {
      _showErrorSnackBar('Erreur lors du chargement des membres: $e');
    } finally {
      setState(() => _isLoadingMembers = false);
    }
  }

  Future<void> _handleAssignProject() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMember == null) {
      _showErrorSnackBar('Veuillez sélectionner un membre');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.assignProject({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'assigned_to': _selectedMember!.id,
        'start_date': _startDate?.toIso8601String().split('T')[0],
        'end_date': _endDate?.toIso8601String().split('T')[0],
        'status': _selectedStatus,
      });

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Projet assigné avec succès'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        Navigator.pop(context);
      } else {
        _showErrorSnackBar(result['message'] ?? 'Erreur lors de l\'assignation');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigner un projet'),
      ),
      body: _isLoadingMembers
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Titre du projet
              CustomInput(
                label: 'Titre du projet',
                controller: _titleController,
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Titre requis';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description
              CustomInput(
                label: 'Description',
                controller: _descriptionController,
                maxLines: 4,
                prefixIcon: Icons.description_outlined,
              ),

              const SizedBox(height: 16),

              // Membre à assigner
              const Text(
                'Assigner à',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(color: Colors.grey),
                ),
                child: _members.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Aucun membre disponible'),
                )
                    : DropdownButton<Member>(
                  value: _selectedMember,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _members.map((member) {
                    return DropdownMenuItem<Member>(
                      value: member,
                      child: Text(
                          '${member.fullName} - ${member.position ?? ""}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMember = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Date de début
              const Text(
                'Date de début',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context, true),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppConstants.textSecondaryColor),
                      const SizedBox(width: 12),
                      Text(
                        _startDate == null
                            ? 'Sélectionner une date'
                            : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                        style: TextStyle(
                          color: _startDate == null
                              ? AppConstants.textSecondaryColor
                              : AppConstants.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Date de fin
              const Text(
                'Date de fin',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context, false),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppConstants.textSecondaryColor),
                      const SizedBox(width: 12),
                      Text(
                        _endDate == null
                            ? 'Sélectionner une date'
                            : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                        style: TextStyle(
                          color: _endDate == null
                              ? AppConstants.textSecondaryColor
                              : AppConstants.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Statut
              const Text(
                'Statut initial',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(color: Colors.grey),
                ),
                child: DropdownButton<String>(
                  value: _selectedStatus,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text('En attente'),
                    ),
                    DropdownMenuItem(
                      value: 'in_progress',
                      child: Text('En cours'),
                    ),
                    DropdownMenuItem(
                      value: 'testing',
                      child: Text('En test'),
                    ),
                    DropdownMenuItem(
                      value: 'revision',
                      child: Text('Mise à jour'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
              ),

              const SizedBox(height: 30),

              // Bouton d'assignation
              CustomButton(
                text: 'Assigner le projet',
                onPressed: _handleAssignProject,
                isLoading: _isLoading,
                icon: Icons.assignment_turned_in,
              ),
            ],
          ),
        ),
      ),
    );
  }
}