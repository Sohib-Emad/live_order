import 'dart:ui';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:live_order/core/styling/app_colors.dart';

import 'package:live_order/core/utils/animated_snack_dialog.dart';
import 'package:live_order/core/widgets/primay_button_widget.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/features/auth/logic/cubit/auth_cubit.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  late TextEditingController email;
  late TextEditingController username;
  late TextEditingController password;
  late TextEditingController confirmPassword;
  late TextEditingController _vehicleTypeController;
  late TextEditingController _plateNumberController;
  late TextEditingController _nationalIdController;
  late TextEditingController _licenseNumberController;

  String _selectedRole = 'client'; // client / driver
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    username = TextEditingController();
    password = TextEditingController();
    email = TextEditingController();
    confirmPassword = TextEditingController();
    _vehicleTypeController = TextEditingController();
    _plateNumberController = TextEditingController();
    _nationalIdController = TextEditingController();
    _licenseNumberController = TextEditingController();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    email.dispose();
    confirmPassword.dispose();
    _vehicleTypeController.dispose();
    _plateNumberController.dispose();
    _nationalIdController.dispose();
    _licenseNumberController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Base Cream Aesthetic
            Container(color: const Color(0xFFF5F5F0)),

            // 2. Amber Gold Glow Sphere
            Positioned(
              top: -60.h,
              right: -60.w,
              child: AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Container(
                    width: 300.w,
                    height: 300.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(
                        0xfffdad2b,
                      ).withOpacity(0.24 * _fadeController.value),
                    ),
                  );
                },
              ),
            ),

            // 3. Dark Coral/Orange Glow Sphere
            Positioned(
              bottom: -80.h,
              left: -80.w,
              child: AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Container(
                    width: 330.w,
                    height: 330.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(
                        0xfffdad2b,
                      ).withOpacity(0.14 * _fadeController.value),
                    ),
                  );
                },
              ),
            ),

            // 4. Frosted Glass filter
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 95.0, sigmaY: 95.0),
                child: Container(color: Colors.transparent),
              ),
            ),

            // 5. Scrollable Register Interface
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: FadeTransition(
                    opacity: _fadeController,
                    child: Form(
                      key: formKey,
                      child: BlocConsumer<AuthCubit, AuthState>(
                        listenWhen: (previous, current) =>
                            current is AuthError ||
                            current is AuthRegisterSuccess ||
                            current is AuthLoadind,
                        listener: (context, state) {
                          if (state is AuthError) {
                            showAnimatedSnackDialog(
                              context,
                              message: 'فشل إنشاء الحساب: ${state.message}',
                              type: AnimatedSnackBarType.error,
                            );
                          } else if (state is AuthRegisterSuccess) {
                            showAnimatedSnackDialog(
                              context,
                              message:
                                  'تم إنشاء حسابك بنجاح! يمكنك الآن تسجيل الدخول.',
                              type: AnimatedSnackBarType.success,
                            );
                            context.pop();
                          }
                        },
                        builder: (context, state) {
                          final isLoading = state is AuthLoadind;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'إنشاء حساب جديد',
                                style: TextStyle(
                                  fontSize: 23.sp,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF1A1A1A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const HeightSpace(4),
                              Text(
                                'سجل الآن وابدأ الشحن والتوصيل الفوري',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const HeightSpace(26),

                              // Form Fields directly on glowing background
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Custom Interactive Role Cards
                                  Text(
                                    "تحديد نوع الحساب",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF444444),
                                    ),
                                  ),
                                  const HeightSpace(10),
                                  Row(
                                    children: [
                                      // Client Card Selector
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedRole = 'client';
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                            curve: Curves.easeInOut,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 14.h,
                                              horizontal: 8.w,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _selectedRole == 'client'
                                                  ? const Color(
                                                      0xfffdad2b,
                                                    ).withOpacity(0.12)
                                                  : Colors.white.withOpacity(
                                                      0.6,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(18.r),
                                              border: Border.all(
                                                color: _selectedRole == 'client'
                                                    ? AppColors.primaryColor
                                                    : Colors.white.withOpacity(
                                                        0.8,
                                                      ),
                                                width: 1.8,
                                              ),
                                              boxShadow: [
                                                if (_selectedRole == 'client')
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xfffdad2b,
                                                    ).withOpacity(0.15),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                              ],
                                            ),
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                Center(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .person_pin_rounded,
                                                        color:
                                                            _selectedRole ==
                                                                'client'
                                                            ? AppColors
                                                                  .primaryColor
                                                            : const Color(
                                                                0xFF6B7280,
                                                              ),
                                                        size: 24.sp,
                                                      ),
                                                      const HeightSpace(6),
                                                      Text(
                                                        'عميل (شحن)',
                                                        style: TextStyle(
                                                          fontSize: 11.5.sp,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color:
                                                              _selectedRole ==
                                                                  'client'
                                                              ? AppColors
                                                                    .primaryColor
                                                              : const Color(
                                                                  0xFF4B5563,
                                                                ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (_selectedRole == 'client')
                                                  Positioned(
                                                    top: -8.h,
                                                    right: -4.w,
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                        4.w,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .primaryColor,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 10.sp,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const WidthSpace(12),
                                      // Driver Card Selector
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedRole = 'driver';
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                            curve: Curves.easeInOut,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 14.h,
                                              horizontal: 8.w,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _selectedRole == 'driver'
                                                  ? const Color(
                                                      0xfffdad2b,
                                                    ).withOpacity(0.12)
                                                  : Colors.white.withOpacity(
                                                      0.6,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(18.r),
                                              border: Border.all(
                                                color: _selectedRole == 'driver'
                                                    ? AppColors.primaryColor
                                                    : Colors.white.withOpacity(
                                                        0.8,
                                                      ),
                                                width: 1.8,
                                              ),
                                              boxShadow: [
                                                if (_selectedRole == 'driver')
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xfffdad2b,
                                                    ).withOpacity(0.15),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                              ],
                                            ),
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                Center(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .local_shipping_rounded,
                                                        color:
                                                            _selectedRole ==
                                                                'driver'
                                                            ? AppColors
                                                                  .primaryColor
                                                            : const Color(
                                                                0xFF6B7280,
                                                              ),
                                                        size: 24.sp,
                                                      ),
                                                      const HeightSpace(6),
                                                      Text(
                                                        'كابتن (سائق)',
                                                        style: TextStyle(
                                                          fontSize: 11.5.sp,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color:
                                                              _selectedRole ==
                                                                  'driver'
                                                              ? AppColors
                                                                    .primaryColor
                                                              : const Color(
                                                                  0xFF4B5563,
                                                                ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (_selectedRole == 'driver')
                                                  Positioned(
                                                    top: -8.h,
                                                    right: -4.w,
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                        4.w,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .primaryColor,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 10.sp,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const HeightSpace(20),
                                  Divider(color: Colors.grey[200]),
                                  const HeightSpace(16),

                                  // Full Name Field
                                  _buildInputField(
                                    controller: username,
                                    label: 'اسم المستخدم كامل',
                                    hint: 'مثال: محمد أحمد علي',
                                    icon: Icons.person_outline_rounded,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'يرجى إدخال اسم المستخدم';
                                      }
                                      return null;
                                    },
                                  ),
                                  const HeightSpace(16),

                                  // Email Field
                                  _buildInputField(
                                    controller: email,
                                    label: 'البريد الإلكتروني',
                                    hint: 'example@domain.com',
                                    icon: Icons.alternate_email_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'يرجى إدخال البريد الإلكتروني';
                                      }
                                      if (!RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                      ).hasMatch(value)) {
                                        return 'يرجى إدخال بريد إلكتروني صحيح';
                                      }
                                      return null;
                                    },
                                  ),
                                  const HeightSpace(16),

                                  // Password Field
                                  _buildInputField(
                                    controller: password,
                                    label: 'كلمة المرور',
                                    hint: '••••••••',
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: _obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.grey[400],
                                        size: 19.sp,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
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
                                  const HeightSpace(16),

                                  // Confirm Password Field
                                  _buildInputField(
                                    controller: confirmPassword,
                                    label: 'تأكيد كلمة المرور',
                                    hint: '••••••••',
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: _obscureConfirmPassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.grey[400],
                                        size: 19.sp,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى تأكيد كلمة المرور';
                                      }
                                      if (value != password.text) {
                                        return 'كلمة المرور غير متطابقة';
                                      }
                                      return null;
                                    },
                                  ),

                                  // Driver Details with Beautiful Expanding Animation
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeInOutCubic,
                                    child: _selectedRole == 'driver'
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const HeightSpace(16),
                                              Divider(color: Colors.grey[200]),
                                              const HeightSpace(16),
                                              _buildInputField(
                                                controller:
                                                    _vehicleTypeController,
                                                label: 'نوع وموديل شاحنة النقل',
                                                hint:
                                                    'مثال: ربع نقل / جامبو 2025',
                                                icon: Icons
                                                    .local_shipping_outlined,
                                                validator: (value) {
                                                  if (_selectedRole ==
                                                          'driver' &&
                                                      (value == null ||
                                                          value
                                                              .trim()
                                                              .isEmpty)) {
                                                    return 'يرجى إدخال نوع وموديل الشاحنة';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const HeightSpace(16),
                                              _buildInputField(
                                                controller:
                                                    _plateNumberController,
                                                label:
                                                    'رقم لوحة المركبة (أرقام وحروف)',
                                                hint: 'مثال: أ ب ج ١ ٢ ٣ ٤',
                                                icon: Icons.badge_outlined,
                                                validator: (value) {
                                                  if (_selectedRole ==
                                                          'driver' &&
                                                      (value == null ||
                                                          value
                                                              .trim()
                                                              .isEmpty)) {
                                                    return 'يرجى إدخال رقم اللوحة';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const HeightSpace(16),
                                              _buildInputField(
                                                controller: _nationalIdController,
                                                label: 'رقم البطاقة الشخصية (الرقم القومي - ١٤ رقم)',
                                                hint: 'مثال: ٢٩٩٠١٠١١٢٣٤٥٦٧',
                                                icon: Icons.credit_card_outlined,
                                                keyboardType: TextInputType.number,
                                                validator: (value) {
                                                  if (_selectedRole == 'driver') {
                                                    if (value == null || value.trim().isEmpty) {
                                                      return 'يرجى إدخال الرقم القومي';
                                                    }
                                                    if (value.trim().length != 14 || int.tryParse(value.trim()) == null) {
                                                      return 'يجب أن يتكون الرقم القومي من ١٤ رقماً بالكامل';
                                                    }
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const HeightSpace(16),
                                              _buildInputField(
                                                controller: _licenseNumberController,
                                                label: 'رقم رخصة القيادة',
                                                hint: 'مثال: ١٢٣٤٥٦٧٨',
                                                icon: Icons.assignment_ind_outlined,
                                                validator: (value) {
                                                  if (_selectedRole == 'driver' &&
                                                      (value == null || value.trim().isEmpty)) {
                                                    return 'يرجى إدخال رقم رخصة القيادة';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                  const HeightSpace(28),

                                  // Action Button
                                  PrimayButtonWidget(
                                    buttonText: 'تسجيل الحساب',
                                    buttonColor: AppColors.primaryColor,
                                    textColor: Colors.white,
                                    width: double.infinity,
                                    bordersRadius: 16.r,
                                    isLoading: isLoading,
                                    onPress: () {
                                      if (formKey.currentState!.validate()) {
                                        final vehicleInfo =
                                            _selectedRole == 'driver'
                                            ? '${_vehicleTypeController.text.trim()} - لوحة: ${_plateNumberController.text.trim()}'
                                            : null;

                                        context.read<AuthCubit>().register(
                                          email: email.text.trim(),
                                          password: password.text,
                                          username: username.text.trim(),
                                          role: _selectedRole,
                                          vehicleInfo: vehicleInfo,
                                          nationalId: _selectedRole == 'driver' ? _nationalIdController.text.trim() : null,
                                          licenseNumber: _selectedRole == 'driver' ? _licenseNumberController.text.trim() : null,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const HeightSpace(32),

                              // Link back to Login
                              GestureDetector(
                                onTap: () {
                                  context.pop();
                                },
                                child: RichText(
                                  text: TextSpan(
                                    text: 'لديك حساب بالفعل؟ ',
                                    style: TextStyle(
                                      fontSize: 13.5.sp,
                                      color: const Color(0xFF555555),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'سجل دخول',
                                        style: TextStyle(
                                          fontSize: 13.5.sp,
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const HeightSpace(16),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF444444),
          ),
        ),
        const HeightSpace(8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            cursorColor: AppColors.primaryColor,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 12.5.sp,
                color: const Color(0xff9CA4AB),
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xfffdad2b).withOpacity(0.7),
                size: 19.sp,
              ),
              suffixIcon: suffixIcon,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.9),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: AppColors.primaryColor,
                  width: 1.8,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.8,
                ),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.65),
            ),
            style: TextStyle(
              fontSize: 13.5.sp,
              color: const Color(0xFF1A1A1A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
