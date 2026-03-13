class CallHistoryResponse {
  final bool? success;
  final List<CallHistoryItem>? data;
  final MetaData? meta;

  CallHistoryResponse({this.success, this.data, this.meta});

  factory CallHistoryResponse.fromJson(Map<String, dynamic> json) {
    return CallHistoryResponse(
      success: json['success'],
      data: json['data'] != null
          ? (json['data'] as List)
                .map((i) => CallHistoryItem.fromJson(i))
                .toList()
          : null,
      meta: json['meta'] != null ? MetaData.fromJson(json['meta']) : null,
    );
  }
}

class CallHistoryItem {
  final String? id;
  final String? conversationId;
  final String? acceptedAt;
  final int? billableMinutes;
  final String? createdAt;
  final int? durationSeconds;
  final String? endedAt;
  final PartnerDetails? endedBy;
  final UserDetails? from;
  final String? initiatedAt;
  final UserDetails? initiatedBy;
  final String? partnerId;
  final String? rejectedAt;
  final PartnerDetails? rejectedBy;
  final String? status;
  final UserDetails? to;
  final String? updatedAt;
  final String? userId;
  final VoiceRecordings? voiceRecordings;

  CallHistoryItem({
    this.id,
    this.conversationId,
    this.acceptedAt,
    this.billableMinutes,
    this.createdAt,
    this.durationSeconds,
    this.endedAt,
    this.endedBy,
    this.from,
    this.initiatedAt,
    this.initiatedBy,
    this.partnerId,
    this.rejectedAt,
    this.rejectedBy,
    this.status,
    this.to,
    this.updatedAt,
    this.userId,
    this.voiceRecordings,
  });

  factory CallHistoryItem.fromJson(Map<String, dynamic> json) {
    return CallHistoryItem(
      id: json['_id'],
      conversationId: json['conversationId'],
      acceptedAt: json['acceptedAt'],
      billableMinutes: json['billableMinutes'],
      createdAt: json['createdAt'],
      durationSeconds: json['durationSeconds'],
      endedAt: json['endedAt'],
      endedBy: json['endedBy'] != null
          ? PartnerDetails.fromJson(json['endedBy'])
          : null,
      from: json['from'] != null ? UserDetails.fromJson(json['from']) : null,
      initiatedAt: json['initiatedAt'],
      initiatedBy: json['initiatedBy'] != null
          ? UserDetails.fromJson(json['initiatedBy'])
          : null,
      partnerId: json['partnerId'],
      rejectedAt: json['rejectedAt'],
      rejectedBy: json['rejectedBy'] != null
          ? PartnerDetails.fromJson(json['rejectedBy'])
          : null,
      status: json['status'],
      to: json['to'] != null ? UserDetails.fromJson(json['to']) : null,
      updatedAt: json['updatedAt'],
      userId: json['userId'],
      voiceRecordings: json['voiceRecordings'] != null
          ? VoiceRecordings.fromJson(json['voiceRecordings'])
          : null,
    );
  }
}

class PartnerDetails {
  final String? id;
  final String? type;

  PartnerDetails({this.id, this.type});

  factory PartnerDetails.fromJson(Map<String, dynamic> json) {
    return PartnerDetails(id: json['id'], type: json['type']);
  }
}

class UserDetails {
  final String? id;
  final String? type;
  final String? name;
  final String? email;
  final String? image;

  UserDetails({this.id, this.type, this.name, this.email, this.image});

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      email: json['email'],
      image: json['image'],
    );
  }
}

class VoiceRecordings {
  final RecordingDetails? user;
  final RecordingDetails? partner;

  VoiceRecordings({this.user, this.partner});

  factory VoiceRecordings.fromJson(Map<String, dynamic> json) {
    return VoiceRecordings(
      user: json['user'] != null
          ? RecordingDetails.fromJson(json['user'])
          : null,
      partner: json['partner'] != null
          ? RecordingDetails.fromJson(json['partner'])
          : null,
    );
  }
}

class RecordingDetails {
  final String? key;
  final String? url;
  final String? uploadedAt;
  final String? signedUrl;

  RecordingDetails({this.key, this.url, this.uploadedAt, this.signedUrl});

  factory RecordingDetails.fromJson(Map<String, dynamic> json) {
    return RecordingDetails(
      key: json['key'],
      url: json['url'],
      uploadedAt: json['uploadedAt'],
      signedUrl: json['signedUrl'],
    );
  }
}

class MetaData {
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;

  MetaData({this.page, this.limit, this.total, this.totalPages});

  factory MetaData.fromJson(Map<String, dynamic> json) {
    return MetaData(
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      totalPages: json['totalPages'],
    );
  }
}
