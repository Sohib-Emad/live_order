import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/utils/animated_snack_dialog.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/features/driver_orders/logic/cubit/add_order_cubit.dart';
import 'package:live_order/core/models/shipment.dart';

class InteractiveRatingCard extends StatefulWidget {
  final Shipment order;
  const InteractiveRatingCard({super.key, required this.order});

  @override
  State<InteractiveRatingCard> createState() => _InteractiveRatingCardState();
}

class _InteractiveRatingCardState extends State<InteractiveRatingCard> {
  double _rating = 5.0;
  final TextEditingController _reviewController = TextEditingController();
  bool _submitted = false;
  double? _submittedRating;
  String? _submittedReview;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDelivered =
        widget.order.status == 'مكتمل' ||
        widget.order.status == 'Delivered';
    if (!isDelivered) {
      return const SizedBox.shrink();
    }

    final hasRating = widget.order.rating != null || _submitted;
    final ratingToShow = _submitted ? _submittedRating : widget.order.rating;
    final reviewToShow = _submitted ? _submittedReview : widget.order.review;

    if (hasRating) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: const Color(0xFFFFB300),
                  size: 22.sp,
                ),
                const WidthSpace(8),
                Text(
                  'تقييمك لمندوب التوصيل',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const HeightSpace(12),
            Row(
              children: List.generate(5, (index) {
                final starVal = index + 1;
                return Icon(
                  Icons.star_rounded,
                  color: starVal <= (ratingToShow ?? 5.0)
                      ? const Color(0xFFFFB300)
                      : Colors.grey[200],
                  size: 26.sp,
                );
              }),
            ),
            if (reviewToShow != null && reviewToShow.isNotEmpty) ...[
              const HeightSpace(12),
              Text(
                'تعليقك المكتوب:',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
              ),
              const HeightSpace(4),
              Text(
                '"$reviewToShow"',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return BlocConsumer<AddOrderCubit, AddOrderState>(
      listener: (context, state) {
        if (state is AddOrderSuccess) {
          setState(() {
            _submitted = true;
            _submittedRating = _rating;
            _submittedReview = _reviewController.text.trim();
          });
          showAnimatedSnackDialog(
            context,
            message: 'شكرًا لك! تم تسجيل تقييمك للمندوب بنجاح.',
            type: AnimatedSnackBarType.success,
          );
        } else if (state is AddOrderError) {
          showAnimatedSnackDialog(
            context,
            message: state.message,
            type: AnimatedSnackBarType.error,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AddOrderLoading;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.stars_rounded,
                    color: const Color(0xFFFFB300),
                    size: 22.sp,
                  ),
                  const WidthSpace(8),
                  Text(
                    'تقييم كابتن التوصيل',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              const HeightSpace(6),
              Text(
                'شاركنا تجربتك وقيم تعامل وسرعة كابتن التوصيل لتطوير الخدمة.',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey[500],
                  height: 1.4,
                ),
              ),
              const HeightSpace(16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starVal = index + 1;
                  final isSelected = starVal <= _rating;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _rating = starVal.toDouble();
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Icon(
                        Icons.star_rounded,
                        color: isSelected
                            ? const Color(0xFFFFB300)
                            : Colors.grey[200],
                        size: 38.sp,
                      ),
                    ),
                  );
                }),
              ),
              const HeightSpace(16),

              Text(
                'اكتب مراجعتك أو تعليقك (اختياري)',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF555555),
                ),
              ),
              const HeightSpace(8),
              TextFormField(
                controller: _reviewController,
                maxLines: 2,
                cursorColor: const Color(0xFFFFB300),
                decoration: InputDecoration(
                  hintText: 'اكتب تجربتك هنا مع الكابتن...',
                  hintStyle: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[400],
                  ),
                  contentPadding: EdgeInsets.all(12.w),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(
                      color: Color(0xffE8ECF4),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(
                      color: Color(0xFFFFB300),
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xffF7F8F9),
                ),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const HeightSpace(16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          context.read<AddOrderCubit>().rateDriverAndComplete(
                            shipmentId: widget.order.id,
                            driverId: widget.order.driverId,
                            newRating: _rating,
                            review: _reviewController.text.trim(),
                          );
                        },
                  icon: isLoading
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 16),
                  label: Text(
                    isLoading ? 'جاري الإرسال...' : 'إرسال التقييم والدعم',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
