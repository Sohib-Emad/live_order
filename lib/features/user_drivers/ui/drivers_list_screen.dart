import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/features/user_drivers/logic/cubit.dart';
import 'package:live_order/features/user_drivers/logic/state.dart';
import 'package:live_order/features/user_drivers/widget/driver_list_tile.dart';
import 'package:live_order/features/user_drivers/ui/widget/driver_filter_chip.dart';
import 'package:live_order/features/user_drivers/ui/widget/driver_shimmer_list.dart';
import 'package:live_order/core/widgets/app_text_field.dart';
import 'package:live_order/core/widgets/empty_state.dart';

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
                      DriverFilterChip(
                        label: 'All',
                        isSelected: _selectedFilter == 'All',
                        onTap: () => setState(() => _selectedFilter = 'All'),
                      ),
                      const SizedBox(width: AppDesign.space8),
                      DriverFilterChip(
                        label: 'Top Rated',
                        isSelected: _selectedFilter == 'Top Rated',
                        onTap: () => setState(() => _selectedFilter = 'Top Rated'),
                      ),
                      const SizedBox(width: AppDesign.space8),
                      DriverFilterChip(
                        label: 'Heavy Trucks',
                        isSelected: _selectedFilter == 'Heavy Trucks',
                        onTap: () => setState(() => _selectedFilter = 'Heavy Trucks'),
                      ),
                      const SizedBox(width: AppDesign.space8),
                      DriverFilterChip(
                        label: 'Light Vans',
                        isSelected: _selectedFilter == 'Light Vans',
                        onTap: () => setState(() => _selectedFilter = 'Light Vans'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<DriversCubit>().loadDrivers(),
              color: AppDesign.primary,
              child: BlocBuilder<DriversCubit, DriversState>(
                builder: (context, state) {
                  if (state is DriversLoading) {
                    return const DriverShimmerList();
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
                            Navigator.pushNamed(context, AppRoutes.driverDetails, arguments: driver);
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

  List<UserProfile> _getFilteredDrivers(List<UserProfile> list) {
    return list.where((d) {
      if (_searchQuery.isNotEmpty) {
        final matchesName = d.name.toLowerCase().contains(_searchQuery);
        final matchesVehicle = (d.vehicleType ?? '').toLowerCase().contains(_searchQuery);
        if (!matchesName && !matchesVehicle) return false;
      }

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
}
