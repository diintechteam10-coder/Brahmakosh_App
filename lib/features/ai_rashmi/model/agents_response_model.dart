class AgentResponseModel {
  bool? success;
  List<AgentResponseData>? data;

  AgentResponseModel({this.success, this.data});

  AgentResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <AgentResponseData>[];
      json['data'].forEach((v) {
        data!.add(AgentResponseData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};
    dataMap['success'] = success;
    if (data != null) {
      dataMap['data'] = data!.map((v) => v.toJson()).toList();
    }
    return dataMap;
  }
}

class AgentResponseData {
  String? id;
  String? clientId;
  String? name;
  String? description;
  String? voiceName;
  // String? systemPrompt;
  bool? isActive;
  String? createdByRole;
  String? createdBy;
  String? createdAt;
  String? updatedAt;
  int? v;
  String? firstMessage;
  VoiceConfig? voiceConfig;

  AgentResponseData({
    this.id,
    this.clientId,
    this.name,
    this.description,
    this.voiceName,
    // this.systemPrompt,
    this.isActive,
    this.createdByRole,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.firstMessage,
    this.voiceConfig,
  });

  AgentResponseData.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    clientId = json['clientId'];
    name = json['name'];
    description = json['description'];
    voiceName = json['voiceName'];
    // systemPrompt = json['systemPrompt'];
    isActive = json['isActive'];
    createdByRole = json['createdByRole'];
    createdBy = json['createdBy'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
    firstMessage = json['firstMessage'];
    voiceConfig = json['voiceConfig'] != null
        ? VoiceConfig.fromJson(json['voiceConfig'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = id;
    data['clientId'] = clientId;
    data['name'] = name;
    data['description'] = description;
    data['voiceName'] = voiceName;
    // data['systemPrompt'] = systemPrompt;
    data['isActive'] = isActive;
    data['createdByRole'] = createdByRole;
    data['createdBy'] = createdBy;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = v;
    data['firstMessage'] = firstMessage;

    if (voiceConfig != null) {
      data['voiceConfig'] = voiceConfig!.toJson();
    }

    return data;
  }
}

class VoiceConfig {
  String? id;
  String? name;
  String? displayName;
  String? gender;
  bool? isActive;
  String? modelId;
  String? prompt;
  String? voiceId;
  VoiceSettings? voiceSettings;

  VoiceConfig({
    this.id,
    this.name,
    this.displayName,
    this.gender,
    this.isActive,
    this.modelId,
    this.prompt,
    this.voiceId,
    this.voiceSettings,
  });

  VoiceConfig.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    displayName = json['displayName'];
    gender = json['gender'];
    isActive = json['isActive'];
    modelId = json['modelId'];
    prompt = json['prompt'];
    voiceId = json['voiceId'];
    voiceSettings = json['voiceSettings'] != null
        ? VoiceSettings.fromJson(json['voiceSettings'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = id;
    data['name'] = name;
    data['displayName'] = displayName;
    data['gender'] = gender;
    data['isActive'] = isActive;
    data['modelId'] = modelId;
    data['prompt'] = prompt;
    data['voiceId'] = voiceId;

    if (voiceSettings != null) {
      data['voiceSettings'] = voiceSettings!.toJson();
    }

    return data;
  }
}

class VoiceSettings {
  double? similarityBoost;
  double? stability;
  int? style;
  bool? useSpeakerBoost;

  VoiceSettings({
    this.similarityBoost,
    this.stability,
    this.style,
    this.useSpeakerBoost,
  });

  VoiceSettings.fromJson(Map<String, dynamic> json) {
    similarityBoost = (json['similarity_boost'] as num?)?.toDouble();
    stability = (json['stability'] as num?)?.toDouble();
    style = json['style'];
    useSpeakerBoost = json['use_speaker_boost'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['similarity_boost'] = similarityBoost;
    data['stability'] = stability;
    data['style'] = style;
    data['use_speaker_boost'] = useSpeakerBoost;
    return data;
  }
}