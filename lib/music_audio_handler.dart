import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart' as ap;

class MusicAudioHandler extends BaseAudioHandler with SeekHandler {
  final ap.AudioPlayer player = ap.AudioPlayer();

  Future<void> Function()? onSkipNext;
  Future<void> Function()? onSkipPrevious;

  MusicAudioHandler() {
    player.onPlayerStateChanged.listen((state) {
      playbackState.add(playbackState.value.copyWith(
        playing: state == ap.PlayerState.playing,
        controls: [
          MediaControl.skipToPrevious,
          state == ap.PlayerState.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
        },
        processingState: AudioProcessingState.ready,
      ));
    });

    player.onPositionChanged.listen((position) {
      playbackState.add(playbackState.value.copyWith(updatePosition: position));
    });

    player.onDurationChanged.listen((duration) {
      final current = mediaItem.value;
      if (current != null) {
        mediaItem.add(current.copyWith(duration: duration));
      }
    });
  }

  void setNowPlaying(String title, String artist) {
    mediaItem.add(MediaItem(id: '$title|$artist', title: title, artist: artist));
  }

  @override
  Future<void> play() => player.resume();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> skipToNext() async => onSkipNext?.call();

  @override
  Future<void> skipToPrevious() async => onSkipPrevious?.call();

  @override
  Future<void> stop() async {
    await player.stop();
    await super.stop();
  }
}