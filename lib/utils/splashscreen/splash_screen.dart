import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/widgets/gradient_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _showLogos = false;

  final List<String> _logoPaths = [
    "assets/images/login_image_1.png",
    "assets/images/konkrete_klinkers.png",
    "assets/images/iron_smith.png",
    "assets/images/falcon.png",
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _startAnimation();
    _navigateAfterDelay();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );
  }

  void _startAnimation() {
    _controller.forward();

    // Show logos after initial animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showLogos = true;
        });
      }
    });
  }

  Future<void> _navigateAfterDelay() async {
    try {
      await Future.delayed(const Duration(seconds: 5));

      if (!mounted) return;

      SharedPreferences pref = await SharedPreferences.getInstance();
      bool? isLogedIn = pref.getBool("isLogedIn");
      print("IsLogedIn: $isLogedIn");

      if (mounted) {
        if (isLogedIn == true) {
          context.go(RouteNames.homeScreen);
        } else {
          context.go(RouteNames.login);
        }
      }
    } catch (e) {
      print("Navigation error: $e");
      if (mounted) {
        context.go(RouteNames.login);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildLogo(String imagePath, {bool isMainLogo = false}) {
    return Container(
      height: isMainLogo ? 160 : 120,
      width: isMainLogo ? 160 : 120,
      margin: EdgeInsets.all(isMainLogo ? 20 : 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMainLogo ? 15 : 12),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.image_not_supported,
              color: Colors.grey[400],
              size: isMainLogo ? 70 : 50,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Main logo
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: _buildLogo(_logoPaths[0], isMainLogo: true),
                    ),
                  ),
                  const SizedBox(height: 30),
                  AnimatedOpacity(
                    opacity: _showLogos ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 800),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      transform: Matrix4.translationValues(
                        0,
                        _showLogos ? 0 : 50,
                        0,
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (int i = 1; i < _logoPaths.length; i++)
                            _buildLogo(_logoPaths[i]),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Loading indicator
                  Opacity(
                    opacity: _fadeAnimation.value,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: GradientLoader(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
