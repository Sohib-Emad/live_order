// lib/features/user_rate_driver/ui/screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/features/user_rate_driver/logic/cubit.dart';
import 'package:live_order/features/user_rate_driver/logic/state.dart';
import 'package:live_order/features/user_rate_driver/ui/widget/driver_preview_card.dart';
import 'package:live_order/features/user_rate_driver/ui/widget/review_form.dart';
import 'package:live_order/features/user_rate_driver/ui/widget/star_rating.dart';

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

  void _submitReview(String comment, List<String> tags) {
    context.read<RateDriverCubit>().submitDriverReview(
          driverId: widget.driver.uid,
          rating: _rating,
          comment: comment,
          tags: tags,
          reviewerName: 'Ahmed',
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
                DriverPreviewCard(driver: widget.driver),
                const SizedBox(height: AppDesign.space32),
                StarRating(
                  rating: _rating,
                  onRatingChanged: (val) {
                    setState(() {
                      _rating = val;
                    });
                  },
                ),
                const SizedBox(height: AppDesign.space32),
                ReviewForm(
                  isSubmitting: isSubmitting,
                  onSubmit: _submitReview,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
