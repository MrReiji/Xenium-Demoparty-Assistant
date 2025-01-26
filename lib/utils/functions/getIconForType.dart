import 'package:flutter/material.dart';

IconData getIconForType(String type) {
  switch (type.toLowerCase()) {
    case 'event':
      return Icons.event;
    case 'seminar':
      return Icons.school;
    case 'concert':
      return Icons.music_note;
    case 'deadline':
      return Icons.warning;
    case 'compo':
      return Icons.code;
    default:
      return Icons.info;
  }
}
