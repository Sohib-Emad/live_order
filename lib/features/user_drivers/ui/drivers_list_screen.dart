// lib/features/drivers_list/ui/drivers_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/features/drivers_list/logic/cubit.dart';
import 'package:live_order/features/drivers_list/logic/state.dart';
import 'package:live_order/features/drivers_list/widget/driver_list_tile.dart';
import 'package:live_order/shared/widgets/app_text_field.dart';
import 'package:live_order/shared/widgets/empty_state.dart';
import 'package:live_order/shared/widgets/loading_shimmer.dart';

class DriversListScreen extends StatefulWidget {
  const DriversListScreen({super.key});

  @override
  State<DriversListScreen> createState() => _DriversListScreenState();
}

class _DriversListScreenState extends State<DriversListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<DriversCubit>().loadDrivers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppDesign.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cargo Drivers',
          style: AppDesign.heading(fontSize: 18.0),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search & Filter Panel
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(
              AppDesign.space16,
              AppDesign.space12,
              AppDesign.space16,
              AppDesign.space16,
            ),
            child: Column(
              children: [
                AppTextField(
                  hint: 'Search drivers, vehicle types...',
                  controller: _searchController,
                  prefixIcon: const Icon(Icons.search_rounded, color: AppDesign.textSecondary),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim().toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: AppDesign.space12),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: AppDesign.space8),
                      _buildFilterChip('Top Rated'),
                      const SizedBox(width: AppDesign.space8),
                      _buildFilterChip('Heavy Trucks'),
                      const SizedBox(width: AppDesign.space8),
                      _buildFilterChip('Light Vans'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Drivers List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<DriversCubit>().loadDrivers(),
              color: AppDesign.primary,
              child: BlocBuilder<DriversCubit, DriversState>(
                builder: (context, state) {
                  if (state is DriversLoading) {
                    return _buildShimmerList();
                  } else if (state is DriversError) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        padding: const EdgeInsets.all(AppDesign.space24),
                        height: MediaQuery.of(context).size.height * 0.6,
                        alignment: Alignment.center,
                        child: EmptyState(
                          icon: Icons.error_outline_rounded,
                          title: 'Failed to load drivers',
                          subtitle: state.message,
                          actionLabel: 'Retry',
                          onActionTap: () => context.read<DriversCubit>().loadDrivers(),
                        ),
                      ),
                    );
                  } else if (state is DriversLoaded) {
                    final filtered = _getFilteredDrivers(state.drivers);
                    if (filtered.isEmpty) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          padding: const EdgeInsets.all(AppDesign.space24),
                          height: MediaQuery.of(context).size.height * 0.6,
                          alignment: Alignment.center,
                          child: EmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'No drivers found',
                            subtitle: 'Try adjusting your filters or search term.',
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppDesign.space16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final driver = filtered[index];
                        return DriverListTile(
                          driver: driver,
                          onViewTap: () {
                            context.pushNamed('driver_details', extra: driver);
                          },
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppDesign.space16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppDesign.primary : AppDesign.surface,
          borderRadius: BorderRadius.circular(AppDesign.radius24),
          border: Border.all(
            color: isSelected ? AppDesign.primary : AppDesign.border,
            width: 1.0,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppDesign.body(
              color: isSelected ? Colors.white : AppDesign.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 13.0,
            ),
          ),
        ),
      ),
    );
  }

  List<UserProfile> _getFilteredDrivers(List<UserProfile> list) {
    return list.where((d) {
      // 1. Search Query
      if (_searchQuery.isNotEmpty) {
        final matchesName = d.name.toLowerCase().contains(_searchQuery);
        final matchesVehicle = (d.vehicleType ?? '').toLowerCase().contains(_searchQuery);
        if (!matchesName && !matchesVehicle) return false;
      }

      // 2. Filter Tab
      if (_selectedFilter == 'Top Rated') {
        return d.rating >= 4.9;
      } else if (_selectedFilter == 'Heavy Trucks') {
        return (d.vehicleType ?? '').toLowerCase().contains('truck') ||
            (d.vehicleType ?? '').toLowerCase().contains('flatbed');
      } else if (_selectedFilter == 'Light Vans') {
        return (d.vehicleType ?? '').toLowerCase().contains('van') ||
            (d.vehicleType ?? '').toLowerCase().contains('motorcycle');
      }
      return true;
    }).toList();
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDesign.space16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppDesign.space12),
          padding: const EdgeInsets.all(AppDesign.space12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDesign.radius12),
            border: Border.all(color: AppDesign.border, width: 1.0),
          ),
          child: Row(
            children: [
              const LoadingShimmer(width: 52, height: 52, borderRadius: 26),
              const SizedBox(width: AppDesign.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    LoadingShimmer(width: 140, height: 16),
                    SizedBox(height: AppDesign.space8),
                    LoadingShimmer(width: 100, height: 12),
                    SizedBox(height: AppDesign.space12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LoadingShimmer(width: 80, height: 14),
                        LoadingShimmer(width: 60, height: 28, borderRadius: 8),
                      ],
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
}
