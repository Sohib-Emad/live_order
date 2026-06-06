import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/features/user_create_shipment/ui/widget/review_item.dart';

class ReviewCard extends StatelessWidget {
  final String pickupAddress;
  final String dropoffAddress;
  final String cargoType;
  final String size;
  final double weight;
  final String date;
  final String timeRange;
  final String? driverName;
  final String selectedPaymentMethod;
  final ValueChanged<String> onPaymentMethodChanged;

  const ReviewCard({
    super.key,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.cargoType,
    required this.size,
    required this.weight,
    required this.date,
    required this.timeRange,
    this.driverName,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
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
            'مراجعة وتأكيد تفاصيل الطلب',
            style: AppDesign.heading(fontSize: 16.0),
          ),
          const SizedBox(height: AppDesign.space20),
          ReviewItem(title: 'موقع الاستلام (البيك آب)', value: pickupAddress),
          ReviewItem(title: 'موقع التسليم (الدروب أوف)', value: dropoffAddress),
          ReviewItem(title: 'تصنيف ونوع البضاعة', value: cargoType),
          ReviewItem(
            title: 'الحجم والوزن التقريبي للشحنة',
            value: 'حجم $size — ${weight.toInt()} كجم',
          ),
          ReviewItem(
            title: 'موعد التوصيل المختار',
            value: '$date ($timeRange)',
          ),
          if (driverName != null)
            ReviewItem(title: 'السائق المختار للتوصيل', value: driverName!),
          const SizedBox(height: AppDesign.space12),
          Text(
            'طريقة الدفع المفضلة',
            style: AppDesign.body(
              color: AppDesign.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDesign.space12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onPaymentMethodChanged('عند الاستلام'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: selectedPaymentMethod == 'عند الاستلام'
                          ? AppDesign.primary.withOpacity(0.06)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(AppDesign.radius8),
                      border: Border.all(
                        color: selectedPaymentMethod == 'عند الاستلام'
                            ? AppDesign.primary
                            : AppDesign.border,
                        width: selectedPaymentMethod == 'عند الاستلام'
                            ? 1.5
                            : 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.payments_outlined,
                          color: AppDesign.primary,
                          size: 20,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'عند الاستلام',
                          style: AppDesign.body(
                            color: selectedPaymentMethod == 'عند الاستلام'
                                ? AppDesign.primary
                                : AppDesign.textPrimary,
                            fontWeight: selectedPaymentMethod == 'عند الاستلام'
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDesign.space12),
              Expanded(
                child: GestureDetector(
                  onTap: () => onPaymentMethodChanged('بالبطاقة'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: selectedPaymentMethod == 'بالبطاقة'
                          ? AppDesign.primary.withOpacity(0.06)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(AppDesign.radius8),
                      border: Border.all(
                        color: selectedPaymentMethod == 'بالبطاقة'
                            ? AppDesign.primary
                            : AppDesign.border,
                        width: selectedPaymentMethod == 'بالبطاقة' ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.credit_card_outlined,
                          color: AppDesign.primary,
                          size: 20,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'الدفع بالكارت',
                          style: AppDesign.body(
                            color: selectedPaymentMethod == 'بالبطاقة'
                                ? AppDesign.primary
                                : AppDesign.textPrimary,
                            fontWeight: selectedPaymentMethod == 'بالبطاقة'
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: AppDesign.border, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التكلفة التقريبية المتوقعة للطلب',
                style: AppDesign.body(
                  color: AppDesign.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                ),
              ),
              Text(
                '120 ج.م',
                style: AppDesign.heading(
                  color: AppDesign.primary,
                  fontSize: 20.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
