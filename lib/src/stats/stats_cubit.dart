import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';

class StatsState {
  final List<Map<String, String>> topSongs;
  final List<Map<String, String>> topArtists;
  final bool isLoading;
  final String? error;

  const StatsState({
    this.topSongs = const [],
    this.topArtists = const [],
    this.isLoading = false,
    this.error,
  });

  StatsState copyWith({
    List<Map<String, String>>? topSongs,
    List<Map<String, String>>? topArtists,
    bool? isLoading,
    String? error,
  }) {
    return StatsState(
      topSongs: topSongs ?? this.topSongs,
      topArtists: topArtists ?? this.topArtists,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class StatsCubit extends Cubit<StatsState> {
  StatsCubit() : super(const StatsState());

  Future<List<Map<String, String>>> fetchTopSongs(SpotifyApi spotifyApi) async {
    final tracksPages = spotifyApi.me.topTracks();
    final tracks = await tracksPages.getPage(10);

    if (tracks.items == null) {
      return [];
    }

    List<Map<String, String>> topSongs = [];
    for (var track in tracks.items!.take(10)) {
      topSongs.add({
        'title': track.name ?? ' ',
        'author': track.artists?.first.name ?? '',
        'image': track.album?.images?.first.url ?? '',
      });
    }
    return topSongs;
  }

  Future<List<Map<String, String>>> fetchTopArtists(
      SpotifyApi spotifyApi) async {
    final artistsPages = spotifyApi.me.topArtists();
    final artists = await artistsPages.getPage(10);

    if (artists.items == null) {
      return [];
    }

    List<Map<String, String>> topArtists = [];
    for (var artist in artists.items!.take(10)) {
      topArtists.add({
        'title': artist.name ?? ' ',
        'image': artist.images?.first.url ?? '',
      });
    }
    return topArtists;
  }

  Future<void> fetchSongsAndArtists() async {
    try {
      final spotifyApi = getIt.get<SpotifyApi>();
      final songs = await fetchTopSongs(spotifyApi);
      final artists = await fetchTopArtists(spotifyApi);
      emit(StatsState(isLoading: false, topSongs: songs, topArtists: artists));
    } catch (e) {
      emit(StatsState(isLoading: false, error: e.toString()));
    }
  }
}
