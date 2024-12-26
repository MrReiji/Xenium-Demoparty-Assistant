import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:demoparty_assistant/views/widgets/universal/errors/error_display_widget.dart';
import 'package:demoparty_assistant/utils/errors/error_helper.dart';

/// A universal video player widget that supports both YouTube and generic video URLs.
/// 
/// It dynamically determines the video source and adapts the player accordingly:
/// - YouTube: Uses `YoutubePlayer` for playback.
/// - Other URLs: Uses `Chewie` with `VideoPlayerController`.
class UniversalVideoPlayer extends StatefulWidget {
  /// The URL of the video to be played.
  final String videoUrl;

  /// Whether the player is embedded or fullscreen.
  final bool isEmbedded;

  const UniversalVideoPlayer({
    required this.videoUrl,
    this.isEmbedded = true,
    Key? key,
  }) : super(key: key);

  @override
  _UniversalVideoPlayerState createState() => _UniversalVideoPlayerState();
}

class _UniversalVideoPlayerState extends State<UniversalVideoPlayer> {
  late VideoPlayerController _videoPlayerController; // Controller for non-YouTube videos.
  ChewieController? _chewieController; // Controller for Chewie player.
  YoutubePlayerController? _youtubeController; // Controller for YouTube player.
  bool isYoutubeVideo = false; // Tracks if the video is a YouTube video.
  String? errorMessage; // Stores error messages for display.

  @override
  void initState() {
    super.initState();
    _initializePlayer(); // Initialize the video player based on the URL.
  }

  /// Determines the video type (YouTube or generic) and initializes the appropriate player.
  Future<void> _initializePlayer() async {
    setState(() {
      errorMessage = null; // Reset error message on retry.
    });

    try {
      final youtubeId = YoutubePlayer.convertUrlToId(widget.videoUrl); // Extract YouTube video ID.
      if (youtubeId != null) {
        isYoutubeVideo = true;
        _initializeYoutubePlayer(youtubeId);
      } else {
        await _initializeChewiePlayer();
      }
    } catch (e) {
      // Handle errors using ErrorHelper.
      ErrorHelper.handleError(e);
      setState(() {
        errorMessage = ErrorHelper.getErrorMessage(e);
      });
    }
  }

  /// Initializes the YouTube player using the extracted video ID.
  void _initializeYoutubePlayer(String youtubeId) {
    try {
      _youtubeController = YoutubePlayerController(
        initialVideoId: youtubeId,
        flags: const YoutubePlayerFlags(
          autoPlay: false, // Video does not auto-play by default.
          mute: false, // Video audio is not muted.
        ),
      );
    } catch (e) {
      ErrorHelper.handleError(e);
      setState(() {
        errorMessage = ErrorHelper.getErrorMessage(e);
      });
    }
  }

  /// Initializes the Chewie player for non-YouTube videos.
  Future<void> _initializeChewiePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.network(widget.videoUrl); // Load the video URL.
      await _videoPlayerController.initialize(); // Wait for the video to initialize.

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: !widget.isEmbedded, // Autoplay if the video is fullscreen.
        looping: false, // Looping is disabled.
        showControls: true, // Display playback controls.
      );
    } catch (e) {
      ErrorHelper.handleError(e);
      setState(() {
        errorMessage = ErrorHelper.getErrorMessage(e);
      });
    }
  }

  /// Builds the widget tree for the video player.
  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      // Display error message with retry option.
      return ErrorDisplayWidget(
        title: 'Video Player Error',
        message: errorMessage!,
        onRetry: _initializePlayer, // Retry initialization.
      );
    }

    if (isYoutubeVideo) {
      return _buildYoutubePlayer(); // Build YouTube player UI.
    } else {
      return _buildChewiePlayer(); // Build Chewie player UI.
    }
  }

  /// Builds the YouTube player widget.
  Widget _buildYoutubePlayer() {
    if (_youtubeController == null) {
      return const Center(child: CircularProgressIndicator()); // Show loading indicator.
    }

    return YoutubePlayer(
      controller: _youtubeController!,
      showVideoProgressIndicator: true, // Display progress indicator.
      progressIndicatorColor: Theme.of(context).colorScheme.secondary,
    );
  }

  /// Builds the Chewie player widget for non-YouTube videos.
  Widget _buildChewiePlayer() {
    if (_chewieController == null || !_videoPlayerController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator()); // Show loading indicator.
    }

    return AspectRatio(
      aspectRatio: _videoPlayerController.value.aspectRatio, // Maintain video aspect ratio.
      child: Chewie(controller: _chewieController!),
    );
  }

  /// Releases resources when the widget is disposed.
  @override
  void dispose() {
    if (!isYoutubeVideo) {
      _videoPlayerController.dispose(); // Dispose video player controller.
      _chewieController?.dispose(); // Dispose Chewie controller.
    } else {
      _youtubeController?.dispose(); // Dispose YouTube player controller.
    }
    super.dispose();
  }
}
