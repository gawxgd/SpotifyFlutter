import 'package:flutter/material.dart';

class SquareUserComponent extends StatelessWidget {
  final String userName;
  final String userImageUrl;

  const SquareUserComponent({
    super.key,
    required this.userName,
    required this.userImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).primaryColor,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(userImageUrl),
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(height: 8),
          Text(
            userName,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
