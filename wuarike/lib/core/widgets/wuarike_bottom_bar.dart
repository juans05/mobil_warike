import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../router/app_routes.dart';

class WuarikeBottomBar extends StatelessWidget {
  final int currentIndex;
  final VoidCallback? onFabPressed;

  const WuarikeBottomBar({
    super.key,
    required this.currentIndex,
    this.onFabPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Bottom navigation background
        Container(
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.95),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, -2),
                blurRadius: 12,
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.grey,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map),
                label: 'Explorar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                activeIcon: Icon(Icons.search),
                label: 'Buscar',
              ),
              // Placeholder for FAB
              BottomNavigationBarItem(
                icon: SizedBox(width: 48),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_outline),
                activeIcon: Icon(Icons.favorite),
                label: 'Favoritos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
            onTap: (index) {
              if (index == 2) return; // FAB handled separately
              switch (index) {
                case 0:
                  context.go(AppRoutes.map);
                case 1:
                  context.go(AppRoutes.search);
                case 3:
                  context.go(AppRoutes.favorites);
                case 4:
                  context.go(AppRoutes.profile);
              }
            },
          ),
        ),
        // Central FAB
        Positioned(
          bottom: 8,
          child: FloatingActionButton(
            onPressed: onFabPressed,
            backgroundColor: AppColors.secondary,
            elevation: 4,
            child: const Icon(Icons.add_location_alt, color: AppColors.white, size: 28),
          ),
        ),
      ],
    );
  }
}
