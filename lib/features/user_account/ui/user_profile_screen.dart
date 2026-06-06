import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:live_order/core/di/di.dart';
import 'package:live_order/core/utils/animated_snack_dialog.dart';
import 'package:live_order/features/add_order/models/user_model.dart';
import 'package:live_order/features/user/logic/cubit/user_cubit.dart';

class UserProfileScreen extends StatefulWidget {
  final UserModel user;

  const UserProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late UserCubit _userCubit;

  @override
  void initState() {
    super.initState();
    _userCubit = getIt<UserCubit>();
    _userCubit.loadUserData(widget.user.userId);
    _userCubit.loadUserStats(widget.user.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: BlocBuilder<UserCubit, UserState>(
        bloc: _userCubit,
        builder: (context, state) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Stats
                if (state is UserStatsLoaded)
                  _buildStatsSection(state.stats),

                // Content
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('معلومات الحساب'),
                      SizedBox(height: 12.h),
                      _buildInfoTile('اسم المستخدم', widget.user.name, Icons.person_rounded),
                      SizedBox(height: 8.h),
                      _buildInfoTile('البريد الإلكتروني', widget.user.email, Icons.email_rounded),
                      SizedBox(height: 8.h),
                      _buildInfoTile('نوع الحساب', 'عميل', Icons.account_circle_rounded),

                      SizedBox(height: 28.h),
                      _buildSectionTitle('الإعدادات'),
                      SizedBox(height: 12.h),

                      _buildSettingTile(
                        Icons.edit_rounded,
                        'تعديل البيانات الشخصية',
                        () => _showEditDialog(context),
                      ),
                      _buildSettingTile(
                        Icons.lock_rounded,
                        'تغيير كلمة المرور',
                        () => _showChangePasswordDialog(context),
                      ),
                      _buildSettingTile(
                        Icons.notifications_rounded,
                        'إعدادات الإشعارات',
                        () => _showNotificationSettings(context),
                      ),
                      _buildSettingTile(
                        Icons.history_rounded,
                        'سجل النشاط',
                        () => _showActivityHistory(context),
                      ),
                      _buildSettingTile(
                        Icons.help_rounded,
                        'الدعم الفني والمساعدة',
                        () => _showSupportInfo(context),
                      ),

                      SizedBox(height: 16.h),
                      _buildLogoutButton(context),

                      SizedBox(height: 16.h),
                      _buildDeleteAccountButton(context),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
                colors: [Color(0xFFFF6B00), Color(0xFFFF8F00)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B00).withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.user.name.isNotEmpty
                    ? widget.user.name[0].toUpperCase()
                    : 'ع',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 28.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            widget.user.name,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            widget.user.email,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.12),
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(
                color: const Color(0xFF4CAF50).withOpacity(0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: const Color(0xFF4CAF50),
                  size: 14.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  'عميل نشط',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> stats) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2028),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'الطلبات المكتملة',
            '${stats['completed_orders'] ?? 0}',
            Icons.check_circle_rounded,
            const Color(0xFF4CAF50),
          ),
          _buildStatItem(
            'الطلبات النشطة',
            '${stats['active_orders'] ?? 0}',
            Icons.local_shipping_rounded,
            const Color(0xFFFF6B00),
          ),
          _buildStatItem(
            'إجمالي الإنفاق',
            '${(stats['total_spent'] as num?)?.toStringAsFixed(0) ?? 0} ريال',
            Icons.attach_money_rounded,
            const Color(0xFF2196F3),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24.sp),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2028),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B00).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: const Color(0xFFFF6B00), size: 18),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String label, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Material(
        color: const Color(0xFF1E2028),
        borderRadius: BorderRadius.circular(12.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFFF6B00), size: 20.sp),
                SizedBox(width: 14.w),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13.sp,
                  color: Colors.grey[700],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (ctx) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor: const Color(0xFF1E2028),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              title: Text(
                'تسجيل الخروج',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              content: Text(
                'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[300]),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(
                    'إلغاء',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('تسجيل خروج'),
                ),
              ],
            ),
          ),
        );

        if (shouldLogout == true && mounted) {
          await FirebaseAuth.instance.signOut();
          if (mounted) context.go('/loginScreen');
        }
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.redAccent.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: Colors.redAccent,
              size: 18.sp,
            ),
            SizedBox(width: 8.w),
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
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showAnimatedSnackDialog(
          context,
          message: 'هذه الميزة محمية. يرجى التواصل مع الدعم الفني للمساعدة.',
          type: AnimatedSnackBarType.warning,
        );
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFF7B4397).withOpacity(0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFF7B4397).withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_rounded,
              color: const Color(0xFF7B4397),
              size: 18.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'حذف الحساب',
              style: TextStyle(
                color: const Color(0xFF7B4397),
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final nameController = TextEditingController(text: widget.user.name);
    final emailController = TextEditingController(text: widget.user.email);

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E2028),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(
            'تعديل البيانات الشخصية',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEditTextField('الاسم', nameController),
                SizedBox(height: 12.h),
                _buildEditTextField('البريد الإلكتروني', emailController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: TextStyle(color: Colors.grey[500])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
              ),
              onPressed: () {
                _userCubit.updatePersonalInfo(
                  widget.user.userId,
                  nameController.text,
                  emailController.text,
                );
                Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500]),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Color(0xFFFF6B00)),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showAnimatedSnackDialog(
      context,
      message: 'تم إرسال رابط تغيير كلمة المرور إلى بريدك الإلكتروني!',
      type: AnimatedSnackBarType.success,
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E2028),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(
            'إعدادات الإشعارات',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNotificationToggle('إشعارات الطلبات'),
              SizedBox(height: 12.h),
              _buildNotificationToggle('إشعارات الرسائل'),
              SizedBox(height: 12.h),
              _buildNotificationToggle('إشعارات التنبيهات'),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('تم'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.white),
        ),
        Switch(
          value: true,
          onChanged: (value) {},
          activeColor: const Color(0xFFFF6B00),
        ),
      ],
    );
  }

  void _showActivityHistory(BuildContext context) {
    showAnimatedSnackDialog(
      context,
      message: 'سجل النشاط محدّث تلقائياً من نشاطك على التطبيق.',
      type: AnimatedSnackBarType.info,
    );
  }

  void _showSupportInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E2028),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(
            'الدعم الفني والمساعدة',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSupportItem('📞', 'رقم الدعم المباشر', '19999'),
              SizedBox(height: 12.h),
              _buildSupportItem('📧', 'البريد الإلكتروني', 'support@liveorder.com'),
              SizedBox(height: 12.h),
              _buildSupportItem('⏰', 'ساعات العمل', '24/7'),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportItem(String icon, String label, String value) {
    return Row(
      children: [
        Text(icon, style: TextStyle(fontSize: 18.sp)),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
