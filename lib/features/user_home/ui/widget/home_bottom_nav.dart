import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, 'الرئيسية'),
      (Icons.add_box_rounded, 'طلب شحنة'),
      (Icons.account_balance_wallet_rounded, 'المحفظة'),
      (Icons.person_rounded, 'حسابي'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom, top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isSelected = currentIndex == i;
          return IconButton(
            icon: Icon(items[i].$1, color: isSelected ? AppDesign.primary : AppDesign.textSecondary),
            onPressed: () => onTap(i),
            tooltip: items[i].$2,
          );
        }),
      ),
    );
  }
}
