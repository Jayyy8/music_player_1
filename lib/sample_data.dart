import 'package:flutter/cupertino.dart';
import 'song.dart';
import 'music_models.dart';

const List<Album> sampleAlbums = [
  Album(
    title: 'Future Nostalgia',
    artist: 'Dua Lipa',
    coverGradient: [CupertinoColors.systemPurple, CupertinoColors.systemPink],
    coverImagePath: 'assets/images/future_nostalgia.jpeg',
    songs: [
      Song(title: "Don't Start Now", artist: 'Dua Lipa', assetPath: 'audio/dont_start_now.mp3', coverImagePath: 'assets/images/future_nostalgia.jpeg'),
      Song(title: 'Physical', artist: 'Dua Lipa', assetPath: 'audio/physical.mp3', coverImagePath: 'assets/images/future_nostalgia.jpeg'),
      Song(title: 'Levitating', artist: 'Dua Lipa', assetPath: 'audio/levitating.mp3', coverImagePath: 'assets/images/future_nostalgia.jpeg'),
      Song(title: 'Break My Heart', artist: 'Dua Lipa', assetPath: 'audio/break_my_heart.mp3', coverImagePath: 'assets/images/future_nostalgia.jpeg'),
      Song(title: 'Cool', artist: 'Dua Lipa', assetPath: 'audio/cool.mp3', coverImagePath: 'assets/images/future_nostalgia.jpeg'),
      Song(title: 'Hallucinate', artist: 'Dua Lipa', assetPath: 'audio/hallucinate.mp3', coverImagePath: 'assets/images/future_nostalgia.jpeg'),
    ],
  ),
  Album(
    title: 'Cutterpillow',
    artist: 'Eraserheads',
    coverGradient: [CupertinoColors.systemGreen, CupertinoColors.systemYellow],
    coverImagePath: 'assets/images/cutterpillow.jpeg',
    songs: [
      Song(title: 'Superproxy', artist: 'Eraserheads', assetPath: 'audio/superproxy.mp3', coverImagePath: 'assets/images/cutterpillow.jpeg'),
      Song(title: 'Fine Time', artist: 'Eraserheads', assetPath: 'audio/fine_time.mp3', coverImagePath: 'assets/images/cutterpillow.jpeg'),
      Song(title: 'Overdrive', artist: 'Eraserheads', assetPath: 'audio/overdrive.mp3', coverImagePath: 'assets/images/cutterpillow.jpeg'),
      Song(title: 'Torpedo', artist: 'Eraserheads', assetPath: 'audio/torpedo.mp3', coverImagePath: 'assets/images/cutterpillow.jpeg'),
      Song(title: 'Huwag Mo Nang Itanong', artist: 'Eraserheads', assetPath: 'audio/huwag_mo_nang_itanong.mp3', coverImagePath: 'assets/images/cutterpillow.jpeg'),
      Song(title: "Poorman's Grave", artist: 'Eraserheads', assetPath: 'audio/poormans_grave.mp3', coverImagePath: 'assets/images/cutterpillow.jpeg'),
      Song(title: 'Ang Huling El Bimbo', artist: 'Eraserheads', assetPath: 'audio/ang_huling_el_bimbo.mp3', coverImagePath: 'assets/images/cutterpillow.jpeg'),
    ],
  ),
  Album(
    title: 'Pebble House, Vol. 1: Kuwaderno',
    artist: 'Ben&Ben',
    coverGradient: [CupertinoColors.systemYellow, CupertinoColors.systemOrange],
    coverImagePath: 'assets/images/pebble_house.jpeg',
    songs: [
      Song(title: 'Upuan', artist: 'Ben&Ben', assetPath: 'audio/upuan.mp3', coverImagePath: 'assets/images/pebble_house.jpeg'),
      Song(title: 'Kuwaderno', artist: 'Ben&Ben', assetPath: 'audio/kuwaderno.mp3', coverImagePath: 'assets/images/pebble_house.jpeg'),
      Song(title: 'Pasalubong', artist: 'Ben&Ben feat. Moira Dela Torre', assetPath: 'audio/pasalubong.mp3', coverImagePath: 'assets/images/pebble_house.jpeg'),
      Song(title: 'Sugat', artist: 'Ben&Ben feat. Munimuni', assetPath: 'audio/sugat.mp3', coverImagePath: 'assets/images/pebble_house.jpeg'),
      Song(title: 'Lunod', artist: 'Ben&Ben feat. Zild & juan karlos', assetPath: 'audio/lunod.mp3', coverImagePath: 'assets/images/pebble_house.jpeg'),
      Song(title: 'Kapangyarihan', artist: 'Ben&Ben feat. SB19', assetPath: 'audio/kapangyarihan.mp3', coverImagePath: 'assets/images/pebble_house.jpeg'),
    ],
  ),
  Album(
    title: 'Di Ilaw sa Gabing Mapanglaw (Live at Teatrino)',
    artist: 'Dilaw',
    coverGradient: [CupertinoColors.systemIndigo, CupertinoColors.systemBlue],
    coverImagePath: 'assets/images/dilaw.jpeg',
    songs: [
      Song(title: 'Hithit Buwang', artist: 'Dilaw', assetPath: 'audio/hithit_buwang.mp3', coverImagePath: 'assets/images/dilaw.jpeg'),
      Song(title: 'Walwal', artist: 'Dilaw', assetPath: 'audio/walwal.mp3', coverImagePath: 'assets/images/dilaw.jpeg'),
      Song(title: '3019', artist: 'Dilaw', assetPath: 'audio/3019.mp3', coverImagePath: 'assets/images/dilaw.jpeg'),
      Song(title: 'Kaloy', artist: 'Dilaw', assetPath: 'audio/kaloy.mp3', coverImagePath: 'assets/images/dilaw.jpeg'),
      Song(title: 'Maskara', artist: 'Dilaw', assetPath: 'audio/maskara.mp3', coverImagePath: 'assets/images/dilaw.jpeg'),
      Song(title: 'Goodnight Prayer', artist: 'Dilaw', assetPath: 'audio/goodnight_prayer.mp3', coverImagePath: 'assets/images/dilaw.jpeg'),
      Song(title: 'Uhaw', artist: 'Dilaw', assetPath: 'audio/uhaw.mp3', coverImagePath: 'assets/images/dilaw.jpeg'),
      Song(title: 'Janice', artist: 'Dilaw', assetPath: 'audio/janice.mp3', coverImagePath: 'assets/images/dilaw.jpeg'),
      Song(title: 'Sansinukob', artist: 'Dilaw', assetPath: 'audio/sansinukob.mp3', coverImagePath: 'assets/images/dilaw.jpeg'),
      Song(title: 'Orasa', artist: 'Dilaw', assetPath: 'audio/orasa.mp3', coverImagePath: 'assets/images/dilaw.jpeg'),
    ],
  ),
  Album(
    title: 'Ghost Stories',
    artist: 'Coldplay',
    coverGradient: [CupertinoColors.systemBlue, CupertinoColors.systemTeal],
    coverImagePath: 'assets/images/ghost_stories.jpeg',
    songs: [
      Song(title: 'Always in My Head', artist: 'Coldplay', assetPath: 'audio/always_in_my_head.mp3', coverImagePath: 'assets/images/ghost_stories.jpeg'),
      Song(title: 'Magic', artist: 'Coldplay', assetPath: 'audio/magic.mp3', coverImagePath: 'assets/images/ghost_stories.jpeg'),
      Song(title: 'Ink', artist: 'Coldplay', assetPath: 'audio/ink.mp3', coverImagePath: 'assets/images/ghost_stories.jpeg'),
      Song(title: 'True Love', artist: 'Coldplay', assetPath: 'audio/true_love.mp3', coverImagePath: 'assets/images/ghost_stories.jpeg'),
      Song(title: 'Midnight', artist: 'Coldplay', assetPath: 'audio/midnight.mp3', coverImagePath: 'assets/images/ghost_stories.jpeg'),
      Song(title: 'A Sky Full of Stars', artist: 'Coldplay', assetPath: 'audio/a_sky_full_of_stars.mp3', coverImagePath: 'assets/images/ghost_stories.jpeg'),
      Song(title: 'O', artist: 'Coldplay', assetPath: 'audio/o.mp3', coverImagePath: 'assets/images/ghost_stories.jpeg'),
    ],
  ),
  Album(
    title: '21',
    artist: 'Adele',
    coverGradient: [CupertinoColors.systemPink, CupertinoColors.systemRed],
    coverImagePath: 'assets/images/adele_21.jpeg',
    songs: [
      Song(title: 'Rolling in the Deep', artist: 'Adele', assetPath: 'audio/rolling_in_the_deep.mp3', coverImagePath: 'assets/images/adele_21.jpeg'),
      Song(title: 'Rumour Has It', artist: 'Adele', assetPath: 'audio/rumour_has_it.mp3', coverImagePath: 'assets/images/adele_21.jpeg'),
      Song(title: 'Turning Tables', artist: 'Adele', assetPath: 'audio/turning_tables.mp3', coverImagePath: 'assets/images/adele_21.jpeg'),
      Song(title: 'Set Fire to the Rain', artist: 'Adele', assetPath: 'audio/set_fire_to_the_rain.mp3', coverImagePath: 'assets/images/adele_21.jpeg'),
      Song(title: 'Take It All', artist: 'Adele', assetPath: 'audio/take_it_all.mp3', coverImagePath: 'assets/images/adele_21.jpeg'),
      Song(title: 'Someone Like You', artist: 'Adele', assetPath: 'audio/someone_like_you.mp3', coverImagePath: 'assets/images/adele_21.jpeg'),
      Song(title: 'One and Only', artist: 'Adele', assetPath: 'audio/one_and_only.mp3', coverImagePath: 'assets/images/adele_21.jpeg'),
      Song(title: 'Lovesong', artist: 'Adele', assetPath: 'audio/lovesong.mp3', coverImagePath: 'assets/images/adele_21.jpeg'),
    ],
  ),
];

const List<Playlist> samplePlaylists = [
  Playlist(
    title: 'OPM Favorites',
    genre: 'OPM',
    coverGradient: [CupertinoColors.systemPink, CupertinoColors.systemOrange],
    coverImagePath: 'assets/images/opm_favorites.jpeg',
    songs: [
      Song(title: 'What if I miss you for the rest of my life?', artist: 'Janine Berdin', assetPath: 'audio/what_if_i_miss_you_for_the_rest_of_my_life.mp3', coverImagePath: 'assets/images/janine_berdin.png'),
      Song(title: 'Ere', artist: 'juan karlos', assetPath: 'audio/ere.mp3', coverImagePath: 'assets/images/juan_karlos.jpeg'),
      Song(title: 'Multo', artist: 'Cup of Joe', assetPath: 'audio/multo.mp3', coverImagePath: 'assets/images/cup_of_joe.jpeg'),
      Song(title: 'Kalapastangan', artist: 'fitterkarma', assetPath: 'audio/kalapastangan.mp3', coverImagePath: 'assets/images/fitterkarma.jpeg'),
      Song(title: 'Ang Wakas', artist: 'Arthur Miguel', assetPath: 'audio/ang_wakas.mp3', coverImagePath: 'assets/images/arthur_miguel.jpeg'),
      Song(title: 'Ikaw lang Patutunguhan', artist: 'Amiel Sol', assetPath: 'audio/ikaw_lang_patutunguhan.mp3', coverImagePath: 'assets/images/amiel_sol.jpeg'),
      Song(title: 'TAKE ALL THE LOVE', artist: 'Arthur Nery', assetPath: 'audio/take_all_the_love.mp3', coverImagePath: 'assets/images/arthur_nery.jpeg'),
      Song(title: 'Nandito Ako', artist: 'Rob Deniel', assetPath: 'audio/nandito_ako.mp3', coverImagePath: 'assets/images/rob_deniel.jpeg'),
      Song(title: 'Paalam, Leonora', artist: 'Sugarcane', assetPath: 'audio/paalam_leonora.mp3', coverImagePath: 'assets/images/sugarcane.jpeg'),
      Song(title: 'Lifetime (Reimagined)', artist: 'Ben&Ben', assetPath: 'audio/lifetime.mp3', coverImagePath: 'assets/images/ben&ben.jpeg'),
    ],
  ),
  Playlist(
    title: 'Chill Acoustic',
    genre: 'Acoustic',
    coverGradient: [CupertinoColors.systemBrown, CupertinoColors.systemYellow],
    coverImagePath: 'assets/images/chill_acoustic.jpeg',
    songs: [
      Song(title: 'Perfect', artist: 'Ed Sheeran', assetPath: 'audio/perfect.mp3', coverImagePath: 'assets/images/perfect.jpeg'),
      Song(title: 'Gravity', artist: 'John Mayer', assetPath: 'audio/gravity.mp3', coverImagePath: 'assets/images/gravity.jpeg'),
      Song(title: "I'm Yours", artist: 'Jason Mraz', assetPath: 'audio/im_yours.mp3', coverImagePath: 'assets/images/im_yours.jpeg'),
      Song(title: 'Riptide', artist: 'Vance Joy', assetPath: 'audio/riptide.mp3', coverImagePath: 'assets/images/riptide.jpeg'),
      Song(title: "Don't Know Why", artist: 'Norah Jones', assetPath: 'audio/dont_know_why.mp3', coverImagePath: 'assets/images/dont_know_why.jpeg'),
      Song(title: 'Skinny Love', artist: 'Bon Iver', assetPath: 'audio/skinny_love.mp3', coverImagePath: 'assets/images/skinny_love.jpeg'),
    ],
  ),
  Playlist(
    title: 'Workout Energy',
    genre: 'Pop',
    coverGradient: [CupertinoColors.systemRed, CupertinoColors.systemOrange],
    coverImagePath: 'assets/images/workout_energy.jpeg',
    songs: [
      Song(title: 'Stronger', artist: 'Kanye West', assetPath: 'audio/stronger.mp3', coverImagePath: 'assets/images/stronger.jpeg'),
      Song(title: 'Eye of the Tiger', artist: 'Survivor', assetPath: 'audio/eye_of_the_tiger.mp3', coverImagePath: 'assets/images/eye_of_the_tiger.jpeg'),
      Song(title: 'Uptown Funk', artist: 'Mark Ronson feat. Bruno Mars', assetPath: 'audio/uptown_funk.mp3', coverImagePath: 'assets/images/uptown_funk.jpeg'),
      Song(title: "Can't Stop the Feeling!", artist: 'Justin Timberlake', assetPath: 'audio/cant_stop_the_feeling.mp3', coverImagePath: 'assets/images/cant_stop_the_feeling.jpeg'),
      Song(title: 'Titanium', artist: 'David Guetta feat. Sia', assetPath: 'audio/titanium.mp3', coverImagePath: 'assets/images/titanium.jpeg'),
      Song(title: "Don't Stop Me Now", artist: 'Queen', assetPath: 'audio/dont_stop_me_now.mp3', coverImagePath: 'assets/images/dont_stop_me_now.jpeg'),
    ],
  ),
  Playlist(
    title: 'OPM Throwbacks',
    genre: 'OPM',
    coverGradient: [CupertinoColors.systemBlue, CupertinoColors.systemPurple],
    coverImagePath: 'assets/images/opm_throwbacks.jpeg',
    songs: [
      Song(title: 'Anak', artist: 'Freddie Aguilar', assetPath: 'audio/anak.mp3', coverImagePath: 'assets/images/anak.jpeg'),
      Song(title: 'Kahit Maputi Na Ang Buhok Ko', artist: 'Rey Valera', assetPath: 'audio/kahit_maputi_na_ang_buhok_ko.mp3', coverImagePath: 'assets/images/kahit_maputi_na_ang_buhok_ko.jpeg'),
      Song(title: 'Bituing Walang Ningning', artist: 'Sharon Cuneta', assetPath: 'audio/bituing_walang_ningning.mp3', coverImagePath: 'assets/images/bituing_walang_ningning.jpeg'),
      Song(title: 'Manila', artist: 'Hotdog', assetPath: 'audio/manila.mp3', coverImagePath: 'assets/images/manila.jpeg'),
      Song(title: 'Mr. DJ', artist: 'Sharon Cuneta', assetPath: 'audio/mr_dj.mp3', coverImagePath: 'assets/images/mr_dj.jpeg'),
    ],
  ),
  Playlist(
    title: 'Late Night Jazz',
    genre: 'Jazz',
    coverGradient: [CupertinoColors.systemIndigo, CupertinoColors.systemGrey],
    coverImagePath: 'assets/images/late_night_jazz.jpeg',
    songs: [
      Song(title: 'Fly Me to the Moon', artist: 'Frank Sinatra', assetPath: 'audio/fly_me_to_the_moon.mp3', coverImagePath: 'assets/images/fly_me_to_the_moon.jpeg'),
      Song(title: 'Take Five', artist: 'The Dave Brubeck Quartet', assetPath: 'audio/take_five.mp3', coverImagePath: 'assets/images/take_five.jpeg'),
      Song(title: 'My Funny Valentine', artist: 'Chet Baker', assetPath: 'audio/my_funny_valentine.mp3', coverImagePath: 'assets/images/my_funny_valentine.jpeg'),
      Song(title: 'Feeling Good', artist: 'Nina Simone', assetPath: 'audio/feeling_good.mp3', coverImagePath: 'assets/images/feeling_good.jpeg'),
      Song(title: 'What a Wonderful World', artist: 'Louis Armstrong', assetPath: 'audio/what_a_wonderful_world.mp3', coverImagePath: 'assets/images/what_a_wonderful_world.jpeg'),
      Song(title: 'Autumn Leaves', artist: 'Nat King Cole', assetPath: 'audio/autumn_leaves.mp3', coverImagePath: 'assets/images/autumn_leaves.jpeg'),
    ],
  ),
];

final List<Song> allSongs = () {
  final seen = <String>{};
  final combined = <Song>[];
  for (final album in sampleAlbums) {
    for (final s in album.songs) {
      if (seen.add(s.identityKey)) combined.add(s);
    }
  }
  for (final playlist in samplePlaylists) {
    for (final s in playlist.songs) {
      if (seen.add(s.identityKey)) combined.add(s);
    }
  }
  return combined;
}();