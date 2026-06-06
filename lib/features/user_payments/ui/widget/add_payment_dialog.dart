import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/features/user_payments/logic/cubit.dart';
import 'package:live_order/core/widgets/app_button.dart';
import 'package:live_order/core/widgets/app_text_field.dart';

class AddPaymentDialog extends StatefulWidget {
  const AddPaymentDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDesign.radius24),
        ),
      ),
      builder: (ctx) => const AddPaymentDialog(),
    );
  }

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _holderController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  String _cardType = 'visa';

  @override
  void dispose() {
    _holderController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(AppDesign.space20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'إضافة بطاقة ائتمان / خصم',
                    style: AppDesign.heading(fontSize: 18.0),
                  ),
                  const SizedBox(height: AppDesign.space20),
                  AppTextField(
                    label: 'اسم حامل البطاقة',
                    hint: 'مثال: محمد أحمد علي',
                    controller: _holderController,
                    validator: (v) => v == null || v.isEmpty
                        ? 'اسم حامل البطاقة مطلوب'
                        : null,
                  ),
                  const SizedBox(height: AppDesign.space16),
                  AppTextField(
                    label: 'رقم البطاقة',
                    hint: '1234 5678 1234 5678',
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'رقم البطاقة مطلوب';
                      if (v.replaceAll(' ', '').length < 16)
                        return 'أدخل رقم بطاقة صحيح من 16 رقم';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDesign.space16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'تاريخ الانتهاء',
                          hint: 'MM/YY',
                          controller: _expiryController,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'تاريخ الانتهاء مطلوب';
                            if (!v.contains('/'))
                              return 'الصيغة الصحيحة MM/YY';
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
                              'نوع البطاقة',
                              style: AppDesign.body(
                                color: AppDesign.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppDesign.space8),
                            DropdownButtonFormField<String>(
                              value: _cardType,
                              items: const [
                                DropdownMenuItem(
                                  value: 'visa',
                                  child: Text('VISA'),
                                ),
                                DropdownMenuItem(
                                  value: 'mastercard',
                                  child: Text('MASTERCARD'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _cardType = val);
                                }
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDesign.radius8,
                                  ),
                                  borderSide: const BorderSide(
                                    color: AppDesign.border,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDesign.radius8,
                                  ),
                                  borderSide: const BorderSide(
                                    color: AppDesign.primary,
                                  ),
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
                    label: 'ربط البطاقة الآن',
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        final number = _numberController.text.trim();
                        final masked =
                            '**** **** **** ${number.substring(number.length - 4)}';
                        context.read<PaymentsCubit>().addNewCard(
                          holderName: _holderController.text.trim(),
                          cardNumber: masked,
                          expiryDate: _expiryController.text.trim(),
                          cardType: _cardType,
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
