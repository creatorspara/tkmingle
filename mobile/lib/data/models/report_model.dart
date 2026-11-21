class ReportModel {
  final String id;
  final String reporterId;
  final String reporterName;
  final String reportedUserId;
  final String reportedUserName;
  final String reason;
  final String details;
  final String status; // 'pending', 'reviewed', 'resolved', 'dismissed'
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.reportedUserId,
    required this.reportedUserName,
    required this.reason,
    this.details = '',
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ReportModel copyWith({
    String? id,
    String? reporterId,
    String? reporterName,
    String? reportedUserId,
    String? reportedUserName,
    String? reason,
    String? details,
    String? status,
    DateTime? createdAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      reportedUserId: reportedUserId ?? this.reportedUserId,
      reportedUserName: reportedUserName ?? this.reportedUserName,
      reason: reason ?? this.reason,
      details: details ?? this.details,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reportedUserId': reportedUserId,
      'reportedUserName': reportedUserName,
      'reason': reason,
      'details': details,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      reporterId: json['reporterId'] as String,
      reporterName: json['reporterName'] as String? ?? 'Student',
      reportedUserId: json['reportedUserId'] as String,
      reportedUserName: json['reportedUserName'] as String? ?? 'Reported User',
      reason: json['reason'] as String? ?? '',
      details: json['details'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
