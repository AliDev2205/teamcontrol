import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../models/member_model.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/member/edit_profile_screen.dart';

/// Drawer (barre latérale) pour l'admin - Version simplifiée
class AdminDrawer extends StatelessWidget {
  final Member? currentUser;
  final GlobalKey<NavigatorState>? navigatorKey;

  const AdminDrawer({super.key, this.currentUser, this.navigatorKey});

  Future<void> _handleLogout(BuildContext context) async {
    // Afficher une boîte de dialogue de confirmation moderne
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône d'alerte
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppConstants.errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: AppConstants.errorColor,
                  size: 30,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Titre
              const Text(
                'Déconnexion',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Message
              Text(
                'Êtes-vous sûr de vouloir vous déconnecter ?',
                style: TextStyle(
                  fontSize: 14,
                  color: AppConstants.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.textPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.errorColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Déconnexion'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      // Fermer le drawer d'abord
      Navigator.of(context).pop();

      // Attendre un peu pour que l'animation du drawer se termine
      await Future.delayed(const Duration(milliseconds: 300));

      // Déconnexion
      await AuthService.logout();

      // Navigation vers l'écran de connexion
      _navigateToLogin(context);
    }
  }

  void _navigateToLogin(BuildContext context) {
    if (navigatorKey != null && navigatorKey!.currentState != null) {
      navigatorKey!.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280, // Largeur fixe pour un look plus moderne
      child: Column(
        children: [
          // En-tête personnalisé moderne
          _buildModernHeader(),
          
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),
                
                _buildMenuItem(
                  icon: Icons.dashboard_rounded,
                  title: 'Tableau de bord',
                  color: AppConstants.primaryColor,
                  onTap: () {
                    Navigator.pop(context); // Fermer le drawer
                    // Le dashboard est déjà ouvert, donc on ne navigue pas
                  },
                ),
                
                _buildMenuItem(
                  icon: Icons.person_rounded,
                  title: 'Mon profil',
                  color: AppConstants.accentColor,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Divider(height: 1),
                ),
                
                _buildMenuItem(
                  icon: Icons.logout_rounded,
                  title: 'Déconnexion',
                  color: AppConstants.errorColor,
                  onTap: () => _handleLogout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 24, left: 20, right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.primaryColor,
            AppConstants.primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar simple sans badge
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: currentUser?.photo != null
                ? ClipOval(
                    child: Image.network(
                      currentUser!.photo!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          _buildUserInitial(),
                    ),
                  )
                : _buildUserInitial(),
          ),
          
          const SizedBox(height: 16),
          
          // Informations utilisateur
          Text(
            currentUser?.fullName ?? 'Utilisateur',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),
          
          Text(
            currentUser?.email ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),
          
          if (currentUser?.position != null)
            Text(
              currentUser!.position!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white60,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserInitial() {
    return Center(
      child: Text(
        currentUser?.firstName[0].toUpperCase() ?? 'U',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppConstants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: AppConstants.textSecondaryColor,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        onTap: onTap,
      ),
    );
  }
}