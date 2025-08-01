import 'package:flutter/material.dart';
import '../models/guest_model.dart';

class GuestListItem extends StatelessWidget {
  final GuestModel guest;
  final VoidCallback onTap;
  final VoidCallback? onSendInvitation;
  final VoidCallback? onSendReminder;

  const GuestListItem({
    super.key,
    required this.guest,
    required this.onTap,
    this.onSendInvitation,
    this.onSendReminder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _buildAvatar(),
        title: Text(guest.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (guest.email.isNotEmpty) Text(guest.email),
            if (guest.phone != null && guest.phone!.isNotEmpty) Text(guest.phone!),
            const SizedBox(height: 4),
            _buildStatusChip(context),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showOptions(context),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAvatar() {
    Color avatarColor;
    IconData avatarIcon;
    
    switch (guest.status) {
      case GuestStatus.confirmed:
        avatarColor = Colors.green;
        avatarIcon = Icons.check_circle;
        break;
      case GuestStatus.declined:
        avatarColor = Colors.red;
        avatarIcon = Icons.cancel;
        break;
      default:
        avatarColor = Colors.orange;
        avatarIcon = Icons.help;
    }

    return CircleAvatar(
      backgroundColor: avatarColor.withOpacity(0.2),
      child: Icon(avatarIcon, color: avatarColor),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color chipColor;
    String statusText = guest.statusString;
    
    switch (guest.status) {
      case GuestStatus.confirmed:
        chipColor = Colors.green;
        break;
      case GuestStatus.declined:
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                onTap();
              },
            ),
            if (guest.status == GuestStatus.pending && onSendReminder != null)
              ListTile(
                leading: const Icon(Icons.notification_important),
                title: const Text('Envoyer un rappel'),
                onTap: () {
                  Navigator.pop(context);
                  onSendReminder!();
                },
              ),
            if (onSendInvitation != null)
              ListTile(
                leading: const Icon(Icons.mail),
                title: const Text('Renvoyer l\'invitation'),
                onTap: () {
                  Navigator.pop(context);
                  onSendInvitation!();
                },
              ),
          ],
        ),
      ),
    );
  }
}