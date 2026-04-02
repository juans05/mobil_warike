import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/wuarike_button.dart';
import '../../../places/domain/entities/place_submission_entity.dart';
import '../providers/admin_submissions_provider.dart';

class AdminSubmissionsScreen extends ConsumerWidget {
  const AdminSubmissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(pendingSubmissionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Aprobaciones Pendientes'),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
      ),
      body: submissionsAsync.when(
        data: (submissions) {
          if (submissions.isEmpty) {
            return const Center(
              child: Text('No hay solicitudes pendientes ✌️'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final submission = submissions[index];
              return _SubmissionCard(submission: submission);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error al cargar: $e'),
              const SizedBox(height: 16),
              WuarikeButton(
                label: 'Reintentar',
                width: 150,
                onPressed: () => ref.invalidate(pendingSubmissionsProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubmissionCard extends ConsumerWidget {
  final PlaceSubmissionEntity submission;

  const _SubmissionCard({required this.submission});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approvalState = ref.watch(adminSubmissionsNotifierProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cover Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              submission.coverImageUrl,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 150,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        submission.name,
                        style: AppTextStyles.heading3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        submission.district,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  submission.address ?? 'Sin dirección especificada',
                  style: AppTextStyles.body.copyWith(color: AppColors.grey),
                ),
                if (submission.description != null &&
                    submission.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    submission.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: WuarikeButton(
                        label: 'Aprobar',
                        isLoading: approvalState.isLoading,
                        onPressed: approvalState.isLoading
                            ? null
                            : () => ref
                                .read(adminSubmissionsNotifierProvider.notifier)
                                .approve(submission.id!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // For now, rejection just refreshes or does nothing as we haven't implemented it in backend
                    // Rejection with dialog
                    OutlinedButton(
                      onPressed: approvalState.isLoading 
                          ? null 
                          : () => _showRejectDialog(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechazar solicitud'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(
            hintText: 'Motivo del rechazo (ej: Foto poco clara)',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final reason = reasonCtrl.text.trim();
              if (reason.isEmpty) return;
              ref.read(adminSubmissionsNotifierProvider.notifier).reject(submission.id!, reason);
              Navigator.pop(context);
            },
            child: const Text('Rechazar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

