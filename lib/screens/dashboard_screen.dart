import 'package:flutter/material.dart';

// Task model
class Task {
  final String name;
  final String description;
  final DateTime? singleDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isDuration;
  final Color color;
  bool isDone;

  Task({
    required this.name,
    required this.description,
    this.singleDate,
    this.startDate,
    this.endDate,
    required this.isDuration,
    required this.color,
    this.isDone = false,
  });
}

const List<Color> kTaskColors = [
  Color(0xFF00E676),
  Color(0xFFFF5252),
  Color(0xFF448AFF),
  Color(0xFFFFD740),
  Color(0xFFFF6D00),
  Color(0xFFE040FB),
  Color(0xFF00E5FF),
];

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Task> _tasks = [];

  int get _doneCount => _tasks.where((t) => t.isDone).length;

  void _openAddTaskDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => AddTaskDialog(
        onTaskAdded: (task) => setState(() => _tasks.add(task)),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning ☀️';
    if (h < 17) return 'Good afternoon 🌤';
    return 'Good evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_greeting(),
                          style: const TextStyle(
                              color: Color(0xFF888888), fontSize: 14)),
                      const SizedBox(height: 2),
                      const Text('Habitzzz',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5)),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.notifications_outlined,
                        color: Colors.white, size: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Summary card ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
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
                    _stat('Total', '${_tasks.length}'),
                    _vDivider(),
                    _stat('Done', '$_doneCount'),
                    _vDivider(),
                    _stat('Streak', '0 🔥'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Tasks header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('My Tasks',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  Text('${_tasks.length} tasks',
                      style: const TextStyle(
                          color: Color(0xFF888888), fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Task list ──
            Expanded(
              child: _tasks.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _tasks.length,
                      itemBuilder: (ctx, i) => _TaskCard(
                        task: _tasks[i],
                        onToggle: () => setState(
                            () => _tasks[i].isDone = !_tasks[i].isDone),
                      ),
                    ),
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

  Widget _emptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.add_task_rounded,
                  size: 40, color: Color(0xFF00E676)),
            ),
            const SizedBox(height: 20),
            const Text('No tasks yet',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Tap + to add your first habit',
                style: TextStyle(color: Color(0xFF666666), fontSize: 14)),
          ],
        ),
      );
}

// ── Task Card ──────────────────────────────────────────────────────────────
class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  const _TaskCard({required this.task, required this.onToggle});

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
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
                    color: task.isDone ? const Color(0xFF555555) : Colors.white,
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
            onTap: onToggle,
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
                      : const Color(0xFF333333),
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
        ],
      ),
    );
  }
}

// ── Add Task Dialog ────────────────────────────────────────────────────────
class AddTaskDialog extends StatefulWidget {
  final Function(Task) onTaskAdded;
  const AddTaskDialog({super.key, required this.onTaskAdded});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isDuration = false;
  DateTime? _singleDate, _startDate, _endDate;
  Color _selectedColor = kTaskColors[0];

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

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) return;
    if (!_isDuration && _singleDate == null) return;
    if (_isDuration && (_startDate == null || _endDate == null)) return;

    widget.onTaskAdded(Task(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      singleDate: _isDuration ? null : _singleDate,
      startDate: _isDuration ? _startDate : null,
      endDate: _isDuration ? _endDate : null,
      isDuration: _isDuration,
      color: _selectedColor,
    ));
    Navigator.pop(context);
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
            // Title row
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

            // Task Name
            _lbl('Task Name'),
            const SizedBox(height: 8),
            _field(controller: _nameCtrl, hint: 'e.g. Morning Run'),
            const SizedBox(height: 16),

            // Description
            _lbl('Description'),
            const SizedBox(height: 8),
            _field(
                controller: _descCtrl,
                hint: 'Optional description...',
                maxLines: 3),
            const SizedBox(height: 20),

            // Date type toggle
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

            // Date pickers
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

            // Task Color
            _lbl('Task Color'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: kTaskColors.map((c) {
                final sel = _selectedColor == c;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: sel
                          ? Border.all(color: Colors.white, width: 2.5)
                          : null,
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                  color: c.withOpacity(0.6), blurRadius: 10)
                            ]
                          : null,
                    ),
                    child: sel
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Add button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: const Color(0xFF0A0A0A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Add Task',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
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
