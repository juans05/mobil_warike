import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/filter_params.dart';
import '../providers/places_provider.dart';
import 'filters_bottom_sheet.dart';

// Search query state
final _searchQueryProvider = StateProvider<String>((ref) => '');
final _searchFiltersProvider = StateProvider<FilterParams>((ref) => FilterParams.empty);

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(_searchQueryProvider);
    final filters = ref.watch(_searchFiltersProvider);
    final hasFilters = filters.hasActiveFilters;

    final searchAsync = ref.watch(
      searchProvider(SearchParams(query: query)),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: 'Buscar lugares, comida...',
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.grey),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onChanged: (val) {
            ref.read(_searchQueryProvider.notifier).state = val;
          },
          onSubmitted: (val) {
            ref.read(_searchQueryProvider.notifier).state = val;
          },
        ),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                _searchController.clear();
                ref.read(_searchQueryProvider.notifier).state = '';
              },
            ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: Icon(
                  Icons.tune_rounded,
                  color: hasFilters ? AppColors.primary : AppColors.textDark,
                ),
                onPressed: () => _openFilters(context, filters),
              ),
              if (hasFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _buildBody(query, searchAsync),
    );
  }

  Widget _buildBody(
    String query,
    AsyncValue<List<dynamic>> searchAsync,
  ) {
    if (query.trim().isEmpty) {
      return _EmptySearchPrompt();
    }

    return searchAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (err, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.grey, size: 48),
            const SizedBox(height: 12),
            Text(
              err.toString(),
              style: AppTextStyles.body.copyWith(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      data: (places) {
        if (places.isEmpty) {
          return _EmptyResults(query: query);
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: places.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final place = places[index];
            return WuarikeCard(
              id: place.id,
              name: place.name,
              category: place.category,
              imageUrl: place.imageUrl,
              rating: place.rating,
              reviewCount: place.reviewCount,
              priceRange: place.priceRange,
              rarity: place.rarity,
              onTap: () => context.push('/places/${place.id}'),
            );
          },
        );
      },
    );
  }

  void _openFilters(BuildContext context, FilterParams current) async {
    final newFilters = await FiltersBottomSheet.show(
      context,
      initialFilters: current,
    );
    if (newFilters != null && mounted) {
      ref.read(_searchFiltersProvider.notifier).state = newFilters;
    }
  }
}

class _EmptySearchPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: AppColors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Busca wuarikes cerca de ti',
            style: AppTextStyles.heading3.copyWith(color: AppColors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Escribe el nombre del lugar o tipo de comida',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  final String query;

  const _EmptyResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.restaurant,
            size: 64,
            color: AppColors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron lugares',
            style: AppTextStyles.heading3.copyWith(color: AppColors.grey),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'No hay resultados para "$query". Intenta con otro término.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
