import 'package:file_selector/file_selector.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ReorderableListView, ReorderableDragStartListener, Material, MaterialType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'sample_data.dart';
import 'song.dart';
import 'music_models.dart';
import 'providers.dart';
import 'playlist_detail_page.dart';
import 'album_detail_page.dart';

class MusicLibrary extends ConsumerWidget {
  const MusicLibrary({super.key, required this.scrollController});
  final ScrollController scrollController;

  String _stripExtension(String filename) {
    final dotIndex = filename.lastIndexOf('.');
    return dotIndex == -1 ? filename : filename.substring(0, dotIndex);
  }

  Future<void> _importFiles(BuildContext context, WidgetRef ref) async {
    const audioTypeGroup = XTypeGroup(
      label: 'audio',
      extensions: ['mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac'],
      uniformTypeIdentifiers: [
        'public.audio',
        'public.mp3',
        'com.microsoft.waveform-audio',
        'public.mpeg-4-audio',
        'org.xiph.flac',
        'org.xiph.ogg-audio',
      ],
    );

    final files = await openFiles(acceptedTypeGroups: [audioTypeGroup]);
    if (files.isEmpty) return;

    final importedSongs = ref.read(importedSongsProvider);

    for (final f in files) {
      if (!context.mounted) return;

      final existingSong = importedSongs.where((s) => s.filePath == f.path).firstOrNull;
      bool shouldAdd = true;
      bool overwrite = false;

      if (existingSong != null) {
        final action = await showCupertinoDialog<String>(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Duplicate File'),
            content: Text('You have already imported "${f.name}". What would you like to do?'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(ctx).pop('cancel'),
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                onPressed: () => Navigator.of(ctx).pop('keep_both'),
                child: const Text('Keep Both'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.of(ctx).pop('overwrite'),
                child: const Text('Overwrite'),
              ),
            ],
          ),
        );

        if (action == 'overwrite') {
          overwrite = true;
        } else if (action == 'keep_both') {
          overwrite = false;
        } else {
          shouldAdd = false;
        }
      }

      if (shouldAdd) {
        if (overwrite && existingSong != null) {
          await ref.read(importedSongsProvider.notifier).removeSong(existingSong);
        }

        final newSong = Song(
          id: '${DateTime.now().microsecondsSinceEpoch}_${f.name}',
          title: _stripExtension(f.name),
          artist: 'Imported',
          filePath: f.path,
        );
        await ref.read(importedSongsProvider.notifier).addSongs([newSong]);
      }
    }
  }

  Future<void> _changeSongCover(WidgetRef ref, Song song) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    await ref.read(importedSongsProvider.notifier).setSongCover(song, file.path);
  }

  Future<void> _editSongDetail(BuildContext context, WidgetRef ref, Song song, String dialogTitle, String initialValue, bool isTitle) async {
    final controller = TextEditingController(text: initialValue);
    final newValue = await showCupertinoDialog<String>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(dialogTitle),
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

    if (newValue != null && newValue.isNotEmpty && newValue != initialValue) {
      if (isTitle) {
        await ref.read(importedSongsProvider.notifier).updateSongTitle(song, newValue);
      } else {
        await ref.read(importedSongsProvider.notifier).updateSongArtist(song, newValue);
      }
    }
  }

  Future<void> _confirmDeleteSong(BuildContext context, WidgetRef ref, Song song) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Delete Song'),
        content: Text('Delete "${song.title}"? This action cannot be undone.'),
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
      await ref.read(importedSongsProvider.notifier).removeSong(song);
    }
  }

  void _showImportedSongOptions(BuildContext context, WidgetRef ref, Song song) {
    ref.read(isModalOpenProvider.notifier).setOpen(true);
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              _editSongDetail(context, ref, song, 'Edit Song Title', song.title, true);
            },
            child: const Text('Edit Song Title'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              _editSongDetail(context, ref, song, 'Edit Artist', song.artist, false);
            },
            child: const Text('Edit Artist'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              _changeSongCover(ref, song);
            },
            child: const Text('Change Cover Photo'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              _confirmDeleteSong(context, ref, song);
            },
            child: const Text('Delete Song'),
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

  Future<void> _createPlaylist(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showCupertinoDialog<String>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('New Playlist'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'Playlist name',
            autofocus: true,
          ),
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
    if (context.mounted) {
      Navigator.of(context).push(
        CupertinoPageRoute(builder: (_) => PlaylistDetailPage(playlistId: created.id)),
      );
    }
  }

  List<Song> _orderedAllSongs(List<String> customOrder) {
    final byKey = {for (final s in allSongs) s.identityKey: s};
    final alphabetical = [...allSongs]
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    if (customOrder.isEmpty) return alphabetical;

    final ordered = <Song>[];
    final usedKeys = <String>{};
    for (final key in customOrder) {
      final song = byKey[key];
      if (song != null) {
        ordered.add(song);
        usedKeys.add(key);
      }
    }
    for (final song in alphabetical) {
      if (!usedKeys.contains(song.identityKey)) {
        ordered.add(song);
      }
    }
    return ordered;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importedSongs = ref.watch(importedSongsProvider);
    final playlists = ref.watch(userPlaylistsProvider);
    final likedAlbumTitles = ref.watch(likedAlbumsProvider);
    final likedPlaylistTitles = ref.watch(likedPlaylistsProvider);
    final likedSongKeys = ref.watch(likedSongsProvider);
    final viewMode = ref.watch(songsViewModeProvider);
    final customOrder = ref.watch(allSongsOrderProvider);
    final pinned = playlists.where((p) => p.isPinned).toList();
    final unpinned = playlists.where((p) => !p.isPinned).toList();
    final sortedPlaylists = [...pinned, ...unpinned];
    final likedAlbums =
    sampleAlbums.where((a) => likedAlbumTitles.contains(a.title)).toList();
    final likedPlaylists =
    samplePlaylists.where((p) => likedPlaylistTitles.contains(p.title)).toList();

    final allKnownSongs = <String, Song>{};
    for (final s in allSongs) {
      allKnownSongs[s.identityKey] = s;
    }
    for (final s in importedSongs) {
      allKnownSongs[s.identityKey] = s;
    }
    for (final p in playlists) {
      for (final s in p.songs) {
        allKnownSongs[s.identityKey] = s;
      }
    }
    final likedSongs = likedSongKeys
        .map((key) => allKnownSongs[key])
        .whereType<Song>()
        .toList();

    final favoritesEmpty =
        likedAlbums.isEmpty && likedPlaylists.isEmpty && likedSongs.isEmpty;

    final orderedAllSongs = _orderedAllSongs(customOrder);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Library',
                  style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _importFiles(context, ref),
                child: const Icon(CupertinoIcons.add_circled,
                    color: CupertinoColors.white, size: 28),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 160),
            children: [
              const Text('Favorites',
                  style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (favoritesEmpty)
                Text('No favorites yet.',
                    style: TextStyle(color: CupertinoColors.white.withValues(alpha: 0.5)))
              else ...[
                ...likedAlbums.map((album) => _LikedItemRow(
                  title: album.title,
                  subtitle: album.artist,
                  gradient: album.coverGradient,
                  coverImagePath: album.coverImagePath,
                  onTap: () => Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => AlbumDetailPage(
                        title: album.title,
                        subtitle: album.artist,
                        coverGradient: album.coverGradient,
                        coverImagePath: album.coverImagePath,
                        songs: album.songs,
                      ),
                    ),
                  ),
                  onUnlike: () =>
                      ref.read(likedAlbumsProvider.notifier).toggleLike(album.title),
                )),
                ...likedPlaylists.map((playlist) => _LikedItemRow(
                  title: playlist.title,
                  subtitle: playlist.genre,
                  gradient: playlist.coverGradient,
                  coverImagePath: playlist.coverImagePath,
                  onTap: () => Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => AlbumDetailPage(
                        title: playlist.title,
                        subtitle: playlist.genre,
                        coverGradient: playlist.coverGradient,
                        coverImagePath: playlist.coverImagePath,
                        songs: playlist.songs,
                      ),
                    ),
                  ),
                  onUnlike: () => ref
                      .read(likedPlaylistsProvider.notifier)
                      .toggleLike(playlist.title),
                )),
                ...likedSongs.map((song) => _SongRow(
                  song: song,
                  context: likedSongs,
                )),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Your Playlists',
                      style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _createPlaylist(context, ref),
                    child: const Icon(CupertinoIcons.add_circled,
                        color: CupertinoColors.white, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (sortedPlaylists.isEmpty)
                Text('No playlists yet.',
                    style: TextStyle(color: CupertinoColors.white.withValues(alpha: 0.5)))
              else
                ...sortedPlaylists.map((p) => _PlaylistRow(playlist: p)),
              const SizedBox(height: 20),
              if (importedSongs.isNotEmpty) ...[
                const Text('Imported',
                    style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...importedSongs.map((song) => _SongRow(
                  song: song,
                  context: importedSongs,
                  onOptionsTap: () => _showImportedSongOptions(context, ref, song),
                )),
                const SizedBox(height: 20),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('All Songs',
                      style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  GestureDetector(
                    onTap: () => ref.read(songsViewModeProvider.notifier).toggle(),
                    child: Icon(
                      viewMode == SongsViewMode.list
                          ? CupertinoIcons.square_grid_2x2
                          : CupertinoIcons.list_bullet,
                      color: CupertinoColors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (viewMode == SongsViewMode.list)
                GlassCard(
                  padding: EdgeInsets.zero,
                  shape: const LiquidRoundedSuperellipse(borderRadius: 16),
                  child: ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orderedAllSongs.length,
                    proxyDecorator: (Widget child, int index, Animation<double> animation) {
                      return Material(
                        type: MaterialType.transparency,
                        elevation: 0,
                        color: CupertinoColors.transparent,
                        child: child,
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      final reordered = [...orderedAllSongs];
                      var target = newIndex;
                      if (target > oldIndex) target -= 1;
                      final song = reordered.removeAt(oldIndex);
                      reordered.insert(target, song);
                      ref
                          .read(allSongsOrderProvider.notifier)
                          .setOrder(reordered.map((s) => s.identityKey).toList());
                    },
                    itemBuilder: (context, index) {
                      final song = orderedAllSongs[index];
                      final cover = song.coverImageProvider;
                      final isLast = index == orderedAllSongs.length - 1;
                      return Container(
                        key: ValueKey(song.identityKey),
                        decoration: BoxDecoration(
                          border: isLast
                              ? null
                              : Border(
                            bottom: BorderSide(
                              color: CupertinoColors.white.withValues(alpha: 0.08),
                            ),
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () => ref
                              .read(audioPlayerProvider.notifier)
                              .playFromQueue(orderedAllSongs, song),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: CupertinoColors.white.withValues(alpha: 0.15),
                                    image: cover != null
                                        ? DecorationImage(image: cover, fit: BoxFit.cover)
                                        : null,
                                  ),
                                  child: cover == null
                                      ? const Icon(CupertinoIcons.music_note,
                                      color: CupertinoColors.white)
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(song.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: CupertinoColors.white,
                                              fontWeight: FontWeight.w600)),
                                      Text(song.artist,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: CupertinoColors.white
                                                  .withValues(alpha: 0.7),
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                                ReorderableDragStartListener(
                                  index: index,
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Icon(CupertinoIcons.line_horizontal_3,
                                        color: CupertinoColors.white, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: orderedAllSongs.length,
                  itemBuilder: (context, index) =>
                      _SongGridTile(song: orderedAllSongs[index], context: orderedAllSongs),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LikedItemRow extends StatelessWidget {
  const _LikedItemRow({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.coverImagePath,
    required this.onTap,
    required this.onUnlike,
  });
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final String? coverImagePath;
  final VoidCallback onTap;
  final VoidCallback onUnlike;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassListTile.standalone(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        leading: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: coverImagePath == null
                ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            )
                : null,
            image: coverImagePath != null
                ? DecorationImage(image: AssetImage(coverImagePath!), fit: BoxFit.cover)
                : null,
          ),
          child: coverImagePath == null
              ? const Icon(CupertinoIcons.music_albums, color: CupertinoColors.white, size: 20)
              : null,
        ),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: GestureDetector(
          onTap: onUnlike,
          child: const Icon(CupertinoIcons.heart_fill,
              color: CupertinoColors.systemPink, size: 20),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _PlaylistRow extends StatelessWidget {
  const _PlaylistRow({required this.playlist});
  final UserPlaylist playlist;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassListTile.standalone(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        leading: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            gradient: LinearGradient(colors: [
              CupertinoColors.systemIndigo,
              CupertinoColors.systemPurple,
            ]),
          ),
          child: const Icon(CupertinoIcons.music_note_list,
              color: CupertinoColors.white, size: 20),
        ),
        title: Text(playlist.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('${playlist.songs.length} songs'),
        trailing: playlist.isPinned
            ? const Icon(CupertinoIcons.pin_fill, color: CupertinoColors.systemGrey, size: 16)
            : null,
        onTap: () => Navigator.of(context).push(
          CupertinoPageRoute(builder: (_) => PlaylistDetailPage(playlistId: playlist.id)),
        ),
      ),
    );
  }
}

class _SongRow extends ConsumerWidget {
  const _SongRow({required this.song, required this.context, this.onOptionsTap});
  final Song song;
  final List<Song> context;
  final VoidCallback? onOptionsTap;

  @override
  Widget build(BuildContext buildContext, WidgetRef ref) {
    final cover = song.coverImageProvider;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassListTile.standalone(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        leading: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: CupertinoColors.white.withValues(alpha: 0.15),
            image: cover != null ? DecorationImage(image: cover, fit: BoxFit.cover) : null,
          ),
          child: cover == null
              ? const Icon(CupertinoIcons.music_note, color: CupertinoColors.white)
              : null,
        ),
        title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: onOptionsTap != null
            ? GestureDetector(
          onTap: onOptionsTap,
          child: const Icon(CupertinoIcons.ellipsis,
              color: CupertinoColors.white, size: 20),
        )
            : null,
        onTap: () => ref.read(audioPlayerProvider.notifier).playFromQueue(context, song),
      ),
    );
  }
}

class _SongGridTile extends ConsumerWidget {
  const _SongGridTile({required this.song, required this.context});
  final Song song;
  final List<Song> context;

  @override
  Widget build(BuildContext buildContext, WidgetRef ref) {
    final cover = song.coverImageProvider;
    return GestureDetector(
      onTap: () => ref.read(audioPlayerProvider.notifier).playFromQueue(context, song),
      child: GlassCard(
        padding: const EdgeInsets.all(8),
        shape: const LiquidRoundedSuperellipse(borderRadius: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: cover == null
                      ? const LinearGradient(colors: [
                    CupertinoColors.systemTeal,
                    CupertinoColors.systemIndigo,
                  ])
                      : null,
                  image: cover != null
                      ? DecorationImage(image: cover, fit: BoxFit.cover)
                      : null,
                ),
                child: cover == null
                    ? const Icon(CupertinoIcons.music_note,
                    color: CupertinoColors.white, size: 28)
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(song.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
            Text(song.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: CupertinoColors.white.withValues(alpha: 0.6), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}