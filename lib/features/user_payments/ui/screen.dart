// lib/features/user_payments/ui/screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/features/user_payments/logic/cubit.dart';
import 'package:live_order/features/user_payments/logic/state.dart';
import 'package:live_order/features/user_payments/ui/widget/add_payment_dialog.dart';
import 'package:live_order/features/user_payments/ui/widget/empty_cards_block.dart';
import 'package:live_order/features/user_payments/ui/widget/payment_history_list.dart';
import 'package:live_order/features/user_payments/ui/widget/payment_loading_state.dart';
import 'package:live_order/features/user_payments/ui/widget/payment_method_card.dart';
import 'package:live_order/features/user_payments/ui/widget/payment_preference_toggle.dart';
import 'package:live_order/features/user_payments/ui/widget/transaction_filter_chip.dart';
import 'package:live_order/core/widgets/empty_state.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String _selectedTxCategory = 'All';

  @override
  void initState() {
    super.initState();
    context.read<PaymentsCubit>().loadPaymentDetails();
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
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppDesign.textPrimary,
                  ),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          title: Text(
            'المحفظة والمدفوعات',
            style: AppDesign.heading(fontSize: 18.0),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<PaymentsCubit, PaymentsState>(
          builder: (context, state) {
            if (state is PaymentsLoading) {
              return const PaymentLoadingState();
            } else if (state is PaymentsError) {
              return EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'خطأ في المحفظة',
                subtitle: state.message,
                actionLabel: 'إعادة المحاولة',
                onActionTap: () =>
                    context.read<PaymentsCubit>().loadPaymentDetails(),
              );
            } else if (state is PaymentsLoaded) {
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<PaymentsCubit>().loadPaymentDetails(),
                color: AppDesign.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppDesign.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PaymentPreferenceToggle(
                        isCash: state.isCashPreferred,
                        onChanged: (val) {
                          context.read<PaymentsCubit>().togglePaymentPreference(val);
                        },
                      ),

                      const SizedBox(height: AppDesign.space24),

                      // Saved Cards Title + Add Card Action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'البطاقات المحفوظة',
                            style: AppDesign.heading(fontSize: 16.0),
                          ),
                          TextButton(
                            onPressed: () => AddPaymentDialog.show(context),
                            child: Text(
                              '+ إضافة بطاقة جديدة',
                              style: AppDesign.body(
                                color: AppDesign.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDesign.space12),

                      // Cards Slider / List
                      if (state.cards.isEmpty)
                        const EmptyCardsBlock()
                      else
                        SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.cards.length,
                            itemBuilder: (context, index) {
                              final card = state.cards[index];
                              return PaymentMethodCard(
                                card: card,
                                onDelete: () => context.read<PaymentsCubit>().removeCard(card.id),
                              );
                            },
                          ),
                        ),

                      SizedBox(height: AppDesign.space28),

                      // Transactions Title + Filter Chips
                      Text(
                        'سجل المعاملات الأخيرة',
                        style: AppDesign.heading(fontSize: 16.0),
                      ),
                      const SizedBox(height: AppDesign.space12),
                      SizedBox(
                        height: 38,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            TransactionFilterChip(
                              categoryKey: 'All',
                              label: 'الكل',
                              isSelected: _selectedTxCategory == 'All',
                              onTap: () => setState(() => _selectedTxCategory = 'All'),
                            ),
                            const SizedBox(width: AppDesign.space8),
                            TransactionFilterChip(
                              categoryKey: 'Cargo',
                              label: 'الشحنات',
                              isSelected: _selectedTxCategory == 'Cargo',
                              onTap: () => setState(() => _selectedTxCategory = 'Cargo'),
                            ),
                            const SizedBox(width: AppDesign.space8),
                            TransactionFilterChip(
                              categoryKey: 'Refunds',
                              label: 'المستردات',
                              isSelected: _selectedTxCategory == 'Refunds',
                              onTap: () => setState(() => _selectedTxCategory = 'Refunds'),
                            ),
                            const SizedBox(width: AppDesign.space8),
                            TransactionFilterChip(
                              categoryKey: 'Rewards',
                              label: 'المكافآت',
                              isSelected: _selectedTxCategory == 'Rewards',
                              onTap: () => setState(() => _selectedTxCategory = 'Rewards'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDesign.space16),

                      // Transactions List
                      if (state.transactions.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          alignment: Alignment.center,
                          child: Text(
                            'لا توجد معاملات مسجلة حتى الآن.',
                            style: AppDesign.body(
                              color: AppDesign.textSecondary,
                            ),
                          ),
                        )
                      else
                        PaymentHistoryList(
                          transactions: state.transactions,
                          selectedCategory: _selectedTxCategory,
                        ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

}
