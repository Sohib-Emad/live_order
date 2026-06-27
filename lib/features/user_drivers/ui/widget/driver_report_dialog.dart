import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/features/user_drivers/logic/cubit.dart';

void showDriverReportDialog(BuildContext context, UserProfile driver) {
  final cubit = context.read<DriversCubit>();
  final TextEditingController reasonController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesign.radius12),
          ),
          title: Row(
            children: [
              const Icon(Icons.flag_rounded, color: AppDesign.danger),
              const SizedBox(width: 8),
              Text(
                'إبلاغ عن السائق',
                style: AppDesign.heading(fontSize: 16.0),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ساعدنا في الحفاظ على أمان المنصة. يرجى كتابة تفاصيل المشكلة أو الشكوى بالتفصيل وسيقوم فريق الدعم بمراجعتها فوراً.',
                style: AppDesign.body(color: AppDesign.textSecondary),
              ),
              const SizedBox(height: AppDesign.space16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                cursorColor: AppDesign.primary,
                decoration: InputDecoration(
                  hintText: 'اكتب سبب الإبلاغ أو تفاصيل المشكلة هنا...',
                  hintStyle: AppDesign.body(
                    color: AppDesign.textSecondary.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDesign.radius8),
                    borderSide: const BorderSide(color: AppDesign.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDesign.radius8),
                    borderSide: const BorderSide(color: AppDesign.danger),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: AppDesign.body(
                  color: AppDesign.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final text = reasonController.text.trim();
                if (text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى كتابة سبب الإبلاغ أولاً'),
                      backgroundColor: AppDesign.danger,
                    ),
                  );
                  return;
                }
                Navigator.pop(context);

                cubit.reportDriver(driver.uid, driver.name, text);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'تم إرسال بلاغك بنجاح وسيقوم فريق الدعم بفحصه.',
                    ),
                    backgroundColor: AppDesign.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesign.danger,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDesign.radius8),
                ),
              ),
              child: Text(
                'إرسال البلاغ',
                style: AppDesign.body(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
