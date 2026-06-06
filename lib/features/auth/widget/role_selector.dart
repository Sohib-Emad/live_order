import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تحديد نوع الحساب',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF444444),
          ),
        ),
        const HeightSpace(10),
        Row(
          children: [
            _buildRoleCard(
              role: 'client',
              label: 'عميل (شحن)',
              icon: Icons.person_pin_rounded,
            ),
            const WidthSpace(12),
            _buildRoleCard(
              role: 'driver',
              label: 'كابتن (سائق)',
              icon: Icons.local_shipping_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String label,
    required IconData icon,
  }) {
    final isSelected = selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => onRoleChanged(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xfffdad2b).withOpacity(0.12)
                : Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isSelected
                  ? AppDesign.primary
                  : Colors.white.withOpacity(0.8),
              width: 1.8,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xfffdad2b).withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: isSelected
                          ? AppDesign.primary
                          : const Color(0xFF6B7280),
                      size: 24.sp,
                    ),
                    const HeightSpace(6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? AppDesign.primary
                            : const Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Positioned(
                  top: -8.h,
                  right: -4.w,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppDesign.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 10.sp,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
