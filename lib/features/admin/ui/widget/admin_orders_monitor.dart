import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';

class AdminOrdersMonitor extends StatefulWidget {
  final List<Shipment> ordersList;
  final String? initialUserUidFilter;
  final String? initialUserNameFilter;
  final VoidCallback onClearUserFilter;

  const AdminOrdersMonitor({
    super.key,
    required this.ordersList,
    this.initialUserUidFilter,
    this.initialUserNameFilter,
    required this.onClearUserFilter,
  });

  @override
  State<AdminOrdersMonitor> createState() => _AdminOrdersMonitorState();
}

class _AdminOrdersMonitorState extends State<AdminOrdersMonitor> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus =
      'All'; // All, Waiting Driver, Accepted, In Transit, Delivered, Cancelled

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Apply filters
    final filteredList = widget.ordersList.where((order) {
      // 1. Cross-tab user filter
      if (widget.initialUserUidFilter != null) {
        if (order.clientId != widget.initialUserUidFilter &&
            order.driverId != widget.initialUserUidFilter) {
          return false;
        }
      }

      // 2. Status filter
      if (_selectedStatus != 'All') {
        if (_selectedStatus == 'In Transit') {
          if (order.status != 'In Transit' && order.status != 'Picked Up') {
            return false;
          }
        } else {
          if (order.status != _selectedStatus) {
            return false;
          }
        }
      }

      // 3. Search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesCargo = order.cargoType.toLowerCase().contains(q);
        final matchesNotes = order.notes.toLowerCase().contains(q);
        final matchesPickup = order.pickupAddress.toLowerCase().contains(q);
        final matchesDrop = order.dropAddress.toLowerCase().contains(q);
        final matchesClient = order.clientId.toLowerCase().contains(q);
        final matchesDriver = order.driverId.toLowerCase().contains(q);
        return matchesCargo ||
            matchesNotes ||
            matchesPickup ||
            matchesDrop ||
            matchesClient ||
            matchesDriver;
      }

      return true;
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
              hintText: 'ابحث عن شحنة (الاسم، العنوان، المعرف)...',
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

        // Status Filter Row
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
                'بانتظار سائق',
                _selectedStatus == 'Waiting Driver',
                () => setState(() => _selectedStatus == 'Waiting Driver'),
              ),
              SizedBox(width: 6.w),
              _buildFilterChip(
                'مقبولة',
                _selectedStatus == 'Accepted',
                () => setState(() => _selectedStatus == 'Accepted'),
              ),
              SizedBox(width: 6.w),
              _buildFilterChip(
                'جاري التوصيل',
                _selectedStatus == 'In Transit',
                () => setState(() => _selectedStatus == 'In Transit'),
              ),
              SizedBox(width: 6.w),
              _buildFilterChip(
                'مكتملة',
                _selectedStatus == 'Delivered',
                () => setState(() => _selectedStatus == 'Delivered'),
              ),
              SizedBox(width: 6.w),
              _buildFilterChip(
                'ملغاة',
                _selectedStatus == 'Cancelled',
                () => setState(() => _selectedStatus == 'Cancelled'),
              ),
            ],
          ),
        ),

        Expanded(child: _buildContent(filteredList)),
      ],
    );
  }

  Widget _buildContent(List<Shipment> list) {
    if (widget.ordersList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_late_outlined,
                size: 48.sp,
                color: AppDesign.textSecondary,
              ),
            ),
            const HeightSpace(16),
            Text(
              'لا توجد شحنات مسجلة!',
              style: AppDesign.heading(
                fontSize: 15.sp,
                color: AppDesign.textPrimary,
              ),
            ),
            const HeightSpace(4),
            Text(
              'لا تتوفر أي طلبات أو شحنات في النظام حالياً.',
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
              'لم يتم العثور على شحنات تطابق هذا البحث.',
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
        final order = list[index];
        return _OrderCard(
          order: order,
          onTap: () => _showOrderDetails(context, order),
        );
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

  void _showOrderDetails(BuildContext context, Shipment order) {
    final statusColor = _getStatusColor(order.status);
    final statusLabel = _getStatusLabel(order.status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pull handle
                Center(
                  child: Container(
                    width: 40.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: AppDesign.border,
                      borderRadius: BorderRadius.circular(2.5.r),
                    ),
                  ),
                ),
                const HeightSpace(20),

                // Title and status badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.cargoType,
                      style: AppDesign.heading(
                        fontSize: 18.sp,
                        color: AppDesign.textPrimary,
                      ),
                    ),
                    _statusBadge(statusLabel, statusColor),
                  ],
                ),
                const HeightSpace(14),

                // Order ID with Copy option
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: order.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('تم نسخ رقم الشحنة!'),
                        backgroundColor: AppDesign.success,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tag_rounded,
                          color: AppDesign.textSecondary,
                          size: 12.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'رقم الشحنة: ${order.id}',
                          style: AppDesign.body(
                            fontSize: 10.sp,
                            color: AppDesign.textSecondary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.copy_rounded,
                          color: AppDesign.primary,
                          size: 12.sp,
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(color: AppDesign.border, height: 24),

                // Visual Timeline
                Text(
                  'مسار التوصيل',
                  style: AppDesign.heading(
                    fontSize: 13.sp,
                    color: AppDesign.textPrimary,
                  ),
                ),
                const HeightSpace(10),
                _buildTimeline(order),
                const Divider(color: AppDesign.border, height: 28),

                // Specifications
                Text(
                  'المواصفات والبيانات المالية',
                  style: AppDesign.heading(
                    fontSize: 13.sp,
                    color: AppDesign.textPrimary,
                  ),
                ),
                const HeightSpace(12),
                _specGrid(order),
                const Divider(color: AppDesign.border, height: 28),

                // Notes
                if (order.notes.isNotEmpty) ...[
                  Text(
                    'ملاحظات إضافية',
                    style: AppDesign.heading(
                      fontSize: 13.sp,
                      color: AppDesign.textPrimary,
                    ),
                  ),
                  const HeightSpace(8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[500]!.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppDesign.border),
                    ),
                    child: Text(
                      order.notes,
                      style: AppDesign.body(
                        fontSize: 12.sp,
                        color: AppDesign.textPrimary,
                      ),
                    ),
                  ),
                  const Divider(color: AppDesign.border, height: 28),
                ],

                // Client / Driver Profiles Info
                Text(
                  'الأطراف المشاركة',
                  style: AppDesign.heading(
                    fontSize: 13.sp,
                    color: AppDesign.textPrimary,
                  ),
                ),
                const HeightSpace(10),
                _infoCardRow(
                  'العميل (المرسل)',
                  order.clientId,
                  Icons.person_rounded,
                  isClient: true,
                ),
                const HeightSpace(10),
                if (order.driverId.isNotEmpty)
                  _infoCardRow(
                    'السائق (الناقل)',
                    order.driverId,
                    Icons.local_shipping_rounded,
                    isClient: false,
                    driver: order.assignedDriver,
                  )
                else
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.amber.withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Colors.amber,
                          size: 18,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'بانتظار قبول الطلب من أحد السائقين المتاحين.',
                          style: AppDesign.body(
                            fontSize: 11.5.sp,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Rating & Review (if exists)
                if (order.rating != null) ...[
                  const Divider(color: AppDesign.border, height: 28),
                  Text(
                    'تقييم الخدمة',
                    style: AppDesign.heading(
                      fontSize: 13.sp,
                      color: AppDesign.textPrimary,
                    ),
                  ),
                  const HeightSpace(10),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppDesign.success.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppDesign.success.withOpacity(0.20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${order.rating!.toStringAsFixed(1)} / 5.0',
                              style: AppDesign.heading(
                                fontSize: 14.sp,
                                color: AppDesign.textPrimary,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  Icons.star_rounded,
                                  color: i < order.rating!.floor()
                                      ? Colors.amber
                                      : Colors.grey[400],
                                  size: 16.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (order.review != null &&
                            order.review!.isNotEmpty) ...[
                          const HeightSpace(8),
                          Text(
                            '"${order.review}"',
                            style: AppDesign.body(
                              fontSize: 11.5.sp,
                              color: AppDesign.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // Cargo Images
                if (order.images.isNotEmpty) ...[
                  const Divider(color: AppDesign.border, height: 28),
                  Text(
                    'صور الشحنة المرفقة',
                    style: AppDesign.heading(
                      fontSize: 13.sp,
                      color: AppDesign.textPrimary,
                    ),
                  ),
                  const HeightSpace(10),
                  SizedBox(
                    height: 100.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: order.images.length,
                      itemBuilder: (context, i) => _imageThumbnail(
                        context,
                        order.images[i],
                        'صورة ${i + 1}',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(Shipment order) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.grey[500]!.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppDesign.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const Icon(
                Icons.circle_outlined,
                color: Color(0xFF16A34A),
                size: 14,
              ),
              Container(width: 1.5, height: 32.h, color: AppDesign.border),
              const Icon(
                Icons.location_on_rounded,
                color: Colors.redAccent,
                size: 14,
              ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'موقع الاستلام',
                  style: AppDesign.body(
                    fontSize: 9.5.sp,
                    color: AppDesign.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  order.pickupAddress,
                  style: AppDesign.body(
                    fontSize: 11.sp,
                    color: AppDesign.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 14.h),
                Text(
                  'موقع التسليم',
                  style: AppDesign.body(
                    fontSize: 9.5.sp,
                    color: AppDesign.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  order.dropAddress,
                  style: AppDesign.body(
                    fontSize: 11.sp,
                    color: AppDesign.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _specGrid(Shipment order) {
    final sizeLabel = order.size == "small" || order.size == "S"
        ? "صغير"
        : order.size == "medium" || order.size == "M"
        ? "متوسط"
        : "كبير";

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.grey[500]!.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          _specRow(
            'الحجم المقدر',
            sizeLabel,
            Icons.photo_size_select_small_rounded,
          ),
          const Divider(color: AppDesign.border),
          _specRow('الوزن الكلي', '${order.weight} كجم', Icons.scale_rounded),
          const Divider(color: AppDesign.border),
          _specRow('طريقة الدفع', order.paymentMethod, Icons.payment_rounded),
          const Divider(color: AppDesign.border),
          _specRow(
            'قيمة الشحنة المقدرة',
            '${order.priceEstimate} ريال',
            Icons.monetization_on_rounded,
            valueColor: AppDesign.primary,
          ),
          const Divider(color: AppDesign.border),
          _specRow(
            'التاريخ المفضل',
            order.preferredDate.split('T').first,
            Icons.calendar_today_rounded,
          ),
          const Divider(color: AppDesign.border),
          _specRow(
            'الوقت المفضل',
            order.preferredTimeRange,
            Icons.access_time_rounded,
          ),
        ],
      ),
    );
  }

  Widget _specRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppDesign.textSecondary, size: 14.sp),
              SizedBox(width: 8.w),
              Text(
                label,
                style: AppDesign.body(
                  fontSize: 11.sp,
                  color: AppDesign.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: AppDesign.body(
              fontSize: 11.sp,
              color: valueColor ?? AppDesign.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCardRow(
    String title,
    String id,
    IconData icon, {
    required bool isClient,
    UserProfile? driver,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[500]!.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppDesign.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppDesign.primary.withOpacity(0.1),
            child: Icon(icon, color: AppDesign.primary, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppDesign.body(
                    fontSize: 9.5.sp,
                    color: AppDesign.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isClient
                      ? 'المستخدم المالك'
                      : (driver?.name ?? 'سائق النظام'),
                  style: AppDesign.heading(
                    fontSize: 12.sp,
                    color: AppDesign.textPrimary,
                  ),
                ),
                Text(
                  'المعرف: $id',
                  style: AppDesign.body(
                    fontSize: 9.sp,
                    color: AppDesign.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.copy_rounded,
              color: AppDesign.textSecondary,
              size: 14.sp,
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تم نسخ المعرف!'),
                  backgroundColor: AppDesign.success,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'نسخ المعرف',
          ),
        ],
      ),
    );
  }

  Widget _imageThumbnail(BuildContext context, String url, String label) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      constraints: BoxConstraints(maxHeight: 360.h),
                      child: InteractiveViewer(
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.contain,
                          placeholder: (_, __) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (_, __, ___) => Icon(
                            Icons.broken_image,
                            size: 40.sp,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const HeightSpace(10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'إغلاق',
                      style: AppDesign.body(
                        color: AppDesign.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(left: 8.w),
        width: 100.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppDesign.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (_, __) =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            errorWidget: (_, __, ___) =>
                Icon(Icons.broken_image, size: 20.sp, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(
        text,
        style: AppDesign.body(
          fontSize: 9.5.sp,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'Waiting Driver':
        return 'بانتظار سائق';
      case 'Accepted':
        return 'تم القبول';
      case 'In Transit':
      case 'Picked Up':
        return 'جاري التوصيل';
      case 'Delivered':
        return 'تم التسليم';
      case 'Cancelled':
        return 'ملغاة';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Waiting Driver':
        return Colors.amber;
      case 'Accepted':
        return Colors.blueAccent;
      case 'In Transit':
      case 'Picked Up':
        return Colors.orangeAccent;
      case 'Delivered':
        return const Color(0xFF16A34A);
      case 'Cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}

class _OrderCard extends StatelessWidget {
  final Shipment order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    final statusLabel = _getStatusLabel(order.status);
    final sizeLabel = order.size == "small" || order.size == "S"
        ? "صغير"
        : order.size == "medium" || order.size == "M"
        ? "متوسط"
        : "كبير";

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppDesign.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.cargoType,
                  style: AppDesign.heading(
                    fontSize: 14.sp,
                    color: AppDesign.textPrimary,
                  ),
                ),
                _statusBadge(statusLabel, statusColor),
              ],
            ),
            const HeightSpace(10),
            const Divider(color: AppDesign.border, height: 1),
            const HeightSpace(10),

            // Visual route snippet
            Row(
              children: [
                Column(
                  children: [
                    const Icon(
                      Icons.circle_outlined,
                      color: Color(0xFF16A34A),
                      size: 10,
                    ),
                    Container(width: 1, height: 12.h, color: AppDesign.border),
                    const Icon(
                      Icons.location_on_rounded,
                      color: Colors.redAccent,
                      size: 10,
                    ),
                  ],
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.pickupAddress,
                        style: AppDesign.body(
                          fontSize: 10.5.sp,
                          color: AppDesign.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        order.dropAddress,
                        style: AppDesign.body(
                          fontSize: 10.5.sp,
                          color: AppDesign.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const HeightSpace(10),
            const Divider(color: AppDesign.border, height: 1),
            const HeightSpace(10),

            // Bottom info tags
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cargo size & weight tag
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'الحجم: $sizeLabel | ${order.weight} كجم',
                    style: AppDesign.body(
                      fontSize: 9.5.sp,
                      color: AppDesign.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Price estimate
                Text(
                  '${order.priceEstimate} ريال',
                  style: AppDesign.heading(
                    fontSize: 13.sp,
                    color: AppDesign.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(
        text,
        style: AppDesign.body(
          fontSize: 8.5.sp,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'Waiting Driver':
        return 'بانتظار سائق';
      case 'Accepted':
        return 'تم القبول';
      case 'In Transit':
      case 'Picked Up':
        return 'جاري التوصيل';
      case 'Delivered':
        return 'تم التسليم';
      case 'Cancelled':
        return 'ملغاة';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Waiting Driver':
        return Colors.amber;
      case 'Accepted':
        return Colors.blueAccent;
      case 'In Transit':
      case 'Picked Up':
        return Colors.orangeAccent;
      case 'Delivered':
        return const Color(0xFF10B981);
      case 'Cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}
