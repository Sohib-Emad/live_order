// lib/features/payments/ui/screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/features/payments/data/model/payment_models.dart';
import 'package:live_order/features/payments/logic/cubit.dart';
import 'package:live_order/features/payments/logic/state.dart';
import 'package:live_order/shared/widgets/app_button.dart';
import 'package:live_order/shared/widgets/app_text_field.dart';
import 'package:live_order/shared/widgets/empty_state.dart';
import 'package:live_order/shared/widgets/loading_shimmer.dart';
import 'package:live_order/shared/widgets/status_badge.dart';

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
    return Scaffold(
      backgroundColor: AppDesign.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppDesign.textPrimary),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'Payments & Wallet',
          style: AppDesign.heading(fontSize: 18.0),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<PaymentsCubit, PaymentsState>(
        builder: (context, state) {
          if (state is PaymentsLoading) {
            return _buildLoadingState();
          } else if (state is PaymentsError) {
            return EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Wallet Error',
              subtitle: state.message,
              actionLabel: 'Retry',
              onActionTap: () => context.read<PaymentsCubit>().loadPaymentDetails(),
            );
          } else if (state is PaymentsLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<PaymentsCubit>().loadPaymentDetails(),
              color: AppDesign.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppDesign.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment Preference Selector
                    _buildPreferenceToggle(state.isCashPreferred),

                    const SizedBox(height: AppDesign.space24),

                    // Saved Cards Title + Add Card Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Saved Cards',
                          style: AppDesign.heading(fontSize: 16.0),
                        ),
                        TextButton(
                          onPressed: () => _showAddCardSheet(context),
                          child: Text(
                            '+ Add New',
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
                      _buildEmptyCardsBlock()
                    else
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.cards.length,
                          itemBuilder: (context, index) {
                            final card = state.cards[index];
                            return _buildCreditCard(card);
                          },
                        ),
                      ),

                     SizedBox(height: AppDesign.space28),

                    // Transactions Title + Filter Chips
                    Text(
                      'Transaction History',
                      style: AppDesign.heading(fontSize: 16.0),
                    ),
                    const SizedBox(height: AppDesign.space12),
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildFilterChip('All'),
                          const SizedBox(width: AppDesign.space8),
                          _buildFilterChip('Cargo'),
                          const SizedBox(width: AppDesign.space8),
                          _buildFilterChip('Refunds'),
                          const SizedBox(width: AppDesign.space8),
                          _buildFilterChip('Rewards'),
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
                          'No transactions recorded yet.',
                          style: AppDesign.body(color: AppDesign.textSecondary),
                        ),
                      )
                    else
                      _buildTransactionsList(state.transactions),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPreferenceToggle(bool isCash) {
    return Container(
      padding: const EdgeInsets.all(AppDesign.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: AppDesign.border, width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prefer Cash Payments',
                style: AppDesign.body(color: AppDesign.textPrimary, fontWeight: FontWeight.bold, fontSize: 14.5),
              ),
              const SizedBox(height: AppDesign.space4),
              Text(
                'Toggle to settle fees directly in cash.',
                style: AppDesign.body(color: AppDesign.textSecondary, fontSize: 12.0),
              ),
            ],
          ),
          Switch(
            value: isCash,
            activeColor: AppDesign.primary,
            activeTrackColor: AppDesign.primary.withOpacity(0.12),
            onChanged: (val) {
              context.read<PaymentsCubit>().togglePaymentPreference(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCardsBlock() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppDesign.space32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: AppDesign.border, width: 1.0),
      ),
      child: Column(
        children: [
          const Icon(Icons.credit_card_off_outlined, color: AppDesign.textSecondary, size: 36),
          const SizedBox(height: AppDesign.space8),
          Text(
            'No credit cards linked yet',
            style: AppDesign.body(color: AppDesign.textPrimary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDesign.space4),
          Text(
            'Add a card to enable cashless fast checkout.',
            style: AppDesign.body(color: AppDesign.textSecondary, fontSize: 12.0),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCard(SavedCard card) {
    final isVisa = card.cardType.toLowerCase() == 'visa';
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: AppDesign.space12),
      padding: const EdgeInsets.all(AppDesign.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isVisa
              ? [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)]
              : [const Color(0xFF111827), const Color(0xFF374151)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                card.cardType.toUpperCase(),
                style: AppDesign.heading(color: Colors.white, fontSize: 16.0),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.white70, size: 18),
                onPressed: () => context.read<PaymentsCubit>().removeCard(card.id),
              ),
            ],
          ),
          const SizedBox(height: AppDesign.space16),
          Text(
            card.cardNumber,
            style: AppDesign.heading(
              color: Colors.white,
              fontSize: 17.0,
            ),
          ),
          const SizedBox(height: AppDesign.space16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CARD HOLDER',
                    style: TextStyle(color: Colors.white54, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    card.cardHolder.toUpperCase(),
                    style: AppDesign.body(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EXPIRES',
                    style: TextStyle(color: Colors.white54, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    card.expiryDate,
                    style: AppDesign.body(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedTxCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTxCategory = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppDesign.space16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppDesign.primary : AppDesign.surface,
          borderRadius: BorderRadius.circular(AppDesign.radius24),
          border: Border.all(
            color: isSelected ? AppDesign.primary : AppDesign.border,
            width: 1.0,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppDesign.body(
              color: isSelected ? Colors.white : AppDesign.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 13.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList(List<PaymentTransaction> list) {
    final filtered = list.where((tx) {
      if (_selectedTxCategory == 'All') return true;
      if (_selectedTxCategory == 'Cargo' && tx.category == 'cargo') return true;
      if (_selectedTxCategory == 'Refunds' && tx.category == 'refund') return true;
      if (_selectedTxCategory == 'Rewards' && tx.category == 'rewards') return true;
      return false;
    }).toList();

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Text(
          'No matching transactions found.',
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
                      : (tx.category == 'refund' ? Icons.history_rounded : Icons.card_giftcard_rounded),
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
                      tx.title,
                      style: AppDesign.body(color: AppDesign.textPrimary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tx.timestamp.day}/${tx.timestamp.month}/${tx.timestamp.year}',
                      style: AppDesign.body(color: AppDesign.textSecondary, fontSize: 11.0),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${tx.category == 'refund' ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                    style: AppDesign.body(
                      color: tx.category == 'refund' ? AppDesign.success : AppDesign.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: AppDesign.space4),
                  StatusBadge(
                    status: tx.status,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCardSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final holderController = TextEditingController();
    final numberController = TextEditingController();
    final expiryController = TextEditingController();
    String cardType = 'visa';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDesign.radius24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(AppDesign.space20),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add Credit / Debit Card',
                      style: AppDesign.heading(fontSize: 18.0),
                    ),
                    const SizedBox(height: AppDesign.space20),
                    AppTextField(
                      label: 'Card Holder Name',
                      hint: 'John Doe',
                      controller: holderController,
                      validator: (v) => v == null || v.isEmpty ? 'Holder name is required' : null,
                    ),
                    const SizedBox(height: AppDesign.space16),
                    AppTextField(
                      label: 'Card Number',
                      hint: '1234 5678 1234 5678',
                      controller: numberController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Card number is required';
                        if (v.replaceAll(' ', '').length < 16) return 'Enter a valid 16-digit card';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDesign.space16),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Expiry Date',
                            hint: 'MM/YY',
                            controller: expiryController,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Expiry is required';
                              if (!v.contains('/')) return 'Format MM/YY';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: AppDesign.space16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Card Provider',
                                style: AppDesign.body(color: AppDesign.textPrimary, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: AppDesign.space8),
                              DropdownButtonFormField<String>(
                                value: cardType,
                                items: const [
                                  DropdownMenuItem(value: 'visa', child: Text('VISA')),
                                  DropdownMenuItem(value: 'mastercard', child: Text('MASTERCARD')),
                                ],
                                onChanged: (val) {
                                  if (val != null) cardType = val;
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppDesign.radius8),
                                    borderSide: const BorderSide(color: AppDesign.border),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppDesign.radius8),
                                    borderSide: const BorderSide(color: AppDesign.primary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDesign.space24),
                    AppButton(
                      label: 'Link Card',
                      onTap: () {
                        if (formKey.currentState!.validate()) {
                          final number = numberController.text.trim();
                          // Simple masking
                          final masked = '**** **** **** ${number.substring(number.length - 4)}';
                          context.read<PaymentsCubit>().addNewCard(
                                holderName: holderController.text.trim(),
                                cardNumber: masked,
                                expiryDate: expiryController.text.trim(),
                                cardType: cardType,
                              );
                          Navigator.pop(ctx);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(AppDesign.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          LoadingShimmer(width: double.infinity, height: 60, borderRadius: 12),
          SizedBox(height: 24),
          LoadingShimmer(width: 150, height: 20),
          SizedBox(height: 12),
          LoadingShimmer(width: 280, height: 180, borderRadius: 12),
          SizedBox(height: 24),
          LoadingShimmer(width: 150, height: 20),
          SizedBox(height: 12),
          LoadingShimmer(width: double.infinity, height: 80, borderRadius: 12),
        ],
      ),
    );
  }
}
