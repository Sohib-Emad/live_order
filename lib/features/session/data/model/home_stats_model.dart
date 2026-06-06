class HomeStatsModel {
  final int activeShipmentsCount;
  final int completedShipmentsCount;
  final int waitingDriversCount;

  const HomeStatsModel({
    required this.activeShipmentsCount,
    required this.completedShipmentsCount,
    required this.waitingDriversCount,
  });

  factory HomeStatsModel.empty() {
    return const HomeStatsModel(
      activeShipmentsCount: 0,
      completedShipmentsCount: 0,
      waitingDriversCount: 0,
    );
  }
}
