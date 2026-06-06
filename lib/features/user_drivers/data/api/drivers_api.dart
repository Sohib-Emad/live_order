// lib/features/drivers_list/data/api/drivers_api.dart

class DriversApi {
  Future<List<Map<String, dynamic>>> getDriversList() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {
        'uid': 'dr_ahmed',
        'name': 'Ahmed Mansour',
        'email': 'ahmed@cargo.com',
        'imageUrl': 'https://randomuser.me/api/portraits/men/32.jpg',
        'role': 'driver',
        'rating': 4.9,
        'vehicleType': 'Jumbo Flatbed Truck',
        'vehiclePlate': 'د ر س ١ ٢ ٣',
        'vehicleCapacity': '3.5 Tons',
        'totalDeliveries': 248,
        'yearsActive': 4,
        'about': 'Professional driver specialized in transporting bulk goods, furniture, and heavy boxes safely across Cairo governorate.',
        'reviews': [
          {'reviewerName': 'Khaled S.', 'rating': 5.0, 'comment': 'Excellent driver, very careful and punctual!', 'date': '2026-05-20'},
          {'reviewerName': 'Mariam Y.', 'rating': 4.8, 'comment': 'Highly recommended for furniture moving.', 'date': '2026-05-18'}
        ]
      },
      {
        'uid': 'dr_moustafa',
        'name': 'Moustafa Ali',
        'email': 'moustafa@cargo.com',
        'imageUrl': 'https://randomuser.me/api/portraits/men/82.jpg',
        'role': 'driver',
        'rating': 4.95,
        'vehicleType': 'Vito Cargo Van',
        'vehiclePlate': 'س ص ع ٤ ٥ ٦',
        'vehicleCapacity': '1.2 Tons',
        'totalDeliveries': 412,
        'yearsActive': 5,
        'about': 'Safe handling of fragile furniture, electronics, and boxed goods. Reliable service guaranteed.',
        'reviews': [
          {'reviewerName': 'Hassan K.', 'rating': 5.0, 'comment': 'Moustafa was fast and helped with loading!', 'date': '2026-05-22'}
        ]
      },
      {
        'uid': 'dr_samir',
        'name': 'Samir Sabry',
        'email': 'samir@cargo.com',
        'imageUrl': 'https://randomuser.me/api/portraits/men/44.jpg',
        'role': 'driver',
        'rating': 4.85,
        'vehicleType': 'Cargo Motorcycle',
        'vehiclePlate': 'أ ب ج ٧ ٨ ٩',
        'vehicleCapacity': '50 kg',
        'totalDeliveries': 982,
        'yearsActive': 3,
        'about': 'Fast documents and light parcel delivery across all Cairo regions. Express courier services.',
        'reviews': []
      }
    ];
  }
}
