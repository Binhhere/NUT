// lib/shared/models/user_model.dart
// Model đại diện cho user local — Wave 1 (offline-first).
// Wave 3: thêm id, email, authToken khi integrate Supabase.
// Source: DB Architecture → table `users` + local persistence

class UserModel {
  const UserModel({
    this.username,
    this.reason,
    this.createdAt,
    this.onboardingDone = false,
  });

  final String? username;

  /// Lý do tham gia — chọn từ AppConstants.onboardingReasons
  final String? reason;

  /// Ngày tạo tài khoản / lần đầu mở app
  final DateTime? createdAt;

  final bool onboardingDone;

  // ─────────────────────────────────────────────
  // GETTERS
  // ─────────────────────────────────────────────

  /// Hiển thị tên — fallback về "You" nếu chưa đặt tên
  String get displayName =>
      (username != null && username!.isNotEmpty) ? username! : 'You';

  // ─────────────────────────────────────────────
  // COPY WITH
  // ─────────────────────────────────────────────

  UserModel copyWith({
    String? username,
    bool clearUsername = false,
    String? reason,
    bool clearReason = false,
    DateTime? createdAt,
    bool? onboardingDone,
  }) {
    return UserModel(
      username: clearUsername ? null : username ?? this.username,
      reason: clearReason ? null : reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      onboardingDone: onboardingDone ?? this.onboardingDone,
    );
  }

  // ─────────────────────────────────────────────
  // JSON — Wave 3 Supabase sync
  // ─────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'username': username,
        'reason': reason,
        'created_at': createdAt?.toIso8601String(),
        'onboarding_done': onboardingDone,
        // Wave 3: thêm 'id', 'email'
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        username: json['username'] as String?,
        reason: json['reason'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        onboardingDone: (json['onboarding_done'] as bool?) ?? false,
      );

  // ─────────────────────────────────────────────
  // EMPTY / DEFAULT
  // ─────────────────────────────────────────────

  static const empty = UserModel();

  @override
  String toString() =>
      'UserModel(username: $username, reason: $reason, onboardingDone: $onboardingDone)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          other.username == username &&
          other.reason == reason &&
          other.onboardingDone == onboardingDone;

  @override
  int get hashCode => Object.hash(username, reason, onboardingDone);
}
