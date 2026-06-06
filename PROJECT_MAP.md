# PROJECT_MAP — Live Order (منصة الشحنات)

## [TECH_STACK]

| الطبقة | التقنية | الإصدار |
|--------|---------|---------|
| Framework | Flutter | 3.x (SDK ^3.12.0) |
| Language | Dart | ^3.12.0 |
| State Management | flutter_bloc | ^9.1.1 |
| Routing | Navigator 1.0 (onGenerateRoute) | مدمج في Flutter |
| DI | get_it | ^9.2.1 |
| Backend | Supabase (Auth + Postgres + Storage) + FCM للـ push | supabase_flutter ^2.8.3 |
| Maps | google_maps_flutter + flutter_map | ^2.17.1 / ^8.3.0 |
| Geocoding | Google Geocoding API (HTTP) | — |
| Design | Google Fonts (DM Sans) + AppDesign | - |
| Local Storage | flutter_secure_storage | ^10.3.1 |
| Caching | cached_network_image | ^3.4.1 |

---

## [ARCHITECTURE]

```
lib/
├── core/                          # طبقة مشتركة (لا تعتمد على features)
│   ├── constants/                 # AppDesign (ألوان، مسافات، تایپوغرافي)
│   ├── di/                        # GetIt DI (di.dart — النشط)
│   ├── models/                    # النماذج الموحدة
│   │   ├── shipment.dart          # Shipment (نموذج الشحنة الوحيد)
│   │   └── user_profile.dart      # UserProfile (نموذج المستخدم الوحيد) — uid, name, email, imageUrl, role, phone, address, vehicle*, images*
│   ├── routing/                   # onGenerateRoute + AppRoutes
│   ├── services/                  # Supabase client singleton + config (بديل Firebase)
│   ├── utils/                     # StorageHelper, AnimatedSnackDialog, AppLogger
│   └── widgets/                   # primay_button_widget, spacing_widgets (قديم)
│
├── shared/                        # Widgets مشتركة بين الـ features
│   └── widgets/                   # AppButton, AvatarWidget, StatusBadge, إلخ
│
├── features/                      # مقسمة حسب الدور (user_ / driver_)
│   │
│   ├── [user_*] العميل — اللي بيطلب الخدمة:
│   ├── user_home/                 # الصفحة الرئيسية للعميل (كانت client_dashboard)
│   ├── user_create_shipment/      # إنشاء شحنة جديد (كانت create_shipment)
│   ├── user_drivers/              # قائمة السائقين (كانت drivers_list)
│   ├── user_chat/                 # محادثة العميل مع السائق (كانت market_chat)
│   ├── user_profile/              # البروفايل بتاع العميل (كانت market_profile)
│   ├── user_notifications/        # إشعارات العميل (كانت notifications)
│   ├── user_payments/             # مدفوعات العميل (كانت payments)
│   ├── user_rewards/              # مكافآت العميل (كانت rewards)
│   ├── user_rate_driver/          # تقييم السائق (كانت rate_driver)
│   ├── user_tracking/             # تتبع الشحنة (كانت tracking)
│   ├── user_account/              # حساب العميل — UserCubit, UserRepository (كانت user)
│   │
│   ├── [driver_*] السواق:
│   ├── driver_home/               # الصفحة الرئيسية للسواق (كانت driver)
│   ├── driver_orders/             # تفاصيل الطلب للسواق (كانت add_order)
│   ├── driver_chat/               # محادثات السواق (كانت chat)
│   ├── driver_offers/             # عروض السواق (كانت offers)
│   ├── driver_notifications/      # إشعارات السواق (كانت notification)
│   │
│   ├── [مشتركة] الكل يستخدمها:
│   ├── auth/                      # تسجيل الدخول (Supabase Auth)
│   ├── session/                    # Route dispatcher + session streams (role-based)
│   ├── onboarding/                # شاشات الترحيب
│   └── admin/                     # لوحة تحكم المشرف (AdminDashboard)
│
└── main.dart                      # نقطة الدخول (Supabase init + DI + Routing)
```

### نمط الـ Feature الواحد:
```
feature/
├── data/
│   ├── api/          # استدعاءات Supabase مباشرة
│   ├── models/       # نماذج الـ feature (إن لزم)
│   └── repository/   # منطق التخزين (يجمع API)
├── logic/
│   ├── cubit.dart    # BLoC/Cubit
│   └── state.dart    # حالات الـ Cubit
└── ui/
    ├── screen.dart   # الصفحة
    └── widget/       # Widgets مساعدة
```

---

## [SYSTEM_FLOW]

### Client Flow (user_*):
```
تسجيل/دخول → session/ (HomeScreen) → user_home/ (ClientDashboardScreen)
                              ├─ إنشاء شحنة (user_create_shipment/)
                              │   → اختيار سائق → انتظار القبول
                              │   → قبول → user_tracking/ → user_rate_driver/
                              ├─ قائمة السائقين (user_drivers/)
                              ├─ محادثات (user_chat/)
                              └─ إشعارات (user_notifications/)
```

### Driver Flow (driver_*):
```
تسجيل/دخول → session/ (HomeScreen) → driver_home/ (DriverHomeScreen)
                              ├─ لوحة التحكم (إحصائيات + توفر)
                              ├─ العروض (driver_offers/) → قبول/رفض
                              ├─ المحادثات (driver_chat/)
                              └─ الإشعارات (driver_notifications/)
```

### Admin Flow:
```
تسجيل/دخول → session/ (HomeScreen) → admin/ (AdminDashboard)
                              ├─ إدارة السائقين (تفعيل/حظر) — جميع بيانات السواق + الصور
                              ├─ مراقبة المستخدمين — جميع المستخدمين مع صلاحيات حظر/تفعيل
                              └─ مراقبة الطلبات — جميع الشحنات في النظام
```

### Data Flow:
```
UI ← BlocBuilder → Cubit ← Repository ← API (Supabase Postgres)
                        ↕
                   State (Bloc)
```

---

## [ORPHANS & PENDING]

### 🗑️ الملفات التي تم حذفها:
- ~~`features/home/ui/client_home_screen.dart`~~ — 🗑️ مستبدل بـ user_home/
- ~~`features/home/ui/widgets/client_home_tab.dart`~~ — 🗑️ ميت
- ~~`features/home/ui/widgets/client_orders_tab.dart`~~ — 🗑️ ميت
- ~~`features/chat/ui/widgets/client_chats_tab.dart`~~ + ~~`client_chat_list_item.dart`~~ — 🗑️ ميت
- ~~`features/notification/ui/widgets/client_notifications_tab.dart`~~ — 🗑️ ميت
- ~~`features/add_order/models/order_model.dart`~~ + ~~`user_model.dart`~~ — 🗑️ مهمل
- ~~`features/add_order/ui/add_order_screen.dart`~~ + ~~`driver_selection_screen.dart`~~ — 🗑️ ميت
- ~~`core/utils/service_locator.dart`~~ — 🗑️ غير مستخدم
- ~~`core/styling/`~~ — 🗑️ نظام تصميم قديم
- ~~`core/widgets/loading_widget.dart`~~ + ~~`custom_text_field.dart`~~ — 🗑️ غير مستخدمين

### 🔄 إعادة التسمية (Rename) — 16 Feature:
| القديم | الجديد | الدور |
|--------|--------|-------|
| `client_dashboard/` | `user_home/` | العميل |
| `create_shipment/` | `user_create_shipment/` | العميل |
| `drivers_list/` | `user_drivers/` | العميل |
| `market_chat/` | `user_chat/` | العميل |
| `market_profile/` | `user_profile/` | العميل |
| `notifications/` | `user_notifications/` | العميل |
| `payments/` | `user_payments/` | العميل |
| `rewards/` | `user_rewards/` | العميل |
| `rate_driver/` | `user_rate_driver/` | العميل |
| `tracking/` | `user_tracking/` | العميل |
| `driver/` | `driver_home/` | السواق |
| `add_order/` | `driver_orders/` | السواق |
| `chat/` | `driver_chat/` | السواق |
| `offers/` | `driver_offers/` | السواق |
| `notification/` | `driver_notifications/` | السواق |
| `user/` | `user_account/` | العميل |
| `home/` | `session/` | التوجيه + البث المباشر |

### 🗑️ الـ driver flow القديم (بقي في مساره الجديد):
| Feature القديم | Feature الجديد | الملفات | تستخدم في |
|----------------|----------------|---------|-----------|
| `add_order/` | `driver_orders/` | `order_details_screen.dart`, cubit, repo, api | Driver → تفاصيل الشحنة |
| `chat/` | `driver_chat/` | `driver_chats_tab.dart`, `live_chat_sheet.dart`, cubit, repo, api | Driver → محادثات |
| `notification/` | `driver_notifications/` | `driver_notifications_tab.dart`, cubit, repo, api | Driver → إشعارات |
| `offers/` | `driver_offers/` | `driver_offers_tab.dart`, cubit, repo, api | Driver → عروض |

هذه الميزات ستعاد كتابتها لاحقاً بنفس نمط data/api/ → repository/ → cubit.

### ⚠️ مشاكل تقنية معروفة:
- `withOpacity()` قديم في Flutter 3.x (185 إشعار info) — يجب استبداله بـ `withValues(alpha:)`
- `print()` في `add_order_screen.dart:959` — لكن الملف محذوف الآن 🗑️
- صلاحيات الـ `mounted` بعد async في بعض الملفات (add_order/ui/driver_selection_screen.dart — لكن الملف محذوف 🗑️)
- اسم الملف `primay_button_widget.dart` (خطأ إملائي "primay") — يستخدمه 4 ملفات قديمة

### 🏗️ مطلوب في Supabase:
- إنشاء bucket باسم `verification` (عام/public) لتخزين صور التوثيق

### 🆕 الإضافات الحديثة:
- **M19: Map Picker (✔️)** — إنشاء `MapPickerScreen` في `user_create_shipment/` لاختيار الموقع من خريطة Google Maps مع بحث عناوين عبر Nominatim API. العكس الجغرافي (عرض العنوان عند تحريك الخريطة) عبر Nominatim API. (2026-06)
- **M20: Tracking Map (✔️)** — إضافة `TrackingMapWidget` إلى شاشة `ShipmentTrackingScreen` لعرض مسار الرحلة (خط بين الاستلام والتسليم) مع علامات pickup/drop. (2026-06)
- **M21: Fix tracking empty state from stale REST query (✔️)** — `_handleTrackAction` كان يقرأ `activeShipments` من `ClientDashboardCubit` (استعلام REST لمرة واحدة) الذي قد يرجع فاضياً رغم وجود شحنة نشطة. تم تغييره لقراءة `HomeCubit` (realtime stream) بدلاً منه. (2026-06)
- **M22: Driver tracking – real rating, live location marker (✔️)** — ٣ إصلاحات في `user_tracking/`: (1) `driver_card.dart` يستخدم `driver.rating` الحقيقي و `driver.reviews.length` بدل القيم الثابتة `4.9` و `(١٢٣ تقييم)`. (2) `TrackingMapWidget` يعرض علامة زرقاء (`hueAzure`) لموقع السائق من `assignedDriver.currentLat/currentLong`. (3) `TrackingCubit` يشترك في `users` table لتحديث موقع السائق المباشر (`current_lat`/`current_long`) ويُصدر الحالة المحدّثة فوراً. (2026-06)

### 📝 الخطوات المنجزة (Milestones):
1. ~~M1: توحيد النماذج (✔️)~~ — Shipment + UserProfile هما النموذجان الوحيدان
2. ~~M2: توحيد التصميم (✔️)~~ — إزالة core/styling، الاعتماد على AppDesign فقط
3. ~~M3: طبقة FirebaseService (✔️)~~ — API + Repository في create_shipment
4. ~~M4: توحيد DI (✔️)~~ — إزالة service_locator.dart
5. ~~M5: AppLogger (✔️)~~ — `core/utils/logger.dart`
6. ~~M6: توحيد Routing (✔️)~~ — جميع الـ Routes تستعمل AppRoutes
7. ~~M7: تنظيف القديم (✔️)~~ — حذف ملفات ميتة، توثيق الباقي
8. ~~M8: اختبارات (✔️)~~ — 27 اختبار (models + widget)
9. ~~M9: ريفاكتور session/ + إزالة MultiBlocProvider (✔️)~~ — home/ → session/، إزالة 5 Cubits وهمية من MultiBlocProvider، نقل DriverCubit إلى DriverHomeScreen
10. ~~M10: استبدال BottomNavigationBar بـ IconButton (✔️)~~ — client + driver
11. ~~M11: ترحيل Firebase → Supabase (✔️)~~ — Auth, Postgres, Storage; FCM محتفظ به
12. ~~M12: توثيق السائق (✔️)~~ — رفع صور البطاقة (وجه/ظهر) + الرخصة + المركبة عند التسجيل كسواق
13. ~~M13: تطوير لوحة تحكم المدير (✔️)~~ — عرض جميع بيانات المستخدمين (سواق/عملاء) مع الصور الشخصية وصور التوثيق في بطاقات قابلة للتوسيع مع معاينة الصور بالضغط عليها
14. ~~M14: تفعيل Realtime للـ Admin (✔️)~~ — optimistic update محلي للتغييرات + إعادة الاشتراك التلقائي عند فشل الـ stream بدلاً من تعليق الصفحة
15. ~~M15: تفعيل Realtime للسواق (✔️)~~ — نفس نمط auto-retry في HomeCubit + إزالة HomeError الدائم وعرض رسالة "جاري إعادة الاتصال" مؤقتة بدلاً منه
16. ~~M16: إصلاح RLS للـ Admin (✔️)~~ — تحديث `driver_status` كان يفشل صامتاً بسبب RLS (`users_update_own` يسمح فقط بتحديث صف المستخدم نفسه). تم إنشاء RPC function `admin_update_user_status` بتوقيع `SECURITY DEFINER` لتجاوز RLS، وتحديث `AdminApi.updateDriverStatus` لاستخدام `supabase.rpc()` بدلاً من `supabase.from('users').update()
17. ~~M17: إظهار كامل بيانات السواق في لوحة المدير (✔️)~~ — كانت الحقول الاختيارية (`phone`, `address`, `vehicle_*`, `national_id`, `license_number`) لا تظهر لأن `UserProfile.fromJson` كان يقرأ القيم الافتراضية `''` كما هي بدون تحويلها إلى `null`. تم إضافة `_emptyToNull()` في `fromJson` لتحويل `''` → `null`.
18. ~~M18: ربط صفحة تفاصيل السائق (user-facing) بقاعدة البيانات (✔️)~~ — `DriversApi.getDriversList()` و `CreateShipmentApi.fetchDrivers()` كانا يعملان mapping يدوي بــ hardcoded fallbacks وأسماء أعمدة خاطئة (`doc['imageUrl']` مكان `image_url`، `doc['vehicle_info']` مكان `vehicle_type`). تم إرجاع البيانات الخام من Supabase مباشرة والاعتماد على `UserProfile.fromJson()` للمعايرة. تم إزالة الأعمدة الميتة `password` و `vehicle_info` من `supabase_schema.sql`.
19. ~~M22: Driver tracking – real rating, live location marker (✔️)~~ — ٣ إصلاحات في `user_tracking/`: (1) `driver_card.dart` يستخدم `driver.rating` الحقيقي و `driver.reviews.length` بدل القيم الثابتة. (2) `TrackingMapWidget` يعرض علامة زرقاء لموقع السائق المباشر. (3) `TrackingCubit` يشترك في `users` table لتحديث موقع السائق المباشر (`current_lat`/`current_long`).

---

## [DEPENDENCY VERSIONS (2026-06)]

| الحزمة | الحالي | الأحدث | ملاحظات |
|--------|--------|--------|---------|
| supabase_flutter | 2.8.3 | 2.8.3 | بديل cloud_firestore + firebase_auth |
| firebase_messaging | 16.2.2 | 16.3.0 | FCM فقط |
| firebase_core | 4.9.0 | 4.10.0 | تبعية لـ FCM |
| flutter_launcher_icons | 0.13.1 | 0.14.4 | ترقية متاحة |
