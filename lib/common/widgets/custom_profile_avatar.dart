import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:brahmakosh/core/theme/app_theme.dart';

class CustomProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final double borderWidth;
  final Color borderColor;
  final Color backgroundColor;

  const CustomProfileAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 20.0,
    this.borderWidth = 1.0,
    this.borderColor = Colors.white,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: ClipOval(
        child: (imageUrl == null || imageUrl!.isEmpty)
            ? _buildFallbackIcon()
            : CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildFallbackIcon(),
                errorWidget: (context, url, error) => _buildFallbackIcon(),
              ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Icon(
        Icons.person,
        size: radius * 1.2,
        color: AppTheme.primaryGold,
      ),
    );
  }
}
