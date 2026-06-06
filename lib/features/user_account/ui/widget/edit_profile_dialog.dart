import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/constants/app_design.dart';

class EditProfileDialog extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final void Function(String name, String email) onSave;

  const EditProfileDialog({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.onSave,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'تعديل البيانات الشخصية',
          style: AppDesign.heading(fontSize: 16.0),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEditTextField(
                'الاسم كامل',
                _nameController,
                Icons.person_outline_rounded,
              ),
              SizedBox(height: 16.h),
              _buildEditTextField(
                'البريد الإلكتروني',
                _emailController,
                Icons.email_outlined,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: AppDesign.body(color: AppDesign.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppDesign.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              elevation: 0,
            ),
            onPressed: () {
              widget.onSave(_nameController.text, _emailController.text);
              Navigator.pop(context);
            },
            child: Text(
              'حفظ التعديلات',
              style: AppDesign.body(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      style: AppDesign.body(color: AppDesign.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppDesign.body(color: AppDesign.textSecondary),
        prefixIcon: Icon(icon, color: AppDesign.primary),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        filled: true,
        fillColor: AppDesign.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppDesign.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppDesign.primary, width: 1.5),
        ),
      ),
    );
  }
}
