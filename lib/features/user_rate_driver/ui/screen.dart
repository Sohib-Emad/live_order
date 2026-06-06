// lib/features/rate_driver/ui/screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/features/rate_driver/logic/cubit.dart';
import 'package:live_order/features/rate_driver/logic/state.dart';
import 'package:live_order/shared/widgets/app_button.dart';
import 'package:live_order/shared/widgets/app_text_field.dart';
import 'package:live_order/shared/widgets/avatar_widget.dart';
import 'package:live_order/shared/widgets/rating_stars.dart';

class RateDriverScreen extends StatefulWidget {
  final UserProfile driver;

  const RateDriverScreen({
    super.key,
    required this.driver,
  });

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  final List<String> _selectedTags = [];

  final List<String> _feedbackTags = [
    'Careful Driver',
    'Punctual',
    'Great Loader',
    'Professional',
    'Friendly',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _submitReview() {
    context.read<RateDriverCubit>().submitDriverReview(
          driverId: widget.driver.uid,
          rating: _rating,
          comment: _commentController.text.trim(),
          tags: _selectedTags,
          reviewerName: 'Ahmed', // Client Name
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppDesign.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Rate Driver',
          style: AppDesign.heading(fontSize: 18.0),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<RateDriverCubit, RateDriverState>(
        listener: (context, state) {
          if (state is RateDriverSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thank you! Review submitted successfully.'),
                backgroundColor: AppDesign.success,
              ),
            );
            Navigator.pop(context);
          } else if (state is RateDriverError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Submission failed: ${state.message}'),
                backgroundColor: AppDesign.danger,
              ),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is RateDriverSubmitting;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppDesign.space20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppDesign.space12),
                
                // Driver Details Head
                AvatarWidget(
                  imageUrl: widget.driver.imageUrl,
                  fallbackName: widget.driver.name,
                  radius: 36,
                ),
                const SizedBox(height: AppDesign.space12),
                Text(
                  widget.driver.name,
                  style: AppDesign.heading(fontSize: 17.0),
                ),
                const SizedBox(height: AppDesign.space4),
                Text(
                  widget.driver.vehicleType ?? 'Cargo Driver',
                  style: AppDesign.body(color: AppDesign.textSecondary, fontSize: 13.0),
                ),

                const SizedBox(height: AppDesign.space32),

                // Star rating interaction panel
                Text(
                  'How was your delivery service?',
                  style: AppDesign.body(
                    color: AppDesign.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: AppDesign.space12),
                RatingStars(
                  rating: _rating,
                  starSize: 32.0,
                  onRatingChanged: (val) {
                    setState(() {
                      _rating = val;
                    });
                  },
                ),

                const SizedBox(height: AppDesign.space32),

                // Feedback Tags Row
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select what you liked most',
                    style: AppDesign.body(
                      color: AppDesign.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                const SizedBox(height: AppDesign.space12),
                Wrap(
                  spacing: AppDesign.space8,
                  runSpacing: AppDesign.space8,
                  children: _feedbackTags.map((tag) {
                    final isSelected = _selectedTags.contains(tag);
                    return GestureDetector(
                      onTap: () => _toggleTag(tag),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppDesign.space16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppDesign.primary.withOpacity(0.08) : AppDesign.surface,
                          borderRadius: BorderRadius.circular(AppDesign.radius24),
                          border: Border.all(
                            color: isSelected ? AppDesign.primary : AppDesign.border,
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: AppDesign.body(
                            color: isSelected ? AppDesign.primary : AppDesign.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppDesign.space28),

                // Custom Comment Area
                AppTextField(
                  label: 'Add a written review (optional)',
                  hint: 'Explain what went great or any specific tips...',
                  controller: _commentController,
                  keyboardType: TextInputType.multiline,
                ),

                const SizedBox(height: AppDesign.space32),

                // Submit Button
                AppButton(
                  label: 'Submit Review',
                  isLoading: isSubmitting,
                  onTap: isSubmitting ? null : _submitReview,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
