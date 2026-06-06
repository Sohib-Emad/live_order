import 'dart:convert';
import 'dart:io';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:live_order/core/di/di.dart';
import 'package:live_order/core/styling/app_colors.dart';
import 'package:live_order/core/styling/app_styles.dart';
import 'package:live_order/core/utils/animated_snack_dialog.dart';
import 'package:live_order/core/widgets/primay_button_widget.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/features/add_order/logic/cubit/add_order_cubit.dart';
import 'package:live_order/features/add_order/models/order_model.dart';
import 'package:live_order/features/add_order/ui/driver_selection_screen.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dateController;
  late TextEditingController _orderLatController;
  late TextEditingController _orderLongController;
  late TextEditingController _userLatController;
  late TextEditingController _userLongController;

  DateTime _selectedDate = DateTime.now();
  String _selectedStatus = 'نشط';
  String _selectedSize = 'medium';

  final List<String> _statuses = ['نشط', 'قيد التجهيز', 'قيد التوصيل', 'مكتمل'];
  final List<Map<String, String>> _sizes = [
    {'key': 'small', 'label': 'صغير'},
    {'key': 'medium', 'label': 'متوسط'},
    {'key': 'large', 'label': 'كبير'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _orderLatController = TextEditingController();
    _orderLongController = TextEditingController();
    _userLatController = TextEditingController();
    _userLongController = TextEditingController();
    _dateController = TextEditingController(
      text:
          "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _orderLatController.dispose();
    _orderLongController.dispose();
    _userLatController.dispose();
    _userLongController.dispose();
    super.dispose();
  }

  // Open native Date Picker
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: const Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // Open Custom Premium Google Maps Place Picker
  void _pickOrderLocationFromMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PremiumGoogleMapsPlacePicker(
          initialCenter: const LatLng(30.0444, 31.2357),
          onPicked: (selectedLatLng) {
            setState(() {
              _orderLatController.text = selectedLatLng.latitude.toString();
              _orderLongController.text = selectedLatLng.longitude.toString();
            });
            Navigator.pop(context);
            showAnimatedSnackDialog(
              context,
              message: 'تم تحديد موقع التوصيل بنجاح من الخريطة!',
              type: AnimatedSnackBarType.success,
            );
          },
        ),
      ),
    );
  }

  void _simulateOrderLocation() {
    // Cairo locations simulation
    setState(() {
      _orderLatController.text = '30.0444';
      _orderLongController.text = '31.2357';
    });
    showAnimatedSnackDialog(
      context,
      message: 'تم تحديد موقع التوصيل بنجاح (القاهرة)',
      type: AnimatedSnackBarType.info,
    );
  }

  void _simulateUserLocation() {
    // Current user location simulation (Cairo Airport area)
    setState(() {
      _userLatController.text = '30.0784';
      _userLongController.text = '31.2859';
    });
    showAnimatedSnackDialog(
      context,
      message: 'تم رصد موقعك الحالي بنجاح (القاهرة)',
      type: AnimatedSnackBarType.info,
    );
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
            'إنشاء طلب جديد',
            style: AppStyles.black18BoldStyle.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<AddOrderCubit, AddOrderState>(
            listener: (context, state) {
              if (state is AddOrderSuccess) {
                showAnimatedSnackDialog(
                  context,
                  message: 'تم إنشاء الطلب بنجاح وإدراجه في النظام!',
                  type: AnimatedSnackBarType.success,
                );
                context.pop();
              } else if (state is AddOrderError) {
                showAnimatedSnackDialog(
                  context,
                  message: state.message,
                  type: AnimatedSnackBarType.error,
                );
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Graphic card
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
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52.w,
                              height: 52.w,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: const Icon(
                                Icons.explore_rounded,
                                color: Color(0xFFFFB300),
                                size: 26,
                              ),
                            ),
                            const WidthSpace(16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'موقع وجغرافيات الطلب الجديد',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const HeightSpace(4),
                                  Text(
                                    'يرجى توفير إحداثيات المواقع وتاريخ الشحن بدقة للتتبع المباشر',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const HeightSpace(24),

                      // Order Details Section
                      _buildSectionTitle(
                        'بيانات ومحتويات الطلب',
                        Icons.edit_note_rounded,
                      ),
                      const HeightSpace(12),
                      _buildCard([
                        _buildInputField(
                          controller: _nameController,
                          label: 'اسم الطلب',
                          hint: 'مثال: وجبة عشاء عائلية فاخرة',
                          icon: Icons.shopping_bag_outlined,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'يرجى إدخال اسم ومحتوى الطلب';
                            }
                            return null;
                          },
                        ),
                        const HeightSpace(16),

                        // Date Picker Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تاريخ الطلب (Date Picker)',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF555555),
                              ),
                            ),
                            const HeightSpace(8),
                            TextFormField(
                              controller: _dateController,
                              readOnly: true,
                              onTap: _selectDate,
                              cursorColor: AppColors.primaryColor,
                              decoration: InputDecoration(
                                hintText: 'اختر تاريخ الطلب',
                                hintStyle: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xff8391A1),
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: Icon(
                                  Icons.calendar_today_rounded,
                                  color: AppColors.primaryColor,
                                  size: 18,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 14.h,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: const BorderSide(
                                    color: Color(0xffE8ECF4),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryColor,
                                    width: 1.5,
                                  ),
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
                        ),
                        const HeightSpace(16),

                        Text(
                          'حالة الطلب البدئية',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF555555),
                          ),
                        ),
                        const HeightSpace(8),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: _statuses.map((status) {
                            final isSelected = _selectedStatus == status;
                            return ChoiceChip(
                              label: Text(
                                status,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[800],
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: const Color(0xFFFFB300),
                              backgroundColor: Colors.grey[200],
                              checkmarkColor: Colors.white,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedStatus = status;
                                  });
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const HeightSpace(16),
                        Text(
                          'حجم الشحنة (Shipment Size)',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF555555),
                          ),
                        ),
                        const HeightSpace(8),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: _sizes.map((size) {
                            final isSelected = _selectedSize == size['key'];
                            return ChoiceChip(
                              label: Text(
                                size['label']!,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[800],
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: const Color(0xFFFFB300),
                              backgroundColor: Colors.grey[200],
                              checkmarkColor: Colors.white,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedSize = size['key']!;
                                  });
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ]),

                      const HeightSpace(24),

                      // Order Coordinates Section (Google Maps Place Picker)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildSectionTitle(
                              'موقع وجهة الطلب (Order Location)',
                              Icons.pin_drop_rounded,
                            ),
                          ),
                          Wrap(
                            spacing: 8.w,
                            children: [
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: _simulateOrderLocation,
                                icon: const Icon(
                                  Icons.gps_fixed_rounded,
                                  size: 14,
                                  color: Color(0xFF1A1A1A),
                                ),
                                label: Text(
                                  'تحديد تلقائي',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: const Color(0xFF1A1A1A),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: _pickOrderLocationFromMap,
                                icon: const Icon(
                                  Icons.map_rounded,
                                  size: 14,
                                  color: Color(0xFFFFB300),
                                ),
                                label: Text(
                                  'اختر من الخريطة',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: const Color(0xFFFFB300),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const HeightSpace(10),
                      _buildCard([
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                controller: _orderLatController,
                                label: 'خط العرض (Order Lat)',
                                hint: 'حدد موقعك على الخريطة',
                                icon: Icons.map_rounded,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'مطلوب';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'رقم غير صحيح';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const WidthSpace(12),
                            Expanded(
                              child: _buildInputField(
                                controller: _orderLongController,
                                label: 'خط الطول (Order Long)',
                                hint: 'حدد موقعك على الخريطة',
                                icon: Icons.map_rounded,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'مطلوب';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'رقم غير صحيح';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ]),

                      const HeightSpace(24),

                      // User Coordinates Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildSectionTitle(
                              'موقعك الحالي (User Location)',
                              Icons.my_location_rounded,
                            ),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: _simulateUserLocation,
                            icon: const Icon(
                              Icons.gps_fixed_rounded,
                              size: 16,
                              color: Color(0xFF1A1A1A),
                            ),
                            label: Text(
                              'تحديد موقعي',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF1A1A1A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const HeightSpace(10),
                      _buildCard([
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                controller: _userLatController,
                                label: 'خط العرض (User Lat)',
                                hint: 'مثال: 24.7742',
                                icon: Icons.location_history_rounded,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'مطلوب';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'رقم غير صحيح';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const WidthSpace(12),
                            Expanded(
                              child: _buildInputField(
                                controller: _userLongController,
                                label: 'خط الطول (User Long)',
                                hint: 'مثال: 46.7386',
                                icon: Icons.location_history_rounded,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'مطلوب';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'رقم غير صحيح';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ]),

                      const HeightSpace(32),

                      // Submit Button
                      Center(
                        child: PrimayButtonWidget(
                          buttonText: 'إنشاء وإدراج الطلب',
                          buttonColor: const Color(0xFF1A1A1A),
                          textColor: Colors.white,
                          width: double.infinity,
                          bordersRadius: 16.r,
                          isLoading: state is AddOrderLoading,
                          onPress: () {
                            if (_formKey.currentState!.validate()) {
                              final order = OrderModel(
                                orderId: '',
                                orderName: _nameController.text.trim(),
                                orderLat: double.parse(
                                  _orderLatController.text.trim(),
                                ),
                                orderLong: double.parse(
                                  _orderLongController.text.trim(),
                                ),
                                userLat: double.parse(
                                  _userLatController.text.trim(),
                                ),
                                userLong: double.parse(
                                  _userLongController.text.trim(),
                                ),
                                orderUserId: '',
                                orderDate: _dateController.text.trim(),
                                orderStatus: 'Waiting Driver',
                                orderSize: _selectedSize,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (context) => getIt<AddOrderCubit>(),
                                    child: DriverSelectionScreen(temporaryShipment: order),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const HeightSpace(20),
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 20),
        const WidthSpace(8),
        Expanded(
          child: Text(
            title,
            style: AppStyles.black15BoldStyle.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
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
          maxLines: maxLines,
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

// Custom Premium Google Maps Place Picker
class PremiumGoogleMapsPlacePicker extends StatefulWidget {
  final LatLng initialCenter;
  final Function(LatLng) onPicked;

  const PremiumGoogleMapsPlacePicker({
    super.key,
    required this.initialCenter,
    required this.onPicked,
  });

  @override
  State<PremiumGoogleMapsPlacePicker> createState() =>
      _PremiumGoogleMapsPlacePickerState();
}

class _PremiumGoogleMapsPlacePickerState
    extends State<PremiumGoogleMapsPlacePicker> {
  GoogleMapController? _mapController;
  late LatLng _selectedLatLng;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _selectedLatLng = widget.initialCenter;

    // Auto-fetch user's current GPS location on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _determinePosition();
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        showAnimatedSnackDialog(
          context,
          message: 'خدمات الموقع الجغرافي (GPS) معطلة على هذا الجهاز.',
          type: AnimatedSnackBarType.warning,
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          showAnimatedSnackDialog(
            context,
            message: 'تم رفض صلاحية الوصول للموقع الجغرافي.',
            type: AnimatedSnackBarType.warning,
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        showAnimatedSnackDialog(
          context,
          message: 'صلاحيات الموقع معطلة نهائياً من إعدادات الهاتف.',
          type: AnimatedSnackBarType.warning,
        );
      }
      return;
    }

    try {
      Position? position;
      try {
        // Try getting position with medium accuracy (faster lock indoors and simulators)
        position = await Geolocator.getCurrentPosition(
          // ignore: deprecated_member_use
          desiredAccuracy: LocationAccuracy.medium,
          // ignore: deprecated_member_use
          timeLimit: const Duration(seconds: 15),
        );
      } catch (e) {
        try {
          // Retry with low accuracy (nearly instant)
          position = await Geolocator.getCurrentPosition(
            // ignore: deprecated_member_use
            desiredAccuracy: LocationAccuracy.low,
            // ignore: deprecated_member_use
            timeLimit: const Duration(seconds: 5),
          );
        } catch (_) {
          position = await Geolocator.getLastKnownPosition();
        }
      }

      if (position != null) {
        final currentLatLng = LatLng(position.latitude, position.longitude);
        if (mounted) {
          setState(() {
            _selectedLatLng = currentLatLng;
          });
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: currentLatLng, zoom: 15.0),
            ),
          );
          showAnimatedSnackDialog(
            context,
            message: 'تم تحديد موقعك الحالي بنجاح!',
            type: AnimatedSnackBarType.success,
          );
        }
      } else {
        // Fallback gracefully to Egypt center (Cairo)
        if (mounted) {
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: widget.initialCenter, zoom: 15.0),
            ),
          );
          showAnimatedSnackDialog(
            context,
            message: 'تعذر رصد الموقع المباشر. يرجى تفعيل الـ GPS في الهاتف أو اختيار القاهرة.',
            type: AnimatedSnackBarType.info,
          );
        }
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final client = HttpClient();
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1&countrycodes=eg',
      );
      final request = await client.getUrl(uri);
      request.headers.set('user-agent', 'live_order_app');
      final response = await request.close();

      if (response.statusCode == 200) {
        final jsonString = await response.transform(utf8.decoder).join();
        final List data = json.decode(jsonString);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          final target = LatLng(lat, lon);

          setState(() {
            _selectedLatLng = target;
          });

          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: target, zoom: 15.0),
            ),
          );
        } else {
          if (mounted) {
            showAnimatedSnackDialog(
              context,
              message: 'لم يتم العثور على نتائج للموقع المكتوب.',
              type: AnimatedSnackBarType.error,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showAnimatedSnackDialog(
          context,
          message: 'حدث خطأ أثناء البحث عن الموقع.',
          type: AnimatedSnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1A1A),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            'تحديد موقع التوصيل',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: Stack(
          children: [
            // Google Map View
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.initialCenter,
                zoom: 15.0,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              myLocationEnabled: false, // Custom FAB handles this beautifully
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              onCameraMove: (position) {
                _selectedLatLng = position.target;
              },
              onCameraIdle: () {
                setState(() {});
              },
            ),

            // Fixed Location Pin exactly at the center of the screen
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 36.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      child: Text(
                        'اسحب الخريطة لتحديد الموقع',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFFFFB300),
                      size: 44,
                    ),
                  ],
                ),
              ),
            ),

            // Premium Search Bar at the top of the map
            Positioned(
              top: 16.h,
              left: 16.w,
              right: 16.w,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onFieldSubmitted: _searchLocation,
                        cursorColor: const Color(0xFFFFB300),
                        decoration: InputDecoration(
                          hintText: 'ابحث عن اسم الحي أو الشارع هنا...',
                          hintStyle: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[400],
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    if (_isSearching)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFFB300),
                            ),
                          ),
                        ),
                      )
                    else
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFFFFB300),
                        ),
                        onPressed: () => _searchLocation(_searchController.text),
                      ),
                  ],
                ),
              ),
            ),

            // Floating GPS Target Button to snap to current location
            Positioned(
              bottom: 96.h,
              right: 20.w,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: const Color(0xFF1A1A1A),
                  foregroundColor: const Color(0xFFFFB300),
                  onPressed: _determinePosition,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: const Icon(Icons.gps_fixed_rounded, size: 20),
                ),
              ),
            ),

            // Confirm Location Action Button at the bottom
            Positioned(
              bottom: 24.h,
              left: 20.w,
              right: 20.w,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB300).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB300),
                    foregroundColor: const Color(0xFF1A1A1A),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    widget.onPicked(_selectedLatLng);
                  },
                  child: Text(
                    'تأكيد موقع التوصيل المختار',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
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
