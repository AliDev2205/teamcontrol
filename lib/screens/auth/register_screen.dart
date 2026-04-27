import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import 'login_screen.dart';

/// Écran d'inscription (Register)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _departmentController.dispose();
    _employeeIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('Les mots de passe ne correspondent pas');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.register({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'position': _positionController.text.trim(),
        'department': _departmentController.text.trim(),
        'employee_id': _employeeIdController.text.trim(),
        'password': _passwordController.text,
        'role': 'member',
      });

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Inscription réussie ! Vous pouvez maintenant vous connecter'),
            backgroundColor: AppConstants.successColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        _showErrorSnackBar(result['message'] ?? 'Erreur lors de l\'inscription');
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
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nouveau Membre'),
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.textPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // En-tête
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 50,
                        color: AppConstants.primaryColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ajouter un membre',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Créez un compte pour un nouveau collaborateur',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Section Informations personnelles
                _buildSectionHeader(
                  title: 'Informations personnelles',
                  icon: Icons.person_outline_rounded,
                ),

                // Prénom et Nom en ligne
                Row(
                  children: [
                    Expanded(
                      child: CustomInput(
                        label: 'Prénom',
                        hint: 'Jean',
                        controller: _firstNameController,
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requis';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomInput(
                        label: 'Nom',
                        hint: 'Dupont',
                        controller: _lastNameController,
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requis';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Email
                CustomInput(
                  label: 'Email professionnel',
                  hint: 'jean.dupont@arnostech.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email requis';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Format email invalide';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Téléphone
                CustomInput(
                  label: 'Téléphone',
                  hint: '+229 01 65 30 22 51',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_rounded,
                ),

                const SizedBox(height: 24),

                // Section Informations professionnelles
                _buildSectionHeader(
                  title: 'Informations professionnelles',
                  icon: Icons.business_center_rounded,
                ),

                // Poste et Département en ligne
                Row(
                  children: [
                    Expanded(
                      child: CustomInput(
                        label: 'Poste',
                        hint: 'Développeur',
                        controller: _positionController,
                        prefixIcon: Icons.work_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomInput(
                        label: 'Département',
                        hint: 'IT',
                        controller: _departmentController,
                        prefixIcon: Icons.business_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ID Employé
                CustomInput(
                  label: 'Identifiant employé',
                  hint: 'EMP2024001',
                  controller: _employeeIdController,
                  prefixIcon: Icons.badge_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ID employé requis';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Section Sécurité
                _buildSectionHeader(
                  title: 'Sécurité',
                  icon: Icons.lock_rounded,
                ),

                // Mot de passe
                CustomInput(
                  label: 'Mot de passe',
                  hint: 'Créez un mot de passe sécurisé',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixIconPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mot de passe requis';
                    }
                    if (value.length < 6) {
                      return '6 caractères minimum';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Confirmer mot de passe
                CustomInput(
                  label: 'Confirmer le mot de passe',
                  hint: 'Répétez le mot de passe',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: Icons.lock_reset_rounded,
                  suffixIcon: _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixIconPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirmation requise';
                    }
                    if (value != _passwordController.text) {
                      return 'Mots de passe différents';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Bouton d'inscription
                CustomButton(
                  text: 'Créer le compte',
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                  icon: Icons.person_add_alt_rounded,
                ),

                const SizedBox(height: 20),

                // Lien vers la connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Déjà un compte ? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: Text(
                        'Se connecter',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}