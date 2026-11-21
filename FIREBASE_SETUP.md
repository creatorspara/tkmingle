# TKMingle — Firebase Backend & Production Setup Guide

## Architecture Overview

TKMingle is built with a clean **Repository Pattern** and **Dependency Injection** via Riverpod.
Currently, it operates in **Standalone Local / Development Mode** with full offline persistence, real-time reactive streams, mock seed data, and zero configuration required.

To connect live Firebase services in production:

### 1. Create Firebase Project
1. Navigate to [Firebase Console](https://console.firebase.google.com/).
2. Create a new project: **TKMingle-Campus**.
3. Add an Android app with package ID:
   ```
   com.tkmingle.app
   ```
4. Download the generated `google-services.json` and place it in:
   ```
   android/app/google-services.json
   ```

### 2. Enable Firebase Authentication
1. Go to **Authentication > Sign-in method**.
2. Enable **Email/Password**.
3. (Optional) Configure Custom Email Domain validation or Cloud Function for sending 6-digit verification OTPs to `@tkmce.ac.in`.

### 3. Deploy Cloud Firestore Rules
In Firebase Console, go to **Firestore Database > Rules** and paste the contents of `firestore.rules`:
```bash
firebase deploy --only firestore:rules
```

### 4. Firestore Collections Hierarchy
```
users/
  {userId}/
    name: string
    email: string
    department: string
    academicYear: string
    bio: string
    profileImage: string
    interests: array
    hobbies: array
    skills: array
    verified: boolean
    discoverable: boolean
    socialAvailability: string
    prompts: map
    role: string ("student" | "admin")
    blockedUserIds: array

connectionRequests/
  {requestId}/
    senderId: string
    receiverId: string
    status: string ("pending" | "accepted" | "declined")
    createdAt: timestamp

connections/
  {connectionId}/
    userIds: array [userA, userB]
    createdAt: timestamp

circles/
  {circleId}/
    name: string
    description: string
    category: string
    icon: string
    createdBy: string
    memberCount: number
    isApproved: boolean

posts/
  {postId}/
    circleId: string
    circleName: string
    authorId: string
    authorName: string
    authorDept: string
    authorImage: string
    content: string
    likesCount: number
    commentsCount: number

conversations/
  {conversationId}/
    participants: array [userA, userB]
    lastMessage: string
    lastMessageAt: timestamp

messages/
  {messageId}/
    conversationId: string
    senderId: string
    message: string
    type: string ("text" | "image" | "icebreaker")
    timestamp: timestamp
    readStatus: boolean

reports/
  {reportId}/
    reporterId: string
    reportedUserId: string
    reason: string
    details: string
    status: string ("pending" | "resolved")

notifications/
  {notifId}/
    userId: string
    type: string
    title: string
    body: string
    referenceId: string
    read: boolean
    createdAt: timestamp
```

### 5. Enabling Live Firebase Repositories
In `pubspec.yaml`, uncomment:
```yaml
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
cloud_firestore: ^5.4.4
firebase_storage: ^12.3.4
```
And swap the repository provider bindings in `lib/state/`:
- `authRepositoryProvider -> FirestoreAuthRepository`
- `userRepositoryProvider -> FirestoreUserRepository`
- `connectionRepositoryProvider -> FirestoreConnectionRepository`
- `circleRepositoryProvider -> FirestoreCircleRepository`
- `messageRepositoryProvider -> FirestoreMessageRepository`
