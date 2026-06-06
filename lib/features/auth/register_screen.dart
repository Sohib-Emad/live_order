import 'dart:io';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/utils/animated_snack_dialog.dart';
import 'package:live_order/core/widgets/auth_background.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/features/auth/logic/cubit/auth_cubit.dart';
import 'package:live_order/features/auth/widget/register_form.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late TextEditingController email;
  late TextEditingController username;
  late TextEditingController password;
  late TextEditingController confirmPassword;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _vehicleTypeController;
  late TextEditingController _vehiclePlateController;
  late TextEditingController _vehicleCapacityController;
  late TextEditingController _nationalIdController;
  late TextEditingController _licenseNumberController;

  String _selectedRole = 'client';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _fadeController;

  File? _driverImage;
  File? _idFrontImage;
  File? _idBackImage;
  File? _licenseImage;
  File? _vehicleImage;

  @override
  void initState() {
    super.initState();
    username = TextEditingController();
    password = TextEditingController();
    email = TextEditingController();
    confirmPassword = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _vehicleTypeController = TextEditingController();
    _vehiclePlateController = TextEditingController();
    _vehicleCapacityController = TextEditingController();
    _nationalIdController = TextEditingController();
    _licenseNumberController = TextEditingController();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeController.forward();
  }

  Future<void> _pickImage(void Function(File) onPicked) async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      setState(() => onPicked(File(xFile.path)));
    }
  }

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    email.dispose();
    confirmPassword.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _vehicleTypeController.dispose();
    _vehiclePlateController.dispose();
    _vehicleCapacityController.dispose();
    _nationalIdController.dispose();
    _licenseNumberController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (!formKey.currentState!.validate()) return;
    context.read<AuthCubit>().register(
      email: email.text.trim(),
      password: password.text,
      username: username.text.trim(),
      role: _selectedRole,
      phone: _selectedRole == 'driver' ? _phoneController.text.trim() : null,
      address: _addressController.text.trim(),
      vehicleType: _selectedRole == 'driver' ? _vehicleTypeController.text.trim() : null,
      vehiclePlate: _selectedRole == 'driver' ? _vehiclePlateController.text.trim() : null,
      vehicleCapacity: _selectedRole == 'driver' ? _vehicleCapacityController.text.trim() : null,
      nationalId: _selectedRole == 'driver' ? _nationalIdController.text.trim() : null,
      licenseNumber: _selectedRole == 'driver' ? _licenseNumberController.text.trim() : null,
      driverImage: _selectedRole == 'driver' ? _driverImage : null,
      idFrontImage: _selectedRole == 'driver' ? _idFrontImage : null,
      idBackImage: _selectedRole == 'driver' ? _idBackImage : null,
      licenseImage: _selectedRole == 'driver' ? _licenseImage : null,
      vehicleImage: _selectedRole == 'driver' ? _vehicleImage : null,
    );
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
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: FadeTransition(
                    opacity: _fadeController,
                    child: Form(
                      key: formKey,
                      child: BlocConsumer<AuthCubit, AuthState>(
                        listenWhen: (previous, current) =>
                            current is AuthError || current is AuthRegisterSuccess || current is AuthLoadind,
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
                              message: 'تم إنشاء حسابك بنجاح! يمكنك الآن تسجيل الدخول.',
                              type: AnimatedSnackBarType.success,
                            );
                            Navigator.pop(context);
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
                              RegisterForm(
                                usernameController: username,
                                emailController: email,
                                passwordController: password,
                                confirmPasswordController: confirmPassword,
                                phoneController: _phoneController,
                                addressController: _addressController,
                                vehicleTypeController: _vehicleTypeController,
                                vehiclePlateController: _vehiclePlateController,
                                vehicleCapacityController: _vehicleCapacityController,
                                nationalIdController: _nationalIdController,
                                licenseNumberController: _licenseNumberController,
                                selectedRole: _selectedRole,
                                obscurePassword: _obscurePassword,
                                obscureConfirmPassword: _obscureConfirmPassword,
                                isLoading: isLoading,
                                onRoleChanged: (role) => setState(() => _selectedRole = role),
                                onToggleObscurePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                                onToggleObscureConfirmPassword: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                onRegister: _onRegister,
                                driverImage: _driverImage,
                                idFrontImage: _idFrontImage,
                                idBackImage: _idBackImage,
                                licenseImage: _licenseImage,
                                vehicleImage: _vehicleImage,
                                onPickDriverImage: () => _pickImage((f) => _driverImage = f),
                                onPickIdFront: () => _pickImage((f) => _idFrontImage = f),
                                onPickIdBack: () => _pickImage((f) => _idBackImage = f),
                                onPickLicense: () => _pickImage((f) => _licenseImage = f),
                                onPickVehicle: () => _pickImage((f) => _vehicleImage = f),
                              ),
                              const HeightSpace(32),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
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
