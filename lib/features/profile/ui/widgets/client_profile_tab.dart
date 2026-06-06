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


class ClientProfileTab extends StatelessWidget {
  final UserModel clientUser;
  final int completedCount;

  const ClientProfileTab({
    super.key,
    required this.clientUser,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final profileRepo = getIt<ProfileRepo>();

    return StreamBuilder<DocumentSnapshot>(
      stream: profileRepo.streamUserDetails(clientUser.userId),
      builder: (context, userSnapshot) {
        String homeAddress = 'اضغط لإضافة عنوان المنزل';
        String workAddress = 'اضغط لإضافة عنوان العمل';

        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          final data = userSnapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            homeAddress = data['home_address'] ?? 'اضغط لإضافة عنوان المنزل';
            workAddress = data['work_address'] ?? 'اضغط لإضافة عنوان العمل';
          }
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 28.h),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E2028), Color(0xFF111318)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 76.w,
                      height: 76.w,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB300).withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          clientUser.name.isNotEmpty ? clientUser.name[0].toUpperCase() : 'ع',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28.sp),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      clientUser.name,
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      clientUser.email,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, color: const Color(0xFF4CAF50), size: 14.sp),
                          SizedBox(width: 6.w),
                          Text(
                            '$completedCount شحنة مكتملة',
                            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF4CAF50)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('العناوين المحفوظة'),
                    SizedBox(height: 12.h),
                    _addressTile(
                      context,
                      Icons.home_rounded,
                      'المنزل',
                      homeAddress,
                      onTap: () => _editSavedAddress(context, 'home_address', 'المنزل', homeAddress),
                    ),
                    SizedBox(height: 8.h),
                    _addressTile(
                      context,
                      Icons.business_rounded,
                      'العمل',
                      workAddress,
                      onTap: () => _editSavedAddress(context, 'work_address', 'العمل', workAddress),
                    ),
                    SizedBox(height: 28.h),

                    _sectionTitle('الإعدادات'),
                    SizedBox(height: 12.h),
                    _settingTile(Icons.edit_rounded, 'تعديل البيانات الشخصية', () {
                      showAnimatedSnackDialog(
                        context,
                        message: 'ميزة تعديل الملف الشخصي ستتوفر قريباً!',
                        type: AnimatedSnackBarType.info,
                      );
                    }),
                    _settingTile(Icons.lock_rounded, 'تغيير كلمة المرور', () {
                      showAnimatedSnackDialog(
                        context,
                        message: 'تم إرسال رابط إعادة تعيين كلمة المرور لهاتفك/بريدك!',
                        type: AnimatedSnackBarType.success,
                      );
                    }),
                    _settingTile(Icons.language_rounded, 'اللغة الحالية (العربية)', () {
                      showAnimatedSnackDialog(
                        context,
                        message: 'التطبيق متوفر حالياً باللغة العربية فقط.',
                        type: AnimatedSnackBarType.info,
                      );
                    }),
                    _settingTile(Icons.contact_support_rounded, 'الدعم الفني ومركز المساعدة', () {
                      showAnimatedSnackDialog(
                        context,
                        message: 'رقم الدعم الفني المباشر هو: 19999 للرد على استفسارك.',
                        type: AnimatedSnackBarType.info,
                      );
                    }),
                    SizedBox(height: 12.h),
                    GestureDetector(
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) context.go('/loginScreen');
                      },
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Colors.redAccent.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: Colors.redAccent,
                              size: 20.sp,
                            ),
                            SizedBox(width: 14.w),
                            Text(
                              'تسجيل الخروج',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5),
    );
  }

  Widget _addressTile(BuildContext context, IconData icon, String title, String desc, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2028),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB300).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: const Color(0xFFFFB300), size: 17),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5.sp, color: Colors.white)),
                  SizedBox(height: 2.h),
                  Text(desc, style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.edit_rounded, size: 15.sp, color: Colors.grey[700]),
          ],
        ),
      ),
    );
  }

  Widget _settingTile(IconData icon, String label, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Material(
        color: const Color(0xFF1E2028),
        borderRadius: BorderRadius.circular(16.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey[400], size: 19.sp),
                SizedBox(width: 14.w),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w500, color: Colors.grey[200]),
                  ),
                ),
                Icon(Icons.arrow_back_ios_new_rounded, size: 13.sp, color: Colors.grey[700]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editSavedAddress(BuildContext context, String key, String title, String currentValue) {
    final controller = TextEditingController(
      text: currentValue.contains('اضغط لإضافة') ? '' : currentValue,
    );
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: const Color(0xFF1E2028),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
            title: Text(
              'تعديل عنوان $title',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            content: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'أدخل العنوان الجديد...',
                hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFFFFB300)),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text('إلغاء', style: TextStyle(color: Colors.grey[600], fontSize: 13.sp)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                onPressed: () async {
                  final newAddr = controller.text.trim();
                  if (newAddr.isNotEmpty) {
                    final res = await getIt<ProfileRepo>().updateUserAddress(clientUser.userId, key, newAddr);
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
                            message: 'تم تحديث عنوان $title بنجاح!',
                            type: AnimatedSnackBarType.success,
                          );
                        }
                      },
                    );
                  }
                },
                child: const Text('حفظ', style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ],
          ),
        );
      },
    );
  }
}
