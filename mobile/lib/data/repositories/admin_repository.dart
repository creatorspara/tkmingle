import '../models/user_model.dart';
import '../models/report_model.dart';
import 'user_repository.dart';
import 'circle_repository.dart';

class AdminStats {
  final int totalStudents;
  final int verifiedStudents;
  final int pendingVerifications;
  final int activeCircles;
  final int pendingReports;

  AdminStats({
    required this.totalStudents,
    required this.verifiedStudents,
    required this.pendingVerifications,
    required this.activeCircles,
    required this.pendingReports,
  });
}

class VerificationRequest {
  final String requestId;
  final UserModel user;
  final String documentType; // 'College ID Card', 'Fee Receipt', 'Admission Slip'
  final String documentUrl;
  final DateTime submittedAt;
  final String status; // 'pending', 'approved', 'rejected'

  VerificationRequest({
    required this.requestId,
    required this.user,
    required this.documentType,
    this.documentUrl = '',
    DateTime? submittedAt,
    this.status = 'pending',
  }) : submittedAt = submittedAt ?? DateTime.now();
}

abstract class AdminRepository {
  Future<AdminStats> getStats();
  Future<List<VerificationRequest>> getPendingVerifications();
  Future<void> reviewVerification(String requestId, bool approve, String userId);
  Future<List<ReportModel>> getReportQueue();
  Future<void> resolveReport(String reportId, String action, String targetUserId);
  Future<List<String>> getAllowedDomains();
  Future<void> addAllowedDomain(String domain);
  Future<void> removeAllowedDomain(String domain);
}

class LocalAdminRepository implements AdminRepository {
  final UserRepository userRepository;
  final CircleRepository circleRepository;
  
  final List<VerificationRequest> _verificationQueue = [];
  final List<ReportModel> _reports = [];
  final List<String> _allowedDomains = ['tkmce.ac.in'];

  LocalAdminRepository({
    required this.userRepository,
    required this.circleRepository,
  }) {
    // Seed sample reports
    _reports.add(
      ReportModel(
        id: 'rep_1',
        reporterId: 'user_current',
        reporterName: 'Abhiram V.',
        reportedUserId: 'user_fake_1',
        reportedUserName: 'Random Bot Account',
        reason: 'Impersonation & Spamming links',
        details: 'Sent suspicious external link claiming to be college exam leaks.',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    );

    // Seed pending verification request
    _verificationQueue.add(
      VerificationRequest(
        requestId: 'vreq_1',
        user: UserModel(
          uid: 'user_pending_1',
          name: 'Nikhil R. Nair',
          email: 'nikhil.nair.2023@gmail.com',
          department: 'Civil Engineering',
          academicYear: '2nd Year',
          bio: 'Civil engineering student looking for campus friends.',
          verified: false,
          verificationMethod: 'Manual ID Upload',
        ),
        documentType: 'TKMCE Student ID Card',
        documentUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=400&q=80',
        submittedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    );
  }

  @override
  Future<AdminStats> getStats() async {
    final students = await userRepository.getAllStudentsForAdmin();
    final circles = await circleRepository.getAllCirclesForAdmin();
    final verified = students.where((s) => s.verified).length;

    return AdminStats(
      totalStudents: students.length,
      verifiedStudents: verified,
      pendingVerifications: _verificationQueue.where((v) => v.status == 'pending').length,
      activeCircles: circles.where((c) => c.isApproved).length,
      pendingReports: _reports.where((r) => r.status == 'pending').length,
    );
  }

  @override
  Future<List<VerificationRequest>> getPendingVerifications() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _verificationQueue.where((v) => v.status == 'pending').toList();
  }

  @override
  Future<void> reviewVerification(String requestId, bool approve, String userId) async {
    final index = _verificationQueue.indexWhere((v) => v.requestId == requestId);
    if (index != -1) {
      _verificationQueue[index] = VerificationRequest(
        requestId: requestId,
        user: _verificationQueue[index].user,
        documentType: _verificationQueue[index].documentType,
        documentUrl: _verificationQueue[index].documentUrl,
        submittedAt: _verificationQueue[index].submittedAt,
        status: approve ? 'approved' : 'rejected',
      );
      if (approve) {
        await userRepository.verifyUser(userId);
      }
    }
  }

  @override
  Future<List<ReportModel>> getReportQueue() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_reports);
  }

  @override
  Future<void> resolveReport(String reportId, String action, String targetUserId) async {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      _reports[index] = _reports[index].copyWith(status: 'resolved');
    }
    if (action == 'suspend') {
      await userRepository.suspendUser(targetUserId, true);
    }
  }

  @override
  Future<List<String>> getAllowedDomains() async {
    return List.from(_allowedDomains);
  }

  @override
  Future<void> addAllowedDomain(String domain) async {
    final d = domain.trim().toLowerCase();
    if (d.isNotEmpty && !_allowedDomains.contains(d)) {
      _allowedDomains.add(d);
    }
  }

  @override
  Future<void> removeAllowedDomain(String domain) async {
    _allowedDomains.remove(domain.trim().toLowerCase());
  }
}
