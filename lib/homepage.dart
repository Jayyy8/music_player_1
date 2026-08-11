import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'song.dart';
import 'sample_data.dart';
import 'providers.dart';
import 'album_detail_page.dart';
import 'playlist_detail_page.dart';

class Homepage extends ConsumerWidget {
  const Homepage({super.key, required this.scrollController});
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentSongs = ref.watch(recentlyPlayedProvider);
    final userPlaylists = ref.watch(userPlaylistsProvider);
    final likedAlbumTitles = ref.watch(likedAlbumsProvider);
    final likedPlaylistTitles = ref.watch(likedPlaylistsProvider);
    final featuredSongsList = ref.watch(featuredSongsProvider);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 160),
      children: [
        if (recentSongs.isNotEmpty) ...[
          const _SectionHeader('Recents'),
          SizedBox(
            height: 172,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: recentSongs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final song = recentSongs[index];
                return _RecentSongCard(
                  song: song,
                  onTap: () =>
                      ref.read(audioPlayerProvider.notifier).playFromQueue(recentSongs, song),
                );
              },
            ),
          ),
        ],
        _SectionHeader(
          'Featured Songs',
          trailing: GestureDetector(
            onTap: () => ref.read(featuredSongsProvider.notifier).reshuffle(),
            child: Icon(CupertinoIcons.shuffle,
                color: CupertinoColors.label.resolveFrom(context), size: 20),
          ),
        ),
        SizedBox(
          height: 172,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: featuredSongsList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final song = featuredSongsList[index];
              return _FeaturedSongCard(
                song: song,
                onTap: () => ref
                    .read(audioPlayerProvider.notifier)
                    .playFromQueue(featuredSongsList, song),
              );
            },
          ),
        ),
        const _SectionHeader('Albums'),
        SizedBox(
          height: 196,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sampleAlbums.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final album = sampleAlbums[index];
              final isLiked = likedAlbumTitles.contains(album.title);
              return _CoverCard(
                title: album.title,
                subtitle: album.artist,
                gradient: album.coverGradient,
                coverImage: album.coverImagePath != null
                    ? AssetImage(album.coverImagePath!)
                    : null,
                isLiked: isLiked,
                onToggleLike: () =>
                    ref.read(likedAlbumsProvider.notifier).toggleLike(album.title),
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
                onShuffle: () =>
                    ref.read(audioPlayerProvider.notifier).shufflePlayCollection(album.songs),
              );
            },
          ),
        ),
        const _SectionHeader('Top Playlists'),
        SizedBox(
          height: 196,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: samplePlaylists.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final playlist = samplePlaylists[index];
              final isLiked = likedPlaylistTitles.contains(playlist.title);
              return _CoverCard(
                title: playlist.title,
                subtitle: playlist.genre,
                gradient: playlist.coverGradient,
                coverImage: playlist.coverImagePath != null
                    ? AssetImage(playlist.coverImagePath!)
                    : null,
                isLiked: isLiked,
                onToggleLike: () =>
                    ref.read(likedPlaylistsProvider.notifier).toggleLike(playlist.title),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => AlbumDetailPage(
                        title: playlist.title,
                        subtitle: playlist.genre,
                        coverGradient: playlist.coverGradient,
                        coverImagePath: playlist.coverImagePath,
                        songs: playlist.songs,
                      ),
                    ),
                  );
                },
                onShuffle: () =>
                    ref.read(audioPlayerProvider.notifier).shufflePlayCollection(playlist.songs),
              );
            },
          ),
        ),
        const _SectionHeader('Your Playlists'),
        if (userPlaylists.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('No playlists yet.',
                style: TextStyle(color: CupertinoColors.white.withValues(alpha: 0.5))),
          )
        else
          SizedBox(
            height: 196,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: userPlaylists.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final playlist = userPlaylists[index];
                return _CoverCard(
                  title: playlist.name,
                  subtitle: '${playlist.songs.length} songs',
                  gradient: const [
                    CupertinoColors.systemIndigo,
                    CupertinoColors.systemPurple,
                  ],
                  coverImage: playlist.coverImagePath != null
                      ? FileImage(File(playlist.coverImagePath!))
                      : null,
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => PlaylistDetailPage(playlistId: playlist.id),
                      ),
                    );
                  },
                  onShuffle: playlist.songs.isEmpty
                      ? null
                      : () => ref
                      .read(audioPlayerProvider.notifier)
                      .shufflePlayCollection(playlist.songs),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: CupertinoColors.label.resolveFrom(context),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _RecentSongCard extends StatelessWidget {
  const _RecentSongCard({required this.song, required this.onTap});
  final Song song;
  final VoidCallback onTap;

  static const List<List<Color>> _gradients = [
    [CupertinoColors.systemPink, CupertinoColors.systemPurple],
    [CupertinoColors.systemBlue, CupertinoColors.systemTeal],
    [CupertinoColors.systemOrange, CupertinoColors.systemYellow],
    [CupertinoColors.systemGreen, CupertinoColors.systemTeal],
    [CupertinoColors.systemIndigo, CupertinoColors.systemBlue],
  ];

  List<Color> get _gradient {
    final index = song.title.hashCode.abs() % _gradients.length;
    return _gradients[index];
  }

  @override
  Widget build(BuildContext context) {
    final cover = song.coverImageProvider;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 128,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 128,
              height: 128,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: cover == null
                    ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _gradient,
                )
                    : null,
                image: cover != null
                    ? DecorationImage(image: cover, fit: BoxFit.cover)
                    : null,
              ),
              child: cover == null
                  ? const Icon(CupertinoIcons.music_note,
                  color: CupertinoColors.white, size: 32)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: CupertinoColors.label.resolveFrom(context),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedSongCard extends StatelessWidget {
  const _FeaturedSongCard({required this.song, required this.onTap});
  final Song song;
  final VoidCallback onTap;

  static const List<List<Color>> _gradients = [
    [CupertinoColors.systemPurple, CupertinoColors.systemPink],
    [CupertinoColors.systemTeal, CupertinoColors.systemBlue],
    [CupertinoColors.systemYellow, CupertinoColors.systemOrange],
    [CupertinoColors.systemTeal, CupertinoColors.systemGreen],
    [CupertinoColors.systemBlue, CupertinoColors.systemIndigo],
  ];

  List<Color> get _gradient {
    final index = song.title.hashCode.abs() % _gradients.length;
    return _gradients[index];
  }

  @override
  Widget build(BuildContext context) {
    final cover = song.coverImageProvider;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 128,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 128,
              height: 128,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: cover == null
                    ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _gradient,
                )
                    : null,
                image: cover != null
                    ? DecorationImage(image: cover, fit: BoxFit.cover)
                    : null,
              ),
              child: cover == null
                  ? const Icon(CupertinoIcons.music_note,
                  color: CupertinoColors.white, size: 32)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: CupertinoColors.label.resolveFrom(context),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverCard extends StatelessWidget {
  const _CoverCard({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    this.onShuffle,
    this.coverImage,
    this.isLiked,
    this.onToggleLike,
  });
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback? onTap;
  final VoidCallback? onShuffle;
  final ImageProvider? coverImage;
  final bool? isLiked;
  final VoidCallback? onToggleLike;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: 140,
                  height: 140,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: coverImage == null
                        ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradient,
                    )
                        : null,
                    image: coverImage != null
                        ? DecorationImage(image: coverImage!, fit: BoxFit.cover)
                        : null,
                  ),
                  child: coverImage == null
                      ? const Icon(CupertinoIcons.music_albums,
                      color: CupertinoColors.white, size: 36)
                      : null,
                ),
                if (onToggleLike != null)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: GestureDetector(
                      onTap: onToggleLike,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CupertinoColors.black.withValues(alpha: 0.55),
                        ),
                        child: Icon(
                          (isLiked ?? false)
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          color: (isLiked ?? false)
                              ? CupertinoColors.systemPink
                              : CupertinoColors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                if (onShuffle != null)
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: GestureDetector(
                      onTap: onShuffle,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CupertinoColors.black.withValues(alpha: 0.55),
                        ),
                        child: const Icon(CupertinoIcons.shuffle,
                            color: CupertinoColors.white, size: 14),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: CupertinoColors.label.resolveFrom(context),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}