import 'dart:ui';
import 'package:animated_snack_bar/animated_snack_bar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/core/styling/app_colors.dart';
import 'package:live_order/core/utils/animated_snack_dialog.dart';
import 'package:live_order/core/widgets/primay_button_widget.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/features/auth/logic/cubit/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  late TextEditingController email;
  late TextEditingController password;
  bool _obscurePassword = true;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    email = TextEditingController();
    password = TextEditingController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
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
            // 1. Sleek Brand Cream Background
            Container(color: const Color(0xFFF5F5F0)),

            // 2. Premium Glow Blob 1 (Amber Gold)
            Positioned(
              top: -80.h,
              right: -80.w,
              child: AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Container(
                    width: 320.w,
                    height: 320.w,
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

            // 3. Premium Glow Blob 2 (Soft Dark Coral/Orange)
            Positioned(
              bottom: -100.h,
              left: -100.w,
              child: AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Container(
                    width: 350.w,
                    height: 350.w,
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

            // 4. Frosted Glass Filter
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 95.0, sigmaY: 95.0),
                child: Container(color: Colors.transparent),
              ),
            ),

            // 5. Scrollable Content Layer
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 20.h,
                  ),
                  child: FadeTransition(
                    opacity: _fadeController,
                    child: Form(
                      key: formKey,
                      child: BlocConsumer<AuthCubit, AuthState>(
                        listenWhen: (previous, current) =>
                            current is AuthError || current is AuthSuccess,
                        listener: (context, state) {
                          if (state is AuthError) {
                            showAnimatedSnackDialog(
                              context,
                              message: 'فشل تسجيل الدخول: ${state.message}',
                              type: AnimatedSnackBarType.error,
                            );
                          }
                          if (state is AuthSuccess) {
                            showAnimatedSnackDialog(
                              context,
                              message: 'مرحباً بك مجدداً في لايف أوردر!',
                              type: AnimatedSnackBarType.success,
                            );
                            context.pushReplacementNamed(AppRoutes.homeScreen);
                          }
                        },
                        builder: (context, state) {
                          final isLoading = state is AuthLoadind;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'لايف أوردر',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF1A1A1A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const HeightSpace(4),
                              Text(
                                'سوق الشحن الذكي ونقل البضائع المباشر',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const HeightSpace(28),

                              // Form Fields directly on glowing background
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'تسجيل الدخول',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const HeightSpace(20),

                                  // Email Input Field
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

                                  // Password Input Field
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
                                      if (value.length < 6) {
                                        return 'يجب ألا تقل كلمة المرور عن 6 أحرف';
                                      }
                                      return null;
                                    },
                                  ),
                                  const HeightSpace(28),

                                  // Custom Luxury Primay Button with Scale Effect on loading
                                  PrimayButtonWidget(
                                    buttonText: 'تسجيل دخول',
                                    buttonColor: AppColors.primaryColor,
                                    textColor: Colors.white,
                                    width: double.infinity,
                                    bordersRadius: 16.r,
                                    isLoading: isLoading,
                                    onPress: () {
                                      if (formKey.currentState!.validate()) {
                                        context.read<AuthCubit>().login(
                                          email.text.trim(),
                                          password.text,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const HeightSpace(32),

                              // Redirection to Register Screen Link
                              GestureDetector(
                                onTap: () {
                                  context.pushNamed(AppRoutes.registerScreen);
                                },
                                child: RichText(
                                  text: TextSpan(
                                    text: 'ليس لديك حساب؟ ',
                                    style: TextStyle(
                                      fontSize: 13.5.sp,
                                      color: const Color(0xFF555555),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'سجل الآن',
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
