import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../admin/admin_dashboard.dart';
import '../member/member_dashboard.dart';

/// Écran de connexion
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        // Connexion réussie
        final isAdmin = result['user'].isAdmin;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
            isAdmin ? const AdminDashboard() : const MemberDashboard(),
          ),
        );
      } else {
        // Erreur de connexion
        _showErrorSnackBar(result['message'] ?? 'Erreur de connexion');
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icône moderne à la place du logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppConstants.primaryColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.lock_person_rounded,
                      size: 50,
                      color: AppConstants.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Titre principal
                  Text(
                    'Connexion',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppConstants.textPrimaryColor,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Sous-titre
                  Text(
                    'Accédez à votre espace de travail',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppConstants.textSecondaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Champ email
                  CustomInput(
                    label: 'Adresse email',
                    hint: 'exemple@arnostech.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'L\'email est requis';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Format d\'email invalide';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Champ mot de passe
                  CustomInput(
                    label: 'Mot de passe',
                    hint: 'Entrez votre mot de passe',
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
                        return 'Le mot de passe est requis';
                      }
                      if (value.length < 6) {
                        return '6 caractères minimum';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),
                  // Bouton de connexion
                  CustomButton(
                    text: 'Se connecter',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                    icon: Icons.arrow_forward_rounded,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}