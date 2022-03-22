import 'package:Excite/screens/home_screen/notifiers/audio_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../api/Songs.dart';

class AllSongs extends StatefulWidget {
  AllSongs({Key? key, required this.audioHelper, required this.playsongs})
      : super(key: key);
  final AudioHelper audioHelper;
  final List<Songs> playsongs;

  @override
  State<AllSongs> createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  int taps = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.audioHelper
        .setInitialPlaylist(widget.playsongs)
        .then((value) => print('DONE'));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioHelper>(
      builder: (_, helper, __) {
        return SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
            itemCount: widget.playsongs.length,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.audioHelper
                          .setInitialPlaylist(widget.playsongs)
                          .then((value) {
                        helper.getIndex();
                        helper.playIndex(index);
                      });
                    });
                  },
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: widget.playsongs[index].songImage,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            widget.playsongs[index].songArtist,
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(fontSize: 14),
                                color: Colors.white),
                          ),
                          subtitle: Text(
                            widget.playsongs[index].songName,
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0)),
                          selected: true,
                          selectedTileColor:
                              Colors.blueAccent.shade100.withOpacity(0.1),
                        ),
                      )),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
