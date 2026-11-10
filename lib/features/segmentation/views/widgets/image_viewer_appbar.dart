import 'package:flutter/material.dart';
import 'package:segma/models/models.dart';

class ImageViewerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ImageModel image;
  final VoidCallback onBack;

  const ImageViewerAppBar({
    super.key,
    required this.image,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
        onPressed: onBack,
        tooltip: 'Retour',
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            image.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            image.path,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
