import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/features/session/logic/cubit/home_cubit.dart';
import 'package:live_order/features/session/logic/state.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          String name = 'مستخدم';
          if (state is HomeLoaded) {
            name = state.user.name;
          }
          final hour = DateTime.now().hour;
          final greeting = hour < 12 ? 'صباح الخير ' : 'مساء الخير ';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: AppDesign.body(color: AppDesign.textSecondary, fontSize: 12.0)),
              Text(name, style: AppDesign.heading(fontSize: 16.0)),
            ],
          );
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: AppDesign.space16),
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              int unreadCount = 0;
              if (state is HomeLoaded) {
                unreadCount = state.unreadNotificationsCount;
              }
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: AppDesign.textPrimary),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 12, top: 12,
                      child: Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(color: AppDesign.danger, shape: BoxShape.circle),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
