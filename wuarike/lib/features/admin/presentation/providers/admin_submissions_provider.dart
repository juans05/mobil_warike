import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../places/domain/entities/place_submission_entity.dart';
import '../../domain/usecases/get_pending_submissions_usecase.dart';
import '../../domain/usecases/approve_submission_usecase.dart';
import '../../domain/usecases/reject_submission_usecase.dart';

final pendingSubmissionsProvider = FutureProvider<List<PlaceSubmissionEntity>>((ref) async {
  final useCase = sl<GetPendingSubmissionsUseCase>();
  return await useCase();
});

class AdminSubmissionsNotifier extends StateNotifier<AsyncValue<void>> {
  final ApproveSubmissionUseCase _approveUseCase;
  final RejectSubmissionUseCase _rejectUseCase;
  final Ref _ref;

  AdminSubmissionsNotifier({
    required ApproveSubmissionUseCase approveUseCase,
    required RejectSubmissionUseCase rejectUseCase,
    required Ref ref,
  }) : _approveUseCase = approveUseCase,
       _rejectUseCase = rejectUseCase,
       _ref = ref,
       super(const AsyncValue.data(null));

  Future<void> approve(String id) async {
    state = const AsyncValue.loading();
    try {
      await _approveUseCase(id);
      state = const AsyncValue.data(null);
      _ref.invalidate(pendingSubmissionsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> reject(String id, String reason) async {
    state = const AsyncValue.loading();
    try {
      await _rejectUseCase(id, reason);
      state = const AsyncValue.data(null);
      _ref.invalidate(pendingSubmissionsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final adminSubmissionsNotifierProvider =
    StateNotifierProvider<AdminSubmissionsNotifier, AsyncValue<void>>((ref) {
  return AdminSubmissionsNotifier(
    approveUseCase: sl<ApproveSubmissionUseCase>(),
    rejectUseCase: sl<RejectSubmissionUseCase>(),
    ref: ref,
  );
});
