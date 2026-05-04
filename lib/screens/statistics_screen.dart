import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../services/task_service.dart';

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
    final monthName = DateFormat('MMMM yyyy').format(_currentMonth);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
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
                  const Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Track your monthly progress',
                    style: TextStyle(fontSize: 13, color: Colors.white38),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
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
                      calendarStyle: const CalendarStyle(
                        defaultTextStyle: TextStyle(color: Colors.white),
                        weekendTextStyle: TextStyle(color: Colors.white70),
                        selectedTextStyle: TextStyle(color: Colors.black),
                        todayTextStyle: TextStyle(color: Colors.white),
                        selectedDecoration: BoxDecoration(
                          color: Color(0xFF00E676),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Color(0xFF00E676),
                          shape: BoxShape.circle,
                        ),
                        outsideDaysVisible: false,
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        leftChevronIcon:
                            Icon(Icons.chevron_left, color: Colors.white54),
                        rightChevronIcon:
                            Icon(Icons.chevron_right, color: Colors.white54),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('Total', '$total'),
                        _buildStat('Completed', '$done'),
                        _buildStat('Rate', '${rate.toStringAsFixed(0)}%'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    '$monthName Progress',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: total == 0
                        ? const SizedBox(
                            height: 120,
                            child: Center(
                              child: Text(
                                'Add tasks to see your breakdown',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 14),
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

                  const Text(
                    'Activities this month',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
                                color: const Color(0xFF161616),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.name,
                                          style: TextStyle(
                                            color: task.isDone
                                                ? Colors.white38
                                                : Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            decoration: task.isDone
                                                ? TextDecoration.lineThrough
                                                : null,
                                            decorationColor: Colors.white38,
                                          ),
                                        ),
                                        if (task.description.isNotEmpty)
                                          Text(
                                            task.description,
                                            style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: task.isDone
                                          ? const Color(0xFF00E676)
                                              .withOpacity(0.12)
                                          : Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      task.isDone ? 'Done' : 'Pending',
                                      style: TextStyle(
                                        color: task.isDone
                                            ? const Color(0xFF00E676)
                                            : Colors.white38,
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

  Widget _buildStat(String label, String value) => Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
        ],
      );
}
