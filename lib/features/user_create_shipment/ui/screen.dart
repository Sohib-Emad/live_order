// lib/features/create_shipment/ui/screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/features/create_shipment/logic/cubit.dart';
import 'package:live_order/features/create_shipment/logic/state.dart';
import 'package:live_order/shared/widgets/app_button.dart';
import 'package:live_order/shared/widgets/app_text_field.dart';

class CreateShipmentScreen extends StatefulWidget {
  final UserProfile? preselectedDriver;

  const CreateShipmentScreen({
    super.key,
    this.preselectedDriver,
  });

  @override
  State<CreateShipmentScreen> createState() => _CreateShipmentScreenState();
}

class _CreateShipmentScreenState extends State<CreateShipmentScreen> {
  int _currentStep = 0;

  // Step 1 Controllers
  final TextEditingController _pickupController = TextEditingController(text: 'Maadi, Cairo, Egypt');
  final TextEditingController _dropoffController = TextEditingController(text: 'New Cairo, Egypt');

  // Step 2 Fields
  String _selectedCargoType = 'Furniture';
  String _selectedSize = 'M';
  double _weight = 10.0;
  final TextEditingController _notesController = TextEditingController();

  // Step 3 Fields
  final TextEditingController _dateController = TextEditingController(text: '2026-06-01');
  String _selectedTimeRange = '09:00 AM - 12:00 PM';

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _submit() {
    final shipment = Shipment(
      id: '',
      pickupAddress: _pickupController.text.trim(),
      pickupLat: 30.0444,
      pickupLng: 31.2357,
      dropAddress: _dropoffController.text.trim(),
      dropLat: 30.0771,
      dropLng: 31.3426,
      cargoType: _selectedCargoType,
      size: _selectedSize,
      weight: _weight,
      notes: _notesController.text.trim(),
      images: const [],
      preferredDate: _dateController.text.trim(),
      preferredTimeRange: _selectedTimeRange,
      priceEstimate: 120.0,
      status: 'Waiting Driver',
      assignedDriver: widget.preselectedDriver,
    );

    context.read<CreateShipmentCubit>().submitShipment(shipment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppDesign.textPrimary),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'Book Cargo Shipment',
          style: AppDesign.heading(fontSize: 17.0),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<CreateShipmentCubit, CreateShipmentState>(
        listener: (context, state) {
          if (state is CreateShipmentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Shipment successfully booked!'),
                backgroundColor: AppDesign.success,
              ),
            );
            context.go('/homeScreen');
          } else if (state is CreateShipmentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Booking failed: ${state.message}'),
                backgroundColor: AppDesign.danger,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CreateShipmentLoading;

          return Column(
            children: [
              // Wizard Steps Indicator
              _buildStepIndicator(),

              // Step Content Area
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(AppDesign.space16),
                  child: Column(
                    children: [
                      if (_currentStep == 0) _buildLocationsStep(),
                      if (_currentStep == 1) _buildCargoStep(),
                      if (_currentStep == 2) _buildScheduleStep(),
                      if (_currentStep == 3) _buildReviewStep(),
                    ],
                  ),
                ),
              ),

              // Bottom Actions
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: AppDesign.space16, vertical: AppDesign.space12),
                child: Row(
                  children: [
                    if (_currentStep > 0) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading ? null : _prevStep,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppDesign.border, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDesign.radius8),
                            ),
                          ),
                          child: Text(
                            'Back',
                            style: AppDesign.body(color: AppDesign.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDesign.space12),
                    ],
                    Expanded(
                      child: AppButton(
                        label: _currentStep == 3 ? 'Confirm & Book' : 'Continue',
                        isLoading: isLoading,
                        onTap: isLoading ? null : _nextStep,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: AppDesign.space16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          return Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isActive ? AppDesign.primary : AppDesign.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? AppDesign.primary : AppDesign.border,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: AppDesign.body(
                    color: isActive ? Colors.white : AppDesign.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0,
                  ),
                ),
              ),
              if (index < 3)
                Container(
                  width: 36,
                  height: 2,
                  color: index < _currentStep ? AppDesign.primary : AppDesign.border,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLocationsStep() {
    return Container(
      padding: const EdgeInsets.all(AppDesign.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: AppDesign.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Locations',
            style: AppDesign.heading(fontSize: 16.0),
          ),
          const SizedBox(height: AppDesign.space20),
          AppTextField(
            label: 'Pickup Location Address',
            hint: 'E.g. Maadi, Cairo...',
            controller: _pickupController,
            prefixIcon: const Icon(Icons.location_on_rounded, color: AppDesign.success),
          ),
          const SizedBox(height: AppDesign.space20),
          AppTextField(
            label: 'Dropoff Location Address',
            hint: 'E.g. New Cairo...',
            controller: _dropoffController,
            prefixIcon: const Icon(Icons.location_on_rounded, color: AppDesign.danger),
          ),
        ],
      ),
    );
  }

  Widget _buildCargoStep() {
    final cargoTypes = ['Furniture', 'Electronics', 'Boxes', 'Documents', 'Other'];
    final sizes = ['S', 'M', 'L', 'XL'];

    return Container(
      padding: const EdgeInsets.all(AppDesign.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: AppDesign.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cargo Details',
            style: AppDesign.heading(fontSize: 16.0),
          ),
          const SizedBox(height: AppDesign.space20),

          // Cargo Type
          Text(
            'Cargo Category',
            style: AppDesign.body(color: AppDesign.textPrimary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDesign.space8),
          DropdownButtonFormField<String>(
            value: _selectedCargoType,
            items: cargoTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCargoType = val);
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: AppDesign.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesign.radius8),
                borderSide: const BorderSide(color: AppDesign.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesign.radius8),
                borderSide: const BorderSide(color: AppDesign.primary),
              ),
            ),
          ),

          const SizedBox(height: AppDesign.space20),

          // Cargo Size
          Text(
            'Cargo Size Dimension',
            style: AppDesign.body(color: AppDesign.textPrimary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDesign.space8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: sizes.map((size) {
              final isSelected = _selectedSize == size;
              return GestureDetector(
                onTap: () => setState(() => _selectedSize = size),
                child: Container(
                  width: 54,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSelected ? AppDesign.primary : AppDesign.surface,
                    borderRadius: BorderRadius.circular(AppDesign.radius8),
                    border: Border.all(color: isSelected ? AppDesign.primary : AppDesign.border, width: 1.0),
                  ),
                  child: Center(
                    child: Text(
                      size,
                      style: AppDesign.heading(color: isSelected ? Colors.white : AppDesign.textPrimary, fontSize: 14.0),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppDesign.space20),

          // Weight Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cargo Weight',
                style: AppDesign.body(color: AppDesign.textPrimary, fontWeight: FontWeight.bold),
              ),
              Text(
                '${_weight.toInt()} kg',
                style: AppDesign.heading(fontSize: 15.0),
              ),
            ],
          ),
          Slider(
            value: _weight,
            min: 1.0,
            max: 200.0,
            activeColor: AppDesign.primary,
            inactiveColor: AppDesign.border,
            onChanged: (val) => setState(() => _weight = val),
          ),

          const SizedBox(height: AppDesign.space12),

          // Notes
          AppTextField(
            label: 'Additional Delivery Notes',
            hint: 'E.g. fragile, requires loading assistance...',
            controller: _notesController,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleStep() {
    final times = ['09:00 AM - 12:00 PM', '12:00 PM - 03:00 PM', '03:00 PM - 06:00 PM', '06:00 PM - 09:00 PM'];

    return Container(
      padding: const EdgeInsets.all(AppDesign.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: AppDesign.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule Delivery',
            style: AppDesign.heading(fontSize: 16.0),
          ),
          const SizedBox(height: AppDesign.space20),
          AppTextField(
            label: 'Preferred Date',
            hint: 'YYYY-MM-DD',
            controller: _dateController,
            prefixIcon: const Icon(Icons.calendar_today_rounded, color: AppDesign.primary),
          ),
          const SizedBox(height: AppDesign.space24),
          Text(
            'Preferred Time Window',
            style: AppDesign.body(color: AppDesign.textPrimary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDesign.space8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: times.length,
            itemBuilder: (context, index) {
              final t = times[index];
              final isSel = _selectedTimeRange == t;
              return GestureDetector(
                onTap: () => setState(() => _selectedTimeRange = t),
                child: Container(
                  margin: const EdgeInsets.only(bottom: AppDesign.space8),
                  padding: const EdgeInsets.symmetric(horizontal: AppDesign.space16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSel ? AppDesign.primary.withOpacity(0.08) : AppDesign.surface,
                    borderRadius: BorderRadius.circular(AppDesign.radius8),
                    border: Border.all(color: isSel ? AppDesign.primary : AppDesign.border, width: 1.0),
                  ),
                  child: Text(
                    t,
                    style: AppDesign.body(
                      color: isSel ? AppDesign.primary : AppDesign.textPrimary,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.w400,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return Container(
      padding: const EdgeInsets.all(AppDesign.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: AppDesign.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Review',
            style: AppDesign.heading(fontSize: 16.0),
          ),
          const SizedBox(height: AppDesign.space20),
          _buildReviewItem('PICKUP', _pickupController.text),
          _buildReviewItem('DROPOFF', _dropoffController.text),
          _buildReviewItem('CARGO TYPE', _selectedCargoType),
          _buildReviewItem('CARGO SIZE & WEIGHT', '$_selectedSize Size — ${_weight.toInt()} kg'),
          _buildReviewItem('PREFERRED SCHEDULE', '${_dateController.text} ($_selectedTimeRange)'),
          if (widget.preselectedDriver != null)
            _buildReviewItem('ASSIGNED DRIVER', widget.preselectedDriver!.name),

          const Divider(color: AppDesign.border, height: 32),

          // Total Settle Cost
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price Estimate Settle',
                style: AppDesign.body(color: AppDesign.textPrimary, fontWeight: FontWeight.bold, fontSize: 14.5),
              ),
              Text(
                '\$120.00',
                style: AppDesign.heading(color: AppDesign.primary, fontSize: 20.0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String title, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDesign.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: AppDesign.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: AppDesign.body(color: AppDesign.textPrimary, fontWeight: FontWeight.bold, fontSize: 13.5),
          ),
        ],
      ),
    );
  }
}
