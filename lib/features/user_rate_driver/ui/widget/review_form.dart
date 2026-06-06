import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/widgets/app_button.dart';
import 'package:live_order/core/widgets/app_text_field.dart';

class ReviewForm extends StatefulWidget {
  final bool isSubmitting;
  final void Function(String comment, List<String> tags) onSubmit;

  const ReviewForm({
    super.key,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        AppTextField(
          label: 'Add a written review (optional)',
          hint: 'Explain what went great or any specific tips...',
          controller: _commentController,
          keyboardType: TextInputType.multiline,
        ),
        const SizedBox(height: AppDesign.space32),
        AppButton(
          label: 'Submit Review',
          isLoading: widget.isSubmitting,
          onTap: widget.isSubmitting
              ? null
              : () => widget.onSubmit(
                    _commentController.text.trim(),
                    _selectedTags,
                  ),
        ),
      ],
    );
  }
}
