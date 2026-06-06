import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:live_order/core/styling/app_colors.dart';
import 'package:live_order/core/styling/app_styles.dart';
import 'package:live_order/core/utils/animated_snack_dialog.dart';
import 'package:live_order/core/widgets/primay_button_widget.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/features/add_order/models/user_model.dart';
import 'package:live_order/features/driver/logic/cubit/driver_cubit.dart';

class DriverRegisterScreen extends StatefulWidget {
  const DriverRegisterScreen({super.key});

  @override
  State<DriverRegisterScreen> createState() => _DriverRegisterScreenState();
}

class _DriverRegisterScreenState extends State<DriverRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _vehicleTypeController;
  late TextEditingController _plateNumberController;
  late TextEditingController _nationalIdController;
  late TextEditingController _licenseNumberController;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _vehicleTypeController = TextEditingController();
    _plateNumberController = TextEditingController();
    _nationalIdController = TextEditingController();
    _licenseNumberController = TextEditingController();

    final driverCubit = context.read<DriverCubit>();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      driverCubit.getDriverDetails(uid);
    }
  }

  @override
  void dispose() {
    _vehicleTypeController.dispose();
    _plateNumberController.dispose();
    _nationalIdController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F0),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF1A1A1A),
                  size: 18,
                ),
                onPressed: () => context.pop(),
              ),
            ),
          ),
          centerTitle: true,
          title: Text(
            'التسجيل كـ سائق شحن',
            style: AppStyles.black18BoldStyle.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<DriverCubit, DriverState>(
            listener: (context, state) {
              if (state is DriverDetailsLoaded) {
                _currentUser = state.driver;
              } else if (state is DriverSuccess) {
                showAnimatedSnackDialog(
                  context,
                  message: 'تم تقديم طلب التسجيل بنجاح! بانتظار موافقة الإدارة تفعيل حسابك.',
                  type: AnimatedSnackBarType.success,
                );
                context.go('/homeScreen');
              } else if (state is DriverError) {
                showAnimatedSnackDialog(
                  context,
                  message: state.message,
                  type: AnimatedSnackBarType.error,
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is DriverLoading;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A1A1A), Color(0xFF3D3D3D)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 60.w,
                              height: 60.w,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.local_shipping_rounded,
                                color: AppColors.primaryColor,
                                size: 30.sp,
                              ),
                            ),
                            const HeightSpace(16),
                            Text(
                              'انضم إلى فريق سائقي التوصيل',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const HeightSpace(6),
                            Text(
                              'ابدأ باستقبال طلبات شحن البضائع وحقق أرباحاً ممتازة بتسجيل مركبتك معنا.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12.sp,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const HeightSpace(24),
                      Text(
                        'بيانات المركبة المطلوبة للتسجيل',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      const HeightSpace(12),
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInputField(
                              controller: _vehicleTypeController,
                              label: 'نوع وموديل شاحنة النقل',
                              hint: 'مثال: شيفروليه جامبو / ربع نقل 2025',
                              icon: Icons.local_shipping_outlined,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'يرجى إدخال نوع المركبة';
                                }
                                return null;
                              },
                            ),
                            const HeightSpace(16),
                            _buildInputField(
                              controller: _plateNumberController,
                              label: 'رقم لوحة المركبة (أرقام وحروف)',
                              hint: 'مثال: أ ب ج ١ ٢ ٣ ٤',
                              icon: Icons.badge_outlined,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
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
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'يرجى إدخال الرقم القومي';
                                }
                                if (val.trim().length != 14 || int.tryParse(val.trim()) == null) {
                                  return 'يجب أن يتكون الرقم القومي من ١٤ رقماً بالكامل';
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
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'يرجى إدخال رقم رخصة القيادة';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const HeightSpace(32),
                      PrimayButtonWidget(
                        buttonText: 'إرسال طلب التسجيل',
                        buttonColor: AppColors.primaryColor,
                        textColor: Colors.white,
                        width: double.infinity,
                        bordersRadius: 16.r,
                        isLoading: isLoading,
                        onPress: () {
                          if (_formKey.currentState!.validate()) {
                            if (_currentUser == null) {
                              showAnimatedSnackDialog(
                                context,
                                message: 'تعذر جلب بيانات المستخدم الحالية. يرجى الانتظار والمحاولة لاحقاً.',
                                type: AnimatedSnackBarType.error,
                              );
                              return;
                            }

                            final vehicleInfo =
                                '${_vehicleTypeController.text.trim()} - لوحة: ${_plateNumberController.text.trim()}';

                            final updatedUser = _currentUser!.copyWith(
                              role: 'driver',
                              vehicleInfo: vehicleInfo,
                              driverStatus: 'pending',
                              isAvailable: true,
                              currentLat: 30.0444,
                              currentLong: 31.2357,
                              nationalId: _nationalIdController.text.trim(),
                              licenseNumber: _licenseNumberController.text.trim(),
                            );

                            context.read<DriverCubit>().registerDriver(updatedUser);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
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
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF555555),
          ),
        ),
        const HeightSpace(8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          cursorColor: AppColors.primaryColor,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xff8391A1),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(icon, color: AppColors.greyColor, size: 18),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 14.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xffE8ECF4), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            filled: true,
            fillColor: const Color(0xffF7F8F9),
          ),
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
