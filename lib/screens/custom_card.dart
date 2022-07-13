import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class CustomCard extends StatelessWidget {
  String title;
  String image;
  String content;
  Color color;
  // ignore: use_key_in_widget_constructors
  CustomCard(
      {required this.title,
      required this.content,
      required this.image,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        elevation: 8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: SizedBox(
                height: 80,
                child: Center(
                  child: CircleAvatar(
                      radius: 80,
                      backgroundColor: color,
                      child: Image(
                        image: AssetImage(image),
                        height: 60,
                      )),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Center(
                child: Text(title,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 10.0)),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(6),
                child: Center(
                    child: Text(
                  content,
                  style: GoogleFonts.poppins(
                      fontSize: 10.0, fontWeight: FontWeight.bold),
                )))
          ],
        ),
      ),
    );
  }
}
