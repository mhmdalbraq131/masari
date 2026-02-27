class AuditLog {
  final String id;
  final String actor;
  final String action;
  final String targetType;
  final String targetId;
  final String details;
  final DateTime createdAt;

  const AuditLog({
    required this.id,
    required this.actor,
    required this.action,
    required this.targetType,
    required this.targetId,
    required this.details,
    required this.createdAt,
  });
}
