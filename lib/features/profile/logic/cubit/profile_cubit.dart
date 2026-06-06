import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/features/profile/data/repo/profile_repo.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;

  ProfileCubit({required this.profileRepo}) : super(ProfileInitial());

  // Update user address
  void updateAddress(String userId, String key, String newAddress) async {
    emit(ProfileLoading());
    final result = await profileRepo.updateUserAddress(userId, key, newAddress);
    result.fold(
      (error) => emit(ProfileError(message: error)),
      (_) => emit(ProfileAddressUpdateSuccess()),
    );
  }

  // Update driver vehicle info
  void updateVehicleInfo(String userId, String vehicleInfo) async {
    emit(ProfileLoading());
    final result = await profileRepo.updateDriverVehicleInfo(userId, vehicleInfo);
    result.fold(
      (error) => emit(ProfileError(message: error)),
      (_) => emit(ProfileVehicleUpdateSuccess()),
    );
  }
}
