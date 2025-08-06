import 'package:calma_flutter/features/insights/data/repositories/call_session_repository.dart';
import 'package:calma_flutter/features/insights/data/repositories/session_insight_repository.dart';
import 'package:calma_flutter/features/insights/services/psychologist_invitation_service.dart';
import 'package:calma_flutter/features/insights/services/psychologist_invitation_checker_service.dart';
import 'package:calma_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:calma_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:calma_flutter/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:calma_flutter/features/profile/data/repositories/user_profile_repository_impl.dart';
import 'package:calma_flutter/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:calma_flutter/features/insights/domain/repositories/psychologist_repository.dart';
import 'package:calma_flutter/features/insights/data/repositories/psychologist_repository_impl.dart';
import 'package:calma_flutter/features/profile/presentation/viewmodels/user_profile_viewmodel.dart';
import 'package:calma_flutter/features/profile/services/profile_photo_service.dart';
import 'package:calma_flutter/features/reminders/data/repositories/reminder_repository_impl.dart';
import 'package:calma_flutter/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:calma_flutter/features/reminders/presentation/viewmodels/reminder_viewmodel.dart';
import 'package:calma_flutter/features/streak/services/streak_service.dart';
import 'package:calma_flutter/core/services/supabase_service.dart';
import 'package:get_it/get_it.dart';

/// Singleton para injeção de dependências
final GetIt getIt = GetIt.instance;

/// Configura a injeção de dependências
void setupInjection() {
  // Serviços
  getIt.registerLazySingleton(() => SupabaseService());
  getIt.registerLazySingleton(() => StreakService());
  getIt.registerLazySingleton(() => PsychologistInvitationService(SupabaseService.client));
  getIt.registerLazySingleton(() => PsychologistInvitationCheckerService());
  
  // Repositórios
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  getIt.registerLazySingleton(() => CallSessionRepository());
  getIt.registerLazySingleton(() => SessionInsightRepository());
  getIt.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(SupabaseService.client)
  );
  
  getIt.registerLazySingleton<PsychologistRepository>(
    () => PsychologistRepositoryImpl(SupabaseService.client)
  );
  getIt.registerLazySingleton<ReminderRepository>(
    () => ReminderRepositoryImpl()
  );
  
  // Serviços adicionais
  getIt.registerLazySingleton(() => ProfilePhotoService(getIt<UserProfileRepository>()));
  
  // ViewModels
  getIt.registerLazySingleton(() => AuthViewModel(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => UserProfileViewModel(getIt<UserProfileRepository>()));
  getIt.registerLazySingleton(() => ReminderViewModel(getIt<ReminderRepository>()));
}
