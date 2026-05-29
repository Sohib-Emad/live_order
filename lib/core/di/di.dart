import 'package:get_it/get_it.dart';
import 'package:live_order/features/auth/logic/cubit/auth_cubit.dart';
import 'package:live_order/features/auth/repo/auth_repo.dart';

final GetIt getIt = GetIt.instance;

Future<void> init() async {
  getIt.registerSingleton<AuthRepo>(AuthRepo());

  getIt.registerFactory(() => AuthCubit(authRepo: getIt<AuthRepo>()));
}
