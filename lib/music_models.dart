import 'package:flutter/cupertino.dart';
import 'song.dart';

class Album {
  final String title;
  final String artist;
  final List<Color> coverGradient;
  final List<Song> songs;
  final String? coverImagePath;

  const Album({
    required this.title,
    required this.artist,
    required this.coverGradient,
    required this.songs,
    this.coverImagePath,
  });
}

class Playlist {
  final String title;
  final String genre;
  final List<Color> coverGradient;
  final List<Song> songs;
  final String? coverImagePath;

  const Playlist({
    required this.title,
    required this.genre,
    required this.coverGradient,
    required this.songs,
    this.coverImagePath,
  });
}

class UserPlaylist {
  final String id;
  final String name;
  final String? coverImagePath;
  final List<Song> songs;
  final bool isPinned;

  const UserPlaylist({
    required this.id,
    required this.name,
    this.coverImagePath,
    this.songs = const [],
    this.isPinned = false,
  });

  UserPlaylist copyWith({
    String? name,
    String? coverImagePath,
    List<Song>? songs,
    bool? isPinned,
  }) {
    return UserPlaylist(
      id: id,
      name: name ?? this.name,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      songs: songs ?? this.songs,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'coverImagePath': coverImagePath,
    'songs': songs.map((s) => s.toJson()).toList(),
    'isPinned': isPinned,
  };

  factory UserPlaylist.fromJson(Map<String, dynamic> json) => UserPlaylist(
    id: json['id'] as String,
    name: json['name'] as String,
    coverImagePath: json['coverImagePath'] as String?,
    songs: (json['songs'] as List<dynamic>)
        .map((s) => Song.fromJson(s as Map<String, dynamic>))
        .toList(),
    isPinned: json['isPinned'] as bool? ?? false,
  );
}