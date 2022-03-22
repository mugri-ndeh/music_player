import 'package:Excite/screens/home_screen/api/Songs.dart';
import 'package:Excite/screens/home_screen/api/local_storage.dart';
import 'package:Excite/screens/home_screen/notifiers/audio_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FavouritesWidget extends StatefulWidget {
  FavouritesWidget({
    Key? key,
    required this.audioHelper,
  }) : super(key: key);
  final AudioHelper audioHelper;

  @override
  State<FavouritesWidget> createState() => _FavouritesWidgetState();
}

class _FavouritesWidgetState extends State<FavouritesWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<FavouritesHelper>(
        builder: (_, favProv, __) => favProv.favourites.length == 0
            ? Center(
                child: Text(
                  'No favourites',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                itemCount: favProv.favourites.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.audioHelper.getIndex();
                          widget.audioHelper
                              .setInitialPlaylist(favProv.favourites
                                  .map((e) => Songs.fromJson(e))
                                  .toList())
                              .then((value) {
                            widget.audioHelper.getIndex();
                            widget.audioHelper.playIndex(index);
                            print(Songs.fromJson(favProv.favourites[index]));
                          });
                        });
                      },
                      child: Dismissible(
                        key: Key(favProv.favourites
                            .map((e) => Songs.fromJson(e))
                            .toList()[index]
                            .songName),
                        onDismissed: (direction) {
                          debugPrint('DELETE');
                          setState(() {
                            favProv.remove(
                                Songs.fromJson(favProv.favourites[index]));
                            Fluttertoast.showToast(
                                msg: 'Removed from favourites');
                          });
                        },
                        background: Container(color: Colors.grey),
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: Songs.fromJson(
                                            favProv.favourites[index])
                                        .songImage,
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  Songs.fromJson(favProv.favourites[index])
                                      .songArtist,
                                  style: GoogleFonts.poppins(
                                      textStyle: TextStyle(fontSize: 14),
                                      color: Colors.white),
                                ),
                                subtitle: Text(
                                  Songs.fromJson(favProv.favourites[index])
                                      .songName,
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
                    ),
                  );
                },
              ),
      ),
    );
  }
}
