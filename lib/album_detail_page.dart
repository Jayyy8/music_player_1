import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'song.dart';
import 'providers.dart';

class AlbumDetailPage extends ConsumerWidget {
  const AlbumDetailPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.coverGradient,
    required this.songs,
    this.coverImagePath,
  });

  final String title;
  final String subtitle;
  final List<Color> coverGradient;
  final List<Song> songs;
  final String? coverImagePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerProvider);
    final likedSongKeys = ref.watch(likedSongsProvider);

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0A0A2E),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black.withValues(alpha: 0.4),
        border: null,
        middle: Text(title, style: const TextStyle(color: CupertinoColors.white)),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A2E),
              Color(0xFF3A1C71),
              Color(0xFFD76D77),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
            children: [
              Center(
                child: Container(
                  width: 180,
                  height: 180,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: coverImagePath == null
                        ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: coverGradient,
                    )
                        : null,
                    image: coverImagePath != null
                        ? DecorationImage(
                        image: AssetImage(coverImagePath!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: coverImagePath == null
                      ? const Icon(CupertinoIcons.music_albums,
                      color: CupertinoColors.white, size: 56)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: CupertinoColors.white.withValues(alpha: 0.7),
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: songs.isEmpty
                          ? null
                          : () => ref
                          .read(audioPlayerProvider.notifier)
                          .playFromQueue(songs, songs.first),
                      child: const Icon(CupertinoIcons.play_circle_fill,
                          color: CupertinoColors.activeGreen, size: 36),
                    ),
                    const SizedBox(width: 16),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: songs.isEmpty
                          ? null
                          : () => ref
                          .read(audioPlayerProvider.notifier)
                          .shufflePlayCollection(songs),
                      child: const Icon(CupertinoIcons.shuffle,
                          color: CupertinoColors.white, size: 28),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ...songs.map((song) {
                final isCurrent = audioState.currentSong?.identityKey == song.identityKey;
                final isLiked = likedSongKeys.contains(song.identityKey);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () {
                      if (isCurrent) {
                        ref.read(audioPlayerProvider.notifier).togglePlayPause();
                      } else {
                        ref.read(audioPlayerProvider.notifier).playFromQueue(songs, song);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: isCurrent
                            ? CupertinoColors.white.withValues(alpha: 0.14)
                            : CupertinoColors.white.withValues(alpha: 0.06),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCurrent && audioState.isPlaying
                                ? CupertinoIcons.pause_fill
                                : CupertinoIcons.play_fill,
                            color: isCurrent
                                ? CupertinoColors.activeGreen
                                : CupertinoColors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(song.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isCurrent
                                          ? CupertinoColors.activeGreen
                                          : CupertinoColors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    )),
                                Text(song.artist,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: CupertinoColors.white.withValues(alpha: 0.6),
                                      fontSize: 12,
                                    )),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => ref
                                .read(likedSongsProvider.notifier)
                                .toggleLike(song.identityKey),
                            child: Icon(
                              isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                              color: isLiked
                                  ? CupertinoColors.systemPink
                                  : CupertinoColors.systemGrey,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}