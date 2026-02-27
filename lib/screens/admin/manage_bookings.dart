import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service.dart';
import '../../data/models/booking_record.dart';
import '../../data/models/user_role.dart';
import '../../logic/admin_data_state.dart';
import '../../logic/app_state.dart';
import '../../services/audit_log_service.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class ManageBookingsScreen extends StatefulWidget {
  const ManageBookingsScreen({super.key});

  @override
  State<ManageBookingsScreen> createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends State<ManageBookingsScreen> {
  String _workflowLabel(WorkflowStatus status) {
    switch (status) {
      case WorkflowStatus.received:
        return 'تم الاستلام';
      case WorkflowStatus.verified:
        return 'تم التحقق';
      case WorkflowStatus.approved:
        return 'تمت الموافقة';
      case WorkflowStatus.paid:
        return 'تم الدفع';
      case WorkflowStatus.completed:
        return 'مكتمل';
    }
  }

  void _changeStatus(int index, String status) {
    final record = context.read<AppState>().busBookings[index];
    context.read<AppState>().updateBusBookingStatus(record.ticketId, status);
    final actor = context.read<AuthService>().username ?? 'غير معروف';
    context.read<AuditLogService>().log(
          actor: actor,
          action: 'تغيير حالة الحجز',
          targetType: 'booking',
          targetId: record.ticketId,
          details: 'الحالة: $status',
        );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تصدير البيانات')),
    );
  }

  Future<void> _openWorkflowDialog(BookingRecord record) async {
    final users = context.read<AdminDataState>().users;
    final staff = users.where((u) => u.active && u.role != UserRole.user && u.role != UserRole.guest).toList();
    WorkflowStatus selectedStatus = record.workflowStatus;
    String? assignee = record.assignedTo;
    final noteController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تحديث سير العمل'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<WorkflowStatus>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(labelText: 'الحالة الداخلية'),
                items: WorkflowStatus.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(_workflowLabel(status)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) selectedStatus = value;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: assignee,
                decoration: const InputDecoration(labelText: 'تعيين لموظف'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('بدون تعيين')),
                  ...staff.map(
                    (user) => DropdownMenuItem(
                      value: user.name,
                      child: Text(user.name),
                    ),
                  ),
                ],
                onChanged: (value) => assignee = value,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'ملاحظة داخلية'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final note = noteController.text.trim();
              final actor = context.read<AuthService>().username ?? 'غير معروف';
              final appState = context.read<AppState>();
              final audit = context.read<AuditLogService>();
              final notes = [...record.internalNotes];
              if (note.isNotEmpty) {
                final stamp = DateTime.now().toIso8601String().replaceFirst('T', ' ').split('.').first;
                notes.add('$stamp - $actor: $note');
              }
              await appState.updateBookingWorkflow(
                    ticketId: record.ticketId,
                    workflowStatus: selectedStatus,
                    assignedTo: assignee,
                    internalNotes: notes,
                  );
              if (!mounted) return;
              await audit.log(
                    actor: actor,
                    action: 'تحديث الحجز',
                    targetType: 'booking',
                    targetId: record.ticketId,
                    details: 'الحالة: ${_workflowLabel(selectedStatus)}, التعيين: ${assignee ?? 'بدون'}',
                  );
              if (!mounted) return;
              navigator.pop();
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandedAppBar(
        title: 'إدارة الحجوزات',
        actions: [
          IconButton(
            onPressed: _exportData,
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'تصدير',
          ),
        ],
      ),
      body: ResponsiveContainer(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: context.watch<AppState>().busBookings.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final booking = context.watch<AppState>().busBookings[index];
            return Card(
              child: ListTile(
                title: Text('رقم الحجز: ${booking.ticketId}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الشركة: ${booking.company}'),
                    const SizedBox(height: 4),
                    Text('الحالة الداخلية: ${_workflowLabel(booking.workflowStatus)}'),
                    if (booking.assignedTo != null)
                      Text('مُعيّن إلى: ${booking.assignedTo}'),
                    if (booking.internalNotes.isNotEmpty)
                      Text('ملاحظات: ${booking.internalNotes.length}'),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) => _changeStatus(index, value),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'مؤكدة', child: Text('اعتماد')),
                    PopupMenuItem(value: 'مرفوضة', child: Text('رفض')),
                    PopupMenuItem(value: 'قيد المراجعة', child: Text('قيد المراجعة')),
                  ],
                  child: _StatusChip(status: booking.status),
                ),
                onTap: () => _openWorkflowDialog(booking),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  Color _color() {
    switch (status) {
      case 'مؤكدة':
        return Colors.green;
      case 'مرفوضة':
        return Colors.redAccent;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

