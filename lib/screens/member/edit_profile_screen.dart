import 'dart:convert';
import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/member_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

/// Écran d'édition de profil - Version moderne
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();
  final _departmentController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  Member? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      _currentUser = await AuthService.getCurrentUser();

      if (_currentUser != null) {
        _firstNameController.text = _currentUser!.firstName;
        _lastNameController.text = _currentUser!.lastName;
        _emailController.text = _currentUser!.email;
        _phoneController.text = _currentUser!.phone ?? '';
        _positionController.text = _currentUser!.position ?? '';
        _departmentController.text = _currentUser!.department ?? '';
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors du chargement: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final Map<String, dynamic> updateData = {'id': _currentUser!.id};

      // Inclure uniquement les champs modifiés; si vide intentionnel, envoyer null
      final firstName = _firstNameController.text.trim();
      if (firstName != _currentUser!.firstName) {
        updateData['first_name'] = firstName.isEmpty ? null : firstName;
      }

      final lastName = _lastNameController.text.trim();
      if (lastName != _currentUser!.lastName) {
        updateData['last_name'] = lastName.isEmpty ? null : lastName;
      }

      final phone = _phoneController.text.trim();
      if (phone != (_currentUser!.phone ?? '')) {
        updateData['phone'] = phone.isEmpty ? null : phone;
      }

      final position = _positionController.text.trim();
      if (position != (_currentUser!.position ?? '')) {
        updateData['position'] = position.isEmpty ? null : position;
      }

      final department = _departmentController.text.trim();
      if (department != (_currentUser!.department ?? '')) {
        updateData['department'] = department.isEmpty ? null : department;
      }

      final result = await ApiService.updateProfile(updateData);

      if (!mounted) return;

      if (result['success'] == true) {
        // Mettre à jour les données locales
        final updatedUser = Member.fromJson(result['data']);
        await AuthService.updateUserData(updatedUser);

        _showSuccessSnackBar('Profil mis à jour avec succès');
        Navigator.pop(context);
      } else {
        _showErrorSnackBar(result['message'] ?? 'Erreur lors de la sauvegarde');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la sauvegarde: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.accentColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier mon profil'),
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.textPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
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
                    'Chargement du profil...',
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section informations personnelles
                    _buildPersonalInfoSection(),

                    const SizedBox(height: 24),

                    // Section informations professionnelles
                    _buildProfessionalInfoSection(),

                    const SizedBox(height: 32),

                    // Bouton de sauvegarde
                    CustomButton(
                      text: 'Sauvegarder les modifications',
                      onPressed: _handleSave,
                      isLoading: _isSaving,
                      icon: Icons.save_rounded,
                    ),

                    const SizedBox(height: 16),

                    // Note informative
                    _buildInfoNote(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPersonalInfoSection() {
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
                  color: AppConstants.accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: AppConstants.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Informations personnelles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Prénom et Nom en ligne
          Row(
            children: [
              Expanded(
                child: CustomInput(
                  label: 'Prénom',
                  controller: _firstNameController,
                  prefixIcon: Icons.person_outline_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomInput(
                  label: 'Nom',
                  controller: _lastNameController,
                  prefixIcon: Icons.person_outline_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Email (lecture seule)
          CustomInput(
            label: 'Email professionnel',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_rounded,
            enabled: false,
          ),
          const SizedBox(height: 16),
          // Téléphone
          CustomInput(
            label: 'Téléphone',
            hint: 'Ex:+2290196016933',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoSection() {
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
                  color: Colors.amber.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.work_rounded,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Informations professionnelles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Poste et Département en ligne
          Row(
            children: [
              Expanded(
                child: CustomInput(
                  label: 'Poste / Fonction',
                  hint: 'Ex: Développeur Flutter',
                  controller: _positionController,
                  prefixIcon: Icons.work_outline_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomInput(
                  label: 'Département',
                  hint: 'Ex: Développement',
                  controller: _departmentController,
                  prefixIcon: Icons.business_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppConstants.accentColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppConstants.accentColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informations importantes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pour modifier votre adresse email ou votre mot de passe, veuillez contacter un administrateur.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppConstants.textSecondaryColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}