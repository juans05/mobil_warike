import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final bool interactive;
  final ValueChanged<double>? onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 20,
    this.interactive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index + 1 <= rating;
        final half = !filled && index + 0.5 <= rating;

        final icon = filled
            ? Icons.star_rounded
            : half
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded;

        if (interactive) {
          return GestureDetector(
            onTap: () => onRatingChanged?.call((index + 1).toDouble()),
            child: Icon(icon, color: AppColors.rating, size: size),
          );
        }
        return Icon(icon, color: AppColors.rating, size: size);
      }),
    );
  }
}
