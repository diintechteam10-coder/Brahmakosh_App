class RemediesModel {
  bool? success;
  RemediesData? data;

  RemediesModel({this.success, this.data});

  RemediesModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? RemediesData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class RemediesData {
  BirthData? birthData;
  Remedies? remedies;

  RemediesData({this.birthData, this.remedies});

  RemediesData.fromJson(Map<String, dynamic> json) {
    birthData = json['birthData'] != null
        ? BirthData.fromJson(json['birthData'])
        : null;
    remedies = json['remedies'] != null
        ? Remedies.fromJson(json['remedies'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (birthData != null) {
      data['birthData'] = birthData!.toJson();
    }
    if (remedies != null) {
      data['remedies'] = remedies!.toJson();
    }
    return data;
  }
}

class BirthData {
  int? day;
  int? month;
  int? year;
  int? hour;
  int? min;
  double? lat;
  double? lon;
  double? tzone;

  BirthData({
    this.day,
    this.month,
    this.year,
    this.hour,
    this.min,
    this.lat,
    this.lon,
    this.tzone,
  });

  BirthData.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    month = json['month'];
    year = json['year'];
    hour = json['hour'];
    min = json['min'];
    lat = json['lat'];
    lon = json['lon'];
    tzone = json['tzone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    data['month'] = month;
    data['year'] = year;
    data['hour'] = hour;
    data['min'] = min;
    data['lat'] = lat;
    data['lon'] = lon;
    data['tzone'] = tzone;
    return data;
  }
}

class Remedies {
  Puja? puja;
  Gemstones? gemstone;
  Rudraksha? rudraksha;

  Remedies({this.puja, this.gemstone, this.rudraksha});

  Remedies.fromJson(Map<String, dynamic> json) {
    puja = json['puja'] != null ? Puja.fromJson(json['puja']) : null;
    gemstone = json['gemstone'] != null
        ? Gemstones.fromJson(json['gemstone'])
        : null;
    rudraksha = json['rudraksha'] != null
        ? Rudraksha.fromJson(json['rudraksha'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (puja != null) {
      data['puja'] = puja!.toJson();
    }
    if (gemstone != null) {
      data['gemstone'] = gemstone!.toJson();
    }
    if (rudraksha != null) {
      data['rudraksha'] = rudraksha!.toJson();
    }
    return data;
  }
}

class Puja {
  String? summary;
  List<PujaSuggestion>? suggestions;

  Puja({this.summary, this.suggestions});

  Puja.fromJson(Map<String, dynamic> json) {
    summary = json['summary'];
    if (json['suggestions'] != null) {
      suggestions = <PujaSuggestion>[];
      json['suggestions'].forEach((v) {
        if (v is Map<String, dynamic>) {
          suggestions!.add(PujaSuggestion.fromJson(v));
        } else if (v is String) {
          suggestions!.add(PujaSuggestion(title: v));
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['summary'] = summary;
    if (suggestions != null) {
      data['suggestions'] = suggestions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PujaSuggestion {
  String? status;
  int? priority;
  String? title;
  String? pujaId;
  String? summary;
  String? link;

  PujaSuggestion({
    this.status,
    this.priority,
    this.title,
    this.pujaId,
    this.summary,
    this.link,
  });

  PujaSuggestion.fromJson(Map<String, dynamic> json) {
    status = json['status']?.toString();
    priority = json['priority'] is int
        ? json['priority']
        : int.tryParse(json['priority']?.toString() ?? '');
    title = json['title']?.toString();
    pujaId = json['pujaId']?.toString() ?? json['puja_id']?.toString();
    summary = json['summary']?.toString();
    link = json['link']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['priority'] = priority;
    data['title'] = title;
    data['pujaId'] = pujaId;
    data['summary'] = summary;
    data['link'] = link;
    return data;
  }
}

class Gemstones {
  GemstoneDetail? life;
  GemstoneDetail? benefic;
  GemstoneDetail? lucky;

  Gemstones({this.life, this.benefic, this.lucky});

  Gemstones.fromJson(Map<String, dynamic> json) {
    life = json['LIFE'] != null ? GemstoneDetail.fromJson(json['LIFE']) : null;
    benefic = json['BENEFIC'] != null
        ? GemstoneDetail.fromJson(json['BENEFIC'])
        : null;
    lucky = json['LUCKY'] != null
        ? GemstoneDetail.fromJson(json['LUCKY'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (life != null) {
      data['LIFE'] = life!.toJson();
    }
    if (benefic != null) {
      data['BENEFIC'] = benefic!.toJson();
    }
    if (lucky != null) {
      data['LUCKY'] = lucky!.toJson();
    }
    return data;
  }
}

class GemstoneDetail {
  String? name;
  String? gemKey;
  String? semiGem;
  String? wearFinger;
  String? weightCaret;
  String? wearMetal;
  String? wearDay;
  String? gemDeity;

  GemstoneDetail({
    this.name,
    this.gemKey,
    this.semiGem,
    this.wearFinger,
    this.weightCaret,
    this.wearMetal,
    this.wearDay,
    this.gemDeity,
  });

  GemstoneDetail.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    gemKey = json['gem_key'];
    semiGem = json['semi_gem'];
    wearFinger = json['wear_finger'];
    weightCaret = json['weight_caret'];
    wearMetal = json['wear_metal'];
    wearDay = json['wear_day'];
    gemDeity = json['gem_deity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['gem_key'] = gemKey;
    data['semi_gem'] = semiGem;
    data['wear_finger'] = wearFinger;
    data['weight_caret'] = weightCaret;
    data['wear_metal'] = wearMetal;
    data['wear_day'] = wearDay;
    data['gem_deity'] = gemDeity;
    return data;
  }
}

class Rudraksha {
  String? imgUrl;
  String? rudrakshaKey;
  String? name;
  String? recommend;
  String? detail;

  Rudraksha({
    this.imgUrl,
    this.rudrakshaKey,
    this.name,
    this.recommend,
    this.detail,
  });

  Rudraksha.fromJson(Map<String, dynamic> json) {
    imgUrl = json['img_url'];
    rudrakshaKey = json['rudraksha_key'];
    name = json['name'];
    recommend = json['recommend'];
    detail = json['detail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['img_url'] = imgUrl;
    data['rudraksha_key'] = rudrakshaKey;
    data['name'] = name;
    data['recommend'] = recommend;
    data['detail'] = detail;
    return data;
  }
}
