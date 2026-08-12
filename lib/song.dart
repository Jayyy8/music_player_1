import 'dart:io';
import 'package:flutter/widgets.dart';

class Song {
  final String? id;
  final String title;
  final String artist;
  final String? assetPath;
  final String? filePath;
  final String? coverImagePath;
  final String? coverFilePath;

  const Song({
    this.id,
    required this.title,
    required this.artist,
    this.assetPath,
    this.filePath,
    this.coverImagePath,
    this.coverFilePath,
  }) : assert(assetPath != null || filePath != null,
  'Song must have either an assetPath or filePath');


  String get identityKey => id ?? assetPath ?? filePath ?? '$title|$artist';

  ImageProvider? get coverImageProvider {
    if (coverFilePath != null) return FileImage(File(coverFilePath!));
    if (coverImagePath != null) return AssetImage(coverImagePath!);
    return null;
  }

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? assetPath,
    String? filePath,
    String? coverImagePath,
    String? coverFilePath,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      assetPath: assetPath ?? this.assetPath,
      filePath: filePath ?? this.filePath,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      coverFilePath: coverFilePath ?? this.coverFilePath,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'assetPath': assetPath,
    'filePath': filePath,
    'coverImagePath': coverImagePath,
    'coverFilePath': coverFilePath,
  };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
    id: json['id'] as String?,
    title: json['title'] as String,
    artist: json['artist'] as String,
    assetPath: json['assetPath'] as String?,
    filePath: json['filePath'] as String?,
    coverImagePath: json['coverImagePath'] as String?,
    coverFilePath: json['coverFilePath'] as String?,
  );
}