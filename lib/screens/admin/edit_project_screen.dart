import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../models/project_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class EditProjectScreen extends StatefulWidget {
  final Project project;
  const EditProjectScreen({super.key, required this.project});

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  String _status = 'pending';
  bool _isSaving = false;
  bool _isDeleting = false;
  int? _adminId;

  @override
  void initState() {
    super.initState();
    _prefill();
    _loadAdmin();
  }

  Future<void> _loadAdmin() async {
    final user = await AuthService.getCurrentUser();
    _adminId = user?.id;
  }

  void _prefill() {
    _titleController.text = widget.project.title;
    _descriptionController.text = widget.project.description ?? '';
    _startDateController.text = widget.project.startDate != null
        ? _formatIso(widget.project.startDate!)
        : '';
    _endDateController.text = widget.project.endDate != null
        ? _formatIso(widget.project.endDate!)
        : '';
    _status = widget.project.status;
  }

  String _formatIso(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final body = {
        'project_id': widget.project.id,
        if (_titleController.text.trim() != widget.project.title)
          'title': _titleController.text.trim(),
        if ((_descriptionController.text.trim()) !=
            (widget.project.description ?? ''))
          'description': _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        if (_startDateController.text !=
            (widget.project.startDate != null
                ? _formatIso(widget.project.startDate!)
                : ''))
          'start_date': _startDateController.text.isEmpty
              ? null
              : _startDateController.text,
        if (_endDateController.text !=
            (widget.project.endDate != null
                ? _formatIso(widget.project.endDate!)
                : ''))
          'end_date': _endDateController.text.isEmpty
              ? null
              : _endDateController.text,
        if (_status != widget.project.status) 'status': _status,
        if (_adminId != null) 'admin_id': _adminId,
      };

      final res = await ApiService.updateProject(body);
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Projet mis à jour'),
            backgroundColor: AppConstants.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (mounted) Navigator.pop(context, true);
      } else {
        _showError(res['message'] ?? 'Erreur lors de la mise à jour');
      }
    } catch (e) {
      _showError('Erreur: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmDelete() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le projet'),
        content: const Text(
            'Cette action supprimera le projet, ses phases et affectations. Continuer ?'),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.errorColor,
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _delete();
                  },
                  child: const Text('Supprimer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _delete() async {
    setState(() => _isDeleting = true);
    try {
      final res = await ApiService.deleteProject(
        projectId: widget.project.id,
        adminId: _adminId ?? 0,
      );
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Projet supprimé'),
            backgroundColor: AppConstants.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (mounted) Navigator.pop(context, true);
      } else {
        _showError(res['message'] ?? 'Erreur lors de la suppression');
      }
    } catch (e) {
      _showError('Erreur: $e');
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _showError(String m) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le projet'),
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.textPrimaryColor,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Supprimer',
            icon: Icon(Icons.delete_outline, color: AppConstants.errorColor),
            onPressed: _isDeleting ? null : _confirmDelete,
          ),
          IconButton(
            tooltip: 'Enregistrer',
            icon: Icon(Icons.save_rounded, color: AppConstants.primaryColor),
            onPressed: _isSaving ? null : _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildText('Titre *', controller: _titleController, required: true),
              const SizedBox(height: 12),
              _buildText('Description', controller: _descriptionController, maxLines: 3),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDate('Date de début', _startDateController),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDate('Date de fin', _endDateController),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildStatusPicker(),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer les modifications'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isDeleting ? null : _confirmDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Supprimer le projet'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppConstants.errorColor,
                  side: BorderSide(color: AppConstants.errorColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildText(String label,
      {required TextEditingController controller, int maxLines = 1, bool required = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null
          : null,
    );
  }

  Widget _buildDate(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onTap: () async {
        final initial = controller.text.isNotEmpty
            ? DateTime.tryParse(controller.text) ?? DateTime.now()
            : DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );
        if (picked != null) {
          controller.text = _formatIso(picked);
        }
      },
    );
  }

  Widget _buildStatusPicker() {
    const statuses = ['pending', 'in_progress', 'testing', 'revision', 'completed'];
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Statut',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _status,
          isExpanded: true,
          items: statuses
              .map((s) => DropdownMenuItem(value: s, child: Text(_statusLabel(s))))
              .toList(),
          onChanged: (v) => setState(() => _status = v!),
        ),
      ),
    );
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'pending':
        return 'En attente';
      case 'in_progress':
        return 'En cours';
      case 'testing':
        return 'En test';
      case 'revision':
        return 'Mise à jour';
      case 'completed':
        return 'Terminé';
      default:
        return s;
    }
  }
}

