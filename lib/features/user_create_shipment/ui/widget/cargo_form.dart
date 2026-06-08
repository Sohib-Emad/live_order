import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/widgets/app_text_field.dart';

class CargoForm extends StatelessWidget {
  final String selectedCargoType;
  final ValueChanged<String> onCargoTypeChanged;
  final String selectedSize;
  final ValueChanged<String> onSizeChanged;
  final double weight;
  final ValueChanged<double> onWeightChanged;
  final TextEditingController notesController;

  const CargoForm({
    super.key,
    required this.selectedCargoType,
    required this.onCargoTypeChanged,
    required this.selectedSize,
    required this.onSizeChanged,
    required this.weight,
    required this.onWeightChanged,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    final cargoTypes = [
      'أثاث وموبيليا',
      'أجهزة إلكترونية',
      'صناديق وكراتين',
      'أوراق ومستندات',
      'شحنات أخرى',
    ];
    final sizes = ['S', 'M', 'L', 'XL'];

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
          Text(
            'تفاصيل البضاعة المشحونة',
            style: AppDesign.heading(fontSize: 16.0),
          ),
          const SizedBox(height: AppDesign.space20),
          Text(
            'تصنيف نوع الشحنة',
            style: AppDesign.body(
              color: AppDesign.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDesign.space8),
          DropdownButtonFormField<String>(
            initialValue: selectedCargoType,
            items: cargoTypes
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (val) {
              if (val != null) onCargoTypeChanged(val);
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: AppDesign.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
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
          const SizedBox(height: AppDesign.space20),
          Text(
            'حجم وأبعاد الشحنة',
            style: AppDesign.body(
              color: AppDesign.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDesign.space8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: sizes.map((size) {
              final isSelected = selectedSize == size;
              return GestureDetector(
                onTap: () => onSizeChanged(size),
                child: Container(
                  width: 54,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSelected ? AppDesign.primary : AppDesign.surface,
                    borderRadius: BorderRadius.circular(AppDesign.radius8),
                    border: Border.all(
                      color: isSelected ? AppDesign.primary : AppDesign.border,
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      size,
                      style: AppDesign.heading(
                        color: isSelected
                            ? Colors.white
                            : AppDesign.textPrimary,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDesign.space20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الوزن التقريبي للبضاعة',
                style: AppDesign.body(
                  color: AppDesign.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${weight.toInt()} كجم',
                style: AppDesign.heading(fontSize: 15.0),
              ),
            ],
          ),
          Slider(
            value: weight,
            min: 1.0,
            max: 200.0,
            activeColor: AppDesign.primary,
            inactiveColor: AppDesign.border,
            onChanged: onWeightChanged,
          ),
          const SizedBox(height: AppDesign.space12),
          AppTextField(
            label: 'ملاحظات إضافية للتوصيل',
            hint: 'مثال: قابلة للكسر، تحتاج مساعدة في التنزيل والتحميل...',
            controller: notesController,
          ),
        ],
      ),
    );
  }
}
