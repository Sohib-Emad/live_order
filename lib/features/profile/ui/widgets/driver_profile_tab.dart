import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:live_order/core/utils/animated_snack_dialog.dart';
import 'package:live_order/features/add_order/models/user_model.dart';
import 'package:live_order/features/profile/data/repo/profile_repo.dart';
import 'package:live_order/core/di/di.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';

class DriverProfileTab extends StatelessWidget {
  final UserModel driver;
  final int completedCount;

  const DriverProfileTab({
    super.key,
    required this.driver,
    required this.completedCount,
  });

  static const _dark = Color(0xFF1A1A1A);
  static const _orange = Color(0xFFFFB300);

  @override
  Widget build(BuildContext context) {
    final profileRepo = getIt<ProfileRepo>();

    return StreamBuilder<DocumentSnapshot>(
      stream: profileRepo.streamUserDetails(driver.userId),
      builder: (context, snapshot) {
        String vehicleInfo = 'مرسيدس أكتروس 2024';
        String nationalId = '29901011400234';
        String licenseNumber = 'DL-8374902';

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            vehicleInfo = data['vehicle_info'] ?? 'اضغط لإضافة بيانات الشاحنة';
            nationalId = data['national_id'] ?? 'لم تسجل بعد';
            licenseNumber = data['license_number'] ?? 'لم تسجل بعد';
          }
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            children: [
              // Profile Card
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30.r,
                      backgroundColor: _dark,
                      child: Text(
                        driver.name.isNotEmpty
                            ? driver.name[0]
                            : 'ك',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24.sp,
                        ),
                      ),
                    ),
                    const WidthSpace(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: _dark,
                            ),
                          ),
                          const HeightSpace(4),
                          Text(
                            driver.email,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                          const HeightSpace(6),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8E1),
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: _orange,
                                      size: 12.sp,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      driver.rating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFF57F17),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const WidthSpace(8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                                child: Text(
                                  'رحلات منجزة: $completedCount',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const HeightSpace(20),

              // Driver Details Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'بيانات السائق والمركبة',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: _dark,
                    ),
                  ),
                  const HeightSpace(12),
                  _buildProfileDetailItem(
                    icon: Icons.local_shipping_rounded,
                    title: 'المركبة والشاحنة',
                    desc: vehicleInfo,
                    onTap: () => _editDriverField(
                      context,
                      'vehicle_info',
                      'المركبة والشاحنة',
                      vehicleInfo,
                    ),
                  ),
                  const HeightSpace(8),
                  _buildProfileDetailItem(
                    icon: Icons.badge_rounded,
                    title: 'الرقم القومي',
                    desc: nationalId,
                  ),
                  const HeightSpace(8),
                  _buildProfileDetailItem(
                    icon: Icons.contact_mail_rounded,
                    title: 'رقم رخصة القيادة',
                    desc: licenseNumber,
                  ),
                ],
              ),
              const HeightSpace(24),

              // Settings Menu
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الخيارات والإعدادات',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: _dark,
                    ),
                  ),
                  const HeightSpace(12),
                  _buildSettingMenuItem(
                    Icons.contact_support_rounded,
                    'الدعم الفني ومركز المساعدة',
                    () {
                      showAnimatedSnackDialog(
                        context,
                        message:
                            'رقم دعم الكباتن المباشر هو: 19999 للرد على أي طارئ.',
                        type: AnimatedSnackBarType.info,
                      );
                    },
                  ),
                  _buildSettingMenuItem(
                    Icons.logout_rounded,
                    'تسجيل الخروج من المنصة',
                    () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) context.go('/loginScreen');
                    },
                    isDanger: true,
                  ),
                ],
              ),
              const HeightSpace(30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileDetailItem({
    required IconData icon,
    required String title,
    required String desc,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: _orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: _orange, size: 18),
            ),
            const WidthSpace(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      color: _dark,
                    ),
                  ),
                  const HeightSpace(3),
                  Text(
                    desc,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.edit_rounded, size: 16.sp, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingMenuItem(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDanger = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
          leading: Icon(
            icon,
            color: isDanger ? Colors.redAccent : _dark,
            size: 20.sp,
          ),
          title: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12.5.sp,
              color: isDanger ? Colors.redAccent : _dark,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: isDanger
                ? Colors.redAccent.withOpacity(0.5)
                : Colors.grey[400],
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  void _editDriverField(BuildContext context, String key, String title, String currentValue) {
    final controller = TextEditingController(
      text: currentValue.contains('اضغط لإضافة') ? '' : currentValue,
    );
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: Text(
              'تعديل $title',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: _dark,
              ),
            ),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'أدخل بيانات $title الجديدة...',
                hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: _orange),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text(
                  'إلغاء',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _dark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                onPressed: () async {
                  final newVal = controller.text.trim();
                  if (newVal.isNotEmpty) {
                    final res = await getIt<ProfileRepo>().updateDriverVehicleInfo(driver.userId, newVal);
                    res.fold(
                      (err) {
                        if (dialogCtx.mounted) {
                          showAnimatedSnackDialog(
                            context,
                            message: err,
                            type: AnimatedSnackBarType.error,
                          );
                        }
                      },
                      (_) {
                        if (dialogCtx.mounted) {
                          Navigator.pop(dialogCtx);
                          showAnimatedSnackDialog(
                            context,
                            message: 'تم تحديث $title بنجاح!',
                            type: AnimatedSnackBarType.success,
                          );
                        }
                      },
                    );
                  }
                },
                child: Text(
                  'حفظ',
                  style: TextStyle(color: Colors.white, fontSize: 13.sp),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
