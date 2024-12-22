import 'package:flutter/material.dart';

class SongComponent extends StatelessWidget {
  final String songName;
  final String songImageUrl;
  final String songAuthor;

  const SongComponent({
    super.key,
    required this.songName,
    required this.songImageUrl,
    required this.songAuthor,
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
          backgroundImage: NetworkImage(songImageUrl),
          backgroundColor: Colors.grey[200],
        ),
        title: Text(
          songName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          songAuthor,
        ),
      ),
    );
  }
}
