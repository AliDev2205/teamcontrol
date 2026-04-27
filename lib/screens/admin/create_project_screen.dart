import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/constants.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/member_model.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  
  final List<Phase> _phases = [];
  bool _isLoading = false;
  Member? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _currentUser = await AuthService.getCurrentUser();
    setState(() {});
  }

  void _addPhase() {
    setState(() {
      _phases.add(Phase(orderNumber: _phases.length + 1));
    });
  }

  void _removePhase(int index) {
    setState(() {
      _phases.removeAt(index);
      // Réindexer les orderNumber après suppression
      for (int i = 0; i < _phases.length; i++) {
        _phases[i] = Phase(
          title: _phases[i].title,
          description: _phases[i].description,
          orderNumber: i + 1,
        );
      }
    });
  }

  void _updatePhase(int index, String title, String description) {
    setState(() {
      _phases[index] = Phase(
        title: title,
        description: description,
        orderNumber: index + 1,
      );
    });
  }

  Future<void> _createProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final projectData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'created_by': _currentUser?.id,
        'start_date': _selectedStartDate != null ? DateFormat('yyyy-MM-dd').format(_selectedStartDate!) : null,
        'end_date': _selectedEndDate != null ? DateFormat('yyyy-MM-dd').format(_selectedEndDate!) : null,
        'phases': _phases.map((phase) => {
          'title': phase.title,
          'description': phase.description,
        }).toList(),
      };

      final result = await ApiService.createProjectWithPhases(projectData);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Projet créé avec succès'),
            backgroundColor: AppConstants.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erreur lors de la création'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Projet'),
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
              color: _isLoading ? Colors.grey : AppConstants.primaryColor,
            ),
            onPressed: _isLoading ? null : _createProject,
            tooltip: 'Sauvegarder',
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
                    'Création du projet...',
                    style: AppConstants.captionStyle,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProjectInfo(),
                    const SizedBox(height: 24),
                    _buildPhasesSection(),
                    const SizedBox(height: 24),
                    _buildCreateButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProjectInfo() {
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
                  Icons.info_rounded,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Informations du projet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Titre du projet *',
              labelStyle: TextStyle(color: AppConstants.textSecondaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              prefixIcon: Icon(Icons.title_rounded, color: AppConstants.primaryColor),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le titre est requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description',
              labelStyle: TextStyle(color: AppConstants.textSecondaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              prefixIcon: Icon(Icons.description_rounded, color: AppConstants.primaryColor),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _startDateController,
                  decoration: InputDecoration(
                    labelText: 'Date de début',
                    labelStyle: TextStyle(color: AppConstants.textSecondaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    prefixIcon: Icon(Icons.calendar_today_rounded, color: AppConstants.primaryColor),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context, _startDateController),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _endDateController,
                  decoration: InputDecoration(
                    labelText: 'Date de fin',
                    labelStyle: TextStyle(color: AppConstants.textSecondaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    prefixIcon: Icon(Icons.event_available_rounded, color: AppConstants.primaryColor),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context, _endDateController),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhasesSection() {
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
                      Icons.linear_scale_rounded,
                      color: AppConstants.accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Phases du projet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                ],
              ),
              FloatingActionButton.small(
                onPressed: _addPhase,
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                child: const Icon(Icons.add_rounded),
                heroTag: 'add_phase',
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          Text(
            'Définissez les différentes phases de votre projet dans l\'ordre d\'exécution',
            style: AppConstants.captionStyle,
          ),
          
          const SizedBox(height: 20),
          
          if (_phases.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300), // Removed dashed, only solid is available.
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.linear_scale_rounded,
                    size: 50,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aucune phase définie',
                    style: TextStyle(
                      color: AppConstants.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cliquez sur + pour ajouter la première phase',
                    style: AppConstants.captionStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Column(
              children: _phases.asMap().entries.map((entry) {
                final index = entry.key;
                final phase = entry.value;
                return _buildPhaseItem(index, phase);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPhaseItem(int index, Phase phase) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Phase ${phase.orderNumber}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppConstants.primaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: AppConstants.errorColor),
                onPressed: () => _removePhase(index),
                iconSize: 20,
                tooltip: 'Supprimer cette phase',
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          TextFormField(
            initialValue: phase.title,
            decoration: InputDecoration(
              labelText: 'Titre de la phase *',
              labelStyle: TextStyle(color: AppConstants.textSecondaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) => _updatePhase(index, value, phase.description),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le titre de la phase est requis';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 12),
          
          TextFormField(
            initialValue: phase.description,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Description (optionnelle)',
              labelStyle: TextStyle(color: AppConstants.textSecondaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) => _updatePhase(index, phase.title, value),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _createProject,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_task_rounded,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'CRÉER LE PROJET',
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
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('fr'),
      helpText: 'Sélectionner la date',
      cancelText: 'ANNULER',
      confirmText: 'OK',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppConstants.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppConstants.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final String frenchFormatted = DateFormat('d MMMM yyyy', 'fr_FR').format(picked);
      controller.text = frenchFormatted;
      if (identical(controller, _startDateController)) {
        _selectedStartDate = picked;
      } else if (identical(controller, _endDateController)) {
        _selectedEndDate = picked;
      }
    }
  }
}

class Phase {
  String title;
  String description;
  int orderNumber;

  Phase({
    this.title = '',
    this.description = '',
    required this.orderNumber,
  });
}