import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sample_data.dart';
import 'song.dart';
import 'music_models.dart';
import 'providers.dart';
import 'album_detail_page.dart';

class SearchResultsView extends ConsumerWidget {
  const SearchResultsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider).trim().toLowerCase();
    final importedSongs = ref.watch(importedSongsProvider);

    if (query.isEmpty) {
      return Center(
        child: Text(
          'Search for songs, albums, or artists',
          style: TextStyle(
            color: CupertinoColors.white.withValues(alpha: 0.5),
            fontSize: 15,
          ),
        ),
      );
    }

    final allSongsCombined = [...allSongs, ...importedSongs];

    final matchedSongs = allSongsCombined.where((song) {
      return song.title.toLowerCase().contains(query) ||
          song.artist.toLowerCase().contains(query);
    }).toList();

    final matchedAlbums = sampleAlbums.where((album) {
      return album.title.toLowerCase().contains(query) ||
          album.artist.toLowerCase().contains(query);
    }).toList();

    if (matchedSongs.isEmpty && matchedAlbums.isEmpty) {
      return Center(
        child: Text(
          'No results for "$query"',
          style: TextStyle(
            color: CupertinoColors.white.withValues(alpha: 0.5),
            fontSize: 15,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
      children: [
        if (matchedAlbums.isNotEmpty) ...[
          const _ResultHeader('Albums'),
          ...matchedAlbums.map((album) => _AlbumResultRow(album: album)),
          const SizedBox(height: 20),
        ],
        if (matchedSongs.isNotEmpty) ...[
          const _ResultHeader('Songs'),
          ...matchedSongs.map((song) => _SongResultRow(song: song)),
        ],
      ],
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: CupertinoColors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AlbumResultRow extends StatelessWidget {
  const _AlbumResultRow({required this.album});
  final Album album;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => AlbumDetailPage(
                title: album.title,
                subtitle: album.artist,
                coverGradient: album.coverGradient,
                coverImagePath: album.coverImagePath,
                songs: album.songs,
              ),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(colors: album.coverGradient),
              ),
              child: const Icon(CupertinoIcons.music_albums,
                  color: CupertinoColors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(album.title,
                      style: const TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w600)),
                  Text(album.artist,
                      style: TextStyle(
                          color: CupertinoColors.white.withValues(alpha: 0.7),
                          fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SongResultRow extends ConsumerWidget {
  const _SongResultRow({required this.song});
  final Song song;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => ref.read(audioPlayerProvider.notifier).playSong(song),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: CupertinoColors.white.withValues(alpha: 0.1),
              ),
              child: const Icon(CupertinoIcons.music_note,
                  color: CupertinoColors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(song.title,
                      style: const TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w600)),
                  Text(song.artist,
                      style: TextStyle(
                          color: CupertinoColors.white.withValues(alpha: 0.7),
                          fontSize: 12)),
                ],
              ),
            ),
            const Icon(CupertinoIcons.play_circle,
                color: CupertinoColors.white, size: 24),
          ],
        ),
      ),
    );
  }
}