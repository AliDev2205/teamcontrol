import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../services/api_service.dart';

class NotificationBell extends StatefulWidget {
  final int memberId;
  final VoidCallback? onNotificationsUpdated;
  final Color? iconColor;
  final Color? badgeColor;
  final double? iconSize;
  final bool showBadge;

  const NotificationBell({
    super.key,
    required this.memberId,
    this.onNotificationsUpdated,
    this.iconColor,
    this.badgeColor,
    this.iconSize,
    this.showBadge = true,
  });

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  List<dynamic> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;
  bool _dialogOpen = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (_dialogOpen) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final notifications = await ApiService.getNotifications(widget.memberId);
      setState(() {
        _notifications = notifications;
        _unreadCount = notifications.where((n) => n['is_read'] == false).length;
      });
    } catch (e) {
      print('❌ Erreur chargement notifications: $e');
      setState(() {
        _hasError = true;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      await ApiService.markNotificationRead(notificationId);
      await _loadNotifications();
      widget.onNotificationsUpdated?.call();
    } catch (e) {
      print('❌ Erreur marquage lecture: $e');
      _showErrorSnackbar('Erreur lors du marquage comme lu');
    }
  }

  Future<void> _markAllAsRead() async {
    if (_unreadCount == 0) return;
    
    setState(() => _isLoading = true);
    
    try {
      final unreadNotifications = _notifications.where((n) => n['is_read'] == false).toList();
      for (var notification in unreadNotifications) {
        await ApiService.markNotificationRead(notification['notification_id']);
      }
      await _loadNotifications();
      widget.onNotificationsUpdated?.call();
      _showSuccessSnackbar('Toutes les notifications marquées comme lues');
    } catch (e) {
      print('❌ Erreur marquage multiple: $e');
      _showErrorSnackbar('Erreur lors du marquage multiple');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showNotificationsDialog() {
    setState(() => _dialogOpen = true);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: 400,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // En-tête
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_active_rounded,
                            color: AppConstants.primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Notifications',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '$_unreadCount non lue(s)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppConstants.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_unreadCount > 0 && !_isLoading)
                          TextButton.icon(
                            onPressed: _markAllAsRead,
                            icon: const Icon(Icons.done_all_rounded, size: 16),
                            label: const Text('Tout marquer comme lu'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppConstants.primaryColor,
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded),
                          onPressed: _loadNotifications,
                          tooltip: 'Actualiser',
                        ),
                      ],
                    ),
                  ),

                  // Contenu
                  Expanded(
                    child: _buildNotificationsContent(setDialogState),
                  ),

                  // Footer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_notifications.length} notification(s)',
                          style: AppConstants.captionStyle,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() => _dialogOpen = false);
                          },
                          child: const Text('Fermer'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).then((_) {
      setState(() => _dialogOpen = false);
      _loadNotifications();
    });
  }

  Widget _buildNotificationsContent(StateSetter setDialogState) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppConstants.primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'Chargement des notifications...',
              style: AppConstants.captionStyle,
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Impossible de charger les notifications',
              style: AppConstants.captionStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_rounded,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune notification',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous serez notifié des nouvelles activités',
              style: AppConstants.captionStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationItem(notification, setDialogState);
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification, StateSetter setDialogState) {
    final isUnread = notification['is_read'] == false;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isUnread 
            ? AppConstants.primaryColor.withOpacity(0.05) 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            if (isUnread) {
              setDialogState(() {});
              _markAsRead(notification['notification_id']);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification['type']).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getNotificationIcon(notification['type']),
                    color: _getNotificationColor(notification['type']),
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
                        notification['message'],
                        style: TextStyle(
                          fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                          color: isUnread ? AppConstants.textPrimaryColor : AppConstants.textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Informations supplémentaires
                      if (notification['project_title'] != null)
                        Text(
                          'Projet: ${notification['project_title']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                      
                      const SizedBox(height: 4),
                      
                      // Date
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: AppConstants.textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatNotificationDate(notification['created_at']),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppConstants.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Indicateur non lu
                if (isUnread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppConstants.errorColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'assignment': return Icons.assignment_rounded;
      case 'update': return Icons.update_rounded;
      case 'progress_update': return Icons.trending_up_rounded;
      case 'phase_complete': return Icons.check_circle_rounded;
      case 'project_complete': return Icons.flag_rounded;
      case 'member_added': return Icons.person_add_rounded;
      case 'admin_comment': return Icons.comment_rounded;
      case 'progress_validation': return Icons.verified_rounded;
      case 'deadline': return Icons.warning_rounded;
      case 'reminder': return Icons.notification_important_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'assignment': return AppConstants.primaryColor;
      case 'progress_update': return AppConstants.accentColor;
      case 'phase_complete': return AppConstants.successColor;
      case 'project_complete': return Colors.green;
      case 'progress_validation': return Colors.orange;
      case 'deadline': return AppConstants.errorColor;
      case 'reminder': return Colors.amber;
      default: return AppConstants.primaryColor;
    }
  }

  String _formatNotificationDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes < 1) return 'À l\'instant';
          return 'Il y a ${difference.inMinutes} min';
        }
        return 'Il y a ${difference.inHours} h';
      } else if (difference.inDays == 1) {
        return 'Hier à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays < 7) {
        return 'Il y a ${difference.inDays} jours';
      } else {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }
    } catch (e) {
      return 'Date inconnue';
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            _unreadCount > 0 ? Icons.notifications_active_rounded : Icons.notifications_rounded,
            color: widget.iconColor ?? AppConstants.textPrimaryColor,
            size: widget.iconSize ?? 24,
          ),
          onPressed: _showNotificationsDialog,
          tooltip: 'Notifications ($_unreadCount non lue(s))',
        ),
        
        // Badge
        if (widget.showBadge && _unreadCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: widget.badgeColor ?? AppConstants.errorColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                _unreadCount > 9 ? '9+' : _unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}