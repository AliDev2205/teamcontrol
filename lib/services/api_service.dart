import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/member_model.dart';
import '../models/project_model.dart';
import '../models/progress_model.dart';
import '../models/project_phase_model.dart';
import '../services/auth_service.dart';

/// Service API pour toutes les requêtes HTTP
class ApiService {
  /// Headers par défaut pour toutes les requêtes
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
      };

  // ==================== AUTH ====================

  /// Login avec meilleure gestion d'erreur
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('🔄 Tentative de connexion vers: ${AppConstants.loginUrl}');
      
      final response = await http.post(
        Uri.parse(AppConstants.loginUrl),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Timeout - Serveur non accessible'),
      );

      print('📡 Réponse reçue - Status: ${response.statusCode}');
      print('📦 Corps de la réponse: ${response.body}');

      // Vérifier si la réponse est du JSON valide
      if (response.body.trim().isEmpty) {
        throw Exception('Réponse vide du serveur');
      }

      // Vérifier si c'est du HTML (erreur)
      if (response.body.contains('<!DOCTYPE') || response.body.contains('<html')) {
        throw Exception('Le serveur renvoie du HTML au lieu de JSON. Vérifiez l\'URL de l\'API.');
      }

      final data = jsonDecode(response.body);
      return data;
      
    } on FormatException catch (e) {
      print('❌ Erreur JSON: $e');
      return {
        'success': false,
        'message': 'Erreur de format de données. Le serveur ne renvoie pas du JSON valide.',
      };
    } catch (e) {
      print('❌ Erreur de connexion: $e');
      return {
        'success': false,
        'message': 'Impossible de se connecter au serveur. Vérifiez votre connexion internet et l\'URL de l\'API.',
      };
    }
  }

  /// Inscription (Register)
  static Future<Map<String, dynamic>> register(Map<String, dynamic> memberData) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.registerUrl),
        headers: _headers,
        body: jsonEncode(memberData),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de l\'inscription: $e',
      };
    }
  }

  // ==================== ADMIN - MEMBERS ====================

  /// Récupérer tous les membres
  static Future<List<Member>> getAllMembers() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.getAllMembersUrl),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        List<Member> members = [];
        for (var memberJson in data['data']) {
          members.add(Member.fromJson(memberJson));
        }
        return members;
      } else {
        throw Exception(data['message'] ?? 'Erreur lors de la récupération');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Mettre à jour un membre (admin)
  static Future<Map<String, dynamic>> updateMember(
      Map<String, dynamic> memberData) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.updateMemberUrl),
        headers: _headers,
        body: jsonEncode(memberData),
      );
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la mise à jour du membre: $e',
      };
    }
  }

  /// Supprimer un membre (admin)
  static Future<Map<String, dynamic>> deleteMember(int memberId) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.deleteMemberUrl),
        headers: _headers,
        body: jsonEncode({'member_id': memberId}),
      );
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la suppression: $e',
      };
    }
  }

  /// Activer/Désactiver un membre (admin)
  static Future<Map<String, dynamic>> toggleMemberStatus(
      {required int memberId, required String status}) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.toggleMemberStatusUrl),
        headers: _headers,
        body: jsonEncode({'member_id': memberId, 'status': status}),
      );
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors du changement de statut: $e',
      };
    }
  }

  /// Ajouter un membre (utilise register)
  static Future<Map<String, dynamic>> addMember(
      Map<String, dynamic> memberData) async {
    return await register(memberData);
  }

  // ==================== ADMIN - PROJECTS ====================

  /// Récupérer tous les projets
  static Future<List<Project>> getAllProjects() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.getAllProjectsUrl),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        List<Project> projects = [];
        for (var projectJson in data['data']) {
          projects.add(Project.fromJson(projectJson));
        }
        return projects;
      } else {
        throw Exception(data['message'] ?? 'Erreur lors de la récupération');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Assigner un projet à un membre
  static Future<Map<String, dynamic>> assignProject(
      Map<String, dynamic> projectData) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.assignProjectUrl),
        headers: _headers,
        body: jsonEncode(projectData),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de l\'assignation: $e',
      };
    }
  }

  /// Mettre à jour un projet (admin)
  static Future<Map<String, dynamic>> updateProject(
      Map<String, dynamic> projectData) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.updateProjectUrl),
        headers: _headers,
        body: jsonEncode(projectData),
      );
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la mise à jour du projet: $e',
      };
    }
  }

  /// Supprimer un projet (admin)
  static Future<Map<String, dynamic>> deleteProject(
      {required int projectId, required int adminId}) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.deleteProjectUrl),
        headers: _headers,
        body: jsonEncode({
          'project_id': projectId,
          'admin_id': adminId,
        }),
      );
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la suppression du projet: $e',
      };
    }
  }

  // ==================== MEMBER - PROJECTS ====================

  /// Récupérer les projets d'un membre
  static Future<List<Project>> getMemberProjects(int memberId) async {
    try {
      print('🔄 Chargement projets pour membre: $memberId');
      
      final response = await http.get(
        Uri.parse('${AppConstants.getMemberProjectsUrl}?member_id=$memberId'),
        headers: _headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Timeout lors du chargement des projets'),
      );

      print('📡 Réponse projets - Status: ${response.statusCode}');

      // Vérifier si la réponse est vide
      if (response.body.trim().isEmpty) {
        throw Exception('Réponse vide du serveur pour les projets');
      }

      // Vérifier si c'est du HTML (erreur PHP)
      if (response.body.contains('<!DOCTYPE') || 
          response.body.contains('<html') || 
          response.body.contains('<br />') ||
          response.body.contains('Parse error') ||
          response.body.contains('Fatal error')) {
        throw Exception('Le serveur renvoie du HTML/erreur PHP au lieu de JSON. Vérifiez le fichier get_projects.php');
      }

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        List<Project> projects = [];
        for (var projectJson in data['data']) {
          projects.add(Project.fromJson(projectJson));
        }
        print('✅ Projets chargés: ${projects.length}');
        return projects;
      } else {
        throw Exception(data['message'] ?? 'Erreur lors de la récupération des projets');
      }
    } on FormatException catch (e) {
      print('❌ Erreur JSON projets: $e');
      throw Exception('Erreur de format JSON pour les projets');
    } catch (e) {
      print('❌ Erreur getMemberProjects: $e');
      throw Exception('Erreur lors du chargement des projets: $e');
    }
  }

  // ==================== MEMBER - PROGRESS ====================

  /// Ajouter une mise à jour de progrès
  static Future<Map<String, dynamic>> addProgress(
      Map<String, dynamic> progressData) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.addProgressUrl),
        headers: _headers,
        body: jsonEncode(progressData),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de l\'ajout: $e',
      };
    }
  }

  /// Récupérer l'historique des progrès d'un projet
  static Future<List<Progress>> getProgress(int projectId) async {
    http.Response? response;
    try {
      response = await http.get(
        Uri.parse('${AppConstants.getProgressUrl}?project_id=$projectId'),
        headers: _headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Timeout lors du chargement des progrès'),
      );

      // Journalisation utile au debug
      print('📡 Réponse progrès - Status: ${response.statusCode}');
      // Limiter l'affichage du corps si très long
      final bodyPreview = response.body.length > 200
          ? response.body.substring(0, 200) + '...'
          : response.body;
      print('📦 Corps progrès: $bodyPreview');

      // Vérifier si la réponse est vide
      if (response.body.trim().isEmpty) {
        throw Exception('Réponse vide du serveur pour les progrès');
      }

      // Vérifier si c'est du HTML ou une erreur PHP, typique quand un script renvoie une page
      if (response.body.contains('<!DOCTYPE') ||
          response.body.contains('<html') ||
          response.body.contains('<br />') ||
          response.body.contains('Parse error') ||
          response.body.contains('Fatal error') ||
          response.body.contains('Warning:') ||
          response.body.contains('Notice:')) {
        throw Exception('Le serveur renvoie du HTML/erreur PHP au lieu de JSON. Vérifiez le fichier get_progress.php');
      }

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        List<Progress> progressList = [];
        for (var progressJson in data['data']) {
          progressList.add(Progress.fromJson(progressJson));
        }
        return progressList;
      } else {
        throw Exception(data['message'] ?? 'Erreur lors de la récupération des progrès');
      }
    } on FormatException catch (e) {
      // jsonDecode a échoué: donner un message clair avec un aperçu
      final preview = response?.body != null && response!.body.isNotEmpty
          ? (response.body.length > 100
              ? response.body.substring(0, 100) + '...'
              : response.body)
          : 'Réponse vide';
      print('❌ Erreur JSON progrès: $e');
      throw Exception('Erreur de format JSON pour les progrès. Le serveur a retourné: $preview');
    } catch (e) {
      throw Exception('Erreur lors du chargement des progrès: $e');
    }
  }

  /// Marquer un projet comme terminé
  static Future<Map<String, dynamic>> markProjectDone(
      int projectId, int memberId, String finalComment) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.markProjectDoneUrl),
        headers: _headers,
        body: jsonEncode({
          'project_id': projectId,
          'member_id': memberId,
          'final_comment': finalComment,
        }),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la finalisation: $e',
      };
    }
  }

  /// Mettre à jour le profil
  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> profileData) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.updateProfileUrl),
        headers: _headers,
        body: jsonEncode(profileData),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la mise à jour: $e',
      };
    }
  }

  // ==================== ADMIN - PROJECT PHASES ====================
  
  static Future<Map<String, dynamic>> createProjectWithPhases(
      Map<String, dynamic> projectData) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/admin/create_project_with_phases.php'),
        headers: _headers,
        body: jsonEncode(projectData),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la création du projet: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> assignMultipleMembers(
      Map<String, dynamic> assignData) async {
    try {
      print('🔄 Tentative d\'assignation multiple');
      print('📦 Données: $assignData');
      
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/admin/assign_multiple_members.php'),
        headers: _headers,
        body: jsonEncode(assignData),
      ).timeout(const Duration(seconds: 30));

      print('📡 Réponse - Status: ${response.statusCode}');
      print('📦 Corps: ${response.body}');

      // Vérifier si c'est une erreur HTML
      if (response.body.trim().isEmpty) {
        throw Exception('Réponse vide du serveur');
      }
      
      if (response.body.contains('<!DOCTYPE') || 
          response.body.contains('<html') || 
          response.body.contains('<br />')) {
        throw Exception('Le serveur renvoie du HTML. Vérifiez l\'endpoint PHP.');
      }

      final data = jsonDecode(response.body);
      return data;
      
    } on FormatException catch (e) {
      print('❌ Erreur JSON: $e');
      return {
        'success': false,
        'message': 'Erreur de format de données du serveur',
      };
    } catch (e) {
      print('❌ Erreur d\'assignation: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  /// Récupérer les phases d'un projet
  static Future<List<ProjectPhase>> getProjectPhases(int projectId) async {
    http.Response? response;
    try {
      print('🔄 Chargement phases pour projet: $projectId');
      
      response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/member/get_phases.php?project_id=$projectId'),
        headers: _headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Timeout lors du chargement des phases'),
      );

      print('📡 Réponse phases - Status: ${response.statusCode}');
      print('📦 Corps phases: ${response.body}');

      // Vérifier si la réponse est vide
      if (response.body.trim().isEmpty) {
        throw Exception('Réponse vide du serveur pour les phases');
      }

      // Vérifier si c'est du HTML (erreur PHP)
      if (response.body.contains('<!DOCTYPE') || 
          response.body.contains('<html') || 
          response.body.contains('<br />') ||
          response.body.contains('Parse error') ||
          response.body.contains('Fatal error') ||
          response.body.contains('Warning:') ||
          response.body.contains('Notice:')) {
        throw Exception('Le serveur renvoie du HTML/erreur PHP au lieu de JSON. Vérifiez le fichier get_phases.php');
      }

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        List<ProjectPhase> phases = [];
        for (var phaseJson in data['data']) {
          phases.add(ProjectPhase.fromJson(phaseJson));
        }
        print('✅ Phases chargées: ${phases.length}');
        return phases;
      } else {
        throw Exception(data['message'] ?? 'Erreur lors de la récupération des phases');
      }
    } on FormatException catch (e) {
      print('❌ Erreur JSON phases: $e');
      final bodyPreview = response?.body != null && response!.body.isNotEmpty 
          ? (response.body.length > 100 ? response.body.substring(0, 100) + "..." : response.body)
          : 'Réponse vide';
      throw Exception('Erreur de format JSON. Le serveur a retourné: $bodyPreview');
    } catch (e) {
      print('❌ Erreur getProjectPhases: $e');
      throw Exception('Erreur lors du chargement des phases: $e');
    }
  }

  /// Mettre à jour le statut d'une phase
  static Future<Map<String, dynamic>> updatePhaseStatus(
      int phaseId, String status) async {
    try {
      // Récupérer l'utilisateur connecté
    final currentUser = await AuthService.getCurrentUser();
      final response = await http.post(
        Uri.parse(AppConstants.updatePhaseStatusUrl),
        headers: _headers,
        body: jsonEncode({
          'phase_id': phaseId,
          'status': status,
          'member_id': currentUser?.id,
        }),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la mise à jour: $e',
      };
    }
  }

  /// Récupérer les notifications d'un membre
  static Future<List<dynamic>> getNotifications(int memberId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.getNotificationsUrl}?member_id=$memberId'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Erreur lors de la récupération');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Marquer une notification comme lue
  static Future<Map<String, dynamic>> markNotificationRead(int notificationId) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.markNotificationReadUrl),
        headers: _headers,
        body: jsonEncode({
          'notification_id': notificationId,
        }),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la mise à jour: $e',
      };
    }
  }

  /// Récupérer les logs d'activité
  static Future<List<dynamic>> getActivityLogs({int? projectId, int? memberId}) async {
    try {
      String url = AppConstants.getActivityLogsUrl;
      List<String> params = [];
      
      if (projectId != null) params.add('project_id=$projectId');
      if (memberId != null) params.add('member_id=$memberId');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Erreur lors de la récupération');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Ajouter ces méthodes dans ApiService
static Future<List<dynamic>> getPendingValidations([int? adminId]) async {
  try {
    String url = '${AppConstants.baseUrl}/admin/get_pending_validations.php';
    if (adminId != null) {
      url += '?admin_id=$adminId';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: _headers,
    );

    final data = jsonDecode(response.body);

    if (data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Erreur lors de la récupération');
    }
  } catch (e) {
    throw Exception('Erreur: $e');
  }
}

static Future<Map<String, dynamic>> validateProgress({
  required int progressId,
  required int adminId,
  required String status,
  String comment = '',
}) async {
  try {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/admin/validate_progress.php'),
      headers: _headers,
      body: jsonEncode({
        'progress_id': progressId,
        'admin_id': adminId,
        'validation_status': status,
        'admin_comment': comment,
      }),
    );

    final data = jsonDecode(response.body);
    return data;
  } catch (e) {
    return {
      'success': false,
      'message': 'Erreur lors de la validation: $e',
    };
  }
}
}