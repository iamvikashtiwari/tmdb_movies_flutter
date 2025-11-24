import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_app/core/constants.dart';
import 'package:movie_app/data/models.dart';

class MovieCard extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback onTap;
  final bool small;

  const MovieCard({
    required this.movie,
    required this.onTap,
    this.small = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final poster = movie.posterPath != null
        ? '${Constants.imageBase}${movie.posterPath}'
        : null;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: small ? 140 : 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: poster != null
                  ? CachedNetworkImage(
                imageUrl: poster,
                height: small ? 160 : 220,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (c, u) => Container(
                  height: small ? 160 : 220,
                  color: Colors.grey[300],
                ),
                errorWidget: (c, u, e) => Container(
                  height: small ? 160 : 220,
                  color: Colors.grey,
                ),
              )
                  : Container(
                height: small ? 160 : 220,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              movie.releaseDate ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
