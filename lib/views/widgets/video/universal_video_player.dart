import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:demoparty_assistant/views/widgets/universal/errors/error_display_widget.dart';
import 'package:demoparty_assistant/utils/errors/error_helper.dart';

/// A universal video player that adapts based on the video source.
class UniversalVideoPlayer extends StatefulWidget {
  final String videoUrl; // The URL of the video
  final bool isEmbedded; // Whether the player is embedded or fullscreen

  const UniversalVideoPlayer({
    required this.videoUrl,
    this.isEmbedded = true,
    Key? key,
  }) : super(key: key);

  @override
  _UniversalVideoPlayerState createState() => _UniversalVideoPlayerState();
}

class _UniversalVideoPlayerState extends State<UniversalVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubeController;
  bool isYoutubeVideo = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  /// Initializes the video player based on the URL type.
  Future<void> _initializePlayer() async {
    setState(() {
      errorMessage = null;
    });

    try {
      final youtubeId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      if (youtubeId != null) {
        isYoutubeVideo = true;
        _initializeYoutubePlayer(youtubeId);
      } else {
        await _initializeChewiePlayer();
      }
    } catch (e) {
      ErrorHelper.handleError(e);
      setState(() {
        errorMessage = _mapErrorToMessage(e);
      });
    }
  }

  /// Maps errors to user-friendly messages.
  String _mapErrorToMessage(Object error) {
    if (error is SocketException) {
      return """
Unable to connect to the internet.
Please check your network connection and try again.
""";
    } else if (error is PlatformException &&
        error.message?.contains('ExoPlaybackException: Source error') == true) {
      return """
The video cannot be loaded because there is no internet connection.
Please connect to the internet and try again.
""";
    } else {
      return ErrorHelper.getErrorMessage(error);
    }
  }

  /// Initializes the YouTube player with the extracted YouTube ID.
  void _initializeYoutubePlayer(String youtubeId) {
    try {
      _youtubeController = YoutubePlayerController(
        initialVideoId: youtubeId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    } catch (e) {
      ErrorHelper.handleError(e);
      setState(() {
        errorMessage = _mapErrorToMessage(e);
      });
    }
  }

  /// Initializes the Chewie player for non-YouTube videos.
  Future<void> _initializeChewiePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: !widget.isEmbedded, // Autoplay if fullscreen
        looping: false,
        showControls: true,
      );
    } catch (e) {
      ErrorHelper.handleError(e);
      setState(() {
        errorMessage = _mapErrorToMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return ErrorDisplayWidget(
        title: 'Video Player Error',
        message: errorMessage!,
        onRetry: _initializePlayer, // Retry initialization
      );
    }

    if (isYoutubeVideo) {
      return _buildYoutubePlayer();
    } else {
      return _buildChewiePlayer();
    }
  }

  /// Builds the YouTube player widget.
  Widget _buildYoutubePlayer() {
    if (_youtubeController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return YoutubePlayer(
      controller: _youtubeController!,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Theme.of(context).colorScheme.secondary,
    );
  }

  /// Builds the Chewie player widget for non-YouTube videos.
  Widget _buildChewiePlayer() {
    if (_chewieController == null ||
        !_videoPlayerController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return AspectRatio(
      aspectRatio: _videoPlayerController.value.aspectRatio,
      child: Chewie(controller: _chewieController!),
    );
  }

  @override
  void dispose() {
    if (!isYoutubeVideo) {
      _videoPlayerController.dispose();
      _chewieController?.dispose();
    } else {
      _youtubeController?.dispose();
    }
    super.dispose();
  }
}
