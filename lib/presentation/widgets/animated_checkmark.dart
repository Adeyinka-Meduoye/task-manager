import 'package:flutter/material.dart';
import 'package:task_manager/core/constants/app_colors.dart';

class AnimatedCheckmark extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback onTap;

  const AnimatedCheckmark({
    super.key,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary),
          color: isCompleted ? AppColors.primary : Colors.transparent,
        ),
        child: isCompleted
            ? const Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}