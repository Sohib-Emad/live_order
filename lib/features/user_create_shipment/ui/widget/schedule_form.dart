import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/widgets/app_text_field.dart';

class ScheduleForm extends StatelessWidget {
  final TextEditingController dateController;
  final String selectedTimeRange;
  final ValueChanged<String> onTimeRangeChanged;

  const ScheduleForm({
    super.key,
    required this.dateController,
    required this.selectedTimeRange,
    required this.onTimeRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final times = [
      '09:00 صباحاً - 12:00 ظهراً',
      '12:00 ظهراً - 03:00 عصراً',
      '03:00 عصراً - 06:00 مساءً',
      '06:00 مساءً - 09:00 مساءً',
    ];

    return Container(
      padding: const EdgeInsets.all(AppDesign.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: AppDesign.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('جدولة موعد الشحن', style: AppDesign.heading(fontSize: 16.0)),
          const SizedBox(height: AppDesign.space20),
          AppTextField(
            label: 'تاريخ التوصيل المفضل',
            hint: 'YYYY-MM-DD',
            controller: dateController,
            prefixIcon: const Icon(
              Icons.calendar_today_rounded,
              color: AppDesign.primary,
            ),
          ),
          const SizedBox(height: AppDesign.space24),
          Text(
            'فترة التوقيت المفضلة خلال اليوم',
            style: AppDesign.body(
              color: AppDesign.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDesign.space8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: times.length,
            itemBuilder: (context, index) {
              final t = times[index];
              final isSel = selectedTimeRange == t;
              return GestureDetector(
                onTap: () => onTimeRangeChanged(t),
                child: Container(
                  margin: const EdgeInsets.only(bottom: AppDesign.space8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDesign.space16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSel
                        ? AppDesign.primary.withOpacity(0.08)
                        : AppDesign.surface,
                    borderRadius: BorderRadius.circular(AppDesign.radius8),
                    border: Border.all(
                      color: isSel ? AppDesign.primary : AppDesign.border,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    t,
                    style: AppDesign.body(
                      color: isSel ? AppDesign.primary : AppDesign.textPrimary,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.w400,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
