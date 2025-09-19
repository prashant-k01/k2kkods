import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k2k/utils/theme.dart';

class AnimatedProgressBar extends StatelessWidget {
  final double progress; // from 0.0 to 1.0

  const AnimatedProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: progress.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Background track with neumorphic style
              Container(
                height: 20.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: Colors.grey.shade200.withOpacity(0.6),
                  border: Border.all(
                    color: Colors.purple.shade100.withOpacity(0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      spreadRadius: 1,
                      offset: const Offset(2, 2),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 6,
                      spreadRadius: 1,
                      offset: const Offset(-2, -2),
                    ),
                  ],
                ),
              ),
              // Foreground progress with animated gradient and pulse
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 20.h,
                width: MediaQuery.of(context).size.width * value,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  gradient: LinearGradient(
                    colors: value < 0.3
                        ? [
                            Colors.purple.shade200.withOpacity(0.7),
                            Colors.purple.shade300.withOpacity(0.9),
                          ]
                        : value < 0.7
                        ? [
                            Colors.purple.shade300,
                            Colors.purple.shade500,
                            Colors.blue.shade300,
                          ]
                        : [
                            Colors.purple.shade400,
                            Colors.blue.shade300,
                            Colors.purple.shade600,
                          ],
                    stops: value < 0.3 ? [0.0, 1.0] : [0.0, 0.5, 1.0],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.shade300.withOpacity(0.5),
                      blurRadius: value == 1.0 ? 16 : 8,
                      spreadRadius: value == 1.0 ? 4 : 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                // Shimmer effect for progress
                child: value > 0
                    ? ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.3),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          tileMode: TileMode.mirror,
                        ).createShader(bounds),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
              // Animated percentage text with bounce effect on completion
              Positioned.fill(
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: value * 100),
                    duration: const Duration(milliseconds: 800),
                    curve: value == 1.0 ? Curves.elasticOut : Curves.easeOut,
                    builder: (context, textValue, child) {
                      return Text(
                        '${textValue.toInt()}%',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.8),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
