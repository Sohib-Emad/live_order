import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/widgets/primary_button_widget.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/features/auth/widget/custom_input_field.dart';
import 'package:live_order/features/auth/widget/role_selector.dart';

class RegisterForm extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController vehicleTypeController;
  final TextEditingController vehiclePlateController;
  final TextEditingController vehicleCapacityController;
  final TextEditingController nationalIdController;
  final TextEditingController licenseNumberController;
  final String selectedRole;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool isLoading;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onToggleObscurePassword;
  final VoidCallback onToggleObscureConfirmPassword;
  final VoidCallback onRegister;
  final File? driverImage;
  final File? idFrontImage;
  final File? idBackImage;
  final File? licenseImage;
  final File? vehicleImage;
  final VoidCallback? onPickDriverImage;
  final VoidCallback? onPickIdFront;
  final VoidCallback? onPickIdBack;
  final VoidCallback? onPickLicense;
  final VoidCallback? onPickVehicle;

  const RegisterForm({
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.phoneController,
    required this.addressController,
    required this.vehicleTypeController,
    required this.vehiclePlateController,
    required this.vehicleCapacityController,
    required this.nationalIdController,
    required this.licenseNumberController,
    required this.selectedRole,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.isLoading,
    required this.onRoleChanged,
    required this.onToggleObscurePassword,
    required this.onToggleObscureConfirmPassword,
    required this.onRegister,
    this.driverImage,
    this.idFrontImage,
    this.idBackImage,
    this.licenseImage,
    this.vehicleImage,
    this.onPickDriverImage,
    this.onPickIdFront,
    this.onPickIdBack,
    this.onPickLicense,
    this.onPickVehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RoleSelector(
          selectedRole: selectedRole,
          onRoleChanged: onRoleChanged,
        ),
        const HeightSpace(24),
        _sectionHeader('بيانات الحساب', Icons.person_outline_rounded),
        const HeightSpace(14),
        CustomInputField(
          controller: usernameController,
          label: 'اسم المستخدم كامل',
          hint: 'مثال: محمد أحمد علي',
          icon: Icons.person_outline_rounded,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'يرجى إدخال اسم المستخدم';
            }
            return null;
          },
        ),
        const HeightSpace(12),
        CustomInputField(
          controller: emailController,
          label: 'البريد الإلكتروني',
          hint: 'example@domain.com',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'يرجى إدخال البريد الإلكتروني';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'يرجى إدخال بريد إلكتروني صحيح';
            }
            return null;
          },
        ),
        const HeightSpace(12),
        CustomInputField(
          controller: passwordController,
          label: 'كلمة المرور',
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          obscureText: obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey[400],
              size: 19.sp,
            ),
            onPressed: onToggleObscurePassword,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال كلمة المرور';
            }
            if (value.length < 8) {
              return 'يجب ألا تقل كلمة المرور عن 8 أحرف';
            }
            return null;
          },
        ),
        const HeightSpace(12),
        CustomInputField(
          controller: confirmPasswordController,
          label: 'تأكيد كلمة المرور',
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          obscureText: obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              obscureConfirmPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey[400],
              size: 19.sp,
            ),
            onPressed: onToggleObscureConfirmPassword,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى تأكيد كلمة المرور';
            }
            if (value != passwordController.text) {
              return 'كلمة المرور غير متطابقة';
            }
            return null;
          },
        ),
        const HeightSpace(12),
        CustomInputField(
          controller: addressController,
          label: 'العنوان',
          hint: 'المدينة، المنطقة، الشارع',
          icon: Icons.location_on_outlined,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          child: selectedRole == 'driver'
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeightSpace(24),
                    _sectionHeader('معلومات السواق', Icons.info_outline_rounded),
                    const HeightSpace(14),
                    CustomInputField(
                      controller: phoneController,
                      label: 'رقم الجوال',
                      hint: 'مثال: ٠١٠٠٠٠٠٠٠٠',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (selectedRole == 'driver' &&
                            (value == null || value.trim().isEmpty)) {
                          return 'يرجى إدخال رقم الجوال';
                        }
                        return null;
                      },
                    ),
                    const HeightSpace(12),
                    CustomInputField(
                      controller: vehicleTypeController,
                      label: 'نوع المركبة',
                      hint: 'مثال: تروسيكل، دراجة نارية، سيارة',
                      icon: Icons.directions_car_rounded,
                    ),
                    const HeightSpace(12),
                    CustomInputField(
                      controller: vehiclePlateController,
                      label: 'رقم اللوحة',
                      hint: 'مثال: أ ب ج ١٢٣',
                      icon: Icons.confirmation_number_rounded,
                    ),
                    const HeightSpace(12),
                    CustomInputField(
                      controller: vehicleCapacityController,
                      label: 'سعة المركبة',
                      hint: 'مثال: ٥٠٠ كجم',
                      icon: Icons.speed_rounded,
                    ),
                    const HeightSpace(12),
                    CustomInputField(
                      controller: nationalIdController,
                      label: 'الرقم القومي',
                      hint: 'مثال: ٢٩٨٠١٠١٠١٠١٠١٠١',
                      icon: Icons.badge_rounded,
                    ),
                    const HeightSpace(12),
                    CustomInputField(
                      controller: licenseNumberController,
                      label: 'رقم رخصة القيادة',
                      hint: 'مثال: ١٢٣٤٥٦',
                      icon: Icons.assignment_ind_rounded,
                    ),
                    const HeightSpace(16),
                    _buildImagePickerField(
                      label: 'الصورة الشخصية',
                      pickedFile: driverImage,
                      onPick: onPickDriverImage,
                    ),
                    const HeightSpace(24),
                    _sectionHeader('مستندات التوثيق', Icons.verified_outlined),
                    const HeightSpace(14),
                    _buildImagePickerField(
                      label: 'صورة البطاقة (وجه)',
                      pickedFile: idFrontImage,
                      onPick: onPickIdFront,
                    ),
                    const HeightSpace(10),
                    _buildImagePickerField(
                      label: 'صورة البطاقة (ظهر)',
                      pickedFile: idBackImage,
                      onPick: onPickIdBack,
                    ),
                    const HeightSpace(10),
                    _buildImagePickerField(
                      label: 'صورة رخصة القيادة',
                      pickedFile: licenseImage,
                      onPick: onPickLicense,
                    ),
                    const HeightSpace(10),
                    _buildImagePickerField(
                      label: 'صورة المركبة',
                      pickedFile: vehicleImage,
                      onPick: onPickVehicle,
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        const HeightSpace(32),
        PrimaryButtonWidget(
          buttonText: 'تسجيل الحساب',
          buttonColor: AppDesign.primary,
          textColor: Colors.white,
          width: double.infinity,
          borderRadius: 16.r,
          isLoading: isLoading,
          onPress: onRegister,
        ),
      ],
    );
  }

  Widget _sectionHeader(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppDesign.primary),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerField({
    required String label,
    required File? pickedFile,
    required VoidCallback? onPick,
  }) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: pickedFile != null ? AppDesign.primary : Colors.grey[200]!,
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: pickedFile != null
              ? Stack(
                  children: [
                    Image.file(
                      pickedFile,
                      width: double.infinity,
                      height: 140.h,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildPlaceholder(label, true),
                    ),
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: Colors.greenAccent, size: 14.sp),
                            SizedBox(width: 4.w),
                            Text(
                              'تم',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8.h,
                      left: 8.w,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                )
              : _buildPlaceholder(label, false),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String label, bool hasError) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 28.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasError ? Icons.broken_image_outlined : Icons.image_outlined,
            color: hasError ? Colors.red[300] : Colors.grey[350],
            size: 32.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            hasError ? 'تعذر تحميل الصورة' : label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: hasError ? Colors.red[300] : const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            'اضغط لاختيار صورة',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
