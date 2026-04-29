import 'package:core/widgets/custom_app_loader.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:core/constants/app_colors.dart';

class AppRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final double displacement;
  final double loaderOffset;

  const AppRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.displacement = 100.0,
    this.loaderOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      onRefresh: onRefresh,
      offsetToArmed: displacement,
      builder:
          (BuildContext context, Widget child, IndicatorController controller) {
        return Stack(
          children: <Widget>[
            // The content remains static, providing a more stable feel
            child,

            // Loader appears on top and slides down slightly during the pull
            AnimatedBuilder(
              animation: controller,
              builder: (BuildContext context, Widget? _) {
                final double value = controller.value.clamp(0.0, 1.5);
                if (value <= 0) return const SizedBox.shrink();

                // Calculate a smooth slide-down position for the bubble
                final double topPosition = (displacement * value) / 3;

                return Positioned(
                  top: topPosition,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Transform.scale(
                      scale: value.clamp(0.0, 1.0),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.1),
                              blurRadius: 12,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const CustomAppLoader(size: 30),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
      child: child,
    );
  }
}










