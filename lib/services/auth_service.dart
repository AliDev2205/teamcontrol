import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/member_model.dart';
import 'api_service.dart';

/// Service d'authentification
/// Gère la connexion, déconnexion et stockage des données utilisateur
class AuthService {
  // Clés pour SharedPreferences
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserData = 'userData';

  /// Connexion
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final result = await ApiService.login(email, password);

    if (result['success'] == true) {
      // Sauvegarder les données de l'utilisateur
      await _saveUserData(result['data']);
      return {
        'success': true,
        'message': result['message'],
        'user': Member.fromJson(result['data']),
      };
    } else {
      return result;
    }
  }

  /// Déconnexion
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserData);
  }

  /// Vérifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Récupérer les données de l'utilisateur connecté
  static Future<Member?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_keyUserData);

    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      return Member.fromJson(userData);
    }
    return null;
  }

  /// Sauvegarder les données utilisateur
  static Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserData, jsonEncode(userData));
  }

  /// Mettre à jour les données utilisateur (après modification profil)
  static Future<void> updateUserData(Member member) async {
    await _saveUserData(member.toJson());
  }

  /// Vérifier si l'utilisateur connecté est admin
  static Future<bool> isAdmin() async {
    final user = await getCurrentUser();
    return user?.isAdmin ?? false;
  }

  /// Récupérer l'ID de l'utilisateur connecté
  static Future<int?> getCurrentUserId() async {
    final user = await getCurrentUser();
    return user?.id;
  }

  /// Récupérer le rôle de l'utilisateur connecté
  static Future<String?> getCurrentUserRole() async {
    final user = await getCurrentUser();
    return user?.role;
  }
}