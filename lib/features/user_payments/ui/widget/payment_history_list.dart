import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/features/user_payments/data/model/payment_models.dart';
import 'package:live_order/core/widgets/status_badge.dart';

class PaymentHistoryList extends StatelessWidget {
  final List<PaymentTransaction> transactions;
  final String selectedCategory;

  const PaymentHistoryList({
    super.key,
    required this.transactions,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = transactions.where((tx) {
      if (selectedCategory == 'All') return true;
      if (selectedCategory == 'Cargo' && tx.category == 'cargo') return true;
      if (selectedCategory == 'Refunds' && tx.category == 'refund') return true;
      if (selectedCategory == 'Rewards' && tx.category == 'rewards') return true;
      return false;
    }).toList();

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Text(
          'لم يتم العثور على عمليات مطابقة.',
          style: AppDesign.body(color: AppDesign.textSecondary),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final tx = filtered[index];

        String actionTitle = tx.title;
        if (tx.title.toLowerCase().contains('cargo shipment')) {
          actionTitle = 'شحنة بضائع';
        } else if (tx.title.toLowerCase().contains('refund')) {
          actionTitle = 'مستردات المحفظة';
        } else if (tx.title.toLowerCase().contains('reward')) {
          actionTitle = 'مكافأة تشجيعية';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: AppDesign.space8),
          padding: const EdgeInsets.all(AppDesign.space12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDesign.radius12),
            border: Border.all(color: AppDesign.border, width: 1.0),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppDesign.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  tx.category == 'cargo'
                      ? Icons.local_shipping_rounded
                      : (tx.category == 'refund'
                            ? Icons.history_rounded
                            : Icons.card_giftcard_rounded),
                  color: AppDesign.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDesign.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      actionTitle,
                      style: AppDesign.body(
                        color: AppDesign.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tx.timestamp.day}/${tx.timestamp.month}/${tx.timestamp.year}',
                      style: AppDesign.body(
                        color: AppDesign.textSecondary,
                        fontSize: 11.0,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${tx.category == 'refund' ? '+' : '-'}${tx.amount.toStringAsFixed(0)} ج.م',
                    style: AppDesign.body(
                      color: tx.category == 'refund'
                          ? AppDesign.success
                          : AppDesign.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: AppDesign.space4),
                  StatusBadge(
                    status: tx.status == 'Completed'
                        ? 'مكتمل'
                        : (tx.status == 'Pending' ? 'معلق' : 'فاشل'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
