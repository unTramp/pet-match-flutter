import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/design/tokens/sizes.dart';
import '../../core/design/tokens/strokes.dart';
import '../../core/theme/app_colors.dart';

class BreedGalleryPage extends StatefulWidget {
  const BreedGalleryPage({super.key, required this.images});

  final List<String> images;

  @override
  State<BreedGalleryPage> createState() => _BreedGalleryPageState();
}

class _BreedGalleryPageState extends State<BreedGalleryPage> {
  final PageController _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_current + 1} / ${widget.images.length}'),
      ),
      body: SafeArea(
        child: PageView.builder(
          controller: _controller,
          itemCount: widget.images.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder:
              (_, i) => InteractiveViewer(
                minScale: 1,
                maxScale: 3,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: widget.images[i],
                    fit: BoxFit.contain,
                    placeholder:
                        (_, __) => const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: AppStroke.indicator,
                          ),
                        ),
                    errorWidget:
                        (_, __, ___) => const Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.onDarkMuted,
                          size: AppIconSize.hero,
                        ),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
