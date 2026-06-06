import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/features/add_order/models/order_model.dart';
import 'package:live_order/features/home/logic/home_logic_helper.dart';

class ClientOrdersTab extends StatefulWidget {
  final List<OrderModel> allOrders;

  const ClientOrdersTab({super.key, required this.allOrders});

  @override
  State<ClientOrdersTab> createState() => _ClientOrdersTabState();
}

class _ClientOrdersTabState extends State<ClientOrdersTab> {
  String _ordersFilter = 'All';

  @override
  Widget build(BuildContext context) {
    List<OrderModel> filteredList;
    if (_ordersFilter == 'All') {
      filteredList = widget.allOrders;
    } else if (_ordersFilter == 'Active') {
      filteredList = widget.allOrders
          .where(
            (o) => o.orderStatus != 'Delivered' && o.orderStatus != 'Cancelled',
          )
          .toList();
    } else if (_ordersFilter == 'Completed') {
      filteredList =
          widget.allOrders.where((o) => o.orderStatus == 'Delivered').toList();
    } else {
      filteredList =
          widget.allOrders.where((o) => o.orderStatus == 'Cancelled').toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
          color: const Color(0xFF1E2028),
          child: Row(
            children: [
              Icon(Icons.inventory_2_rounded, color: const Color(0xFFFFB300), size: 22.sp),
              SizedBox(width: 10.w),
              Text(
                'شحناتي وطلباتي',
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Filters
        Container(
          color: const Color(0xFF1A1D24),
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _filterChip('All', 'الكل'),
                SizedBox(width: 8.w),
                _filterChip('Active', 'قيد التوصيل'),
                SizedBox(width: 8.w),
                _filterChip('Completed', 'مكتملة'),
                SizedBox(width: 8.w),
                _filterChip('Cancelled', 'ملغاة'),
              ],
            ),
          ),
        ),

        Expanded(
          child: filteredList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_rounded,
                        size: 56.sp,
                        color: Colors.grey[800],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'لا توجد شحنات هنا',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) =>
                      _buildShipmentCard(context, filteredList[index]),
                ),
        ),
      ],
    );
  }

  Widget _filterChip(String value, String title) {
    final isSelected = _ordersFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _ordersFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                )
              : null,
          color: isSelected ? null : const Color(0xFF2A2D35),
          borderRadius: BorderRadius.circular(30.r),
          border: isSelected
              ? null
              : Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[500],
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildShipmentCard(BuildContext context, OrderModel order) {
    final statusColor = HomeLogicHelper.getStatusColor(order.orderStatus);
    final statusLabel = HomeLogicHelper.getStatusLabel(order.orderStatus);
    return GestureDetector(
      onTap: () => context.pushNamed(AppRoutes.orderDetailsScreen, extra: order),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2028),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB300).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: const Icon(Icons.shopping_bag_rounded, color: Color(0xFFFFB300), size: 20),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderName,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    order.orderDate.split('T').first,
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
