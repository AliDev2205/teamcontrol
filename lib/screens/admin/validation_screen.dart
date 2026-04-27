import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/member_model.dart';

class ValidationScreen extends StatefulWidget {
  const ValidationScreen({super.key});

  @override
  State<ValidationScreen> createState() => _ValidationScreenState();
}

class _ValidationScreenState extends State<ValidationScreen> {
  List<dynamic> _pendingValidations = [];
  bool _isLoading = true;
  Member? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _currentUser = await AuthService.getCurrentUser();
    if (_currentUser != null) {
      _loadPendingValidations();
    }
  }

  Future<void> _loadPendingValidations() async {
    setState(() => _isLoading = true);
    try {
      final validations = await ApiService.getPendingValidations(_currentUser!.id);
      setState(() {
        _pendingValidations = validations;
      });
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _validateProgress(int progressId, String status, String comment) async {
    try {
      final result = await ApiService.validateProgress(
        progressId: progressId,
        adminId: _currentUser!.id,
        status: status,
        comment: comment,
      );

      if (result['success'] == true) {
        _showSuccessSnackBar(status == 'approved' ? 'Progression approuvée' : 'Progression rejetée');
        _loadPendingValidations();
      } else {
        _showErrorSnackBar(result['message'] ?? 'Erreur lors de la validation');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
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
      ),
    );
  }

  void _showValidationDialog(Map<String, dynamic> validation) {
    showDialog(
      context: context,
      builder: (context) => ValidationDialog(
        validation: validation,
        onValidate: _validateProgress,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validations en attente'),
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.textPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppConstants.primaryColor),
            onPressed: _loadPendingValidations,
            tooltip: 'Actualiser',
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
                    'Chargement des validations...',
                    style: AppConstants.captionStyle,
                  ),
                ],
              ),
            )
          : _pendingValidations.isEmpty
              ? _buildEmptyState()
              : _buildValidationsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 80,
              color: AppConstants.textSecondaryColor.withOpacity(0.4),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucune validation en attente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Toutes les mises à jour des membres ont été validées',
              style: AppConstants.captionStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationsList() {
    return Column(
      children: [
        // En-tête avec compteur
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_pendingValidations.length} validation(s) en attente',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'À traiter',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Liste des validations
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadPendingValidations,
            backgroundColor: Colors.white,
            color: AppConstants.primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingValidations.length,
              itemBuilder: (context, index) {
                final validation = _pendingValidations[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: _buildValidationCard(validation),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValidationCard(Map<String, dynamic> validation) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showValidationDialog(validation),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icône de statut
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.update_rounded,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      validation['project_title'] ?? 'Projet sans titre',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      validation['member_name'] ?? 'Membre inconnu',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        validation['update_text'] ?? 'Aucune description',
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Indicateur d'action
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppConstants.textSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ValidationDialog extends StatefulWidget {
  final Map<String, dynamic> validation;
  final Function(int, String, String) onValidate;

  const ValidationDialog({
    super.key,
    required this.validation,
    required this.onValidate,
  });

  @override
  State<ValidationDialog> createState() => _ValidationDialogState();
}

class _ValidationDialogState extends State<ValidationDialog> {
  final TextEditingController _commentController = TextEditingController();
  String _selectedStatus = 'approved';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user_rounded,
                    color: AppConstants.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Valider la progression',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Informations du projet
            _buildInfoRow('Projet', widget.validation['project_title'] ?? 'Non spécifié'),
            _buildInfoRow('Membre', widget.validation['member_name'] ?? 'Non spécifié'),
            
            const SizedBox(height: 16),

            // Mise à jour
            const Text(
              'Mise à jour du membre:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                widget.validation['update_text'] ?? 'Aucune description fournie',
                style: const TextStyle(fontSize: 13),
              ),
            ),

            const SizedBox(height: 20),

            // Statut
            const Text(
              'Décision:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: DropdownButton<String>(
                value: _selectedStatus,
                isExpanded: true,
                underline: const SizedBox(),
                icon: Icon(Icons.arrow_drop_down_rounded, color: AppConstants.primaryColor),
                items: const [
                  DropdownMenuItem(
                    value: 'approved',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                        SizedBox(width: 8),
                        Text('Approuver la progression'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'rejected',
                    child: Row(
                      children: [
                        Icon(Icons.cancel_rounded, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('Rejeter la progression'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // Commentaire
            const Text(
              'Commentaire (optionnel):',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ajoutez un commentaire pour le membre...',
                hintStyle: TextStyle(color: AppConstants.textSecondaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onValidate(
                        widget.validation['progress_id'],
                        _selectedStatus,
                        _commentController.text.trim(),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedStatus == 'approved' 
                          ? AppConstants.successColor 
                          : AppConstants.errorColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(_selectedStatus == 'approved' ? 'Approuver' : 'Rejeter'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}