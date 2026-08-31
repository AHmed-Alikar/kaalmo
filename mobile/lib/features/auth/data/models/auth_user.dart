import 'package:flutter/foundation.dart';

/// Mirror of the backend `toPublicUser` shape.
@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.roles,
    required this.language,
    required this.emailVerified,
    required this.phoneVerified,
    required this.identityVerified,
    required this.status,
    required this.pushEnabled,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final List<String> roles;
  final String language;
  final bool emailVerified;
  final bool phoneVerified;
  final bool identityVerified;

  /// 'active' | 'suspended' | 'banned'
  final String status;
  final bool pushEnabled;

  bool get isOrganizer => roles.contains('organizer');
  bool get isBeneficiary => roles.contains('beneficiary');
  bool get isActive => status == 'active';
  bool get needsEmailVerification => !emailVerified;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: '${json['id'] ?? json['_id'] ?? ''}',
      fullName: '${json['fullName'] ?? ''}',
      email: '${json['email'] ?? ''}',
      phone: '${json['phone'] ?? ''}',
      roles: (json['roles'] as List?)?.map((e) => '$e').toList() ?? const ['donor'],
      language: '${json['language'] ?? 'so'}',
      emailVerified: json['emailVerified'] == true,
      phoneVerified: json['phoneVerified'] == true,
      identityVerified: json['identityVerified'] == true,
      status: '${json['status'] ?? 'active'}',
      pushEnabled: json['pushEnabled'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'roles': roles,
        'language': language,
        'emailVerified': emailVerified,
        'phoneVerified': phoneVerified,
        'identityVerified': identityVerified,
        'status': status,
        'pushEnabled': pushEnabled,
      };

  AuthUser copyWith({bool? emailVerified, String? language, bool? pushEnabled}) => AuthUser(
        id: id,
        fullName: fullName,
        email: email,
        phone: phone,
        roles: roles,
        language: language ?? this.language,
        emailVerified: emailVerified ?? this.emailVerified,
        phoneVerified: phoneVerified,
        identityVerified: identityVerified,
        status: status,
        pushEnabled: pushEnabled ?? this.pushEnabled,
      );
}
