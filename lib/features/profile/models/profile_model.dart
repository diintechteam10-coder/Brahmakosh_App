class ProfileModel {
  final String id;
  final String email;
  final String authMethod;
  final int registrationStep;
  final bool emailVerified;
  final bool mobileVerified;
  final bool isActive;
  final bool loginApproved;
  final String createdAt;
  final String updatedAt;
  final String? mobile;
  final String? profileImage;
  final String? profileImageUrl;
  final String role;
  final int credits;
  final int karmaPoints;

  /// 👇 ADD THIS
  final UserProfile? profile;

  ProfileModel({
    required this.id,
    required this.email,
    required this.authMethod,
    required this.registrationStep,
    required this.emailVerified,
    required this.mobileVerified,
    required this.isActive,
    required this.loginApproved,
    required this.createdAt,
    required this.updatedAt,
    this.mobile,
    this.profileImage,
    this.profileImageUrl,
    required this.role,
    this.credits = 0,
    this.karmaPoints = 0,
    this.profile,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      authMethod: json['authMethod'] ?? '',
      registrationStep: (json['registrationStep'] as num?)?.toInt() ?? 0,
      emailVerified: json['emailVerified'] ?? false,
      mobileVerified: json['mobileVerified'] ?? false,
      isActive: json['isActive'] ?? false,
      loginApproved: json['loginApproved'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      mobile: json['mobile'],
      profileImage: json['profileImage'],
      profileImageUrl: json['profileImageUrl'],
      role: json['role'] ?? 'user',
      credits: (json['credits'] as num?)?.toInt() ?? 0,
      karmaPoints: (json['karmaPoints'] as num?)?.toInt() ?? 0,

      /// 👇 MAP PROFILE SAFELY
      profile: json['profile'] != null
          ? UserProfile.fromJson(json['profile'])
          : null,
    );
  }
}

class UserProfile {
  final String? name;
  final String? dob;
  final String? gowthra;
  final String? placeOfBirth;
  final String? timeOfBirth;
  final String? profileImage;

  UserProfile({
    this.name,
    this.dob,
    this.gowthra,
    this.placeOfBirth,
    this.timeOfBirth,
    this.profileImage,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      dob: json['dob'],
      gowthra: json['gowthra'],
      placeOfBirth: json['placeOfBirth'],
      timeOfBirth: json['timeOfBirth'],
      profileImage: json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dob': dob,
      'gowthra': gowthra,
      'placeOfBirth': placeOfBirth,
      'timeOfBirth': timeOfBirth,
      'profile_image': profileImage,
    };
  }
}
