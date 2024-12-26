import 'package:demoparty_assistant/views/Theme.dart';
import 'package:flutter/material.dart';

Color getColorForType(String key) {
  switch (key.toLowerCase()) {
    // Specific types
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

    // Named colors (from Theme.dart)
    case 'authorizationcolor':
      return authorizationColor;
    case 'settingscolor':
      return settingsColor;
    case 'aboutpartycolor':
      return aboutPartyColor;
    case 'newscolor':
      return newsColor;
    case 'streamsscolor':
      return streamsColor;
    case 'timetablecolor':
      return timetableColor;
    case 'competitionscolor':
      return competitionsColor;
    case 'getinvolvedcolor':
      return getInvolvedColor;
    case 'locationcolor':
      return locationColor;
    case 'contactcolor':
      return contactColor;
    case 'userscolor':
      return usersColor;
    case 'votingcolor':
      return votingColor;

    // Default
    default:
      return mutedTextColor; // A neutral fallback color
  }
}
