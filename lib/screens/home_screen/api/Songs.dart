class Songs {
  final String id;
  final String songName;
  final String songArtist;
  final String songImage;
  final String songSrc;

  const Songs({
    required this.id,
    required this.songName,
    required this.songArtist,
    required this.songImage,
    required this.songSrc,
  });

  factory Songs.fromJson(Map<String, dynamic> json) => Songs(
        id: json['id'],
        songArtist: json['song_artist'],
        songName: json['song_name'],
        songImage: json['song_image'],
        songSrc: json["song_src"],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'song_name': songName,
        'song_artist': songArtist,
        'song_image': songImage,
        "song_src": songSrc,
      };
}
