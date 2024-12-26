import 'package:demoparty_assistant/views/Theme.dart';
import 'package:demoparty_assistant/utils/navigation/app_router_paths.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final List<Map<String, dynamic>> drawerItems = [
  {
    'icon': FontAwesomeIcons.userLock,
    'title': 'Authorization',
    'page': 'authorization',
    'route': AppRouterPaths.authorization,
    'iconColor': authorizationColor, // Ustal kolor dla Authorization w theme.dart
  },
  {
  'icon': FontAwesomeIcons.cog,
  'title': 'Settings',
  'page': 'Settings',
  'route': AppRouterPaths.settings,
  'iconColor': settingsColor,
},
  {
    'icon': FontAwesomeIcons.infoCircle,
    'title': 'About the Party',
    'page': null,
    'iconColor': aboutPartyColor, // Bright Coral
    'subItems': [
      {
        'icon': FontAwesomeIcons.bullhorn,
        'title': 'Xenium Party',
        'page': 'Xenium Party',
        'url': 'https://2024.xenium.rocks/about/xenium/',
        'iconColor': aboutPartyColor,
      },
      {
        'icon': FontAwesomeIcons.users,
        'title': 'Organizers',
        'page': 'Organizers',
        'url': 'https://2024.xenium.rocks/about/orgas/',
        'iconColor': aboutPartyColor,
      },
      {
        'icon': FontAwesomeIcons.exclamationTriangle,
        'title': 'Important Changes',
        'page': 'Important Changes',
        'url': 'https://2024.xenium.rocks/about/wazne-zmiany/',
        'iconColor': aboutPartyColor
      },
      {
        'icon': FontAwesomeIcons.question,
        'title': 'First Time Visitor?',
        'page': 'First Time Visitor?',
        'url': 'https://2024.xenium.rocks/about/czym-jest-demoscena/',
        'iconColor': aboutPartyColor,
      },
    ]
  },
  {
    'icon': FontAwesomeIcons.newspaper,
    'title': 'News',
    'page': 'News',
    'route': AppRouterPaths.news,
    'iconColor': newsColor, // Vivid Blue
  },
  {
  'icon': FontAwesomeIcons.video,
  'title': 'Streams',
  'page': 'Streams',
  'route': AppRouterPaths.streams,
  'iconColor': streamsColor, // Ustal kolor dla Streams w theme.dart
},

  {
    'icon': FontAwesomeIcons.calendar,
    'title': 'Timetable',
    'page': 'Timetable',
    'route': AppRouterPaths.timeTable,
    'iconColor': timetableColor, // Sky Blue
  },
  {
    'icon': FontAwesomeIcons.trophy,
    'title': 'Competitions',
    'page': null,
    'iconColor': competitionsColor, // Lime Green
    'subItems': [
      {
        'icon': FontAwesomeIcons.book,
        'title': 'General Rules',
        'page': 'General Rules',
        'url': 'https://2024.xenium.rocks/kompoty/zasady/',
        'iconColor': competitionsColor,
      },
      {
        'icon': FontAwesomeIcons.desktop,
        'title': 'Demo',
        'page': 'Demo',
        'url': 'https://2024.xenium.rocks/kompoty/demo/',
        'iconColor': competitionsColor,
      },
      {
        'icon': FontAwesomeIcons.code,
        'title': 'Intro (256B / 1KB / 4KB / 64KB)',
        'page': 'Intro (256B / 1KB / 4KB / 64KB)',
        'url': 'https://2024.xenium.rocks/kompoty/intro-256b-1kb-4kb-64kb/',
        'iconColor': competitionsColor,
      },
      {
        'icon': FontAwesomeIcons.paintBrush,
        'title': 'Freestyle GFX',
        'page': 'Freestyle GFX',
        'url': 'https://2024.xenium.rocks/kompoty/freestyle-gfx/',
        'iconColor': competitionsColor,
      },
      {
        'icon': FontAwesomeIcons.tv,
        'title': 'Oldschool GFX',
        'page': 'Oldschool GFX',
        'url': 'https://2024.xenium.rocks/kompoty/oldschool-gfx/',
        'iconColor': competitionsColor,
      },
      {
        'icon': FontAwesomeIcons.font,
        'title': 'ASCII / ANSI / PETSCII GFX',
        'page': 'ASCII / ANSI / PETSCII GFX',
        'url': 'https://2024.xenium.rocks/kompoty/ascii-ansii-petscii-gfx/',
        'iconColor': competitionsColor,
      },
      {
        'icon': FontAwesomeIcons.fileCode,
        'title': 'Executable GFX',
        'page': 'Executable GFX',
        'url': 'https://2024.xenium.rocks/kompoty/executable-gfx/',
        'iconColor': competitionsColor,
      },
      {
        'icon': FontAwesomeIcons.music,
        'title': 'Streaming MSX',
        'page': 'Streaming MSX',
        'url': 'https://2024.xenium.rocks/kompoty/streaming-msx/',
        'iconColor': competitionsColor,
      },
      {
        'icon': FontAwesomeIcons.music,
        'title': 'Tracked MSX',
        'page': 'Tracked MSX',
        'url': 'https://2024.xenium.rocks/kompoty/tracked-msx/',
        'iconColor': competitionsColor,
      },
      {
        'icon': FontAwesomeIcons.music,
        'title': 'Synth MSX',
        'page': 'Synth MSX',
        'url': 'https://2024.xenium.rocks/kompoty/synth-msx/',
        'iconColor': competitionsColor,
      },
      {
        'icon': FontAwesomeIcons.music,
        'title': 'Chip MSX',
        'page': 'Chip MSX',
        'url': 'https://2024.xenium.rocks/kompoty/chip-msx/',
        'iconColor': competitionsColor,
      },
      {
        'icon': FontAwesomeIcons.film,
        'title': 'Anim',
        'page': 'Anim',
        'url': 'https://2024.xenium.rocks/kompoty/anim/',
        'iconColor': competitionsColor,
      },
      {
        'icon': FontAwesomeIcons.asterisk,
        'title': 'Wild',
        'page': 'Wild',
        'url': 'https://2024.xenium.rocks/kompoty/wild/',
        'iconColor': competitionsColor,
      },
    ]
  },
  {
    'icon': FontAwesomeIcons.handsHelping,
    'title': 'Get Involved',
    'page': null,
    'iconColor': getInvolvedColor, // Bright Teal
    'subItems': [
      {
        'icon': FontAwesomeIcons.ticketAlt,
        'title': 'Admission',
        'page': 'Admission',
        'url': 'https://2024.xenium.rocks/wez-udzial/wstep/',
        'iconColor': getInvolvedColor,
      },
      {
        'icon': FontAwesomeIcons.fileUpload,
        'title': 'Submit Work',
        'page': 'Submit Work',
        'url': 'https://2024.xenium.rocks/wez-udzial/zglos-prace/',
        'iconColor': getInvolvedColor,
      },
      {
        'icon': FontAwesomeIcons.gavel,
        'title': 'Rules',
        'page': 'Rules',
        'url': 'https://2024.xenium.rocks/wez-udzial/regulamin/',
        'iconColor': getInvolvedColor,
      },
    ]
  },
  {
    'icon': FontAwesomeIcons.mapMarkerAlt,
    'title': 'Location',
    'page': null,
    'iconColor': locationColor, // Vivid Red
    'subItems': [
      {
        'icon': FontAwesomeIcons.car,
        'title': 'Transportation & Parking',
        'page': 'Transportation & Parking',
        'url': 'https://2024.xenium.rocks/lokalizacja/dojazd/',
        'iconColor': locationColor,
      },
      {
        'icon': FontAwesomeIcons.bed,
        'title': 'Accommodation',
        'page': 'Accommodation',
        'url': 'https://2024.xenium.rocks/lokalizacja/nocleg/',
        'iconColor': locationColor,
      },
      {
        'icon': FontAwesomeIcons.map,
        'title': 'Party Place',
        'page': 'Party Place',
        'url': 'https://2024.xenium.rocks/lokalizacja/party-place/',
        'iconColor': locationColor,
      },
    ]
  },
  {
  'icon': FontAwesomeIcons.addressBook,
  'title': 'Contact',
  'page': 'Contact',
  'route': AppRouterPaths.contact,
  'iconColor': contactColor, //Vivid purple
},
  {
    'icon': FontAwesomeIcons.users,
    'title': 'Users',
    'page': 'Users',
    'route': AppRouterPaths.users,
    'iconColor': usersColor, // Light Gray
  },
  {
    'icon': FontAwesomeIcons.voteYea,
    'title': 'Voting Results',
    'page': 'voting results',
    'route': AppRouterPaths.voting_results,
    'iconColor': votingColor,
  },
{
  'icon': FontAwesomeIcons.voteYea,
  'title': 'Voting',
  'page': 'voting',
  'route': AppRouterPaths.voting,
  'iconColor': votingColor,
},
];
