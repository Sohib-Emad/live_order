import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/core/styling/app_assets.dart';
import 'package:live_order/core/styling/app_colors.dart';
import 'package:live_order/core/styling/app_styles.dart';
import 'package:live_order/core/widgets/custom_text_field.dart';
import 'package:live_order/core/widgets/primay_button_widget.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/features/auth/logic/cubit/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController email;
  late TextEditingController password;

  @override
  void initState() {
    super.initState();

    email = TextEditingController();
    password = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: BlocConsumer<AuthCubit, AuthState>(
                listenWhen: (previous, current) =>
                    current is AuthError || current is AuthSuccess,
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                  if (state is AuthSuccess) {
                    GoRouter.of(
                      context,
                    ).pushNamed(AppRoutes.homeScreen); // ✅ بس كده
                  }
                },
                buildWhen: (previous, current) =>
                    current is AuthLoadind ||
                    current is AuthError ||
                    current is AuthSuccess,
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const HeightSpace(28),
                      SizedBox(
                        width: 335.w,
                        child: Text(
                          "Login To Your Account",
                          style: AppStyles.primaryHeadLinesStyle,
                        ),
                      ),
                      const HeightSpace(8),
                      SizedBox(
                        width: 335.w,
                        child: Text(
                          "it's great to see you again",
                          style: AppStyles.grey12MediumStyle,
                        ),
                      ),
                      const HeightSpace(20),
                      Center(
                        child: Image.asset(
                          AppAssets.order,
                          width: 190.w,
                          height: 190.w,
                        ),
                      ),
                      const HeightSpace(32),
                      Text("Email", style: AppStyles.black16w500Style),
                      const HeightSpace(8),
                      CustomTextField(
                        controller: email,
                        hintText: "Enter Your Email",
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Your Email";
                          }
                          return null;
                        },
                      ),
                      const HeightSpace(16),
                      Text("Password", style: AppStyles.black16w500Style),
                      const HeightSpace(8),
                      CustomTextField(
                        hintText: "Enter Your Password",
                        controller: password,
                        suffixIcon: Icon(
                          Icons.remove_red_eye,
                          color: AppColors.greyColor,
                          size: 20.sp,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Your Password";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                      const HeightSpace(55),
                      state is AuthLoadind
                          ? const Center(child: CircularProgressIndicator())
                          : PrimayButtonWidget(
                              buttonText: "Sign in",
                              onPress: () {
                                if (formKey.currentState!.validate()) {
                                  context.read<AuthCubit>().login(
                                    email.text,
                                    password.text,
                                  );
                                }
                              },
                            ),
                      const HeightSpace(80),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            context.pushNamed(AppRoutes.registerScreen);
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: AppStyles.black16w500Style.copyWith(
                                color: AppColors.secondaryColor,
                              ),
                              children: [
                                TextSpan(
                                  text: "Join",
                                  style: AppStyles.black15BoldStyle,
                                ),
                              ],
                            ),
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
    );
  }
}
