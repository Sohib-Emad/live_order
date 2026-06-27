import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/utils/animated_snack_dialog.dart';
import 'package:live_order/core/widgets/auth_background.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/features/auth/logic/cubit/auth_cubit.dart';
import 'package:live_order/features/auth/logic/state.dart';
import 'package:live_order/features/auth/widget/login_form.dart';

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
            AuthBackground(animation: _fadeController),
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
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.homeScreen,
                            );
                          }
                        },
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                'assets/lottie/login.json',
                                width: 160.w,
                                height: 100.w,
                              ),
                              // const HeightSpace(16),
                              Text(
                                'لايف أوردر',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF1A1A1A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              // const HeightSpace(4),
                              // Text(
                              //   'سوق الشحن الذكي ونقل البضائع المباشر',
                              //   style: TextStyle(
                              //     fontSize: 12.sp,
                              //     color: const Color(0xFF6B7280),
                              //     fontWeight: FontWeight.w600,
                              //   ),
                              // ),
                              // const HeightSpace(28),
                              LoginForm(
                                emailController: email,
                                passwordController: password,
                                obscurePassword: _obscurePassword,
                                isLoading: isLoading,
                                onToggleObscurePassword: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                onLogin: () {
                                  if (formKey.currentState!.validate()) {
                                    context.read<AuthCubit>().login(
                                      email.text.trim(),
                                      password.text,
                                    );
                                  }
                                },
                              ),
                              const HeightSpace(32),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.registerScreen,
                                  );
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
                                          color: AppDesign.primary,
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
}
