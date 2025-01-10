import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_flutter/src/components/artist_component.dart';
import 'package:spotify_flutter/src/components/song_component.dart';
import 'package:spotify_flutter/src/stats/stats_cubit.dart';

class StatsView extends StatelessWidget {
  const StatsView({super.key});

  static const String routeName = '/stats';

  static const String name = 'Spotify stats';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StatsCubit()..fetchSongsAndArtists(),
      child: Scaffold(
        body: BlocBuilder<StatsCubit, StatsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              return Center(
                child: Text(
                  'Failed to load stats: ${state.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Songs Section
                  const Text(
                    'Top Songs',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (state.topSongs.isEmpty)
                    const Text('No songs available.')
                  else
                    ...state.topSongs.map((song) {
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
                  if (state.topArtists.isEmpty)
                    const Text('No artists available.')
                  else
                    ...state.topArtists.map((artist) {
                      return ArtistComponent(
                        artistImageUrl: artist['image'] ?? '',
                        artistName: artist['title'] ?? 'Unknown artist',
                      );
                    }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
