import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../services/theme_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime _currentMonth = DateTime.now();

  List<Task> _parseTasks(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((d) => Task.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  List<Task> _tasksForMonth(List<Task> allTasks) {
    return allTasks.where((task) {
      final taskDate = task.singleDate ?? task.startDate;
      if (taskDate == null) return false;
      return taskDate.year == _currentMonth.year &&
          taskDate.month == _currentMonth.month;
    }).toList();
  }

  int _totalInMonth(List<Task> tasks) => tasks.length;
  int _doneInMonth(List<Task> tasks) => tasks.where((t) => t.isDone).length;
  double _completionRate(List<Task> tasks) {
    final total = tasks.length;
    return total == 0 ? 0 : (_doneInMonth(tasks) / total) * 100;
  }

  List<PieChartSectionData> _pieChartSections(List<Task> tasks) {
    if (tasks.isEmpty) return [];
    return tasks.map((t) {
      return PieChartSectionData(
        value: 1,
        color: t.color,
        radius: 80,
        title: '',
        showTitle: false,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final isDark = themeService.isDarkMode;

    final bg = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5);
    final cardBg = isDark ? const Color(0xFF141414) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF121212);
    final textSecondary = isDark ? Colors.white38 : const Color(0xFF888888);
    final textTertiary = isDark ? Colors.white54 : const Color(0xFF666666);
    final listBg = isDark ? const Color(0xFF161616) : Colors.white;

    final monthName = DateFormat('MMMM yyyy').format(_currentMonth);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: TaskService.streamTasks(_userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
                ),
              );
            }
            final allTasks = snapshot.hasData
                ? _parseTasks(snapshot.data!)
                : <Task>[];
            final tasksForMonth = _tasksForMonth(allTasks);
            final total = _totalInMonth(tasksForMonth);
            final done = _doneInMonth(tasksForMonth);
            final rate = _completionRate(tasksForMonth);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track your monthly progress',
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: TableCalendar(
                      firstDay: DateTime(2020),
                      lastDay: DateTime(2030),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      calendarFormat: CalendarFormat.month,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                          _currentMonth = focusedDay;
                        });
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        defaultTextStyle: TextStyle(color: textPrimary),
                        weekendTextStyle: TextStyle(color: textTertiary),
                        selectedTextStyle: const TextStyle(color: Colors.black),
                        todayTextStyle: TextStyle(color: isDark ? Colors.white : const Color(0xFF121212)),
                        selectedDecoration: const BoxDecoration(
                          color: Color(0xFF00E676),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: const BoxDecoration(
                          color: Color(0xFF00E676),
                          shape: BoxShape.circle,
                        ),
                        outsideDaysVisible: false,
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                        leftChevronIcon: Icon(Icons.chevron_left, color: textTertiary),
                        rightChevronIcon: Icon(Icons.chevron_right, color: textTertiary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('Total', '$total', textPrimary, textSecondary),
                        _buildStat('Completed', '$done', textPrimary, textSecondary),
                        _buildStat('Rate', '${rate.toStringAsFixed(0)}%', textPrimary, textSecondary),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    '$monthName Progress',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: total == 0
                        ? SizedBox(
                            height: 120,
                            child: Center(
                              child: Text(
                                'Add tasks to see your breakdown',
                                style: TextStyle(color: textSecondary, fontSize: 14),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 220,
                            child: PieChart(
                              PieChartData(
                                sections: _pieChartSections(tasksForMonth),
                                centerSpaceRadius: 0,
                                sectionsSpace: 3,
                                startDegreeOffset: -90,
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Activities this month',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  tasksForMonth.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              'No activities recorded yet',
                              style: TextStyle(color: Colors.white38),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tasksForMonth.length,
                          itemBuilder: (context, index) {
                            final task = tasksForMonth[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: listBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border(
                                  left: BorderSide(color: task.color, width: 3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: task.color.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      task.isDone
                                          ? Icons.check_circle_rounded
                                          : Icons.radio_button_unchecked_rounded,
                                      color: task.color,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.name,
                                          style: TextStyle(
                                            color: task.isDone ? textSecondary : textPrimary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            decoration: task.isDone ? TextDecoration.lineThrough : null,
                                            decorationColor: textSecondary,
                                          ),
                                        ),
                                        if (task.description.isNotEmpty)
                                          Text(
                                            task.description,
                                            style: TextStyle(color: textSecondary, fontSize: 12),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: task.isDone
                                          ? const Color(0xFF00E676).withOpacity(0.12)
                                          : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE0E0E0)),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      task.isDone ? 'Done' : 'Pending',
                                      style: TextStyle(
                                        color: task.isDone ? const Color(0xFF00E676) : textSecondary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color textPrimary, Color textSecondary) => Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      );
}
