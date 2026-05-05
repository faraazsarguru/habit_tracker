import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../services/theme_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String get _userId => FirebaseAuth.instance.currentUser!.uid;
  int _streak = 0;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final streak = await TaskService.calculateStreak(_userId);
    if (mounted) setState(() => _streak = streak);
  }

  Future<void> _openAddTaskDialog() {
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => AddTaskDialog(userId: _userId),
    );
  }

  Future<void> _openEditTaskDialog(Task task) {
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => EditTaskDialog(userId: _userId, task: task),
    );
  }

  List<Task> _filterTasks(List<Task> tasks) {
    if (_selectedFilter == 'all') return tasks;
    return tasks.where((t) => t.priority == _selectedFilter).toList();
  }

  Widget _buildFilterTabs(bool isDark, Color textSecondary) {
    final filters = const ['all', 'high', 'medium', 'low'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f;
          final label = f == 'all' ? 'All' : Task(priority: f, name: '', isDuration: true, createdAt: DateTime.now(), userId: '').priorityLabel;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF00E676) : (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF0A0A0A) : textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning ☀️';
    if (h < 17) return 'Good afternoon ☀️';
    return 'Good evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final isDark = themeService.isDarkMode;

    final bg = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5);
    final textPrimary = isDark ? Colors.white : const Color(0xFF121212);
    final textSecondary = isDark ? const Color(0xFF888888) : const Color(0xFF666666);
    final emptyBg = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_greeting(),
                          style: TextStyle(color: textSecondary, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text('Habitzzz',
                          style: TextStyle(
                              color: textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            StreamBuilder<QuerySnapshot>(
              stream: TaskService.streamTasks(_userId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading tasks'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
                      ),
                    ),
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                final tasks = docs
                    .map((d) =>
                        Task.fromMap(d.data() as Map<String, dynamic>, d.id))
                    .toList();
                final filteredTasks = _filterTasks(tasks);
                final doneCount = tasks.where((t) => t.isDone).length;

                return Expanded(
                  child: OrientationBuilder(
                    builder: (context, orientation) {
                      final isLandscape = orientation == Orientation.landscape;
                        return isLandscape
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 340,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(24, 0, 12, 0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _statsCard(tasks, doneCount, _streak),
                                          const SizedBox(height: 16),
                                          _buildFilterTabs(isDark, textSecondary),
                                        ],
                                      ),
                                    ),
                                  ),
                                    Expanded(
                                    child: filteredTasks.isEmpty
                                        ? _emptyState(
                                            emptyBg: emptyBg,
                                            textPrimary: textPrimary,
                                            textSecondary: textSecondary)
                                        : ListView.builder(
                                            padding: const EdgeInsets.fromLTRB(12, 0, 24, 0),
                                            itemCount: filteredTasks.length,
                                            itemBuilder: (ctx, i) => _TaskCard(
                                              task: filteredTasks[i],
                                              isDark: isDark,
                                              onToggle: () {
                                                TaskService.toggleDone(
                                                  userId: _userId,
                                                  taskId: filteredTasks[i].id!,
                                                  isDone: filteredTasks[i].isDone,
                                                );
                                                _loadStreak();
                                              },
                                              onDelete: () {
                                                TaskService.deleteTask(
                                                  userId: _userId,
                                                  taskId: filteredTasks[i].id!,
                                                );
                                                _loadStreak();
                                              },
                                              onEdit: () => _openEditTaskDialog(filteredTasks[i]),
                                            ),
                                          ),
                                  ),
                                ],
                              )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: _statsCard(tasks, doneCount, _streak),
                                ),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: _buildFilterTabs(isDark, textSecondary),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: filteredTasks.isEmpty
                                      ? _emptyState(
                                          emptyBg: emptyBg,
                                          textPrimary: textPrimary,
                                          textSecondary: textSecondary)
                                      : ListView.builder(
                                          padding: const EdgeInsets.symmetric(horizontal: 24),
                                          itemCount: filteredTasks.length,
                                          itemBuilder: (ctx, i) => _TaskCard(
                                            task: filteredTasks[i],
                                            isDark: isDark,
                                            onToggle: () {
                                              TaskService.toggleDone(
                                                userId: _userId,
                                                taskId: filteredTasks[i].id!,
                                                isDone: filteredTasks[i].isDone,
                                              );
                                              _loadStreak();
                                            },
                                            onDelete: () {
                                              TaskService.deleteTask(
                                                userId: _userId,
                                                taskId: filteredTasks[i].id!,
                                              );
                                              _loadStreak();
                                            },
                                            onEdit: () => _openEditTaskDialog(filteredTasks[i]),
                                          ),
                                        ),
                                ),
                              ],
                            );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTaskDialog,
        backgroundColor: const Color(0xFF00E676),
        foregroundColor: const Color(0xFF0A0A0A),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, size: 30),
      ),
    );
  }

  Widget _statsCard(List<Task> tasks, int doneCount, int streak) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF00E676), Color(0xFF00BFA5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _stat('Total', '${tasks.length}'),
            _vDivider(),
            _stat('Done', '$doneCount'),
            _vDivider(),
            _stat('Streak', '$streak 🔥'),
          ],
        ),
      );

  Widget _stat(String label, String value) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Color(0xFF0A0A0A),
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF0A3D1A),
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      );

  Widget _vDivider() => Container(
      width: 1, height: 36, color: const Color(0xFF0A3D1A).withOpacity(0.4));

  Widget _emptyState({required Color emptyBg, required Color textPrimary, required Color textSecondary}) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: emptyBg,
                  borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.add_task_rounded,
                  size: 40, color: Color(0xFF00E676)),
            ),
            const SizedBox(height: 20),
            Text('No tasks yet',
                style: TextStyle(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Tap + to add your first habit',
                style: TextStyle(color: textSecondary, fontSize: 14)),
          ],
        ),
      );
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final bool isDark;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  const _TaskCard(
      {required this.task, required this.isDark, required this.onToggle, required this.onDelete, required this.onEdit});

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : const Color(0xFF121212);
    final textDone = isDark ? const Color(0xFF555555) : const Color(0xFF999999);
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFDDDDDD);

    return GestureDetector(
      onTap: onEdit,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141414) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: task.color.withOpacity(0.25), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                  color: task.color, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.name,
                    style: TextStyle(
                      color: task.isDone ? textDone : textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(task.description,
                        style: const TextStyle(
                            color: Color(0xFF888888), fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 12, color: task.color),
                      const SizedBox(width: 4),
                      Text(
                        task.isDuration
                            ? '${_fmt(task.startDate!)} → ${_fmt(task.endDate!)}'
                            : _fmt(task.singleDate!),
                        style: TextStyle(
                            color: task.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                onToggle();
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color:
                      task.isDone ? const Color(0xFF00E676) : Colors.transparent,
                  border: Border.all(
                    color: task.isDone
                        ? const Color(0xFF00E676)
                        : borderColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: task.isDone
                    ? const Icon(Icons.check_rounded,
                        color: Color(0xFF0A0A0A), size: 18)
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                onDelete();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent, size: 16),
              ),
            ),
        ],
      ),
    ),
    );
  }
}

class AddTaskDialog extends StatefulWidget {
  final String userId;
  const AddTaskDialog({super.key, required this.userId});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isDuration = false;
  DateTime? _singleDate, _startDate, _endDate;
  String _priority = 'medium';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick({required bool isStart}) async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00E676),
            onPrimary: Color(0xFF0A0A0A),
            surface: Color(0xFF1A1A1A),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (d == null) return;
    setState(() {
      if (!_isDuration) {
        _singleDate = d;
      } else if (isStart) {
        _startDate = d;
      } else {
        _endDate = d;
      }
    });
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    if (!_isDuration && _singleDate == null) return;
    if (_isDuration && (_startDate == null || _endDate == null)) return;

    setState(() => _isLoading = true);

    await TaskService.addTask(
      userId: widget.userId,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      singleDate: _isDuration ? null : _singleDate,
      startDate: _isDuration ? _startDate : null,
      endDate: _isDuration ? _endDate : null,
      isDuration: _isDuration,
      priority: _priority,
    );

    if (mounted) Navigator.pop(context);
  }

  String _fmtD(DateTime? d) =>
      d == null ? 'Pick a date' : '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF141414),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('New Task',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: const Color(0xFF222222),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _lbl('Task Name'),
            const SizedBox(height: 8),
            _field(controller: _nameCtrl, hint: 'e.g. Morning Run'),
            const SizedBox(height: 16),
            _lbl('Description'),
            const SizedBox(height: 8),
            _field(
                controller: _descCtrl,
                hint: 'Optional description...',
                maxLines: 3),
            const SizedBox(height: 20),
            _lbl('Date Type'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                _toggleBtn('Single Date', !_isDuration),
                _toggleBtn('Duration', _isDuration),
              ]),
            ),
            const SizedBox(height: 16),
            if (!_isDuration) ...[
              _lbl('Date'),
              const SizedBox(height: 8),
              _dateBtn(_fmtD(_singleDate), () => _pick(isStart: false)),
            ] else ...[
              _lbl('Start Date'),
              const SizedBox(height: 8),
              _dateBtn(_fmtD(_startDate), () => _pick(isStart: true)),
              const SizedBox(height: 12),
              _lbl('End Date'),
              const SizedBox(height: 8),
              _dateBtn(_fmtD(_endDate), () => _pick(isStart: false)),
            ],
            const SizedBox(height: 20),
            _lbl('Priority'),
            const SizedBox(height: 12),
            Row(
              children: [
                _priorityBtn('High', 'high', const Color(0xFFFF5252)),
                const SizedBox(width: 10),
                _priorityBtn('Medium', 'medium', const Color(0xFF448AFF)),
                const SizedBox(width: 10),
                _priorityBtn('Easy', 'low', const Color(0xFFFFD740)),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: const Color(0xFF0A0A0A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A0A0A)),
                        ),
                      )
                    : const Text('Add Task',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priorityBtn(String label, String value, Color color) {
    final sel = _priority == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: sel ? color : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: sel ? color : const Color(0xFF2A2A2A), width: 1),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: sel
                      ? Colors.white
                      : const Color(0xFF888888))),
        ),
      ),
    );
  }

  Widget _lbl(String t) => Text(t,
      style: const TextStyle(
          color: Color(0xFF888888),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5));

  Widget _field({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF444444)),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00E676), width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }

  Widget _dateBtn(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Row(children: [
            const Icon(Icons.calendar_month_rounded,
                color: Color(0xFF00E676), size: 20),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    color: label == 'Pick a date'
                        ? const Color(0xFF444444)
                        : Colors.white,
                    fontSize: 15)),
          ]),
        ),
      );

  Widget _toggleBtn(String label, bool active) => Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _isDuration = label == 'Duration'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active ? const Color(0xFF00E676) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? const Color(0xFF0A0A0A)
                        : const Color(0xFF666666))),
          ),
        ),
      );
}

class EditTaskDialog extends StatefulWidget {
  final String userId;
  final Task task;
  const EditTaskDialog({super.key, required this.userId, required this.task});

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late bool _isDuration;
  DateTime? _singleDate, _startDate, _endDate;
  late String _priority;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.task.name);
    _descCtrl = TextEditingController(text: widget.task.description);
    _isDuration = widget.task.isDuration;
    _singleDate = widget.task.singleDate;
    _startDate = widget.task.startDate;
    _endDate = widget.task.endDate;
    _priority = widget.task.priority;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick({required bool isStart}) async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00E676),
            onPrimary: Color(0xFF0A0A0A),
            surface: Color(0xFF1A1A1A),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (d == null) return;
    setState(() {
      if (!_isDuration) {
        _singleDate = d;
      } else if (isStart) {
        _startDate = d;
      } else {
        _endDate = d;
      }
    });
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    if (!_isDuration && _singleDate == null) return;
    if (_isDuration && (_startDate == null || _endDate == null)) return;

    setState(() => _isLoading = true);

    await TaskService.updateTask(
      userId: widget.userId,
      taskId: widget.task.id!,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      singleDate: _isDuration ? null : _singleDate,
      startDate: _isDuration ? _startDate : null,
      endDate: _isDuration ? _endDate : null,
      isDuration: _isDuration,
      priority: _priority,
    );

    if (mounted) Navigator.pop(context);
  }

  String _fmtD(DateTime? d) =>
      d == null ? 'Pick a date' : '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF141414),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Edit Task',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: const Color(0xFF222222),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _lbl('Task Name'),
            const SizedBox(height: 8),
            _field(controller: _nameCtrl, hint: 'e.g. Morning Run'),
            const SizedBox(height: 16),
            _lbl('Description'),
            const SizedBox(height: 8),
            _field(
                controller: _descCtrl,
                hint: 'Optional description...',
                maxLines: 3),
            const SizedBox(height: 20),
            _lbl('Date Type'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                _toggleBtn('Single Date', !_isDuration),
                _toggleBtn('Duration', _isDuration),
              ]),
            ),
            const SizedBox(height: 16),
            if (!_isDuration) ...[
              _lbl('Date'),
              const SizedBox(height: 8),
              _dateBtn(_fmtD(_singleDate), () => _pick(isStart: false)),
            ] else ...[
              _lbl('Start Date'),
              const SizedBox(height: 8),
              _dateBtn(_fmtD(_startDate), () => _pick(isStart: true)),
              const SizedBox(height: 12),
              _lbl('End Date'),
              const SizedBox(height: 8),
              _dateBtn(_fmtD(_endDate), () => _pick(isStart: false)),
            ],
            const SizedBox(height: 20),
            _lbl('Priority'),
            const SizedBox(height: 12),
            Row(
              children: [
                _priorityBtn('High', 'high', const Color(0xFFFF5252)),
                const SizedBox(width: 10),
                _priorityBtn('Medium', 'medium', const Color(0xFF448AFF)),
                const SizedBox(width: 10),
                _priorityBtn('Easy', 'low', const Color(0xFFFFD740)),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: const Color(0xFF0A0A0A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A0A0A)),
                        ),
                      )
                    : const Text('Save Changes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priorityBtn(String label, String value, Color color) {
    final sel = _priority == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: sel ? color : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: sel ? color : const Color(0xFF2A2A2A), width: 1),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: sel
                      ? Colors.white
                      : const Color(0xFF888888))),
        ),
      ),
    );
  }

  Widget _lbl(String t) => Text(t,
      style: const TextStyle(
          color: Color(0xFF888888),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5));

  Widget _field({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF444444)),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00E676), width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }

  Widget _dateBtn(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Row(children: [
            const Icon(Icons.calendar_month_rounded,
                color: Color(0xFF00E676), size: 20),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    color: label == 'Pick a date'
                        ? const Color(0xFF444444)
                        : Colors.white,
                    fontSize: 15)),
          ]),
        ),
      );

  Widget _toggleBtn(String label, bool active) => Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _isDuration = label == 'Duration'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active ? const Color(0xFF00E676) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? const Color(0xFF0A0A0A)
                        : const Color(0xFF666666))),
          ),
        ),
      );
}
