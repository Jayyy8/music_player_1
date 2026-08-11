import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ReorderableListView, ReorderableDragStartListener, Material, MaterialType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'music_models.dart';
import 'sample_data.dart';
import 'song.dart';
import 'providers.dart';

class PlaylistDetailPage extends ConsumerWidget {
  const PlaylistDetailPage({super.key, required this.playlistId});
  final String playlistId;

  Future<void> _rename(BuildContext context, WidgetRef ref, UserPlaylist playlist) async {
    final controller = TextEditingController(text: playlist.name);
    final newName = await showCupertinoDialog<String>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Rename Playlist'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(controller: controller, autofocus: true),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      await ref.read(userPlaylistsProvider.notifier).rename(playlist.id, newName);
    }
  }

  Future<void> _changeCover(WidgetRef ref, UserPlaylist playlist) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) {
        debugPrint('Image picker: walang napiling image (cancelled)');
        return;
      }
      debugPrint('Image picker: napili ang ${file.path}');
      await ref.read(userPlaylistsProvider.notifier).setCoverImage(playlist.id, file.path);
    } catch (e, stack) {
      debugPrint('Image picker error: $e');
      debugPrint('$stack');
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, UserPlaylist playlist) async {
    final navigator = Navigator.of(context);
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Delete Playlist'),
        content: Text('Delete "${playlist.name}"? Hindi na ito mababawi.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(userPlaylistsProvider.notifier).delete(playlist.id);
      navigator.pop();
    }
  }

  Future<void> _confirmRemoveSong(
      BuildContext context, WidgetRef ref, UserPlaylist playlist, Song song) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Remove Song'),
        content: Text('Alisin ang "${song.title}" sa playlist na ito?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(userPlaylistsProvider.notifier).removeSong(playlist.id, song);
    }
  }

  void _showOptions(BuildContext context, WidgetRef ref, UserPlaylist playlist) {
    ref.read(isModalOpenProvider.notifier).setOpen(true);
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              _rename(context, ref, playlist);
            },
            child: const Text('Rename'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              _changeCover(ref, playlist);
            },
            child: const Text('Change Cover Photo'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(userPlaylistsProvider.notifier).togglePin(playlist.id);
            },
            child: Text(playlist.isPinned ? 'Unpin' : 'Pin to Top'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              _confirmDelete(context, ref, playlist);
            },
            child: const Text('Delete Playlist'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    ).then((_) {
      ref.read(isModalOpenProvider.notifier).setOpen(false);
    });
  }

  Widget _buildCover(UserPlaylist playlist) {
    if (playlist.coverImagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(playlist.coverImagePath!),
          width: 96,
          height: 96,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 96,
      height: 96,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        gradient: LinearGradient(colors: [
          CupertinoColors.systemIndigo,
          CupertinoColors.systemPurple,
        ]),
      ),
      child: const Icon(CupertinoIcons.music_note_list,
          color: CupertinoColors.white, size: 36),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(userPlaylistsProvider);
    final playlist = playlists.firstWhere(
          (p) => p.id == playlistId,
      orElse: () => UserPlaylist(id: playlistId, name: 'Playlist'),
    );
    final audioState = ref.watch(audioPlayerProvider);
    final likedSongKeys = ref.watch(likedSongsProvider);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.transparent,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.transparent,
        border: null,
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
        child: SizedBox.expand(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _changeCover(ref, playlist),
                        child: _buildCover(playlist),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    playlist.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: CupertinoColors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  minSize: 0,
                                  onPressed: () => _showOptions(context, ref, playlist),
                                  child: const Icon(
                                    CupertinoIcons.ellipsis_circle,
                                    color: CupertinoColors.white,
                                    size: 26,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('${playlist.songs.length} songs',
                                style: TextStyle(
                                    color: CupertinoColors.white.withValues(alpha: 0.6),
                                    fontSize: 13)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  minSize: 0,
                                  onPressed: playlist.songs.isEmpty
                                      ? null
                                      : () => ref
                                      .read(audioPlayerProvider.notifier)
                                      .playFromQueue(playlist.songs, playlist.songs.first),
                                  child: const Icon(CupertinoIcons.play_circle_fill,
                                      color: CupertinoColors.activeGreen, size: 34),
                                ),
                                const SizedBox(width: 14),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  minSize: 0,
                                  onPressed: playlist.songs.isEmpty
                                      ? null
                                      : () => ref
                                      .read(audioPlayerProvider.notifier)
                                      .shufflePlayCollection(playlist.songs),
                                  child: const Icon(CupertinoIcons.shuffle,
                                      color: CupertinoColors.white, size: 26),
                                ),
                                const SizedBox(width: 14),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  minSize: 0,
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (_) => _AddSongsPage(playlist: playlist),
                                      ),
                                    );
                                  },
                                  child: const Icon(CupertinoIcons.add_circled,
                                      color: CupertinoColors.white, size: 28),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: playlist.songs.isEmpty
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 64.0),
                      child: Text('No songs added yet. Click \'+\' to add songs.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: CupertinoColors.white.withValues(alpha: 0.5))),
                    ),
                  )
                      : ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 160),
                    itemCount: playlist.songs.length,
                    // DITO TINA-TANGGAL YUNG SHADOW/OFFSET
                    proxyDecorator: (Widget child, int index, Animation<double> animation) {
                      return Material(
                        type: MaterialType.transparency,
                        elevation: 0,
                        color: CupertinoColors.transparent,
                        child: child,
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      ref
                          .read(userPlaylistsProvider.notifier)
                          .reorderSongs(playlist.id, oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final song = playlist.songs[index];
                      final isCurrent =
                          audioState.currentSong?.identityKey == song.identityKey;
                      final isLiked = likedSongKeys.contains(song.identityKey);
                      return Padding(
                        key: ValueKey(song.identityKey),
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () {
                            if (isCurrent) {
                              ref.read(audioPlayerProvider.notifier).togglePlayPause();
                            } else {
                              ref
                                  .read(audioPlayerProvider.notifier)
                                  .playFromQueue(playlist.songs, song);
                            }
                          },
                          child: Container(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                                  size: 16,
                                ),
                                const SizedBox(width: 12),
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
                                              fontWeight: FontWeight.w500)),
                                      Text(song.artist,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: CupertinoColors.white
                                                  .withValues(alpha: 0.6),
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => ref
                                      .read(likedSongsProvider.notifier)
                                      .toggleLike(song.identityKey),
                                  child: Icon(
                                    isLiked
                                        ? CupertinoIcons.heart_fill
                                        : CupertinoIcons.heart,
                                    color: isLiked
                                        ? CupertinoColors.systemPink
                                        : CupertinoColors.systemGrey,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () =>
                                      _confirmRemoveSong(context, ref, playlist, song),
                                  child: const Icon(CupertinoIcons.minus_circle,
                                      color: CupertinoColors.systemGrey, size: 20),
                                ),
                                const SizedBox(width: 10),
                                ReorderableDragStartListener(
                                  index: index,
                                  child: const Icon(CupertinoIcons.line_horizontal_3,
                                      color: CupertinoColors.systemGrey, size: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddSongsPage extends ConsumerStatefulWidget {
  const _AddSongsPage({required this.playlist});
  final UserPlaylist playlist;

  @override
  ConsumerState<_AddSongsPage> createState() => _AddSongsPageState();
}

class _AddSongsPageState extends ConsumerState<_AddSongsPage> {
  final Set<String> _selectedKeys = {};

  @override
  Widget build(BuildContext context) {
    final imported = ref.watch(importedSongsProvider);
    final existingKeys = widget.playlist.songs.map((s) => s.identityKey).toSet();
    final available = [...allSongs, ...imported]
        .where((s) => !existingKeys.contains(s.identityKey))
        .toList();

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.transparent,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.transparent,
        border: null,
        middle: const Text('Add Songs', style: TextStyle(color: CupertinoColors.white)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _selectedKeys.isEmpty
              ? null
              : () async {
            final toAdd =
            available.where((s) => _selectedKeys.contains(s.identityKey)).toList();
            await ref
                .read(userPlaylistsProvider.notifier)
                .addSongs(widget.playlist.id, toAdd);
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('Add'),
        ),
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
        child: SizedBox.expand(
          child: SafeArea(
            child: available.isEmpty
                ? const Center(
                child: Text('Wala nang ibang kantang maidadagdag.',
                    style: TextStyle(color: CupertinoColors.white)))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: available.length,
              itemBuilder: (context, index) {
                final song = available[index];
                final selected = _selectedKeys.contains(song.identityKey);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (selected) {
                      _selectedKeys.remove(song.identityKey);
                    } else {
                      _selectedKeys.add(song.identityKey);
                    }
                  }),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? CupertinoIcons.check_mark_circled_solid
                              : CupertinoIcons.circle,
                          color: selected
                              ? CupertinoColors.activeGreen
                              : CupertinoColors.systemGrey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(song.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: CupertinoColors.white)),
                              Text(song.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: CupertinoColors.white.withValues(alpha: 0.6),
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}