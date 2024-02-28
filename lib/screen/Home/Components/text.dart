import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget textTitleInHome(String title, double size) {
  return Text(
    title,
    style: GoogleFonts.aBeeZee(
      color: Colors.black,
      fontSize: size,
    ),
  );
}
