# فيتشر المستخدم العادي (User Feature)

## نظرة عامة
فيتشر المستخدم العادي (Client) يوفر واجهة كاملة لإدارة بيانات المستخدم والحساب والإعدادات المختلفة.

## الملفات والهيكل

```
lib/features/user/
├── data/
│   ├── api/
│   │   └── user_api.dart          # API calls للتعامل مع Firebase
│   └── repo/
│       └── user_repo.dart         # Repository للتعامل مع البيانات
├── logic/
│   └── cubit/
│       ├── user_cubit.dart        # Business Logic (Cubit)
│       └── user_state.dart        # States للـ Cubit
├── models/
│   └── user_preferences.dart      # نموذج إعدادات المستخدم
└── ui/
    └── user_profile_screen.dart   # الشاشة الرئيسية للملف الشخصي
```

## الوظائف الرئيسية

### 1. عرض بيانات المستخدم
- عرض اسم المستخدم والبريد الإلكتروني
- عرض صورة الملف الشخصي
- عرض حالة الحساب

### 2. الإحصائيات
- عدد الطلبات المكتملة
- عدد الطلبات النشطة
- إجمالي المبلغ المنفق

### 3. تعديل البيانات الشخصية
- تحديث الاسم والبريد الإلكتروني
- تحديث الصورة الشخصية
- تحديث بيانات الاتصال (الهاتف والعنوان)

### 4. إعدادات الإشعارات
- تفعيل/تعطيل الإشعارات
- إعدادات الإشعارات عبر البريد الإلكتروني
- إعدادات الإشعارات عبر الرسائل القصيرة
- إعدادات الإشعارات Push

### 5. إدارة الحساب
- تسجيل الخروج
- حذف الحساب (محمي)
- تغيير كلمة المرور
- الدعم الفني والمساعدة

## استخدام الفيتشر

### التنقل إلى شاشة الملف الشخصي
```dart
context.pushNamed(
  AppRoutes.userProfileScreen,
  extra: currentUser,
);
```

### استخدام UserCubit
```dart
final userCubit = getIt<UserCubit>();

// تحميل بيانات المستخدم
userCubit.loadUserData(userId);

// تحميل الإحصائيات
userCubit.loadUserStats(userId);

// تحديث البيانات الشخصية
userCubit.updatePersonalInfo(userId, newName, newEmail);

// تحديث بيانات الاتصال
userCubit.updateContactInfo(userId, phone, address);
```

## Firebase Integration

### Collections
- `users` - بيانات المستخدم الأساسية
- `orders` - البيانات المتعلقة بالطلبات
- `user_activity` - سجل نشاط المستخدم

### Fields
```json
{
  "user_id": "string",
  "name": "string",
  "email": "string",
  "phone": "string",
  "address": "string",
  "profile_image": "string",
  "notification_settings": {
    "notifications_enabled": true,
    "email_notifications": true,
    "sms_notifications": false,
    "push_notifications": true
  },
  "created_at": "timestamp",
  "updated_at": "timestamp",
  "is_deleted": false,
  "deleted_at": "timestamp"
}
```

## الألوان المستخدمة

| العنصر | اللون | الكود |
|--------|------|-------|
| اللون الأساسي | برتقالي | `0xFFFF6B00` |
| لون الخلفية | أسود داكن | `0xFF0F1419` |
| لون النجاح | أخضر | `0xFF4CAF50` |
| لون التحذير | أزرق | `0xFF2196F3` |
| لون الخطأ | أحمر | `Colors.redAccent` |

## الحالات (States)

| الحالة | الوصف |
|--------|--------|
| `UserInitial` | الحالة الأولية |
| `UserLoading` | جاري التحميل |
| `UserDataLoaded` | تم جلب البيانات بنجاح |
| `UserStatsLoaded` | تم جلب الإحصائيات بنجاح |
| `UserDataUpdateSuccess` | تم تحديث البيانات بنجاح |
| `UserError` | حدث خطأ ما |
| `UserActivityLoaded` | تم جلب سجل النشاط |
| `UserAccountDeletedSuccess` | تم حذف الحساب بنجاح |

## ملاحظات مهمة

1. **الحماية**: عملية حذف الحساب محمية وتتطلب التواصل مع الدعم الفني
2. **الإشعارات**: تتم مزامنة الإشعارات مع Firebase Messaging
3. **الترجمة**: جميع النصوص في الواجهة مترجمة إلى اللغة العربية
4. **التصميم**: تم استخدام تصميم داكن (Dark Mode) يتماشى مع باقي التطبيق

## المتطلبات
- Firebase Core
- Cloud Firestore
- Firebase Auth
- Firebase Messaging
- Flutter BLoC
- Dartz (للـ Either Pattern)
- Flutter ScreenUtil (للاستجابة)

## الإضافات المستقبلية
- [ ] تحميل الصور من الكاميرا أو المعرض
- [ ] سجل نشاط شامل مع فترات زمنية
- [ ] إشعارات بالعروض الخاصة والخصومات
- [ ] تقارير الحساب والفواتير
- [ ] الربط مع محافظ رقمية
