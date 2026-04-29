import 'package:core/constants/app_colors.dart';
import 'package:core/constants/app_images.dart';
import 'package:flutter/material.dart';

class CustomAppLoader extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const CustomAppLoader({
    super.key,
    this.size = 50.0,
    this.strokeWidth = 1.5,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: Image.asset(
              AppImages.appLogo,
              width: size * 0.8,
              height: size * 0.8,
              fit: BoxFit.cover,
            ),
          ),

          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              color: color ?? AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}










