import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dashboard_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Task> allTasks = [];

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime _currentMonth = DateTime.now();

  List<Task> get _tasksForMonth {
    return allTasks.where((task) {
      final taskDate = task.singleDate ?? task.startDate;
      if (taskDate == null) return false;
      return taskDate.year == _currentMonth.year &&
          taskDate.month == _currentMonth.month;
    }).toList();
  }

  int get _totalInMonth => _tasksForMonth.length;
  int get _doneInMonth => _tasksForMonth.where((t) => t.isDone).length;
  double get _completionRate =>
      _totalInMonth == 0 ? 0 : (_doneInMonth / _totalInMonth) * 100;

  // Simple data for Area Chart (completion per day of month)
  List<FlSpot> get _areaChartData {
    final List<FlSpot> spots = [];
    final daysInMonth =
        DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final tasksOnDay = _tasksForMonth.where((t) {
        final tDate = t.singleDate ?? t.startDate;
        return tDate != null && isSameDay(tDate, date);
      }).toList();

      final doneOnDay = tasksOnDay.where((t) => t.isDone).length;
      final rate =
          tasksOnDay.isEmpty ? 0.0 : (doneOnDay / tasksOnDay.length) * 100;

      spots.add(FlSpot(day.toDouble(), rate));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    if (allTasks.isEmpty) {
      allTasks = _getSampleTasks();
    }

    final monthName = DateFormat('MMMM yyyy').format(_currentMonth);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          // ← This fixes the overflow
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
              Text(
                'Track your monthly progress',
                style: TextStyle(fontSize: 13, color: Colors.white38),
              ),
              const SizedBox(height: 24),

              // Calendar
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

              // Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('Total', _totalInMonth.toString()),
                    _buildStat('Completed', _doneInMonth.toString()),
                    _buildStat(
                        'Rate', '${_completionRate.toStringAsFixed(0)}%'),
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

              // Area Chart
              Container(
                height: 280,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _totalInMonth > 0
                    ? LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  if (value % 5 == 0 || value == 1) {
                                    return Text(
                                      '${value.toInt()}',
                                      style: const TextStyle(
                                          color: Colors.white54, fontSize: 10),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _areaChartData,
                              isCurved: true,
                              color: const Color(0xFF00E676),
                              barWidth: 4,
                              isStrokeCapRound: true,
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(0xFF00E676).withOpacity(0.2),
                              ),
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                        ),
                      )
                    : const Center(
                        child: Text(
                          'Add some tasks to see progress chart',
                          style: TextStyle(color: Colors.white38),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),

              const SizedBox(height: 32),

              // Activities List
              const Text(
                'Activities this month',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              _tasksForMonth.isEmpty
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
                      itemCount: _tasksForMonth.length,
                      itemBuilder: (context, index) {
                        final task = _tasksForMonth[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161616),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: task.color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.name,
                                      style: TextStyle(
                                        color: task.isDone
                                            ? Colors.white54
                                            : Colors.white,
                                        fontWeight: FontWeight.w600,
                                        decoration: task.isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    if (task.description.isNotEmpty)
                                      Text(
                                        task.description,
                                        style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 13,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                task.isDone ? '✓ Done' : 'Pending',
                                style: TextStyle(
                                  color: task.isDone
                                      ? const Color(0xFF00E676)
                                      : Colors.white54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ],
          ),
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

  // Sample tasks for testing
  List<Task> _getSampleTasks() {
    final now = DateTime.now();
    return [
      Task(
          name: "Morning Run",
          description: "5km",
          singleDate: DateTime(now.year, now.month, 5),
          isDuration: false,
          color: const Color(0xFF00E676),
          isDone: true),
      Task(
          name: "Read 20 pages",
          description: "",
          singleDate: DateTime(now.year, now.month, 12),
          isDuration: false,
          color: const Color(0xFF448AFF),
          isDone: true),
      Task(
          name: "No Sugar Day",
          description: "Avoid sweets",
          singleDate: DateTime(now.year, now.month, 18),
          isDuration: false,
          color: const Color(0xFFFF5252),
          isDone: false),
      Task(
          name: "Meditation",
          description: "10 min",
          singleDate: DateTime(now.year, now.month, 22),
          isDuration: false,
          color: const Color(0xFFFFD740),
          isDone: true),
      Task(
          name: "Drink 3L Water",
          description: "",
          singleDate: DateTime(now.year, now.month, 23),
          isDuration: false,
          color: const Color(0xFF00E5FF),
          isDone: true),
    ];
  }
}
