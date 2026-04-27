import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/member_model.dart';

class ProgressUpdateScreen extends StatefulWidget {
  final int projectId;
  final String projectTitle;

  const ProgressUpdateScreen({
    super.key,
    required this.projectId,
    required this.projectTitle,
  });

  @override
  State<ProgressUpdateScreen> createState() => _ProgressUpdateScreenState();
}

class _ProgressUpdateScreenState extends State<ProgressUpdateScreen> {
  final TextEditingController _updateController = TextEditingController();
  final TextEditingController _finalCommentController = TextEditingController();
  bool _isLoading = false;
  bool _markAsFinal = false;
  Member? _currentUser;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _checkIfAdmin();
  }

  Future<void> _loadCurrentUser() async {
    _currentUser = await AuthService.getCurrentUser();
    _isAdmin = _currentUser?.isAdmin ?? false;
    setState(() {});
  }

  Future<void> _checkIfAdmin() async {
    final user = await AuthService.getCurrentUser();
    if (user?.isAdmin ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Les administrateurs ne peuvent pas ajouter de mises à jour'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      });
    }
  }

  Future<void> _submitProgress() async {
    if (!_markAsFinal && _updateController.text.trim().isEmpty) {
      _showErrorSnackBar('Veuillez saisir une mise à jour');
      return;
    }

    if (_markAsFinal && _finalCommentController.text.trim().isEmpty) {
      _showErrorSnackBar('Veuillez saisir un commentaire de clôture');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_currentUser?.id == null) {
        _showErrorSnackBar('Erreur: Impossible d\'identifier l\'utilisateur');
        return;
      }

      if (_markAsFinal) {
        // Si c'est une mise à jour finale, appeler uniquement markProjectDone
        final result = await ApiService.markProjectDone(
          widget.projectId,
          _currentUser!.id,
          _finalCommentController.text.trim(),
        );

        if (result['success'] == true) {
          _showSuccessSnackBar('Projet marqué comme terminé avec succès');
          Navigator.pop(context, true);
        } else {
          _showErrorSnackBar(result['message'] ?? 'Erreur lors de la finalisation du projet');
        }
      } else {
        // Sinon, faire une mise à jour normale
        Map<String, dynamic> progressData = {
          'project_id': widget.projectId,
          'member_id': _currentUser!.id,
          'update_text': _updateController.text.trim(),
          'is_final': false,
        };

        final result = await ApiService.addProgress(progressData);

        if (result['success'] == true) {
          _showSuccessSnackBar('Mise à jour enregistrée avec succès');
          Navigator.pop(context, true);
        } else {
          _showErrorSnackBar(result['message'] ?? 'Erreur lors de l\'enregistrement');
        }
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Accès refusé'),
          backgroundColor: Colors.white,
          foregroundColor: AppConstants.textPrimaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppConstants.errorColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.block_rounded,
                    size: 40,
                    color: AppConstants.errorColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Accès non autorisé',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Les administrateurs ne peuvent pas ajouter de mises à jour de progression.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppConstants.textSecondaryColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Retour'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle mise à jour'),
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.textPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête du projet
            _buildProjectHeader(),

            const SizedBox(height: 24),

            // Formulaire de mise à jour
            _buildUpdateForm(),

            const SizedBox(height: 24),

            // Conseils
            _buildTipsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectHeader() {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.update_rounded,
              color: AppConstants.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.projectTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ajoutez une mise à jour sur l\'avancement du projet',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateForm() {
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
          Text(
            'Détails de la mise à jour',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppConstants.textPrimaryColor,
            ),
          ),

          const SizedBox(height: 20),

          // Champ de description
          TextFormField(
            controller: _updateController,
            maxLines: 6,
            enabled: !_markAsFinal,
            decoration: InputDecoration(
              labelText: 'Description de la mise à jour',
              hintText: _markAsFinal 
                  ? 'La description est verrouillée pour les mises à jour finales'
                  : 'Décrivez ce qui a été accompli, les problèmes rencontrés, les prochaines étapes...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
              ),
              filled: _markAsFinal,
              fillColor: _markAsFinal ? Colors.grey.shade100 : Colors.grey.shade50,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),

          const SizedBox(height: 20),

          // Switch pour mise à jour finale
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _markAsFinal 
                  ? AppConstants.successColor.withOpacity(0.05)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _markAsFinal 
                    ? AppConstants.successColor.withOpacity(0.3)
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _markAsFinal ? Icons.flag_rounded : Icons.flag_outlined,
                  color: _markAsFinal ? AppConstants.successColor : AppConstants.textSecondaryColor,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Marquer comme mise à jour finale',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _markAsFinal ? AppConstants.successColor : AppConstants.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cette mise à jour clôturera le projet',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _markAsFinal,
                  onChanged: (value) {
                    setState(() {
                      _markAsFinal = value;
                    });
                  },
                  activeColor: AppConstants.successColor,
                ),
              ],
            ),
          ),

          // Section commentaire final
          if (_markAsFinal) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.successColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppConstants.successColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppConstants.successColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Clôture du projet',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppConstants.successColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _finalCommentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Résumé final du projet',
                      hintText: 'Livrables accomplis, résultats obtenus, remarques finales...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppConstants.successColor, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Note: Une fois clôturé, le projet ne pourra plus être modifié.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppConstants.successColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Bouton de soumission
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitProgress,
              style: ElevatedButton.styleFrom(
                backgroundColor: _markAsFinal 
                    ? AppConstants.successColor 
                    : AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: (_markAsFinal ? AppConstants.successColor : AppConstants.primaryColor).withOpacity(0.3),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _markAsFinal ? Icons.flag_rounded : Icons.update_rounded,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _markAsFinal ? 'CLÔTURER LE PROJET' : 'ENREGISTRER LA MISE À JOUR',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppConstants.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  color: AppConstants.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Conseils pour une bonne mise à jour',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem('Soyez précis et concret dans vos descriptions'),
          _buildTipItem('Mentionnez les pourcentages d\'avancement'),
          _buildTipItem('Notez les problèmes rencontrés et leurs solutions'),
          _buildTipItem('Décrivez les prochaines étapes prévues'),
          if (_markAsFinal)
            _buildTipItem('Une fois clôturé, le projet ne pourra plus être modifié'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: AppConstants.successColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppConstants.textSecondaryColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _updateController.dispose();
    _finalCommentController.dispose();
    super.dispose();
  }
}