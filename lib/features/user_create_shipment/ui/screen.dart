import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/features/user_create_shipment/logic/cubit.dart';
import 'package:live_order/features/user_create_shipment/logic/state.dart';
import 'package:live_order/core/widgets/app_button.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/features/user_create_shipment/ui/widget/map_picker_screen.dart';
import 'widget/step_indicator.dart';
import 'widget/location_form.dart';
import 'widget/cargo_form.dart';
import 'widget/schedule_form.dart';
import 'widget/review_card.dart';
import 'widget/driver_step.dart';
import 'widget/waiting_screen.dart';

class CreateShipmentScreen extends StatefulWidget {
  final UserProfile? preselectedDriver;

  const CreateShipmentScreen({super.key, this.preselectedDriver});

  @override
  State<CreateShipmentScreen> createState() => _CreateShipmentScreenState();
}

class _CreateShipmentScreenState extends State<CreateShipmentScreen> {
  int _currentStep = 0;
  UserProfile? _selectedDriver;
  bool _showWaitingView = false;
  String? _createdShipmentId;

  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  double? _pickupLat;
  double? _pickupLng;
  double? _dropLat;
  double? _dropLng;

  String _selectedCargoType = 'أثاث وموبيليا';
  String _selectedSize = 'M';
  String _selectedPaymentMethod = 'عند الاستلام';
  Shipment? _createdShipment;
  double _weight = 10.0;
  final TextEditingController _notesController = TextEditingController();

  final TextEditingController _dateController = TextEditingController(
    text: '2026-06-01',
  );
  String _selectedTimeRange = '09:00 صباحاً - 12:00 ظهراً';

  @override
  void initState() {
    super.initState();
    _selectedDriver = widget.preselectedDriver;
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<List<UserProfile>> _fetchDrivers() async {
    return context.read<CreateShipmentCubit>().fetchDrivers();
  }

  Future<void> _pickLocation({required bool isPickup}) async {
    final location = await Navigator.push<MapLocation>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          title: isPickup ? 'اختر موقع الاستلام' : 'اختر موقع التسليم',
          initialLat: isPickup ? _pickupLat : _dropLat,
          initialLng: isPickup ? _pickupLng : _dropLng,
        ),
      ),
    );

    if (location != null) {
      setState(() {
        if (isPickup) {
          _pickupController.text = location.address;
          _pickupLat = location.latitude;
          _pickupLng = location.longitude;
        } else {
          _dropoffController.text = location.address;
          _dropLat = location.latitude;
          _dropLng = location.longitude;
        }
      });
    }
  }

  void _nextStep() {
    if (_currentStep == 3 && _selectedDriver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار كابتن للتوصيل للمتابعة.'),
          backgroundColor: AppDesign.danger,
        ),
      );
      return;
    }

    if (_currentStep < 4) {
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

  Future<void> _cancelPendingShipment() async {
    if (_createdShipmentId != null) {
      await context.read<CreateShipmentCubit>().cancelShipment(_createdShipmentId!);
    }
    setState(() {
      _showWaitingView = false;
    });
  }

  Widget _buildWaitingScreen() {
    return WaitingScreen(
      createdShipmentId: _createdShipmentId,
      createdShipment: _createdShipment,
      selectedDriver: _selectedDriver,
      onCancel: _cancelPendingShipment,
      onRetry: () {
        setState(() {
          _showWaitingView = false;
          _currentStep = 3;
        });
      },
    );
  }

  void _submit() {
    final docId = context.read<CreateShipmentCubit>().generateOrderId();
    final shipment = Shipment(
      id: docId,
      pickupAddress: _pickupController.text.trim(),
      pickupLat: _pickupLat ?? 30.0444,
      pickupLng: _pickupLng ?? 31.2357,
      dropAddress: _dropoffController.text.trim(),
      dropLat: _dropLat ?? 30.0771,
      dropLng: _dropLng ?? 31.3426,
      cargoType: _selectedCargoType,
      size: _selectedSize,
      weight: _weight,
      notes: _notesController.text.trim(),
      images: const [],
      preferredDate: _dateController.text.trim(),
      preferredTimeRange: _selectedTimeRange,
      priceEstimate: 120.0,
      status: 'Waiting Driver',
      assignedDriver: _selectedDriver,
      paymentMethod: _selectedPaymentMethod,
    );

    setState(() {
      _createdShipment = shipment;
    });

    context.read<CreateShipmentCubit>().submitShipment(shipment);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppDesign.surface,
        appBar: _showWaitingView
            ? null
            : AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: Navigator.canPop(context)
                    ? IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppDesign.textPrimary,
                        ),
                        onPressed: () => Navigator.pop(context),
                      )
                    : null,
                title: Text(
                  'حجز طلب شحنة بضائع',
                  style: AppDesign.heading(fontSize: 17.0),
                ),
                centerTitle: true,
              ),
        body: _showWaitingView
            ? _buildWaitingScreen()
            : BlocConsumer<CreateShipmentCubit, CreateShipmentState>(
                listener: (context, state) {
                  if (state is CreateShipmentSuccess) {
                    if (_createdShipment != null) {
                      setState(() {
                        _createdShipmentId = _createdShipment!.id;
                        _showWaitingView = true;
                      });
                    } else {
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.homeScreen, (route) => false);
                    }
                  } else if (state is CreateShipmentError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('فشل الحجز والطلب: ${state.message}'),
                        backgroundColor: AppDesign.danger,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is CreateShipmentLoading;

                  return Column(
                    children: [
                      StepIndicator(currentStep: _currentStep),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(AppDesign.space16),
                          child: Column(
                            children: [
                              if (_currentStep == 0)
                                LocationForm(
                                  pickupController: _pickupController,
                                  dropoffController: _dropoffController,
                                  onPickupTap: () => _pickLocation(isPickup: true),
                                  onDropoffTap: () => _pickLocation(isPickup: false),
                                ),
                              if (_currentStep == 1)
                                CargoForm(
                                  selectedCargoType: _selectedCargoType,
                                  onCargoTypeChanged: (val) =>
                                      setState(() => _selectedCargoType = val),
                                  selectedSize: _selectedSize,
                                  onSizeChanged: (val) =>
                                      setState(() => _selectedSize = val),
                                  weight: _weight,
                                  onWeightChanged: (val) =>
                                      setState(() => _weight = val),
                                  notesController: _notesController,
                                ),
                              if (_currentStep == 2)
                                ScheduleForm(
                                  dateController: _dateController,
                                  selectedTimeRange: _selectedTimeRange,
                                  onTimeRangeChanged: (val) =>
                                      setState(() => _selectedTimeRange = val),
                                ),
                              if (_currentStep == 3)
                                DriverStep(
                                  selectedDriver: _selectedDriver,
                                  fetchDrivers: _fetchDrivers,
                                  onDriverSelected: (driver) =>
                                      setState(() => _selectedDriver = driver),
                                ),
                              if (_currentStep == 4)
                                ReviewCard(
                                  pickupAddress: _pickupController.text,
                                  dropoffAddress: _dropoffController.text,
                                  cargoType: _selectedCargoType,
                                  size: _selectedSize,
                                  weight: _weight,
                                  date: _dateController.text,
                                  timeRange: _selectedTimeRange,
                                  driverName: _selectedDriver?.name,
                                  selectedPaymentMethod:
                                      _selectedPaymentMethod,
                                  onPaymentMethodChanged: (val) =>
                                      setState(() =>
                                          _selectedPaymentMethod = val),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDesign.space16,
                          vertical: AppDesign.space12,
                        ),
                        child: Row(
                          children: [
                            if (_currentStep > 0) ...[
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: isLoading ? null : _prevStep,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppDesign.border,
                                      width: 1.5,
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppDesign.radius8,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'السابق',
                                    style: AppDesign.body(
                                      color: AppDesign.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppDesign.space12),
                            ],
                            Expanded(
                              child: AppButton(
                                label: _currentStep == 4
                                    ? 'تأكيد وحجز الشحنة'
                                    : 'متابعة الخطوات',
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
      ),
    );
  }
}
