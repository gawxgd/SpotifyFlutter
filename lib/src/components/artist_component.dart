import 'package:flutter/material.dart';

class ArtistComponent extends StatelessWidget {
  final String artistName;
  final String artistImageUrl;

  const ArtistComponent({
    super.key,
    required this.artistName,
    required this.artistImageUrl,
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
          backgroundImage: NetworkImage(artistImageUrl),
          backgroundColor: Colors.grey[200],
        ),
        title: Text(
          artistName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
