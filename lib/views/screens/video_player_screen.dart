import 'package:demoparty_assistant/views/widgets/video/universal_video_player.dart';
import 'package:flutter/material.dart';

/// A screen for playing video streams using the UniversalVideoPlayer.
class VideoPlayerScreen extends StatelessWidget {
  final String title;
  final String date;
  final String url;

  const VideoPlayerScreen({
    required this.title,
    required this.date,
    required this.url,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: UniversalVideoPlayer(
              videoUrl: url,
              isEmbedded: false, // Fullscreen behavior for streams
            ),
          ),
        ],
      ),
    );
  }
}
