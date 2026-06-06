import 'package:live_order/core/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/features/onboarding/widget/get_started_button.dart';
import 'package:live_order/features/onboarding/widget/onboarding_page.dart';
import 'package:live_order/features/onboarding/widget/page_indicator.dart';

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
      final user = SupabaseService.instance.client.auth.currentUser;
      if (user != null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
        }
      } else {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
        }
      }
    }

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
      Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
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
        backgroundColor: const Color(0xFFF5F5F0),
        body: SafeArea(
          child: Column(
            children: [
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
                    return OnboardingPage(slide: slide);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PageIndicator(
                      itemCount: _slides.length,
                      currentIndex: _currentIndex,
                    ),
                    GetStartedButton(
                      isLastPage: _currentIndex == _slides.length - 1,
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
