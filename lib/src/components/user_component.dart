import 'package:flutter/material.dart';

class UserComponent extends StatelessWidget {
  final String userName;
  final String userImageUrl;
  final VoidCallback onDelete;
  final bool canDelete;

  const UserComponent({
    super.key,
    required this.userName,
    required this.userImageUrl,
    required this.onDelete,
    this.canDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).primaryColor,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(userImageUrl),
          backgroundColor: Colors.grey[200],
        ),
        title: canDelete
            ? Text(
                "host: $userName",
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : Text(
                userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
        trailing: canDelete
            ? null
            : IconButton(
                icon: Icon(Icons.delete,
                    color: Theme.of(context).colorScheme.error),
                onPressed: onDelete,
              ),
      ),
    );
  }
}
