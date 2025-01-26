import 'dart:ui';

import 'package:demoparty_assistant/views/Theme.dart';

Color getColorForType(String type) {
  switch (type.toLowerCase()) {
    case 'event':
      return eventColor;
    case 'seminar':
      return seminarColor;
    case 'concert':
      return concertColor;
    case 'deadline':
      return deadlineColor;
    case 'compo':
    case 'competition':
      return compoColor;
    default:
      return mutedTextColor; // A neutral color for unknown types
  }
}
