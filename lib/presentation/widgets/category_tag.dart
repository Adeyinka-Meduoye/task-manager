import 'package:flutter/material.dart';
import 'package:task_manager/core/constants/app_colors.dart';
import 'package:task_manager/core/constants/app_strings.dart';
import 'package:task_manager/data/models/category_model.dart';

class CategoryTag extends StatelessWidget {
  final CategoryModel? category;

  const CategoryTag({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(category?.name ?? AppStrings.noCategory),
      backgroundColor: category?.color != null
          ? Color(int.parse(category!.color.replaceFirst('#', '0xFF')))
          : AppColors.secondary,
    );
  }
}