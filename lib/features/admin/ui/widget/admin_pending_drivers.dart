import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/features/admin/logic/cubit/admin_cubit.dart';

class AdminPendingDrivers extends StatefulWidget {
  final List<UserProfile> pendingList;

  const AdminPendingDrivers({super.key, required this.pendingList});

  @override
  State<AdminPendingDrivers> createState() => _AdminPendingDriversState();
}

class _AdminPendingDriversState extends State<AdminPendingDrivers> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter pending list locally based on query
    final filteredList = widget.pendingList.where((driver) {
      final q = _searchQuery.toLowerCase();
      return driver.name.toLowerCase().contains(q) ||
          driver.email.toLowerCase().contains(q) ||
          (driver.phone != null && driver.phone!.contains(q));
    }).toList();

    return Column(
      children: [
        // Search bar at the top of the tab
        if (widget.pendingList.isNotEmpty)
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
                hintText: 'ابحث عن سائق بالاسم أو الجوال...',
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
                  borderSide: const BorderSide(
                    color: AppDesign.border,
                    width: 1,
                  ),
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
                  borderSide: const BorderSide(
                    color: AppDesign.border,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),

        Expanded(child: _buildContent(filteredList)),
      ],
    );
  }

  Widget _buildContent(List<UserProfile> list) {
    if (widget.pendingList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppDesign.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 48.sp,
                color: AppDesign.success,
              ),
            ),
            const HeightSpace(16),
            Text(
              'كل طلبات السائقين مفعلة!',
              style: AppDesign.heading(
                fontSize: 15.sp,
                color: AppDesign.textPrimary,
              ),
            ),
            const HeightSpace(4),
            Text(
              'لا توجد طلبات توثيق معلقة حالياً.',
              style: AppDesign.body(
                fontSize: 12.sp,
                color: AppDesign.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

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
              'لم يتم العثور على نتائج تطابق بحثك.',
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final driver = list[index];
        return _DriverCard(driver: driver);
      },
    );
  }
}

class _DriverCard extends StatelessWidget {
  final UserProfile driver;

  const _DriverCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppDesign.border, width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          colorScheme: const ColorScheme.light(primary: AppDesign.primary),
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          collapsedShape: const RoundedRectangleBorder(),
          shape: const RoundedRectangleBorder(),
          leading: _buildAvatar(44.w),
          title: Text(
            driver.name,
            style: AppDesign.heading(
              fontSize: 14.sp,
              color: AppDesign.textPrimary,
            ),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Row(
              children: [_statusBadge('طلب تفعيل معلق', Colors.amber)],
            ),
          ),
          trailing: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppDesign.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
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
                        const Icon(
                          Icons.verified_user_rounded,
                          color: AppDesign.primary,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'تفعيل حساب السائق',
                          style: AppDesign.heading(
                            color: AppDesign.textPrimary,
                            fontSize: 15.sp,
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      'هل أنت متأكد من رغبتك في تفعيل حساب السائق "${driver.name}"؟ سيتمكن من العمل واستلام شحنات العملاء فوراً.',
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
                          backgroundColor: AppDesign.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'تفعيل الآن',
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
                context.read<AdminCubit>().approveDriver(driver.uid);
              }
            },
            icon: const Icon(
              Icons.check_rounded,
              size: 14,
              color: Colors.white,
            ),
            label: Text(
              'تفعيل',
              style: AppDesign.body(
                fontSize: 11.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          children: [
            const Divider(color: Colors.white10, height: 16),
            _infoRow('البريد الإلكتروني', driver.email, Icons.email_outlined),
            _infoRow('رقم الجوال', driver.phone ?? '—', Icons.phone_outlined),
            if (driver.address != null && driver.address!.isNotEmpty)
              _infoRow('العنوان', driver.address!, Icons.location_on_outlined),
            const Divider(color: AppDesign.border, height: 20),

            if (driver.vehicleType != null ||
                driver.vehiclePlate != null ||
                driver.vehicleCapacity != null) ...[
              _sectionLabel('معلومات المركبة', Icons.directions_car_rounded),
              const HeightSpace(8),
              if (driver.vehicleType != null && driver.vehicleType!.isNotEmpty)
                _infoRow('النوع', driver.vehicleType!, Icons.category_outlined),
              if (driver.vehiclePlate != null &&
                  driver.vehiclePlate!.isNotEmpty)
                _infoRow(
                  'رقم اللوحة',
                  driver.vehiclePlate!,
                  Icons.confirmation_number_rounded,
                ),
              if (driver.vehicleCapacity != null &&
                  driver.vehicleCapacity!.isNotEmpty)
                _infoRow('السعة', driver.vehicleCapacity!, Icons.speed_rounded),
              const Divider(color: AppDesign.border, height: 20),
            ],

            if (driver.nationalId != null || driver.licenseNumber != null) ...[
              _sectionLabel('مستندات الهوية والرخصة', Icons.badge_rounded),
              const HeightSpace(8),
              if (driver.nationalId != null && driver.nationalId!.isNotEmpty)
                _infoRow(
                  'الرقم القومي',
                  driver.nationalId!,
                  Icons.credit_card_rounded,
                ),
              if (driver.licenseNumber != null &&
                  driver.licenseNumber!.isNotEmpty)
                _infoRow(
                  'رقم الرخصة',
                  driver.licenseNumber!,
                  Icons.assignment_ind_rounded,
                ),
              const Divider(color: AppDesign.border, height: 20),
            ],

            _sectionLabel('الوثائق والصور المرفقة', Icons.image_rounded),
            const HeightSpace(10),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: [
                if (driver.imageUrl.isNotEmpty)
                  _imageThumbnail(context, driver.imageUrl, 'الشخصية'),
                if (driver.idFrontImage.isNotEmpty)
                  _imageThumbnail(context, driver.idFrontImage, 'بطاقة (وجه)'),
                if (driver.idBackImage.isNotEmpty)
                  _imageThumbnail(context, driver.idBackImage, 'بطاقة (ظهر)'),
                if (driver.licenseImage.isNotEmpty)
                  _imageThumbnail(context, driver.licenseImage, 'الرخصة'),
                if (driver.vehicleImage.isNotEmpty)
                  _imageThumbnail(context, driver.vehicleImage, 'المركبة'),
              ],
            ),
            const HeightSpace(8),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(double size) {
    if (driver.imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: AppDesign.border.withValues(alpha: 0.3),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: driver.imageUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholder: (_, _) => SizedBox(
              width: size / 2,
              height: size / 2,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            errorWidget: (_, _, _) => Text(
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
      backgroundColor: AppDesign.primary.withValues(alpha: 0.12),
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
    final name = driver.name.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    return parts.take(2).map((e) => e[0]).join();
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        text,
        style: AppDesign.body(
          fontSize: 9.sp,
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
          style: AppDesign.heading(
            fontSize: 12.sp,
            color: AppDesign.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: AppDesign.textSecondary),
          SizedBox(width: 8.w),
          Text(
            '$label: ',
            style: AppDesign.body(
              fontSize: 11.sp,
              color: AppDesign.textSecondary,
            ),
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
        ],
      ),
    );
  }

  Widget _imageThumbnail(BuildContext context, String url, String label) {
    return GestureDetector(
      onTap: () => _showImagePreview(context, url, label),
      child: Container(
        width: 90.w,
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
                height: 60.h,
                width: 90.w,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  height: 60.h,
                  color: AppDesign.border.withValues(alpha: 0.2),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
      errorWidget: (_, _, _) =>
          Container(
                  height: 60.h,
                  color: Colors.red.withValues(alpha: 0.05),
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
              padding: EdgeInsets.symmetric(vertical: 4.h),
              decoration: BoxDecoration(
                color: AppDesign.border.withValues(alpha: 0.3),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(10.r),
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppDesign.body(
                  fontSize: 8.5.sp,
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
                        placeholder: (_, _) => Container(
                          height: 200.h,
                          color: AppDesign.border.withValues(alpha: 0.2),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                errorWidget: (_, _, _) => Container(
                          height: 200.h,
                          color: Colors.red.withValues(alpha: 0.08),
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
