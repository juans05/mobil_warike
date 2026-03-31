import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum Rarity { common, uncommon, rare, epic, legendary }

extension RarityExtension on Rarity {
  String get label => switch (this) {
        Rarity.common => 'COMÚN',
        Rarity.uncommon => 'POCO COMÚN',
        Rarity.rare => 'RARO',
        Rarity.epic => 'ÉPICO',
        Rarity.legendary => 'LEGENDARIO',
      };

  Color get color => switch (this) {
        Rarity.common => AppColors.rarityCommon,
        Rarity.uncommon => AppColors.rarityUncommon,
        Rarity.rare => AppColors.rarityRare,
        Rarity.epic => AppColors.rarityEpic,
        Rarity.legendary => AppColors.rarityLegendary,
      };

  static Rarity fromString(String value) => switch (value.toUpperCase()) {
        'UNCOMMON' || 'POCO COMÚN' || 'POCO COMUN' => Rarity.uncommon,
        'RARE' || 'RARO' => Rarity.rare,
        'EPIC' || 'ÉPICO' || 'EPICO' => Rarity.epic,
        'LEGENDARY' || 'LEGENDARIO' => Rarity.legendary,
        _ => Rarity.common,
      };
}

class RarityChip extends StatelessWidget {
  final String rarity;

  const RarityChip({super.key, required this.rarity});

  @override
  Widget build(BuildContext context) {
    final r = RarityExtension.fromString(rarity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: r.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: r.color, width: 1),
      ),
      child: Text(
        r == Rarity.legendary ? '✨ ${r.label}' : r.label,
        style: AppTextStyles.bodySmall.copyWith(
          color: r.color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
