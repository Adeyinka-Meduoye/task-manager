import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:task_manager/core/constants/app_colors.dart';
import 'package:task_manager/data/models/task_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/domain/providers/task_provider.dart';

class StatisticsViewModel {
  int getTotalTasks(List<TaskModel> tasks) => tasks.length;

  int getCompletedTasks(List<TaskModel> tasks) =>
      tasks.where((task) => task.isCompleted).length;

  int getIncompleteTasks(List<TaskModel> tasks) =>
      tasks.where((task) => !task.isCompleted).length;

  Map<TaskPriority, int> getTasksByPriority(List<TaskModel> tasks) {
    return {
      TaskPriority.low: tasks.where((task) => task.priority == TaskPriority.low).length,
      TaskPriority.medium: tasks.where((task) => task.priority == TaskPriority.medium).length,
      TaskPriority.high: tasks.where((task) => task.priority == TaskPriority.high).length,
    };
  }

  Widget getCompletionChart() {
    return Consumer(builder: (context, ref, child) {
      final tasks = ref.watch(taskListProvider).valueOrNull ?? [];
      final completed = getCompletedTasks(tasks);
      final incomplete = getIncompleteTasks(tasks);

      return PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: completed.toDouble(),
              color: AppColors.primary,
              title: 'Completed',
              radius: 50,
            ),
            PieChartSectionData(
              value: incomplete.toDouble(),
              color: AppColors.secondary,
              title: 'Incomplete',
              radius: 50,
            ),
          ],
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      );
    });
  }

  Widget getPriorityChart() {
    return Consumer(builder: (context, ref, child) {
      final tasks = ref.watch(taskListProvider).valueOrNull ?? [];
      final priorityCounts = getTasksByPriority(tasks);

      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: priorityCounts[TaskPriority.low]?.toDouble() ?? 0,
                  color: Colors.green,
                  width: 20,
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: priorityCounts[TaskPriority.medium]?.toDouble() ?? 0,
                  color: Colors.orange,
                  width: 20,
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: priorityCounts[TaskPriority.high]?.toDouble() ?? 0,
                  color: Colors.red,
                  width: 20,
                ),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text('Low');
                    case 1:
                      return const Text('Medium');
                    case 2:
                      return const Text('High');
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
        ),
      );
    });
  }
}

final statisticsViewModelProvider = Provider<StatisticsViewModel>((ref) => StatisticsViewModel());