// lib/features/user_profile/ui/screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/di/di.dart';
import 'package:live_order/features/session/logic/cubit/home_cubit.dart';
import 'package:live_order/features/user_account/logic/cubit/user_cubit.dart';
import 'package:live_order/features/user_account/ui/user_profile_screen.dart';

class MarketProfileScreen extends StatelessWidget {
  const MarketProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoaded) {
          return BlocProvider(
            create: (context) => getIt<UserCubit>(),
            child: UserProfileScreen(user: state.user),
          );
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
