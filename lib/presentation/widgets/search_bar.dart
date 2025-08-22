import 'package:flutter/material.dart';
import 'package:task_manager/core/constants/app_colors.dart';
import 'package:task_manager/core/constants/app_strings.dart';
import 'package:task_manager/core/constants/app_sizes.dart';

class CustomSearchBar extends StatelessWidget {
  final Function(String) onQueryChanged;

  const CustomSearchBar({super.key, required this.onQueryChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: TextField(
        decoration: InputDecoration(
          hintText: AppStrings.searchHint,
          prefixIcon: Icon(Icons.search, size: AppSizes.iconSizeMedium),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        onChanged: onQueryChanged,
      ),
    );
  }
}