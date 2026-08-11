import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'song.dart';
import 'music_models.dart';
import 'providers.dart';

Route<void> nowPlayingPageRoute() {
  return PageRouteBuilder(
    opaque: false,
    barrierColor: const Color(0x00000000),
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, animation, secondaryAnimation) =>
    const NowPlayingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}

void _showAddToPlaylistSheet(BuildContext context, WidgetRef ref, Song song) {
  showCupertinoModalPopup(
    context: context,
    builder: (context) => _AddToPlaylistSheet(song: song),
  );
}

class NowPlayingPage extends ConsumerStatefulWidget {
  const NowPlayingPage({super.key});

  @override
  ConsumerState<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends ConsumerState<NowPlayingPage> {
  double? _dragValueMs;

  static const List<List<Color>> _gradients = [
    [CupertinoColors.systemPink, CupertinoColors.systemPurple],
    [CupertinoColors.systemBlue, CupertinoColors.systemTeal],
    [CupertinoColors.systemOrange, CupertinoColors.systemYellow],
    [CupertinoColors.systemGreen, CupertinoColors.systemTeal],
    [CupertinoColors.systemIndigo, CupertinoColors.systemBlue],
  ];

  List<Color> _gradientFor(Song song) {
    final index = song.title.hashCode.abs() % _gradients.length;
    return _gradients[index];
  }

  void _playAdjacent({required bool next}) {
    final queueNotifier = ref.read(playbackQueueProvider.notifier);
    final song = next ? queueNotifier.next() : queueNotifier.previous();
    if (song != null) {
      ref.read(audioPlayerProvider.notifier).playSong(song);
    }
    setState(() => _dragValueMs = null);
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) d = Duration.zero;
    final minutes = d.inMinutes.remainder(60).toString();
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioPlayerProvider);
    final queueState = ref.watch(playbackQueueProvider);
    final song = audioState.currentSong;

    if (song == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) Navigator.of(context).pop();
      });
      return const SizedBox.shrink();
    }

    final durationMs = audioState.duration.inMilliseconds.toDouble();
    final maxMs = durationMs > 0 ? durationMs : 1.0;
    final positionMs =
    (_dragValueMs ?? audioState.position.inMilliseconds.toDouble())
        .clamp(0.0, maxMs);
    final remaining = audioState.duration - audioState.position;
    final gradient = _gradientFor(song);
    final cover = song.coverImageProvider;

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 300) {
          Navigator.of(context).pop();
        }
      },
      child: CupertinoPageScaffold(
        backgroundColor: const Color(0xFF0A0A2E),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                gradient.first.withValues(alpha: 0.35),
                const Color(0xFF0A0A2E),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Icon(CupertinoIcons.chevron_down,
                            color: CupertinoColors.white, size: 26),
                      ),
                      const Text('NOW PLAYING',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          )),
                      const SizedBox(width: 26),
                    ],
                  ),
                  const Spacer(),
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: cover == null
                            ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradient,
                        )
                            : null,
                        image: cover != null
                            ? DecorationImage(image: cover, fit: BoxFit.cover)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: gradient.first.withValues(alpha: 0.4),
                            blurRadius: 40,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: cover == null
                          ? const Icon(CupertinoIcons.music_note,
                          color: CupertinoColors.white, size: 90)
                          : null,
                    ),
                  ),
                  const Spacer(),
                  // NA-UPDATE: Binago ang structure ng Stack para hindi mag-overlap at umangat ang text
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 32, // Inangat nang konti para nasa ibaba niya ang '+' button
                          left: 16,   // Padding sa gilid para mas malinis kapag nag-e-ellipsis
                          right: 16,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            children: [
                              Text(song.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  )),
                              const SizedBox(height: 4),
                              Text(song.artist,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: CupertinoColors.white.withValues(alpha: 0.65),
                                    fontSize: 15,
                                  )),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0, // Nakapirmi sa lower right corner ng Stack ang button
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => _showAddToPlaylistSheet(context, ref, song),
                          child: const Icon(CupertinoIcons.add_circled,
                              color: CupertinoColors.white, size: 26),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final widenedWidth = constraints.maxWidth + 32;
                      return Column(
                        children: [
                          SizedBox(
                            height: 44,
                            child: OverflowBox(
                              minWidth: widenedWidth,
                              maxWidth: widenedWidth,
                              alignment: Alignment.center,
                              child: CupertinoSlider(
                                value: positionMs,
                                min: 0,
                                max: maxMs,
                                activeColor: CupertinoColors.white,
                                thumbColor: CupertinoColors.white,
                                onChanged: (value) => setState(() => _dragValueMs = value),
                                onChangeEnd: (value) {
                                  ref
                                      .read(audioPlayerProvider.notifier)
                                      .seek(Duration(milliseconds: value.toInt()));
                                  setState(() => _dragValueMs = null);
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                            child: OverflowBox(
                              minWidth: widenedWidth,
                              maxWidth: widenedWidth,
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(
                                        Duration(milliseconds: positionMs.toInt())),
                                    style: TextStyle(
                                        color: CupertinoColors.white.withValues(alpha: 0.6),
                                        fontSize: 12),
                                  ),
                                  Text(
                                    '-${_formatDuration(remaining)}',
                                    style: TextStyle(
                                        color: CupertinoColors.white.withValues(alpha: 0.6),
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () =>
                            ref.read(playbackQueueProvider.notifier).toggleShuffle(),
                        child: Icon(
                          CupertinoIcons.shuffle,
                          color: queueState.shuffleEnabled
                              ? CupertinoColors.activeGreen
                              : CupertinoColors.white,
                          size: 22,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => _playAdjacent(next: false),
                        child: const Icon(CupertinoIcons.backward_fill,
                            color: CupertinoColors.white, size: 32),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () =>
                            ref.read(audioPlayerProvider.notifier).togglePlayPause(),
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: CupertinoColors.white,
                          ),
                          child: Icon(
                            audioState.isPlaying
                                ? CupertinoIcons.pause_fill
                                : CupertinoIcons.play_fill,
                            color: const Color(0xFF0A0A2E),
                            size: 30,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => _playAdjacent(next: true),
                        child: const Icon(CupertinoIcons.forward_fill,
                            color: CupertinoColors.white, size: 32),
                      ),
                      GestureDetector(
                        onTap: () =>
                            ref.read(audioPlayerProvider.notifier).toggleRepeatOne(),
                        child: Icon(
                          CupertinoIcons.repeat_1,
                          color: audioState.repeatOneEnabled
                              ? CupertinoColors.activeGreen
                              : CupertinoColors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddToPlaylistSheet extends ConsumerWidget {
  const _AddToPlaylistSheet({required this.song});
  final Song song;

  Future<void> _createAndAdd(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showCupertinoDialog<String>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('New Playlist'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
              controller: controller, placeholder: 'Playlist name', autofocus: true),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    final created = await ref.read(userPlaylistsProvider.notifier).createPlaylist(name);
    await ref.read(userPlaylistsProvider.notifier).addSongs(created.id, [song]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(userPlaylistsProvider);
    final isLiked = ref.watch(likedSongsProvider).contains(song.identityKey);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF16213E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Saved in',
                      style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => _createAndAdd(context, ref),
                    child: const Text('New playlist',
                        style: TextStyle(color: CupertinoColors.activeGreen, fontSize: 15)),
                  ),
                ],
              ),
            ),
            _SheetRow(
              icon: CupertinoIcons.heart_fill,
              iconGradient: const [CupertinoColors.systemPurple, CupertinoColors.systemBlue],
              title: 'Liked Songs',
              isChecked: isLiked,
              onTap: () => ref.read(likedSongsProvider.notifier).toggleLike(song.identityKey),
            ),
            ...playlists.map((playlist) {
              final inPlaylist = playlist.songs.any((s) => s.identityKey == song.identityKey);
              return _SheetRow(
                icon: CupertinoIcons.music_note_list,
                iconGradient: const [CupertinoColors.systemIndigo, CupertinoColors.systemPurple],
                coverImagePath: playlist.coverImagePath,
                title: playlist.name,
                subtitle: '${playlist.songs.length} songs',
                isChecked: inPlaylist,
                onTap: () {
                  if (inPlaylist) {
                    ref.read(userPlaylistsProvider.notifier).removeSong(playlist.id, song);
                  } else {
                    ref.read(userPlaylistsProvider.notifier).addSongs(playlist.id, [song]);
                  }
                },
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.icon,
    required this.iconGradient,
    required this.title,
    required this.isChecked,
    required this.onTap,
    this.subtitle,
    this.coverImagePath,
  });
  final IconData icon;
  final List<Color> iconGradient;
  final String title;
  final String? subtitle;
  final bool isChecked;
  final VoidCallback onTap;
  final String? coverImagePath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: coverImagePath == null
                    ? LinearGradient(colors: iconGradient)
                    : null,
                image: coverImagePath != null
                    ? DecorationImage(
                    image: FileImage(File(coverImagePath!)), fit: BoxFit.cover)
                    : null,
              ),
              child: coverImagePath == null
                  ? Icon(icon, color: CupertinoColors.white, size: 20)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: TextStyle(
                            color: CupertinoColors.white.withValues(alpha: 0.6),
                            fontSize: 12)),
                ],
              ),
            ),
            Icon(
              isChecked
                  ? CupertinoIcons.check_mark_circled_solid
                  : CupertinoIcons.add_circled,
              color: isChecked ? CupertinoColors.activeGreen : CupertinoColors.systemGrey,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}