import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'song.dart';
import 'music_models.dart';
import 'music_audio_handler.dart';
import 'sample_data.dart';

// ---- Navigator key (para magamit ng mga widget na wala sa loob ng Navigator's context, gaya ng CollapsedBarOverlay) ----
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

// ---- Audio handler (naka-initialize sa main() bago pa mag-runApp, itine-then override dito) ----
final audioHandlerProvider = Provider<MusicAudioHandler>((ref) {
  throw UnimplementedError('audioHandlerProvider must be overridden in main()');
});

// ---- Tab selection ----
class SelectedIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

final selectedIndexProvider =
NotifierProvider<SelectedIndexNotifier, int>(SelectedIndexNotifier.new);

// ---- Pill collapse state (scroll-driven) ----
class PillCollapsedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setCollapsed(bool value) {
    if (state != value) state = value;
  }
}

final isPillCollapsedProvider =
NotifierProvider<PillCollapsedNotifier, bool>(PillCollapsedNotifier.new);

final scrollControllerProvider = Provider<ScrollController>((ref) {
  final controller = ScrollController();
  ref.onDispose(controller.dispose);
  return controller;
});

// ---- Imported songs (mula sa device file picker, naka-save sa disk) ----
class ImportedSongsNotifier extends Notifier<List<Song>> {
  static const String _prefsKey = 'imported_songs';

  @override
  List<Song> build() {
    _loadFromPrefs();
    return [];
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStrings = prefs.getStringList(_prefsKey) ?? [];
    state = jsonStrings
        .map((s) => Song.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStrings = state.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_prefsKey, jsonStrings);
  }

  Future<void> addSongs(List<Song> songs) async {
    state = [...state, ...songs];
    await _saveToPrefs();
  }

  Future<void> setSongCover(Song song, String filePath) async {
    state = state
        .map((s) => s.identityKey == song.identityKey
        ? s.copyWith(coverFilePath: filePath)
        : s)
        .toList();
    await _saveToPrefs();
  }

  // --- BAGONG METHODS PARA SA EDIT AT DELETE NG IMPORTED SONGS ---

  Future<void> updateSongTitle(Song song, String newTitle) async {
    state = state
        .map((s) => s.identityKey == song.identityKey
        ? s.copyWith(title: newTitle)
        : s)
        .toList();
    await _saveToPrefs();
  }

  Future<void> updateSongArtist(Song song, String newArtist) async {
    state = state
        .map((s) => s.identityKey == song.identityKey
        ? s.copyWith(artist: newArtist)
        : s)
        .toList();
    await _saveToPrefs();
  }

  Future<void> removeSong(Song song) async {
    state = state.where((s) => s.identityKey != song.identityKey).toList();
    await _saveToPrefs();
  }
}

final importedSongsProvider =
NotifierProvider<ImportedSongsNotifier, List<Song>>(ImportedSongsNotifier.new);

// ---- Featured songs (random na pinipili mula sa buong catalog, matatag habang session) ----
class FeaturedSongsNotifier extends Notifier<List<Song>> {
  static const int count = 5;

  @override
  List<Song> build() {
    final pool = <String, Song>{};
    for (final s in allSongs) {
      pool[s.identityKey] = s;
    }
    for (final p in samplePlaylists) {
      for (final s in p.songs) {
        pool[s.identityKey] = s;
      }
    }
    final picks = pool.values.toList()..shuffle();
    return picks.take(count).toList();
  }

  void reshuffle() => ref.invalidateSelf();
}

final featuredSongsProvider =
NotifierProvider<FeaturedSongsNotifier, List<Song>>(FeaturedSongsNotifier.new);

// ---- Search query ----
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

final searchQueryProvider =
NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

// ---- Now Playing page open state ----
class NowPlayingOpenNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setOpen(bool value) => state = value;
}

final isNowPlayingOpenProvider =
NotifierProvider<NowPlayingOpenNotifier, bool>(NowPlayingOpenNotifier.new);

// ---- Modal open state (para sa pag-angat ng pill kapag may bukas na action sheet) ----
class ModalOpenNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setOpen(bool value) => state = value;
}

final isModalOpenProvider =
NotifierProvider<ModalOpenNotifier, bool>(ModalOpenNotifier.new);

// ---- Recently played songs (naka-save sa disk) ----
class RecentlyPlayedNotifier extends Notifier<List<Song>> {
  static const int maxRecents = 15;
  static const String _prefsKey = 'recently_played_songs';

  @override
  List<Song> build() {
    _loadFromPrefs();
    return [];
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStrings = prefs.getStringList(_prefsKey) ?? [];
    final loaded = jsonStrings
        .map((s) => Song.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();

    final seenKeys = <String>{};
    final deduped = <Song>[];
    for (final song in loaded) {
      final dedupeKey = '${song.title}|${song.artist}';
      if (seenKeys.add(dedupeKey)) {
        deduped.add(song);
      }
    }
    state = deduped;
    if (deduped.length != loaded.length) {
      await _saveToPrefs();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStrings = state.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_prefsKey, jsonStrings);
  }

  Future<void> addSong(Song song) async {
    final withoutDuplicate = state
        .where((s) =>
    s.identityKey != song.identityKey &&
        !(s.title == song.title && s.artist == song.artist))
        .toList();
    state = [song, ...withoutDuplicate].take(maxRecents).toList();
    await _saveToPrefs();
  }
}

final recentlyPlayedProvider =
NotifierProvider<RecentlyPlayedNotifier, List<Song>>(RecentlyPlayedNotifier.new);

// ---- User-created playlists (naka-save sa disk) ----
class UserPlaylistsNotifier extends Notifier<List<UserPlaylist>> {
  static const String _prefsKey = 'user_playlists';

  @override
  List<UserPlaylist> build() {
    _loadFromPrefs();
    return [];
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStrings = prefs.getStringList(_prefsKey) ?? [];
    state = jsonStrings
        .map((s) => UserPlaylist.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStrings = state.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_prefsKey, jsonStrings);
  }

  Future<UserPlaylist> createPlaylist(String name) async {
    final playlist = UserPlaylist(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
    );
    state = [...state, playlist];
    await _saveToPrefs();
    return playlist;
  }

  Future<void> rename(String id, String newName) async {
    state = state.map((p) => p.id == id ? p.copyWith(name: newName) : p).toList();
    await _saveToPrefs();
  }

  Future<void> setCoverImage(String id, String? path) async {
    state = state.map((p) => p.id == id ? p.copyWith(coverImagePath: path) : p).toList();
    await _saveToPrefs();
  }

  Future<void> togglePin(String id) async {
    state = state.map((p) => p.id == id ? p.copyWith(isPinned: !p.isPinned) : p).toList();
    await _saveToPrefs();
  }

  Future<void> delete(String id) async {
    state = state.where((p) => p.id != id).toList();
    await _saveToPrefs();
  }

  Future<void> addSongs(String id, List<Song> songsToAdd) async {
    state = state.map((p) {
      if (p.id != id) return p;
      final existingKeys = p.songs.map((s) => s.identityKey).toSet();
      final newSongs =
      songsToAdd.where((s) => !existingKeys.contains(s.identityKey));
      return p.copyWith(songs: [...p.songs, ...newSongs]);
    }).toList();
    await _saveToPrefs();
  }

  Future<void> removeSong(String id, Song song) async {
    state = state.map((p) {
      if (p.id != id) return p;
      return p.copyWith(
          songs: p.songs.where((s) => s.identityKey != song.identityKey).toList());
    }).toList();
    await _saveToPrefs();
  }

  Future<void> reorderSongs(String id, int oldIndex, int newIndex) async {
    state = state.map((p) {
      if (p.id != id) return p;
      final songs = [...p.songs];
      var target = newIndex;
      if (target > oldIndex) target -= 1;
      final song = songs.removeAt(oldIndex);
      songs.insert(target, song);
      return p.copyWith(songs: songs);
    }).toList();
    await _saveToPrefs();
  }
}

final userPlaylistsProvider =
NotifierProvider<UserPlaylistsNotifier, List<UserPlaylist>>(
    UserPlaylistsNotifier.new);

// ---- Liked albums (naka-save sa disk, gamit ang album title bilang key) ----
class LikedAlbumsNotifier extends Notifier<Set<String>> {
  static const String _prefsKey = 'liked_albums';

  @override
  Set<String> build() {
    _loadFromPrefs();
    return {};
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? [];
    state = list.toSet();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, state.toList());
  }

  Future<void> toggleLike(String albumTitle) async {
    final updated = {...state};
    if (updated.contains(albumTitle)) {
      updated.remove(albumTitle);
    } else {
      updated.add(albumTitle);
    }
    state = updated;
    await _saveToPrefs();
  }
}

final likedAlbumsProvider =
NotifierProvider<LikedAlbumsNotifier, Set<String>>(LikedAlbumsNotifier.new);

// ---- Liked playlists (naka-save sa disk, gamit ang playlist title bilang key) ----
class LikedPlaylistsNotifier extends Notifier<Set<String>> {
  static const String _prefsKey = 'liked_playlists';

  @override
  Set<String> build() {
    _loadFromPrefs();
    return {};
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? [];
    state = list.toSet();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, state.toList());
  }

  Future<void> toggleLike(String playlistTitle) async {
    final updated = {...state};
    if (updated.contains(playlistTitle)) {
      updated.remove(playlistTitle);
    } else {
      updated.add(playlistTitle);
    }
    state = updated;
    await _saveToPrefs();
  }
}

final likedPlaylistsProvider =
NotifierProvider<LikedPlaylistsNotifier, Set<String>>(LikedPlaylistsNotifier.new);

// ---- Playback queue (para sa next/previous at shuffle) ----
class PlaybackQueueState {
  final List<Song> songs;
  final int currentIndex;
  final bool shuffleEnabled;
  final List<int> shuffledOrder;

  const PlaybackQueueState({
    this.songs = const [],
    this.currentIndex = 0,
    this.shuffleEnabled = false,
    this.shuffledOrder = const [],
  });

  PlaybackQueueState copyWith({
    List<Song>? songs,
    int? currentIndex,
    bool? shuffleEnabled,
    List<int>? shuffledOrder,
  }) {
    return PlaybackQueueState(
      songs: songs ?? this.songs,
      currentIndex: currentIndex ?? this.currentIndex,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      shuffledOrder: shuffledOrder ?? this.shuffledOrder,
    );
  }
}

class PlaybackQueueNotifier extends Notifier<PlaybackQueueState> {
  @override
  PlaybackQueueState build() => const PlaybackQueueState();

  Song? get currentSong {
    if (state.songs.isEmpty) return null;
    final actualIndex = state.shuffleEnabled && state.shuffledOrder.isNotEmpty
        ? state.shuffledOrder[state.currentIndex]
        : state.currentIndex;
    return state.songs[actualIndex];
  }

  void startQueue(List<Song> songs, Song startSong) {
    if (songs.isEmpty) {
      state = state.copyWith(songs: songs, currentIndex: 0, shuffledOrder: []);
      return;
    }
    final startIndex =
    songs.indexWhere((s) => s.identityKey == startSong.identityKey);
    final safeStartIndex = startIndex == -1 ? 0 : startIndex;

    if (state.shuffleEnabled) {
      final order = List<int>.generate(songs.length, (i) => i);
      order.shuffle();
      order.remove(safeStartIndex);
      state = PlaybackQueueState(
        songs: songs,
        currentIndex: 0,
        shuffleEnabled: true,
        shuffledOrder: [safeStartIndex, ...order],
      );
    } else {
      state = PlaybackQueueState(
        songs: songs,
        currentIndex: safeStartIndex,
        shuffleEnabled: false,
        shuffledOrder: const [],
      );
    }
  }

  void toggleShuffle() {
    if (state.songs.isEmpty) {
      state = state.copyWith(shuffleEnabled: !state.shuffleEnabled);
      return;
    }
    if (!state.shuffleEnabled) {
      final currentActualIndex = state.currentIndex;
      final order = List<int>.generate(state.songs.length, (i) => i);
      order.shuffle();
      order.remove(currentActualIndex);
      state = state.copyWith(
        shuffleEnabled: true,
        shuffledOrder: [currentActualIndex, ...order],
        currentIndex: 0,
      );
    } else {
      final current = currentSong;
      final idx = current != null
          ? state.songs.indexWhere((s) => s.identityKey == current.identityKey)
          : 0;
      state = state.copyWith(
        shuffleEnabled: false,
        currentIndex: idx == -1 ? 0 : idx,
      );
    }
  }

  Song? next() {
    if (state.songs.isEmpty) return null;
    final length =
    state.shuffleEnabled ? state.shuffledOrder.length : state.songs.length;
    final newIndex = (state.currentIndex + 1) % length;
    state = state.copyWith(currentIndex: newIndex);
    return currentSong;
  }

  Song? previous() {
    if (state.songs.isEmpty) return null;
    final length =
    state.shuffleEnabled ? state.shuffledOrder.length : state.songs.length;
    final newIndex = (state.currentIndex - 1 + length) % length;
    state = state.copyWith(currentIndex: newIndex);
    return currentSong;
  }
}

final playbackQueueProvider =
NotifierProvider<PlaybackQueueNotifier, PlaybackQueueState>(
    PlaybackQueueNotifier.new);

// ---- Audio playback ----
class AudioPlayerState {
  final Song? currentSong;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool repeatOneEnabled;

  const AudioPlayerState({
    this.currentSong,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.repeatOneEnabled = false,
  });

  AudioPlayerState copyWith({
    Song? currentSong,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? repeatOneEnabled,
  }) {
    return AudioPlayerState(
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      repeatOneEnabled: repeatOneEnabled ?? this.repeatOneEnabled,
    );
  }
}

class AudioPlayerNotifier extends Notifier<AudioPlayerState> {
  late final MusicAudioHandler _handler;

  @override
  AudioPlayerState build() {
    _handler = ref.read(audioHandlerProvider);

    _handler.player.onPlayerStateChanged.listen((s) {
      state = state.copyWith(isPlaying: s == PlayerState.playing);
    });
    _handler.player.onPositionChanged.listen((p) {
      state = state.copyWith(position: p);
    });
    _handler.player.onDurationChanged.listen((d) {
      state = state.copyWith(duration: d);
    });
    _handler.player.onPlayerComplete.listen((_) {
      state = state.copyWith(isPlaying: false, position: Duration.zero);
      _handleSongComplete();
    });

    _handler.onSkipNext = () async {
      final nextSong = ref.read(playbackQueueProvider.notifier).next();
      if (nextSong != null) await playSong(nextSong);
    };
    _handler.onSkipPrevious = () async {
      final prevSong = ref.read(playbackQueueProvider.notifier).previous();
      if (prevSong != null) await playSong(prevSong);
    };

    ref.onDispose(_handler.player.dispose);
    return const AudioPlayerState();
  }

  Future<void> _handleSongComplete() async {
    if (state.repeatOneEnabled) {
      final current = state.currentSong;
      if (current != null) {
        if (current.assetPath != null) {
          await playAsset(current);
        } else if (current.filePath != null) {
          await playFile(current);
        }
      }
      return;
    }
    final nextSong = ref.read(playbackQueueProvider.notifier).next();
    if (nextSong != null) {
      await playSong(nextSong);
    }
  }

  Future<void> playAsset(Song song) async {
    state = state.copyWith(currentSong: song);
    _handler.setNowPlaying(song.title, song.artist);
    await _handler.player.play(AssetSource(song.assetPath!));
  }

  Future<void> playFile(Song song) async {
    state = state.copyWith(currentSong: song);
    _handler.setNowPlaying(song.title, song.artist);
    await _handler.player.play(DeviceFileSource(song.filePath!));
  }

  Future<void> playSong(Song song) async {
    if (song.assetPath != null) {
      await playAsset(song);
    } else if (song.filePath != null) {
      await playFile(song);
    }
    // Fire-and-forget: hindi na natin hinihintay matapos ang pag-save
    // sa disk bago tumugtog ang kanta — mas mabilis ngayon ang switch.
    ref.read(recentlyPlayedProvider.notifier).addSong(song);
  }

  Future<void> playFromQueue(List<Song> songs, Song startSong) async {
    ref.read(playbackQueueProvider.notifier).startQueue(songs, startSong);
    await playSong(startSong);
  }

  Future<void> shufflePlayCollection(List<Song> songs) async {
    if (songs.isEmpty) return;
    if (!ref.read(playbackQueueProvider).shuffleEnabled) {
      ref.read(playbackQueueProvider.notifier).toggleShuffle();
    }
    final randomSong = (songs.toList()..shuffle()).first;
    ref.read(playbackQueueProvider.notifier).startQueue(songs, randomSong);
    await playSong(randomSong);
  }

  void toggleRepeatOne() {
    state = state.copyWith(repeatOneEnabled: !state.repeatOneEnabled);
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await _handler.pause();
    } else {
      await _handler.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _handler.seek(position);
  }
}

final audioPlayerProvider = NotifierProvider<AudioPlayerNotifier, AudioPlayerState>(
    AudioPlayerNotifier.new);

// ---- Search bar expand/collapse ----
class IsSearchingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setSearching(bool value) => state = value;
}

final isSearchingProvider =
NotifierProvider<IsSearchingNotifier, bool>(IsSearchingNotifier.new);

// ---- Liked songs (naka-save sa disk, gamit ang song identityKey bilang key) ----
class LikedSongsNotifier extends Notifier<Set<String>> {
  static const String _prefsKey = 'liked_songs';

  @override
  Set<String> build() {
    _loadFromPrefs();
    return {};
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? [];
    state = list.toSet();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, state.toList());
  }

  Future<void> toggleLike(String songKey) async {
    final updated = {...state};
    if (updated.contains(songKey)) {
      updated.remove(songKey);
    } else {
      updated.add(songKey);
    }
    state = updated;
    await _saveToPrefs();
  }
}

final likedSongsProvider =
NotifierProvider<LikedSongsNotifier, Set<String>>(LikedSongsNotifier.new);

// ---- View mode ng "All Songs" section (list o grid) ----
enum SongsViewMode { list, grid }

class SongsViewModeNotifier extends Notifier<SongsViewMode> {
  @override
  SongsViewMode build() => SongsViewMode.list;

  void toggle() {
    state = state == SongsViewMode.list ? SongsViewMode.grid : SongsViewMode.list;
  }
}

final songsViewModeProvider =
NotifierProvider<SongsViewModeNotifier, SongsViewMode>(SongsViewModeNotifier.new);

// ---- Custom order ng "All Songs" (list ng identityKeys, naka-save sa disk) ----
class AllSongsOrderNotifier extends Notifier<List<String>> {
  static const String _prefsKey = 'all_songs_order';

  @override
  List<String> build() {
    _loadFromPrefs();
    return [];
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList(_prefsKey) ?? [];
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, state);
  }

  Future<void> setOrder(List<String> keys) async {
    state = keys;
    await _saveToPrefs();
  }
}

final allSongsOrderProvider =
NotifierProvider<AllSongsOrderNotifier, List<String>>(AllSongsOrderNotifier.new);