import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';

class StatsController {
  Future<List<Map<String, String>>> fetchTopSongs(BuildContext context) async {
    try {
      final spotifyApi = getService<SpotifyApi>();
      if (spotifyApi == null) {
        throw Exception('Spotify API is not available');
      }

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
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<List<Map<String, String>>> fetchTopArtists(
      BuildContext context) async {
    try {
      final spotifyApi = getService<SpotifyApi>();
      if (spotifyApi == null) {
        throw Exception('Spotify API is not available');
      }

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
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }
}
