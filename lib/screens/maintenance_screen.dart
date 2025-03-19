import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/maintenance_provider.dart';
import '../models/maintenance_schedule.dart';

class MaintenanceScreen extends StatefulWidget {
  final int vehicleId;

  const MaintenanceScreen({Key? key, required this.vehicleId})
      : super(key: key);

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaintenanceProvider>().loadSchedules(widget.vehicleId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('유지보수 일정'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '진행중'),
            Tab(text: '완료'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScheduleList(context, false),
          _buildScheduleList(context, true),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddScheduleDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildScheduleList(BuildContext context, bool completed) {
    return Consumer<MaintenanceProvider>(
      builder: (context, provider, child) {
        final schedules =
            completed ? provider.completedSchedules : provider.activeSchedules;

        if (schedules.isEmpty) {
          return Center(
            child: Text(
              completed ? '완료된 일정이 없습니다.' : '예정된 일정이 없습니다.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        return ListView.builder(
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            return _buildScheduleCard(context, schedule);
          },
        );
      },
    );
  }

  Widget _buildScheduleCard(
      BuildContext context, MaintenanceSchedule schedule) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(schedule.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (schedule.description != null) Text(schedule.description!),
            const SizedBox(height: 4),
            Row(
              children: [
                if (schedule.dueDate != null) ...[
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(_dateFormat.format(schedule.dueDate!)),
                  const SizedBox(width: 16),
                ],
                if (schedule.dueMileage != null) ...[
                  const Icon(Icons.speed, size: 16),
                  const SizedBox(width: 4),
                  Text('${schedule.dueMileage}km'),
                ],
              ],
            ),
          ],
        ),
        trailing: schedule.isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : IconButton(
                icon: const Icon(Icons.check),
                onPressed: () => _showCompleteDialog(context, schedule),
              ),
        onTap: () => _showEditDialog(context, schedule),
        onLongPress: () => _showDeleteDialog(context, schedule),
      ),
    );
  }

  Future<void> _showAddScheduleDialog(BuildContext context) async {
    String title = '';
    String? description;
    DateTime? dueDate;
    int? dueMileage;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 유지보수 일정'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: '제목'),
                onChanged: (value) => title = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: '설명'),
                onChanged: (value) => description = value,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (date != null) {
                          dueDate = date;
                        }
                      },
                      child: const Text('날짜 선택'),
                    ),
                  ),
                ],
              ),
              TextField(
                decoration: const InputDecoration(labelText: '목표 주행거리 (km)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => dueMileage = int.tryParse(value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (title.isNotEmpty) {
                context.read<MaintenanceProvider>().addSchedule(
                      MaintenanceSchedule(
                        vehicleId: widget.vehicleId,
                        title: title,
                        description: description,
                        dueDate: dueDate,
                        dueMileage: dueMileage,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(
      BuildContext context, MaintenanceSchedule schedule) async {
    String title = schedule.title;
    String? description = schedule.description;
    DateTime? dueDate = schedule.dueDate;
    int? dueMileage = schedule.dueMileage;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일정 수정'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: '제목'),
                controller: TextEditingController(text: title),
                onChanged: (value) => title = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: '설명'),
                controller: TextEditingController(text: description),
                onChanged: (value) => description = value,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: dueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (date != null) {
                          dueDate = date;
                        }
                      },
                      child: Text(dueDate != null
                          ? _dateFormat.format(dueDate!)
                          : '날짜 선택'),
                    ),
                  ),
                ],
              ),
              TextField(
                decoration: const InputDecoration(labelText: '목표 주행거리 (km)'),
                controller:
                    TextEditingController(text: dueMileage?.toString() ?? ''),
                keyboardType: TextInputType.number,
                onChanged: (value) => dueMileage = int.tryParse(value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (title.isNotEmpty) {
                context.read<MaintenanceProvider>().updateSchedule(
                      schedule.copyWith(
                        title: title,
                        description: description,
                        dueDate: dueDate,
                        dueMileage: dueMileage,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCompleteDialog(
      BuildContext context, MaintenanceSchedule schedule) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일정 완료'),
        content: Text('${schedule.title}을(를) 완료 처리하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              context.read<MaintenanceProvider>().completeSchedule(schedule);
              Navigator.pop(context);
            },
            child: const Text('완료'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(
      BuildContext context, MaintenanceSchedule schedule) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일정 삭제'),
        content: Text('${schedule.title}을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              context.read<MaintenanceProvider>().deleteSchedule(schedule);
              Navigator.pop(context);
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
