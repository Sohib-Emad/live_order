import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/core/styling/app_colors.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkNavigationAndRemoveSplash();
  }

  Future<void> _checkNavigationAndRemoveSplash() async {
    const storage = FlutterSecureStorage();
    final hasSeenOnboarding = await storage.read(key: 'has_seen_onboarding');

    if (hasSeenOnboarding == 'true') {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (mounted) {
          context.pushReplacementNamed(AppRoutes.homeScreen);
        }
      } else {
        if (mounted) {
          context.pushReplacementNamed(AppRoutes.loginScreen);
        }
      }
    }

    // Hide native splash screen once initial route check is complete
    FlutterNativeSplash.remove();
  }

  final List<OnboardingModel> _slides = [
    OnboardingModel(
      image: 'assets/icons/logo.png',
      title: 'مرحباً بك في لايف أوردر',
      subtitle: 'منصتك الذكية المتكاملة لشحن ونقل البضائع والركاب في مصر بكل سلاسة وأمان وسهولة.',
    ),
    OnboardingModel(
      image: 'assets/icons/order.png',
      title: 'أنشئ شحنتك بضغطة زر',
      subtitle: 'حدد موقع الاستلام والتسليم على الخريطة المصرية بدقة بالغة واختر حجم شحنتك المناسب.',
    ),
    OnboardingModel(
      image: 'assets/icons/truck.png',
      title: 'اختر سائقك وقارن العروض',
      subtitle: 'قارن عروض السائقين الأقرب إليك والأعلى تقييماً، وتابع شحنتك مباشرة حتى باب البيت.',
    ),
  ];

  Future<void> _completeOnboarding() async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'has_seen_onboarding', value: 'true');
    if (mounted) {
      context.pushReplacementNamed(AppRoutes.loginScreen);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F0), // Beautiful Cream background
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar with Skip Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _currentIndex < _slides.length - 1
                      ? TextButton(
                          onPressed: _completeOnboarding,
                          child: Text(
                            'تخطي',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : const SizedBox(height: 36),
                ),
              ),

              // Page View Slides
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Styled image container
                          Container(
                            width: 240.w,
                            height: 240.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(24.w),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.r),
                              child: Image.asset(
                                slide.image,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const HeightSpace(48),

                          // Title text
                          Text(
                            slide.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1A1A1A),
                              height: 1.3,
                            ),
                          ),
                          const HeightSpace(16),

                          // Subtitle text
                          Text(
                            slide.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              color: Colors.grey[600],
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Control Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Slide Indicators
                    Row(
                      children: List.generate(_slides.length, (index) {
                        final isSelected = index == _currentIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.only(left: 6.w),
                          width: isSelected ? 24.w : 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryColor : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        );
                      }),
                    ),

                    // Next / Action Button
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: const Color(0xFF1A1A1A),
                          padding: EdgeInsets.symmetric(
                            horizontal: _currentIndex == _slides.length - 1 ? 32.w : 24.w,
                            vertical: 14.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (_currentIndex < _slides.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 450),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _completeOnboarding();
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentIndex == _slides.length - 1 ? 'ابدأ الآن' : 'التالي',
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const WidthSpace(6),
                            Icon(
                              _currentIndex == _slides.length - 1
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 16.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingModel {
  final String image;
  final String title;
  final String subtitle;

  OnboardingModel({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}
