// lib/features/user_notifications/ui/screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/features/user_notifications/logic/cubit.dart';
import 'package:live_order/features/user_notifications/logic/state.dart';
import 'package:live_order/features/user_notifications/ui/widget/notification_empty_state.dart';
import 'package:live_order/features/user_notifications/ui/widget/notification_tile.dart';
import 'package:live_order/core/widgets/empty_state.dart';
import 'package:live_order/core/widgets/loading_shimmer.dart';

class MarketNotificationsScreen extends StatefulWidget {
  const MarketNotificationsScreen({super.key});

  @override
  State<MarketNotificationsScreen> createState() => _MarketNotificationsScreenState();
}

class _MarketNotificationsScreenState extends State<MarketNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MarketNotificationsCubit>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppDesign.surface,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppDesign.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'الإشعارات',
            style: AppDesign.heading(fontSize: 18.0),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<MarketNotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsLoading) {
              return _buildLoadingState();
            } else if (state is NotificationsError) {
              return EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'فشل تحميل الإشعارات',
                subtitle: state.message,
                actionLabel: 'إعادة المحاولة',
                onActionTap: () => context.read<MarketNotificationsCubit>().loadNotifications(),
              );
            } else if (state is NotificationsLoaded) {
              final list = state.notifications;
              if (list.isEmpty) {
                return const NotificationEmptyState();
              }
  
              final grouped = _groupNotifications(list);
  
              return RefreshIndicator(
                onRefresh: () => context.read<MarketNotificationsCubit>().loadNotifications(),
                color: AppDesign.primary,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppDesign.space16),
                  itemCount: grouped.keys.length,
                  itemBuilder: (context, sectionIndex) {
                    final groupName = grouped.keys.elementAt(sectionIndex);
                    final items = grouped[groupName]!;
  
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppDesign.space12),
                          child: Text(
                            groupName,
                            style: AppDesign.body(
                              color: AppDesign.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                        ...items.map((item) => NotificationTile(
                          notification: item,
                          onTap: () {
                            if (!item.isRead) {
                              context.read<MarketNotificationsCubit>().markAsRead(item.id);
                            }
                          },
                        )),
                        const SizedBox(height: AppDesign.space12),
                      ],
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Map<String, List<AppNotification>> _groupNotifications(List<AppNotification> list) {
    final Map<String, List<AppNotification>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var item in list) {
      final itemDate = DateTime(item.timestamp.year, item.timestamp.month, item.timestamp.day);
      String group;
      if (itemDate == today) {
        group = 'اليوم';
      } else if (itemDate == yesterday) {
        group = 'أمس';
      } else {
        group = 'سابقاً';
      }

      if (!grouped.containsKey(group)) {
        grouped[group] = [];
      }
      grouped[group]!.add(item);
    }
    return grouped;
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(AppDesign.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          LoadingShimmer(width: 80, height: 16),
          SizedBox(height: 12),
          LoadingShimmer(width: double.infinity, height: 80, borderRadius: 12),
          SizedBox(height: 8),
          LoadingShimmer(width: double.infinity, height: 80, borderRadius: 12),
        ],
      ),
    );
  }
}
