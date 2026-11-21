import 'package:flutter_test/flutter_test.dart';
import 'package:tkmingle/data/repositories/auth_repository.dart';
import 'package:tkmingle/data/repositories/user_repository.dart';
import 'package:tkmingle/data/repositories/connection_repository.dart';
import 'package:tkmingle/data/repositories/circle_repository.dart';
import 'package:tkmingle/data/repositories/message_repository.dart';

void main() {
  group('TKMingle Core Engine Tests', () {
    late LocalUserRepository userRepo;
    late LocalConnectionRepository connRepo;
    late LocalCircleRepository circleRepo;
    late LocalMessageRepository msgRepo;
    late LocalAuthRepository authRepo;

    setUp(() {
      userRepo = LocalUserRepository();
      connRepo = LocalConnectionRepository(userRepository: userRepo);
      circleRepo = LocalCircleRepository();
      msgRepo = LocalMessageRepository(userRepository: userRepo);
      authRepo = LocalAuthRepository();
    });

    test('Auth Repository seeds initial current user correctly', () async {
      final user = await authRepo.getCurrentUser();
      expect(user, isNotNull);
      expect(user!.email, contains('tkmce.ac.in'));
      expect(user.department, equals('Computer Science & Engineering'));
    });

    test('Discovery filters students properly excluding self and suspended', () async {
      final discoverable = await userRepo.getDiscoverableStudents(
        currentUserId: 'user_current',
      );
      expect(discoverable, isNotEmpty);
      expect(discoverable.any((u) => u.uid == 'user_current'), isFalse);
      expect(discoverable.any((u) => u.isAdmin), isFalse);
    });

    test('Cross-department discovery filtering returns other branches', () async {
      final diffDeptStudents = await userRepo.getDiscoverableStudents(
        currentUserId: 'user_current',
        departmentFilter: 'Different Department',
      );
      expect(diffDeptStudents, isNotEmpty);
      expect(diffDeptStudents.every((u) => u.department != 'Computer Science & Engineering'), isTrue);
    });

    test('Connection Request workflow functions as mutual consent', () async {
      // 1. Initial state between current user and Gautham is none
      final initialStatus = await connRepo.getConnectionState('user_current', 'user_gautham');
      expect(initialStatus, equals('none'));

      // 2. Send request
      final req = await connRepo.sendRequest('user_current', 'user_gautham');
      expect(req.status.name, equals('pending'));

      // 3. Status is now pending_sent
      final sentStatus = await connRepo.getConnectionState('user_current', 'user_gautham');
      expect(sentStatus, equals('pending_sent'));

      // 4. Accept request
      await connRepo.acceptRequest(req.id);
      final finalStatus = await connRepo.getConnectionState('user_current', 'user_gautham');
      expect(finalStatus, equals('connected'));
    });

    test('Circle joining and community post creation', () async {
      final circles = await circleRepo.getCircles();
      expect(circles, isNotEmpty);

      final circle = circles.first;
      final initialPosts = await circleRepo.getPostsForCircle(circle.circleId);

      // Create new post
      final newPost = await circleRepo.createPost(
        circleId: circle.circleId,
        circleName: circle.name,
        authorId: 'user_current',
        authorName: 'Abhiram V.',
        authorDept: 'CSE 3rd Year',
        authorImage: '',
        content: 'Excited for the upcoming campus coding symposium!',
      );

      final updatedPosts = await circleRepo.getPostsForCircle(circle.circleId);
      expect(updatedPosts.length, equals(initialPosts.length + 1));
      expect(updatedPosts.first.postId, equals(newPost.postId));
    });

    test('Messaging creates and appends conversation messages with timestamps', () async {
      final conv = await msgRepo.getOrCreateConversation('user_current', 'user_ananya');
      expect(conv.conversationId, isNotEmpty);

      final msg = await msgRepo.sendMessage(
        conversationId: conv.conversationId,
        senderId: 'user_current',
        message: 'Let us meet at Nescafe corner today.',
      );

      final msgs = await msgRepo.getMessages(conv.conversationId);
      expect(msgs.any((m) => m.id == msg.id), isTrue);
    });
  });
}
