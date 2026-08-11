import 'dart:io';
import 'package:flutter/widgets.dart';

class Song {
  final String title;
  final String artist;
  final String? assetPath;
  final String? filePath;
  final String? coverImagePath; // asset path — para sa bundled songs (mula sa album/playlist)
  final String? coverFilePath;  // file path — para sa imported songs (via image_picker)

  const Song({
    required this.title,
    required this.artist,
    this.assetPath,
    this.filePath,
    this.coverImagePath,
    this.coverFilePath,
  }) : assert(assetPath != null || filePath != null,
  'Song must have either an assetPath or filePath');

  String get identityKey => assetPath ?? filePath ?? '$title|$artist';

  /// Ready-to-use na ImageProvider — file muna, tapos asset, tapos null.
  ImageProvider? get coverImageProvider {
    if (coverFilePath != null) return FileImage(File(coverFilePath!));
    if (coverImagePath != null) return AssetImage(coverImagePath!);
    return null;
  }

  Song copyWith({
    String? coverImagePath,
    String? coverFilePath,
  }) {
    return Song(
      title: title,
      artist: artist,
      assetPath: assetPath,
      filePath: filePath,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      coverFilePath: coverFilePath ?? this.coverFilePath,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'artist': artist,
    'assetPath': assetPath,
    'filePath': filePath,
    'coverImagePath': coverImagePath,
    'coverFilePath': coverFilePath,
  };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
    title: json['title'] as String,
    artist: json['artist'] as String,
    assetPath: json['assetPath'] as String?,
    filePath: json['filePath'] as String?,
    coverImagePath: json['coverImagePath'] as String?,
    coverFilePath: json['coverFilePath'] as String?,
  );
}