// lib/features/notifications/ui/screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/features/notifications/data/model/notification_model.dart';
import 'package:live_order/features/notifications/logic/cubit.dart';
import 'package:live_order/features/notifications/logic/state.dart';
import 'package:live_order/shared/widgets/empty_state.dart';
import 'package:live_order/shared/widgets/loading_shimmer.dart';

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
    return Scaffold(
      backgroundColor: AppDesign.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppDesign.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
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
              title: 'Error loading updates',
              subtitle: state.message,
              actionLabel: 'Retry',
              onActionTap: () => context.read<MarketNotificationsCubit>().loadNotifications(),
            );
          } else if (state is NotificationsLoaded) {
            final list = state.notifications;
            if (list.isEmpty) {
              return Center(
                child: EmptyState(
                  icon: Icons.notifications_off_outlined,
                  title: 'All caught up!',
                  subtitle: 'No notifications at this time.',
                ),
              );
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
                      ...items.map((item) => _buildNotificationTile(item)).toList(),
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
        group = 'TODAY';
      } else if (itemDate == yesterday) {
        group = 'YESTERDAY';
      } else {
        group = 'EARLIER';
      }

      if (!grouped.containsKey(group)) {
        grouped[group] = [];
      }
      grouped[group]!.add(item);
    }
    return grouped;
  }

  Widget _buildNotificationTile(AppNotification item) {
    Color getIconColor() {
      switch (item.category) {
        case 'promo':
          return AppDesign.success;
        case 'payment':
          return AppDesign.primary;
        case 'system':
          return AppDesign.danger;
        default:
          return AppDesign.warning;
      }
    }

    IconData getIcon() {
      switch (item.category) {
        case 'promo':
          return Icons.percent_rounded;
        case 'payment':
          return Icons.account_balance_wallet_rounded;
        case 'system':
          return Icons.info_outline_rounded;
        default:
          return Icons.local_shipping_rounded;
      }
    }

    return GestureDetector(
      onTap: () {
        if (!item.isRead) {
          context.read<MarketNotificationsCubit>().markAsRead(item.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDesign.space8),
        padding: const EdgeInsets.all(AppDesign.space16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDesign.radius12),
          border: Border.all(
            color: item.isRead ? AppDesign.border : AppDesign.primary.withOpacity(0.12),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Badge
            Container(
              padding: const EdgeInsets.all(AppDesign.space8),
              decoration: BoxDecoration(
                color: getIconColor().withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(getIcon(), color: getIconColor(), size: 18),
            ),
            const SizedBox(width: AppDesign.space12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppDesign.body(
                            color: AppDesign.textPrimary,
                            fontWeight: item.isRead ? FontWeight.bold : FontWeight.w800,
                            fontSize: 13.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppDesign.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDesign.space4),
                  Text(
                    item.body,
                    style: AppDesign.body(
                      color: item.isRead ? AppDesign.textSecondary : AppDesign.textPrimary.withOpacity(0.8),
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
