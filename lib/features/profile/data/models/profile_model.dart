enum UserRole {
  customer,
  vendor,
  admin;

  String get value {
    switch (this) {
      case UserRole.customer:
        return 'customer';
      case UserRole.vendor:
        return 'vendor';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'vendor':
        return UserRole.vendor;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }
}

class Profile {
  final String id;
  final String fullName;
  final String? phone;
  final String? department;
  final String? bio;
  final String? avatarUrl;
  final UserRole role;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.id,
    required this.fullName,
    this.phone,
    this.department,
    this.bio,
    this.avatarUrl,
    required this.role,
    required this.isApproved,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String?,
      department: json['department'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'customer'),
      isApproved: json['is_approved'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'department': department,
      'bio': bio,
      'avatar_url': avatarUrl,
      'role': role.value,
      'is_approved': isApproved,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Profile copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? department,
    String? bio,
    String? avatarUrl,
    UserRole? role,
    bool? isApproved,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}