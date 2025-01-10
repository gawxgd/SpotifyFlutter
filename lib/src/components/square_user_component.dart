import 'package:flutter/material.dart';

class SquareUserComponent extends StatelessWidget {
  final String userName;
  final String userImageUrl;

  const SquareUserComponent({
    super.key,
    required this.userName,
    required this.userImageUrl,
  });

  Future<bool> _isImageValid(String url) async {
    try {
      final response =
          await NetworkImage(url).obtainKey(const ImageConfiguration());
      return response != null;
    } catch (e) {
      return false;
    }
  }

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
      child: FutureBuilder<bool>(
        future: _isImageValid(userImageUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data == true) {
            return Column(
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
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.error, size: 40, color: Colors.red),
                ),
                const SizedBox(height: 8),
                Text(
                  userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Invalid image',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
