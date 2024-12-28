import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/components/artist_component.dart';
import 'package:spotify_flutter/src/components/song_component.dart';
import 'package:spotify_flutter/src/stats/stats_controller.dart';

class StatsView extends StatefulWidget {
  const StatsView({super.key});

  static const String routeName = '/stats';

  static const String name = 'Spotify stats';

  @override
  StatsViewState createState() => StatsViewState();
}

class StatsViewState extends State<StatsView> {
  final StatsController _controller = StatsController();
  List<Map<String, String>> topSongs = [];
  List<Map<String, String>> topArtists = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final songsAndArtists = await _controller.fetchSongsAndArtists(context);
      setState(() {
        topSongs = songsAndArtists.$1;
        topArtists = songsAndArtists.$2;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load stats: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Songs Section
                  const Text(
                    'Top Songs',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (topSongs.isEmpty)
                    const Text('No songs available.')
                  else
                    ...topSongs.map((song) {
                      return SongComponent(
                        songImageUrl: song['image'] ?? ' ',
                        songName: song['title'] ?? 'No title',
                        songAuthor: song['author'] ?? 'Unknown artist',
                      );
                    }),

                  const SizedBox(height: 20),

                  // Top Artists Section
                  const Text(
                    'Top Artists',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (topArtists.isEmpty)
                    const Text('No artists available.')
                  else
                    ...topArtists.map((artist) {
                      return ArtistComponent(
                        artistImageUrl: artist['image'] ?? '',
                        artistName: artist['title'] ?? 'Unknown artist',
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
