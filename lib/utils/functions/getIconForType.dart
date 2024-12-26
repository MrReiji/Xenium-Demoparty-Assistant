import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

IconData getIconForType(String key) {
  switch (key.toLowerCase()) {
    // Specific types
    case 'event':
      return Icons.event;
    case 'seminar':
      return Icons.school;
    case 'concert':
      return Icons.music_note;
    case 'deadline':
      return Icons.warning;
    case 'compo':
    case 'competition':
      return Icons.code;

    // FontAwesome icons
    case 'userlock':
      return FontAwesomeIcons.userLock;
    case 'cog':
      return FontAwesomeIcons.cog;
    case 'infocircle':
      return FontAwesomeIcons.infoCircle;
    case 'bullhorn':
      return FontAwesomeIcons.bullhorn;
    case 'users':
      return FontAwesomeIcons.users;
    case 'exclamationtriangle':
      return FontAwesomeIcons.exclamationTriangle;
    case 'question':
      return FontAwesomeIcons.question;
    case 'newspaper':
      return FontAwesomeIcons.newspaper;
    case 'video':
      return FontAwesomeIcons.video;
    case 'calendar':
      return FontAwesomeIcons.calendar;
    case 'trophy':
      return FontAwesomeIcons.trophy;
    case 'book':
      return FontAwesomeIcons.book;
    case 'desktop':
      return FontAwesomeIcons.desktop;
    case 'code':
      return FontAwesomeIcons.code;
    case 'paintbrush':
      return FontAwesomeIcons.paintBrush;
    case 'tv':
      return FontAwesomeIcons.tv;
    case 'font':
      return FontAwesomeIcons.font;
    case 'filecode':
      return FontAwesomeIcons.fileCode;
    case 'music':
      return FontAwesomeIcons.music;
    case 'film':
      return FontAwesomeIcons.film;
    case 'asterisk':
      return FontAwesomeIcons.asterisk;
    case 'handshelping':
      return FontAwesomeIcons.handsHelping;
    case 'mapmarkeralt':
      return FontAwesomeIcons.mapMarkerAlt;
    case 'addressbook':
      return FontAwesomeIcons.addressBook;
    case 'voteyea':
      return FontAwesomeIcons.voteYea;

    // Default
    default:
      return Icons.info; // A neutral fallback icon
  }
}
