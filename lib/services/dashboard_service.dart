// lib/services/dashboard_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/dashboard_stats_model.dart';

class DashboardService {
  static Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/admin/dashboard_stats.php'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        return DashboardStats.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Erreur lors de la récupération des statistiques');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}