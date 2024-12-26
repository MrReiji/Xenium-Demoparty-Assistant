import 'dart:typed_data';
import 'package:flutter/material.dart';

/// A widget to display a grid of images.
///
/// This widget is designed to focus on the UI and display images passed to it
/// without directly managing caching or fetching logic.
class ImageGridWidget extends StatelessWidget {
  /// List of image data or URLs to display in the grid.
  ///
  /// If an entry is `Uint8List`, it will be displayed as an in-memory image.
  /// If an entry is `String`, it is treated as a URL and fetched dynamically.
  final List<dynamic> images;

  /// The number of columns in the grid.
  final int columns;

  /// The spacing between grid items.
  final double spacing;

  const ImageGridWidget({
    Key? key,
    required this.images,
    this.columns = 3,
    this.spacing = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) => _buildImage(context, images[index]),
      ),
    );
  }

  /// Builds a single image widget.
  Widget _buildImage(BuildContext context, dynamic image) {
    if (image is Uint8List) {
      // Display an in-memory image.
      return GestureDetector(
        onTap: () => _showImageDialog(context, Image.memory(image), "In-memory image"),
        child: _buildImageContainer(Image.memory(image, fit: BoxFit.cover)),
      );
    } else if (image is String) {
      // Treat the string as a URL and display the image.
      return GestureDetector(
        onTap: () => _showImageDialog(
          context,
          Image.network(image, fit: BoxFit.contain),
          "Image from $image",
        ),
        child: _buildImageContainer(
          Image.network(
            image,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.broken_image,
              color: Colors.red,
            ),
          ),
        ),
      );
    } else {
      // Invalid image type.
      return const Icon(Icons.broken_image, color: Colors.red);
    }
  }

  /// Wraps an image in a container with a consistent style.
  Widget _buildImageContainer(Widget image) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6.0,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: image,
    );
  }

  /// Displays an image in a fullscreen dialog.
  void _showImageDialog(BuildContext context, Widget image, String altText) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black87,
          insetPadding: const EdgeInsets.all(10.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                maxScale: 5.0,
                minScale: 1.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: image,
                ),
              ),
              Positioned(
                top: 16.0,
                right: 16.0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
