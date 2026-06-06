import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/features/admin/logic/cubit/admin_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminUserManagement extends StatefulWidget {
  final List<UserProfile> usersList;
  final void Function(String uid, String name) onViewOrders;

  const AdminUserManagement({
    super.key,
    required this.usersList,
    required this.onViewOrders,
  });

  @override
  State<AdminUserManagement> createState() => _AdminUserManagementState();
}

class _AdminUserManagementState extends State<AdminUserManagement> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRole = 'All'; // All, client, driver, admin
  String _selectedStatus = 'All'; // All, active, pending, blocked

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dynamically filter users list
    final filteredList = widget.usersList.where((user) {
      final matchesSearch =
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (user.phone != null && user.phone!.contains(_searchQuery));

      final matchesRole = _selectedRole == 'All' || user.role == _selectedRole;

      final matchesStatus =
          _selectedStatus == 'All' ||
          (_selectedStatus == 'blocked' && user.driverStatus == 'blocked') ||
          (_selectedStatus == 'pending' &&
              user.role == 'driver' &&
              user.driverStatus == 'pending') ||
          (_selectedStatus == 'active' && user.driverStatus == 'active');

      return matchesSearch && matchesRole && matchesStatus;
    }).toList();

    return Column(
      children: [
        // Search bar
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          child: TextField(
            controller: _searchController,
            style: AppDesign.body(
              color: AppDesign.textPrimary,
              fontSize: 13.sp,
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'ابحث بالاسم، البريد أو رقم الجوال...',
              hintStyle: AppDesign.body(
                color: AppDesign.textSecondary,
                fontSize: 13.sp,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppDesign.textSecondary,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear_rounded,
                        color: AppDesign.textSecondary,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppDesign.border, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(
                  color: AppDesign.primary,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppDesign.border, width: 1),
              ),
            ),
          ),
        ),

        // Role Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          child: Row(
            children: [
              _buildFilterLabel('الدور:'),
              SizedBox(width: 8.w),
              _buildFilterChip(
                'الكل',
                _selectedRole == 'All',
                () => setState(() => _selectedRole = 'All'),
              ),
              SizedBox(width: 6.w),
              _buildFilterChip(
                'عملاء',
                _selectedRole == 'client',
                () => setState(() => _selectedRole = 'client'),
              ),
              SizedBox(width: 6.w),
              _buildFilterChip(
                'سائقين',
                _selectedRole == 'driver',
                () => setState(() => _selectedRole = 'driver'),
              ),
              SizedBox(width: 6.w),
              _buildFilterChip(
                'مدراء',
                _selectedRole == 'admin',
                () => setState(() => _selectedRole = 'admin'),
              ),
            ],
          ),
        ),

        // Status Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
          child: Row(
            children: [
              _buildFilterLabel('الحالة:'),
              SizedBox(width: 8.w),
              _buildFilterChip(
                'الكل',
                _selectedStatus == 'All',
                () => setState(() => _selectedStatus = 'All'),
              ),
              SizedBox(width: 6.w),
              _buildFilterChip(
                'نشط',
                _selectedStatus == 'active',
                () => setState(() => _selectedStatus = 'active'),
              ),
              SizedBox(width: 6.w),
              _buildFilterChip(
                'معلق',
                _selectedStatus == 'pending',
                () => setState(() => _selectedStatus = 'pending'),
              ),
              SizedBox(width: 6.w),
              _buildFilterChip(
                'محظور',
                _selectedStatus == 'blocked',
                () => setState(() => _selectedStatus = 'blocked'),
              ),
            ],
          ),
        ),

        Expanded(child: _buildContent(filteredList)),
      ],
    );
  }

  Widget _buildContent(List<UserProfile> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48.sp,
              color: AppDesign.textSecondary,
            ),
            const HeightSpace(12),
            Text(
              'لم يتم العثور على حسابات تطابق خيارات البحث.',
              style: AppDesign.body(
                fontSize: 12.sp,
                color: AppDesign.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final user = list[index];
        return _UserCard(user: user, onViewOrders: widget.onViewOrders);
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppDesign.primary : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppDesign.primary : AppDesign.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppDesign.body(
            fontSize: 10.5.sp,
            color: isSelected ? Colors.white : AppDesign.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterLabel(String text) {
    return Text(
      text,
      style: AppDesign.body(
        fontSize: 11.sp,
        color: AppDesign.textPrimary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserProfile user;
  final void Function(String uid, String name) onViewOrders;

  const _UserCard({required this.user, required this.onViewOrders});

  Future<void> _makeCall(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final cleanedPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final whatsappUrl = Uri.parse("https://wa.me/$cleanedPhone");
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBlocked = user.driverStatus == 'blocked';
    final isAdmin = user.role == 'admin';
    final isDriver = user.role == 'driver';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h, left: 16.w, right: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isBlocked
              ? AppDesign.danger.withOpacity(0.3)
              : AppDesign.border,
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          colorScheme: const ColorScheme.light(primary: AppDesign.primary),
        ),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          collapsedShape: const RoundedRectangleBorder(),
          shape: const RoundedRectangleBorder(),
          leading: _buildAvatar(40.w),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  user.name,
                  style: AppDesign.heading(
                    fontSize: 13.5.sp,
                    color: isBlocked
                        ? AppDesign.textSecondary
                        : AppDesign.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              _roleBadge(user.role),
              if (isBlocked) ...[
                SizedBox(width: 4.w),
                _statusBadge('محظور', AppDesign.danger),
              ],
            ],
          ),
          subtitle: Text(
            user.email,
            style: AppDesign.body(
              fontSize: 10.sp,
              color: AppDesign.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          children: [
            const Divider(color: AppDesign.border, height: 16),

            // UID row with Copy action
            _infoRow(
              'UID',
              user.uid,
              Icons.fingerprint_rounded,
              trailing: GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: user.uid));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('تم نسخ الـ UID إلى الحافظة!'),
                      backgroundColor: AppDesign.success,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppDesign.border.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.copy_rounded,
                        color: AppDesign.textSecondary,
                        size: 10.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'نسخ',
                        style: AppDesign.body(
                          fontSize: 9.sp,
                          color: AppDesign.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            _infoRow(
              'البريد الإلكتروني',
              user.email,
              Icons.alternate_email_rounded,
            ),

            if (user.phone != null && user.phone!.isNotEmpty)
              _infoRow(
                'رقم الجوال',
                user.phone!,
                Icons.phone_outlined,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.phone_in_talk_rounded,
                        color: Colors.blueAccent,
                        size: 16,
                      ),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      onPressed: () => _makeCall(user.phone!),
                      tooltip: 'اتصال هاتفي',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: Color(0xFF16A34A),
                        size: 16,
                      ),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      onPressed: () => _openWhatsApp(user.phone!),
                      tooltip: 'واتساب',
                    ),
                  ],
                ),
              ),

            if (user.address != null && user.address!.isNotEmpty)
              _infoRow('العنوان', user.address!, Icons.location_on_outlined),

            if (isDriver) ...[
              const Divider(color: AppDesign.border, height: 20),
              _infoRow(
                'التقييم الحالي',
                '${user.rating.toStringAsFixed(1)} ★',
                Icons.star_rounded,
                trailing: Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 14.sp,
                ),
              ),
              _infoRow(
                'عدد الرحلات المنجزة',
                user.totalDeliveries.toString(),
                Icons.trip_origin_rounded,
              ),
              _infoRow(
                'حالة التوافر',
                user.isAvailable ? 'متاح للعمل' : 'غير نشط',
                Icons.toggle_on_outlined,
              ),
              _infoRow(
                'حالة التوثيق',
                user.verificationStatus == 'active'
                    ? 'موثق'
                    : user.verificationStatus == 'pending'
                    ? 'معلق'
                    : 'غير موثق',
                Icons.verified_outlined,
              ),

              if (user.vehicleType != null && user.vehicleType!.isNotEmpty) ...[
                const HeightSpace(8),
                _sectionLabel('تفاصيل المركبة', Icons.directions_car_rounded),
                const HeightSpace(6),
                _infoRow('النوع', user.vehicleType!, Icons.category_outlined),
                if (user.vehiclePlate != null && user.vehiclePlate!.isNotEmpty)
                  _infoRow(
                    'رقم اللوحة',
                    user.vehiclePlate!,
                    Icons.confirmation_number_rounded,
                  ),
                if (user.vehicleCapacity != null &&
                    user.vehicleCapacity!.isNotEmpty)
                  _infoRow(
                    'السعة الاستيعابية',
                    user.vehicleCapacity!,
                    Icons.speed_rounded,
                  ),
              ],

              if (user.nationalId != null || user.licenseNumber != null) ...[
                const HeightSpace(8),
                _sectionLabel('المستندات القانونية', Icons.badge_rounded),
                const HeightSpace(6),
                if (user.nationalId != null && user.nationalId!.isNotEmpty)
                  _infoRow(
                    'الرقم القومي',
                    user.nationalId!,
                    Icons.credit_card_rounded,
                  ),
                if (user.licenseNumber != null &&
                    user.licenseNumber!.isNotEmpty)
                  _infoRow(
                    'رقم الرخصة',
                    user.licenseNumber!,
                    Icons.assignment_ind_rounded,
                  ),
              ],

              if (user.imageUrl.isNotEmpty ||
                  user.idFrontImage.isNotEmpty ||
                  user.idBackImage.isNotEmpty ||
                  user.licenseImage.isNotEmpty ||
                  user.vehicleImage.isNotEmpty) ...[
                const Divider(color: AppDesign.border, height: 20),
                _sectionLabel('الوثائق المصورة', Icons.image_rounded),
                const HeightSpace(8),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: [
                    if (user.imageUrl.isNotEmpty)
                      _imageThumbnail(context, user.imageUrl, 'الشخصية'),
                    if (user.idFrontImage.isNotEmpty)
                      _imageThumbnail(
                        context,
                        user.idFrontImage,
                        'بطاقة (وجه)',
                      ),
                    if (user.idBackImage.isNotEmpty)
                      _imageThumbnail(context, user.idBackImage, 'بطاقة (ظهر)'),
                    if (user.licenseImage.isNotEmpty)
                      _imageThumbnail(context, user.licenseImage, 'الرخصة'),
                    if (user.vehicleImage.isNotEmpty)
                      _imageThumbnail(context, user.vehicleImage, 'المركبة'),
                  ],
                ),
              ],
            ],

            // Action buttons row (Except for Admins)
            if (!isAdmin) ...[
              const Divider(color: AppDesign.border, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // View User Shipments Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppDesign.textPrimary,
                      elevation: 0,
                      side: const BorderSide(color: AppDesign.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                    ),
                    onPressed: () => onViewOrders(user.uid, user.name),
                    icon: const Icon(
                      Icons.receipt_long_rounded,
                      size: 14,
                      color: AppDesign.primary,
                    ),
                    label: Text(
                      'عرض الشحنات',
                      style: AppDesign.body(
                        fontSize: 10.5.sp,
                        color: AppDesign.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Block / Unblock Button
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: isBlocked
                          ? AppDesign.success
                          : AppDesign.danger,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            title: Row(
                              children: [
                                Icon(
                                  isBlocked
                                      ? Icons.lock_open_rounded
                                      : Icons.lock_outline_rounded,
                                  color: isBlocked
                                      ? AppDesign.success
                                      : AppDesign.danger,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  isBlocked
                                      ? 'إلغاء حظر المستخدم'
                                      : 'حظر المستخدم',
                                  style: AppDesign.heading(
                                    color: AppDesign.textPrimary,
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ],
                            ),
                            content: Text(
                              isBlocked
                                  ? 'هل أنت متأكد من رغبتك في إلغاء الحظر عن المستخدم "${user.name}"؟'
                                  : 'هل أنت متأكد من رغبتك في حظر المستخدم "${user.name}"؟ لن يتمكن من استخدام التطبيق أو تلقي الشحنات.',
                              style: AppDesign.body(
                                color: AppDesign.textSecondary,
                                fontSize: 12.sp,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  'إلغاء',
                                  style: AppDesign.body(
                                    color: AppDesign.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isBlocked
                                      ? AppDesign.success
                                      : AppDesign.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  isBlocked ? 'تفعيل الحساب' : 'تأكيد الحظر',
                                  style: AppDesign.body(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        context.read<AdminCubit>().toggleUserBlock(user);
                      }
                    },
                    icon: Icon(
                      isBlocked
                          ? Icons.lock_open_rounded
                          : Icons.lock_outline_rounded,
                      size: 14.sp,
                    ),
                    label: Text(
                      isBlocked ? 'إلغاء الحظر' : 'حظر الحساب',
                      style: AppDesign.body(
                        fontSize: 10.5.sp,
                        color: isBlocked ? AppDesign.success : AppDesign.danger,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(double size) {
    if (user.imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: AppDesign.border.withOpacity(0.3),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: user.imageUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholder: (_, __) => SizedBox(
              width: size / 2,
              height: size / 2,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            errorWidget: (_, __, ___) => Text(
              _initials(),
              style: AppDesign.heading(
                fontSize: size * 0.38,
                color: AppDesign.primary,
              ),
            ),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppDesign.primary.withOpacity(0.12),
      child: Text(
        _initials(),
        style: AppDesign.heading(
          fontSize: size * 0.38,
          color: AppDesign.primary,
        ),
      ),
    );
  }

  String _initials() {
    final name = user.name.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    return parts.take(2).map((e) => e[0]).join();
  }

  Widget _roleBadge(String role) {
    final Color color;
    final String label;
    switch (role) {
      case 'admin':
        color = Colors.red;
        label = 'مدير';
      case 'driver':
        color = AppDesign.primary;
        label = 'سائق';
      default:
        color = Colors.blue;
        label = 'عميل';
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(
        label,
        style: AppDesign.body(
          fontSize: 8.5.sp,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(
        text,
        style: AppDesign.body(
          fontSize: 8.sp,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppDesign.primary),
        SizedBox(width: 6.w),
        Text(
          text,
          style: AppDesign.heading(fontSize: 11.5.sp, color: AppDesign.textPrimary),
        ),
      ],
    );
  }

  Widget _infoRow(
    String label,
    String value,
    IconData icon, {
    Widget? trailing,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: AppDesign.textSecondary),
          SizedBox(width: 8.w),
          Text(
            '$label: ',
            style: AppDesign.body(fontSize: 11.sp, color: AppDesign.textSecondary),
          ),
          Expanded(
            child: Text(
              value,
              style: AppDesign.body(
                fontSize: 11.sp,
                color: AppDesign.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _imageThumbnail(BuildContext context, String url, String label) {
    return GestureDetector(
      onTap: () => _showImagePreview(context, url, label),
      child: Container(
        width: 88.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppDesign.border),
          color: Colors.white,
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
              child: CachedNetworkImage(
                imageUrl: url,
                height: 58.h,
                width: 88.w,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 58.h,
                  color: AppDesign.border.withOpacity(0.2),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 58.h,
                  color: Colors.red.withOpacity(0.05),
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.red[300],
                    size: 18.sp,
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 3.h),
              decoration: BoxDecoration(
                color: AppDesign.border.withOpacity(0.3),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(10.r),
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppDesign.body(
                  fontSize: 7.5.sp,
                  color: AppDesign.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePreview(BuildContext context, String url, String label) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: AppDesign.heading(
                        fontSize: 14.sp,
                        color: AppDesign.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppDesign.textPrimary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const HeightSpace(12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 400.h),
                    child: InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: CachedNetworkImage(
                        imageUrl: url,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => Container(
                          height: 200.h,
                          color: AppDesign.border.withOpacity(0.2),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          height: 200.h,
                          color: Colors.red.withOpacity(0.08),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                color: Colors.red[300],
                                size: 40.sp,
                              ),
                              const HeightSpace(8),
                              Text(
                                'تعذر تحميل الصورة',
                                style: AppDesign.body(
                                  color: Colors.red[300]!,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const HeightSpace(8),
                Text(
                  '💡 يمكنك تكبير الصورة عن طريق السحب بإصبعين',
                  style: AppDesign.body(
                    fontSize: 10.sp,
                    color: AppDesign.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
