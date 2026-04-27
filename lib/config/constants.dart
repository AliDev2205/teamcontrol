import 'package:flutter/material.dart';

/// Configuration générale de l'application Arnos Tech
class AppConstants {
  // ========== URLs API ==========
  //Change cette URL selon ton serveur local ou distant
  //static const String baseUrl = 'http://192.168.100.135/projetflutter/arnos_tech/apis/api';
  static const String baseUrl = 'https://arnostech.bj/lesapis/teamControl';
///static const String baseUrl = 'http://192.168.100.135/projetflutter/arnos_tech/apis/api';
  // Endpoints Auth
  static const String loginUrl = '$baseUrl/auth/login.php';
  static const String registerUrl = '$baseUrl/auth/register.php';

  // Endpoints Admin
  static const String getAllMembersUrl = '$baseUrl/admin/get_all_members.php';
  static const String updateMemberUrl = '$baseUrl/admin/update_member.php';
  static const String deleteMemberUrl = '$baseUrl/admin/delete_member.php';
  static const String toggleMemberStatusUrl = '$baseUrl/admin/toggle_member_status.php';
  static const String assignProjectUrl = '$baseUrl/admin/assign_project.php';
  static const String getAllProjectsUrl = '$baseUrl/admin/get_all_projects.php';
  static const String updateProjectUrl = '$baseUrl/admin/update_project.php';
  static const String deleteProjectUrl = '$baseUrl/admin/delete_project.php';
  static const String validateProgressUrl = '$baseUrl/admin/validate_progress.php';
  static const String getPendingValidationsUrl = '$baseUrl/admin/get_pending_validations.php';


  // Endpoints Member
  static const String getMemberProjectsUrl = '$baseUrl/member/get_projects.php';
  static const String addProgressUrl = '$baseUrl/member/add_progress.php';
  static const String getProgressUrl = '$baseUrl/member/get_progress.php';
  static const String markProjectDoneUrl = '$baseUrl/member/mark_project_done.php';
  static const String updateProfileUrl = '$baseUrl/member/update_profile.php';

  // Phases de projet
static const String getProjectPhasesUrl = '$baseUrl/member/get_phases.php';
static const String updatePhaseStatusUrl = '$baseUrl/member/update_phase_status.php';

// Notifications
static const String getNotificationsUrl = '$baseUrl/notifications/get_notifications.php';
static const String markNotificationReadUrl = '$baseUrl/notifications/mark_read.php';

// Historique d'activité
static const String getActivityLogsUrl = '$baseUrl/activity/get_activity_logs.php';
  // ========== Couleurs Arnos Tech ==========
  // Palette moderne et technologique
  static const Color primaryColor = Color(0xFF007BFF);      // Bleu électrique
  static const Color secondaryColor = Color(0xFF2C2C2C);    // Gris anthracite
  static const Color accentColor = Color(0xFF00D4FF);       // Cyan lumineux
  static const Color successColor = Color(0xFF28A745);      // Vert
  static const Color errorColor = Color(0xFFDC3545);        // Rouge
  static const Color backgroundColor = Color(0xFFF5F5F5);   // Fond clair
  static const Color cardColor = Color(0xFFFFFFFF);         // Blanc
  static const Color textPrimaryColor = Color(0xFF2C2C2C);  // Texte principal
  static const Color textSecondaryColor = Color(0xFF6C757D); // Texte secondaire

  // ========== Styles de texte ==========
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle subHeadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: textPrimaryColor,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    color: textSecondaryColor,
  );

  // ========== Espacements ==========
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double borderRadius = 12.0;
  static const double buttonHeight = 50.0;

  // ========== Messages ==========
  static const String appName = 'Arnos Tech';
  static const String tagline = 'Gestion de projets innovants';

  // Messages d'erreur
  static const String errorNetwork = 'Erreur de connexion. Vérifiez votre internet.';
  static const String errorServer = 'Erreur serveur. Réessayez plus tard.';
  static const String errorUnknown = 'Une erreur est survenue.';
}

/// Thème de l'application
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: AppConstants.primaryColor,
    scaffoldBackgroundColor: AppConstants.backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: AppConstants.primaryColor,
      secondary: AppConstants.accentColor,
      error: AppConstants.errorColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppConstants.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppConstants.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: AppConstants.errorColor, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingMedium,
      ),
    ),
  );
}