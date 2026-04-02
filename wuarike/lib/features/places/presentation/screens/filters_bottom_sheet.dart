import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/wuarike_button.dart';
import '../../domain/entities/filter_params.dart';
import '../../../ubigeo/presentation/providers/ubigeo_provider.dart';

// Local state providers for the sheet
final _sortProvider = StateProvider<String?>((ref) => null);
final _categoriesProvider = StateProvider<List<String>>((ref) => []);
final _districtProvider = StateProvider<String?>((ref) => null);
final _distanceProvider = StateProvider<double>((ref) => 5.0);
final _minRatingProvider = StateProvider<double?>((ref) => null);
final _priceRangeProvider = StateProvider<String?>((ref) => null);
final _amenitiesProvider = StateProvider<List<String>>((ref) => []);

class FiltersBottomSheet extends ConsumerStatefulWidget {
  final FilterParams initialFilters;
  final ValueChanged<FilterParams> onApply;

  const FiltersBottomSheet({
    super.key,
    required this.initialFilters,
    required this.onApply,
  });

  static Future<FilterParams?> show(
    BuildContext context, {
    required FilterParams initialFilters,
  }) async {
    FilterParams? result;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FiltersBottomSheet(
        initialFilters: initialFilters,
        onApply: (f) {
          result = f;
          Navigator.of(context).pop();
        },
      ),
    );
    return result;
  }

  @override
  ConsumerState<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends ConsumerState<FiltersBottomSheet> {
  static const _sortOptions = [
    ('rating', 'Mejor valorado'),
    ('distance', 'Más cercano'),
    ('reviewCount', 'Más reseñas'),
    ('rarity', 'Rareza'),
  ];

  static const _amenitiesList = [
    'WiFi',
    'Estacionamiento',
    'Terraza',
    'Delivery',
    'Acceso sillas de ruedas',
    'Música en vivo',
    'Reservas',
    'Solo efectivo',
  ];

  @override
  void initState() {
    super.initState();
    // Seed state from initialFilters after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(_sortProvider.notifier).state = widget.initialFilters.sortBy;
      ref.read(_categoriesProvider.notifier).state =
          widget.initialFilters.category != null
              ? [widget.initialFilters.category!]
              : [];
      ref.read(_districtProvider.notifier).state = widget.initialFilters.district;
      ref.read(_distanceProvider.notifier).state =
          widget.initialFilters.maxDistanceKm ?? 5.0;
      ref.read(_minRatingProvider.notifier).state = widget.initialFilters.minRating;
      ref.read(_priceRangeProvider.notifier).state = widget.initialFilters.priceRange;
      ref.read(_amenitiesProvider.notifier).state =
          List<String>.from(widget.initialFilters.amenities);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sort = ref.watch(_sortProvider);
    final categories = ref.watch(_categoriesProvider);
    final district = ref.watch(_districtProvider);
    final distance = ref.watch(_distanceProvider);
    final minRating = ref.watch(_minRatingProvider);
    final priceRange = ref.watch(_priceRangeProvider);
    final amenities = ref.watch(_amenitiesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle + Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.greyLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Filtros',
                            style: AppTextStyles.heading2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: _resetAll,
                          child: Text(
                            'Limpiar',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Scrollable body
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  children: [
                    // ── Ordenar por ──────────────────────────────────────
                    _sectionTitle('Ordenar por'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _sortOptions.map((opt) {
                        final selected = sort == opt.$1;
                        return ChoiceChip(
                          label: Text(opt.$2),
                          selected: selected,
                          onSelected: (_) {
                            ref.read(_sortProvider.notifier).state =
                                selected ? null : opt.$1;
                          },
                          selectedColor: AppColors.primary.withOpacity(0.15),
                          labelStyle: AppTextStyles.bodySmall.copyWith(
                            color: selected
                                ? AppColors.primary
                                : AppColors.textDark,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          side: BorderSide(
                            color: selected
                                ? AppColors.primary
                                : AppColors.greyLight,
                          ),
                          backgroundColor: AppColors.white,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ── Categoría ────────────────────────────────────────
                    _sectionTitle('Categoría'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.foodCategories
                          .where((c) => c != 'Todos')
                          .map((cat) {
                        final selected = categories.contains(cat);
                        return FilterChip(
                          label: Text(cat),
                          selected: selected,
                          onSelected: (val) {
                            final list = List<String>.from(categories);
                            val ? list.add(cat) : list.remove(cat);
                            ref.read(_categoriesProvider.notifier).state = list;
                          },
                          selectedColor: AppColors.primary.withOpacity(0.15),
                          checkmarkColor: AppColors.primary,
                          labelStyle: AppTextStyles.bodySmall.copyWith(
                            color: selected
                                ? AppColors.primary
                                : AppColors.textDark,
                          ),
                          side: BorderSide(
                            color: selected
                                ? AppColors.primary
                                : AppColors.greyLight,
                          ),
                          backgroundColor: AppColors.white,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ── Distrito ──────────────────────────────────────────
                    _sectionTitle('Distrito'),
                    const SizedBox(height: 10),
                    ref.watch(districtsProvider).when(
                          data: (districtList) => SizedBox(
                            height: 40,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: districtList.map((d) {
                                final selected = district == d.name;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(d.name),
                                    selected: selected,
                                    onSelected: (_) {
                                      ref.read(_districtProvider.notifier).state =
                                          selected ? null : d.name;
                                    },
                                    selectedColor:
                                        AppColors.primary.withOpacity(0.15),
                                    labelStyle: AppTextStyles.bodySmall.copyWith(
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.textDark,
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                    side: BorderSide(
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.greyLight,
                                    ),
                                    backgroundColor: AppColors.white,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          loading: () => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          error: (err, stack) => Text(
                            'Error cargando distritos',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                    const SizedBox(height: 20),

                    // ── Distancia máxima ──────────────────────────────────
                    Row(
                      children: [
                        _sectionTitle('Distancia máxima'),
                        const Spacer(),
                        Text(
                          '${distance.toStringAsFixed(1)} km',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primary,
                        thumbColor: AppColors.primary,
                        inactiveTrackColor: AppColors.greyLight,
                        overlayColor: AppColors.primary.withOpacity(0.1),
                      ),
                      child: Slider(
                        value: distance,
                        min: 0.5,
                        max: 20.0,
                        divisions: 39,
                        onChanged: (val) {
                          ref.read(_distanceProvider.notifier).state = val;
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Valoración mínima ─────────────────────────────────
                    _sectionTitle('Valoración mínima'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [1.0, 2.0, 3.0, 4.0, 4.5].map((val) {
                        final selected = minRating == val;
                        return GestureDetector(
                          onTap: () {
                            ref.read(_minRatingProvider.notifier).state =
                                selected ? null : val;
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.rating.withOpacity(0.15)
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selected
                                    ? AppColors.rating
                                    : AppColors.greyLight,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: selected
                                      ? AppColors.rating
                                      : AppColors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  val.toString(),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: selected
                                        ? AppColors.rating
                                        : AppColors.textDark,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  '+',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: selected
                                        ? AppColors.rating
                                        : AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ── Rango de precio ───────────────────────────────────
                    _sectionTitle('Rango de precio'),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: AppConstants.priceRanges.map((pr) {
                          final selected = priceRange == pr;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                ref.read(_priceRangeProvider.notifier).state =
                                    selected ? null : pr;
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primary.withOpacity(0.1)
                                      : AppColors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.greyLight,
                                  ),
                                ),
                                child: Text(
                                  pr,
                                  style: AppTextStyles.body.copyWith(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.textDark,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Servicios y comodidades ───────────────────────────
                    _sectionTitle('Servicios y comodidades'),
                    const SizedBox(height: 8),
                    ..._amenitiesList.map((a) {
                      final selected = amenities.contains(a);
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: selected,
                        title: Text(a, style: AppTextStyles.body),
                        activeColor: AppColors.primary,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (val) {
                          final list = List<String>.from(amenities);
                          val == true ? list.add(a) : list.remove(a);
                          ref.read(_amenitiesProvider.notifier).state = list;
                        },
                      );
                    }),
                  ],
                ),
              ),

              // ── Sticky apply button ───────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      offset: const Offset(0, -4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: WuarikeButton(
                  label: 'Aplicar Filtros',
                  onPressed: _applyFilters,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: AppTextStyles.heading3);
  }

  void _resetAll() {
    ref.read(_sortProvider.notifier).state = null;
    ref.read(_categoriesProvider.notifier).state = [];
    ref.read(_districtProvider.notifier).state = null;
    ref.read(_distanceProvider.notifier).state = 5.0;
    ref.read(_minRatingProvider.notifier).state = null;
    ref.read(_priceRangeProvider.notifier).state = null;
    ref.read(_amenitiesProvider.notifier).state = [];
  }

  void _applyFilters() {
    final sort = ref.read(_sortProvider);
    final categories = ref.read(_categoriesProvider);
    final district = ref.read(_districtProvider);
    final distance = ref.read(_distanceProvider);
    final minRating = ref.read(_minRatingProvider);
    final priceRange = ref.read(_priceRangeProvider);
    final amenities = ref.read(_amenitiesProvider);

    final params = FilterParams(
      category: categories.isNotEmpty ? categories.first : null,
      district: district,
      minRating: minRating,
      maxDistanceKm: distance,
      priceRange: priceRange,
      sortBy: sort,
      amenities: amenities,
    );

    widget.onApply(params);
  }
}
