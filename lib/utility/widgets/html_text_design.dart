import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_leads/utility/widgets/size_config.dart';



class TextDesign {
  static Map<String, Style> commonStyles = {
    "p": Style(
      fontSize: FontSize(getFontSize(16)), // Use getFontSize here
    ),
    "strong": Style(
      fontFamily: GoogleFonts.mukta().fontFamily,
      fontWeight: FontWeight.bold,
      fontSize: FontSize(getFontSize(16)), // Use getFontSize here
      lineHeight: LineHeight(1.5),
    ),
    "s": Style(
      fontFamily: GoogleFonts.mukta().fontFamily,
      fontWeight: FontWeight.bold,
      fontSize: FontSize(getFontSize(16)), // Use getFontSize here
      lineHeight: LineHeight(1.5),
    ),
    "em": Style(
      fontFamily: GoogleFonts.mukta().fontFamily,
      fontWeight: FontWeight.bold,
      fontSize: FontSize(getFontSize(16)), // Use getFontSize here
      lineHeight: LineHeight(1.5),
    ),
    "u": Style(
      fontFamily: GoogleFonts.mukta().fontFamily,
      fontWeight: FontWeight.bold,
      fontSize: FontSize(getFontSize(16)), // Use getFontSize here
      lineHeight: LineHeight(1.5),
    ),
  };

  static Map<String, Style> FromtitleStyles = {
    "p": Style(
      fontSize: FontSize(14.0),
      maxLines: 1,
      textOverflow: TextOverflow.ellipsis,
      // alignment: Alignment.centerLeft,
      // textAlign: TextAlign.left,
    ),
    "strong": Style(
      fontWeight: FontWeight.bold,
      fontSize: FontSize(getFontSize(14)), // Use getFontSize here
      lineHeight: LineHeight(1.5),
      maxLines: 1,
      color: Colors.grey,
      textOverflow: TextOverflow.ellipsis,
      // alignment: Alignment.centerLeft,
      // textAlign: TextAlign.left,
    ),
    "s": Style(
      textDecoration: TextDecoration.lineThrough,
      fontSize: FontSize(getFontSize(14)), // Use getFontSize here
      lineHeight: LineHeight(1.5), color: Colors.grey,
      maxLines: 1,
      textOverflow: TextOverflow.ellipsis,
      // alignment: Alignment.centerLeft,
      // textAlign: TextAlign.left,
    ),
    "em": Style(
      fontStyle: FontStyle.italic,
      fontSize: FontSize(getFontSize(14)), // Use getFontSize here
      lineHeight: LineHeight(1.5), color: Colors.grey,
      textOverflow: TextOverflow.ellipsis,
      maxLines: 1,
      // alignment: Alignment.centerLeft,
      // textAlign: TextAlign.left,
    ),
    "u": Style(
      textDecoration: TextDecoration.underline,
      fontSize: FontSize(getFontSize(14)), // Use getFontSize here
      lineHeight: LineHeight(1.5), color: Colors.grey,
      maxLines: 1,
      textOverflow: TextOverflow.ellipsis,
      // alignment: Alignment.centerLeft,
      // textAlign: TextAlign.left,
    ),
  };

  static Map<String, Style> FromnewstitleStyles = {
    "p": Style(
      fontSize: FontSize(14.0),
      fontWeight: FontWeight.w500,
      maxLines: 3,
      textOverflow: TextOverflow.ellipsis,
      // Adding bold weight to paragraphs
    ),
    "strong": Style(
      fontWeight: FontWeight.w500, // Increased from bold to the maximum weight
      fontSize: FontSize(getFontSize(14)),
      lineHeight: LineHeight(1.5),
      color: Colors.grey,
      maxLines: 3,
      textOverflow: TextOverflow.ellipsis,
    ),
    "s": Style(
      textDecoration: TextDecoration.lineThrough,
      fontSize: FontSize(getFontSize(14)),
      lineHeight: LineHeight(1.5),
      color: Colors.grey,
      fontWeight: FontWeight.w500,
      maxLines: 3,
      textOverflow: TextOverflow.ellipsis,
      // Adding bold weight
    ),
    "em": Style(
      fontStyle: FontStyle.italic,
      fontSize: FontSize(getFontSize(14)),
      lineHeight: LineHeight(1.5),
      color: Colors.grey,
      fontWeight: FontWeight.w500, // Adding bold weight
      maxLines: 3,
      textOverflow: TextOverflow.ellipsis,
    ),
    "u": Style(
      textDecoration: TextDecoration.underline,
      fontSize: FontSize(getFontSize(14)),
      lineHeight: LineHeight(1.5),
      color: Colors.grey,
      fontWeight: FontWeight.w500, // Adding bold weight
      maxLines: 3,
      textOverflow: TextOverflow.ellipsis,
    ),
  };

  static Map<String, Style> FromDescriptionStyles = {
    "p": Style(
      fontSize: FontSize(18.0),
    ),
    "strong": Style(
        fontWeight: FontWeight.bold,
        fontSize: FontSize(getFontSize(14)), // Use getFontSize here
        lineHeight: LineHeight(1.5),
        color: Colors.black87,
        textOverflow: TextOverflow.ellipsis),
    "s": Style(
        textDecoration: TextDecoration.lineThrough,
        fontSize: FontSize(getFontSize(14)), // Use getFontSize here
        lineHeight: LineHeight(1.5),
        color: Colors.black87,
        textOverflow: TextOverflow.ellipsis),
    "em": Style(
        fontStyle: FontStyle.italic,
        fontSize: FontSize(getFontSize(14)), // Use getFontSize here
        lineHeight: LineHeight(1.5),
        color: Colors.black87,
        textOverflow: TextOverflow.ellipsis),
    "u": Style(
        textDecoration: TextDecoration.underline,
        fontSize: FontSize(getFontSize(14)), // Use getFontSize here
        lineHeight: LineHeight(1.5),
        color: Colors.black87,
        textOverflow: TextOverflow.ellipsis),
  };

  static Map<String, Style> cardlistdescription = {
    "p": Style(
      fontSize: FontSize(getFontSize(16)), // Use getFontSize here
    ),
    "strong": Style(
        fontFamily: GoogleFonts.mukta().fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: FontSize(getFontSize(16)), // Use getFontSize here
        textOverflow: TextOverflow.visible),
    "s": Style(
        fontFamily: GoogleFonts.mukta().fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: FontSize(getFontSize(16)), // Use getFontSize here
        textOverflow: TextOverflow.visible),
    "em": Style(
        fontFamily: GoogleFonts.mukta().fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: FontSize(getFontSize(16)), // Use getFontSize here
        textOverflow: TextOverflow.visible),
    "u": Style(
        fontFamily: GoogleFonts.mukta().fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: FontSize(getFontSize(16)), // Use getFontSize here
        textOverflow: TextOverflow.visible),
  };

  static Map<String, Style> tweledescription = {
    "p": Style(
      textOverflow: TextOverflow.ellipsis,
      maxLines: 2,
      fontSize: FontSize(getFontSize(14)), // Use getFontSize here
    ),
    "strong": Style(
      maxLines: 2,
      fontFamily: GoogleFonts.mukta().fontFamily,
      fontSize: FontSize(getFontSize(14)), // Use getFontSize here
      textOverflow: TextOverflow.ellipsis,
    ),
    "s": Style(
        maxLines: 2,
        fontFamily: GoogleFonts.mukta().fontFamily,
        fontSize: FontSize(getFontSize(14)), // Use getFontSize here
        textOverflow: TextOverflow.ellipsis),
    "em": Style(
        maxLines: 2,
        fontFamily: GoogleFonts.mukta().fontFamily,
        fontSize: FontSize(getFontSize(14)), // Use getFontSize here
        textOverflow: TextOverflow.ellipsis),
    "u": Style(
        maxLines: 2,
        fontFamily: GoogleFonts.mukta().fontFamily,
        fontSize: FontSize(getFontSize(14)), // Use getFontSize here
        textOverflow: TextOverflow.ellipsis),
  };

  static Map<String, Style> descriptionStyles = {
    "p": Style(
      fontSize: FontSize(14.0),
    ),
    "strong": Style(
      fontSize: FontSize(getFontSize(14)), // Use getFontSize here
      color: Colors.grey,
    ),
    "s": Style(
      textDecoration: TextDecoration.lineThrough,
      fontSize: FontSize(getFontSize(14)), // Use getFontSize here
      color: Colors.grey,
    ),
    "em": Style(
      fontStyle: FontStyle.italic,
      fontSize: FontSize(getFontSize(14)), // Use getFontSize here
      color: Colors.grey,
    ),
    "u": Style(
      textDecoration: TextDecoration.underline,
      fontSize: FontSize(getFontSize(14)), // Use getFontSize here
      color: Colors.grey,
    ),
  };

  static Map<String, Style> savepostFromDescriptionStyles = {
    "p": Style(
      maxLines: 2,
      textOverflow: TextOverflow.ellipsis,
      fontSize: FontSize(10.0),
    ),
    "strong": Style(
        maxLines: 3,
        fontSize: FontSize(getFontSize(14)),
        textOverflow: TextOverflow.ellipsis),
    "s": Style(
        maxLines: 3,
        fontSize: FontSize(getFontSize(14)),
        textOverflow: TextOverflow.ellipsis),
    "em": Style(
        maxLines: 3,
        fontSize: FontSize(getFontSize(14)),
        textOverflow: TextOverflow.ellipsis),
    "u": Style(
        maxLines: 3,
        fontSize: FontSize(getFontSize(14)),
        textOverflow: TextOverflow.ellipsis),
  };
}
