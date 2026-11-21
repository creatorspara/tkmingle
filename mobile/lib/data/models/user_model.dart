class UserModel {
  final String uid;
  final String name;
  final String email;
  final String department;
  final String academicYear;
  final String bio;
  final String profileImage;
  final List<String> interests;
  final List<String> hobbies;
  final List<String> skills;
  final List<String> languages;
  final bool verified;
  final String verificationMethod;
  final bool discoverable;
  final String socialAvailability;
  final Map<String, String> prompts;
  final String role; // 'student' or 'admin'
  final DateTime createdAt;
  final List<String> blockedUserIds;
  final bool isSuspended;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.department,
    required this.academicYear,
    this.bio = '',
    this.profileImage = '',
    this.interests = const [],
    this.hobbies = const [],
    this.skills = const [],
    this.languages = const ['English', 'Malayalam'],
    this.verified = false,
    this.verificationMethod = 'email_otp',
    this.discoverable = true,
    this.socialAvailability = 'Available to hangout & talk tech',
    this.prompts = const {},
    this.role = 'student',
    DateTime? createdAt,
    this.blockedUserIds = const [],
    this.isSuspended = false,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isAdmin => role == 'admin';

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? department,
    String? academicYear,
    String? bio,
    String? profileImage,
    List<String>? interests,
    List<String>? hobbies,
    List<String>? skills,
    List<String>? languages,
    bool? verified,
    String? verificationMethod,
    bool? discoverable,
    String? socialAvailability,
    Map<String, String>? prompts,
    String? role,
    DateTime? createdAt,
    List<String>? blockedUserIds,
    bool? isSuspended,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      academicYear: academicYear ?? this.academicYear,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      interests: interests ?? this.interests,
      hobbies: hobbies ?? this.hobbies,
      skills: skills ?? this.skills,
      languages: languages ?? this.languages,
      verified: verified ?? this.verified,
      verificationMethod: verificationMethod ?? this.verificationMethod,
      discoverable: discoverable ?? this.discoverable,
      socialAvailability: socialAvailability ?? this.socialAvailability,
      prompts: prompts ?? this.prompts,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      blockedUserIds: blockedUserIds ?? this.blockedUserIds,
      isSuspended: isSuspended ?? this.isSuspended,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'department': department,
      'academicYear': academicYear,
      'bio': bio,
      'profileImage': profileImage,
      'interests': interests,
      'hobbies': hobbies,
      'skills': skills,
      'languages': languages,
      'verified': verified,
      'verificationMethod': verificationMethod,
      'discoverable': discoverable,
      'socialAvailability': socialAvailability,
      'prompts': prompts,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'blockedUserIds': blockedUserIds,
      'isSuspended': isSuspended,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String? ?? '',
      department: json['department'] as String? ?? '',
      academicYear: json['academicYear'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      profileImage: json['profileImage'] as String? ?? '',
      interests: List<String>.from(json['interests'] ?? []),
      hobbies: List<String>.from(json['hobbies'] ?? []),
      skills: List<String>.from(json['skills'] ?? []),
      languages: List<String>.from(json['languages'] ?? ['English', 'Malayalam']),
      verified: json['verified'] as bool? ?? false,
      verificationMethod: json['verificationMethod'] as String? ?? 'email_otp',
      discoverable: json['discoverable'] as bool? ?? true,
      socialAvailability: json['socialAvailability'] as String? ?? '',
      prompts: Map<String, String>.from(json['prompts'] ?? {}),
      role: json['role'] as String? ?? 'student',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      blockedUserIds: List<String>.from(json['blockedUserIds'] ?? []),
      isSuspended: json['isSuspended'] as bool? ?? false,
    );
  }
}
