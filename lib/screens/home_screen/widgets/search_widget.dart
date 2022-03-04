import 'package:Excite/constants/constants.dart';
import 'package:Excite/screens/home_screen/api/Songs.dart';
import 'package:Excite/screens/home_screen/api/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchWidget extends StatefulWidget {
  final String text;
  final ValueChanged<String> onChanged;
  final String hintText;

  const SearchWidget({
    Key? key,
    required this.text,
    required this.onChanged,
    required this.hintText,
  }) : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final styleActive = TextStyle(color: white);
    final styleHint = TextStyle(color: white);
    final style = widget.text.isEmpty ? styleHint : styleActive;

    // return Container(
    //   height: 42,
    //   margin: const EdgeInsets.fromLTRB(12, 12, 12, 12),
    //   decoration: BoxDecoration(
    //     borderRadius: BorderRadius.circular(50),
    //     color: black,
    //     border: Border.all(color: white),
    //   ),
    //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    //   child: TextField(
    //     controller: controller,
    //     decoration: InputDecoration(
    //       icon: Icon(Icons.search, color: style.color),
    //       suffixIcon: widget.text.isNotEmpty
    //           ? GestureDetector(
    //               child: Icon(Icons.close, color: style.color),
    //               onTap: () {
    //                 controller.clear();
    //                 widget.onChanged('');
    //                 FocusScope.of(context).requestFocus(FocusNode());
    //               },
    //             )
    //           : null,
    //       hintText: widget.hintText,
    //       hintStyle: style,
    //       border: InputBorder.none,
    //     ),
    //     style: style,
    //     onChanged: widget.onChanged,
    //   ),
    // );

    return TypeAheadField<Songs?>(
      suggestionsCallback: SongsApi.getSongs,
      itemBuilder: (context, Songs? suggesion) {
        final song = suggesion;
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: song!.songImage,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                song.songArtist,
                style: GoogleFonts.poppins(
                    textStyle: TextStyle(fontSize: 14), color: Colors.white),
              ),
              subtitle: Text(
                song.songName,
                style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              selected: true,
              selectedTileColor: Colors.blueAccent.shade100.withOpacity(0.1),
            ),
          ),
        );
      },
      onSuggestionSelected: (Songs? suggesion) {},
    );
  }
}
