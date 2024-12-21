import 'package:flutter/material.dart';
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
      final songs = await _controller.fetchTopSongs(context);
      final artists = await _controller.fetchTopArtists(context);

      setState(() {
        topSongs = songs;
        topArtists = artists;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load stats: $e')),
      );
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
                      return ListTile(
                        leading: song['image'] != ''
                            ? Image.network(song['image']!,
                                width: 50, height: 50)
                            : null,
                        title: Text(song['title'] ?? 'No title'),
                        subtitle: Text(song['author'] ?? 'Unknown artist'),
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
                      return ListTile(
                        leading: artist['image'] != ''
                            ? Image.network(artist['image']!,
                                width: 50, height: 50)
                            : null,
                        title: Text(artist['title'] ?? 'Unknown artist'),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
