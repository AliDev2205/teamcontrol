import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../models/member_model.dart';
import '../../services/api_service.dart';

class ManageMembersScreen extends StatefulWidget {
  const ManageMembersScreen({super.key});

  @override
  State<ManageMembersScreen> createState() => _ManageMembersScreenState();
}

class _ManageMembersScreenState extends State<ManageMembersScreen> {
  List<Member> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await ApiService.getAllMembers();
      setState(() => _members = list);
    } catch (e) {
      _error('Erreur: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _error(String m) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: AppConstants.errorColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les membres'),
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.textPrimaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _members.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final m = _members[i];
                return ListTile(
                  leading: CircleAvatar(child: Text(m.firstName[0].toUpperCase())),
                  title: Text(m.fullName),
                  subtitle: Text('${m.email} • ${m.role.toUpperCase()} • ${m.status}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _openEdit(m);
                      if (v == 'deactivate') _toggleStatus(m, 'inactive');
                      if (v == 'activate') _toggleStatus(m, 'active');
                      if (v == 'delete') _confirmDelete(m);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                      if (m.status == 'active')
                        const PopupMenuItem(value: 'deactivate', child: Text('Désactiver'))
                      else
                        const PopupMenuItem(value: 'activate', child: Text('Activer')),
                      const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _openEdit(Member m) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _EditMemberSheet(member: m, onSaved: _load),
    );
  }

  Future<void> _toggleStatus(Member m, String status) async {
    final res = await ApiService.toggleMemberStatus(memberId: m.id, status: status);
    if (res['success'] == true) {
      _load();
    } else {
      _error(res['message'] ?? 'Erreur');
    }
  }

  void _confirmDelete(Member m) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Supprimer le membre'),
      content: Text('Supprimer définitivement ${m.fullName} ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.errorColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            Navigator.pop(ctx);
            final res = await ApiService.deleteMember(m.id);
            if (res['success'] == true) {
              if (mounted) {
                _load();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${m.fullName} a été supprimé avec succès'),
                    backgroundColor: AppConstants.successColor,
                  ),
                );
              }
            } else {
              if (mounted) {
                _error(res['message'] ?? 'Erreur lors de la suppression');
              }
            }
          },
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );
}
}

class _EditMemberSheet extends StatefulWidget {
  final Member member;
  final VoidCallback onSaved;
  const _EditMemberSheet({required this.member, required this.onSaved});

  @override
  State<_EditMemberSheet> createState() => _EditMemberSheetState();
}

class _EditMemberSheetState extends State<_EditMemberSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _first;
  late TextEditingController _last;
  late TextEditingController _email;
  late TextEditingController _phone;
  late TextEditingController _position;
  late TextEditingController _department;
  late TextEditingController _employeeId;
  String _role = 'member';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _first = TextEditingController(text: widget.member.firstName);
    _last = TextEditingController(text: widget.member.lastName);
    _email = TextEditingController(text: widget.member.email);
    _phone = TextEditingController(text: widget.member.phone ?? '');
    _position = TextEditingController(text: widget.member.position ?? '');
    _department = TextEditingController(text: widget.member.department ?? '');
    _employeeId = TextEditingController(text: widget.member.employeeId ?? '');
    _role = widget.member.role;
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _phone.dispose();
    _position.dispose();
    _department.dispose();
    _employeeId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Modifier le membre', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _text('Prénom', _first),
              const SizedBox(height: 8),
              _text('Nom', _last),
              const SizedBox(height: 8),
              _text('Email', _email, enabled: false),
              const SizedBox(height: 8),
              _text('Téléphone', _phone),
              const SizedBox(height: 8),
              _text('Poste', _position),
              const SizedBox(height: 8),
              _text('Département', _department),
              const SizedBox(height: 8),
              _text('ID Employé', _employeeId),
              const SizedBox(height: 8),
              _rolePicker(),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _text(String label, TextEditingController c, {bool enabled = true}) {
    return TextFormField(
      controller: c,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _rolePicker() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Rôle',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _role,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'member', child: Text('Membre')),
            DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
          ],
          onChanged: (v) => setState(() => _role = v!),
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final body = {
        'member_id': widget.member.id,
        'first_name': _first.text.trim(),
        'last_name': _last.text.trim(),
        'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        'position': _position.text.trim().isEmpty ? null : _position.text.trim(),
        'department': _department.text.trim().isEmpty ? null : _department.text.trim(),
        'employee_id': _employeeId.text.trim().isEmpty ? null : _employeeId.text.trim(),
        'role': _role,
      };
      final res = await ApiService.updateMember(body);
      if (res['success'] == true) {
        widget.onSaved();
        if (mounted) Navigator.pop(context);
      } else {
        _showError(res['message'] ?? 'Erreur');
      }
    } catch (e) {
      _showError('Erreur: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String m) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: AppConstants.errorColor),
    );
  }
}




