import 'dart:convert';
import 'dart:io';
import 'dart:async'; // Added for TimeoutException
import 'dart:developer';
import 'package:brahmakosh/common/exception.dart';
import 'package:brahmakosh/common/models/avtar_list.dart';
import 'package:brahmakosh/common/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brahmakosh/common/models/testimonial_model.dart';
import 'package:brahmakosh/common/api_urls.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/features/home/models/founder_message_model.dart';
import 'package:brahmakosh/common/models/sponsor_model.dart';
import 'package:brahmakosh/common/models/chanting_mantra.dart';
import 'package:brahmakosh/common/models/brahm_reel.dart';
import 'package:brahmakosh/common/models/get_loc.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_checkin_model.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_session_model.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_configuration_model.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_clip_model.dart';
import 'package:brahmakosh/common/models/user_complete_details_model.dart';
import 'package:brahmakosh/features/numerology/models/numerology_history_model.dart';
import 'package:brahmakosh/features/numerology/models/numerology_detail_model.dart';
import 'package:brahmakosh/features/home/models/dosha_dasha_model.dart';
import 'package:brahmakosh/features/home/models/remedies_model.dart';

const bool allowInsecureDevFallback = false;

Future<dynamic> callWebApi(
  TickerProvider? tickerProvider,
  String url,
  Map data, {
  required Function onResponse,
  Function? onError,
  String token = "",
  bool showLoader = true,
  bool hideLoader = true,
  String authPrefix = "Bearer",
  bool shouldLogoutOn401 = true,
}) async {
  if (showLoader && tickerProvider != null)
    Utils.showLoaderDialogNew(tickerProvider);
  try {
    // Validate and log URL
    Utils.print('request url: $url');
    try {
      final parsedUri = Uri.parse(url);
      Utils.print(
        'parsed uri host: ${parsedUri.host}, path: ${parsedUri.path}',
      );
      if (parsedUri.host.isEmpty) {
        Utils.showToast('Invalid server URL');
        if (hideLoader) Utils.hideLoader();
        return;
      }
    } catch (e) {
      Utils.print('ERROR: Invalid URL format: $url');
      Utils.showToast('Invalid server URL');
      if (hideLoader) Utils.hideLoader();
      return;
    }

    Utils.print('request data: ' + json.encode(data).toString());

    Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      'clientId': AppConstants.clientId,
    };
    headers.addIf(token.isNotEmpty, "Authorization", "$authPrefix $token");
    Utils.print('headers: ' + json.encode(headers));

    final http.Response response = await _safePost(
      Uri.parse(url),
      headers,
      json.encode(data),
    ).timeout(const Duration(seconds: 30));

    return await _returnResponse(
      response,
      onResponse,
      onError,
      hideLoader,
      shouldLogoutOn401,
    );
  } on SocketException catch (e) {
    Utils.print('SocketException: ${e.toString()}');
    if (onError != null) {
      onError(e);
    }
    // Only show toast if loader is shown or we specifically want to
    Utils.showToast('No Internet Connection');
    if (hideLoader) Utils.hideLoader();
    return;
  } on TimeoutException catch (e) {
    Utils.print('TimeoutException: ${e.toString()}');
    if (onError != null) {
      onError(e);
    }
    Utils.showToast('Server is taking too long to respond. Please try again.');
    if (hideLoader) Utils.hideLoader();
    return;
  } on http.ClientException catch (e) {
    Utils.print('ClientException: ${e.toString()}');
    if (onError != null) {
      onError(e);
    }
    // Check if it's a network/host lookup error
    if (e.message.contains('Failed host lookup') ||
        e.message.contains('No address associated')) {
      Utils.showToast('No Internet Connection');
    } else {
      Utils.showToast('Connection Error: ${e.message}');
    }
    if (hideLoader) Utils.hideLoader();
    return;
  } catch (e) {
    if (onError != null) {
      onError(e);
    }
    // Don't show generic error for UnauthorizedException as it's handled in _returnResponse
    if (e is! UnauthorisedException) {
      Utils.print('Errors: ${e.toString()}');
      // Replace generic message with something friendlier
      // Utils.showToast(
      //   'We are facing some technical issues. Please try again later.',
      // );
    }
    if (hideLoader) Utils.hideLoader();
  }
}

Future<http.Response> _safePost(
  Uri uri,
  Map<String, String> headers,
  String body,
) async {
  try {
    return await http.post(uri, headers: headers, body: body);
  } on SocketException catch (e) {
    Utils.print('SocketException in _safePost: ${e.toString()}');
    rethrow;
  } on http.ClientException catch (e) {
    Utils.print('ClientException in _safePost: ${e.toString()}');
    rethrow;
  } on HandshakeException catch (e) {
    Utils.print('HandshakeException: ' + e.toString());
    // Dev-only optional fallback: retry over HTTP if HTTPS handshake fails
    if (allowInsecureDevFallback && !kReleaseMode && uri.scheme == 'https') {
      final fallback = uri.replace(scheme: 'http');
      Utils.showToast(
        'Secure connection failed. Retrying over HTTP (dev only).',
      );
      return await http.post(fallback, headers: headers, body: body);
    }
    rethrow;
  }
}

Future<dynamic> callWebApiGet(
  TickerProvider? tickerProvider,
  String url, {
  required Function onResponse,
  Function? onError,
  String token = "",
  bool showLoader = true,
  bool hideLoader = true,
  String authPrefix = "Bearer",
  bool shouldLogoutOn401 = true,
}) async {
  if (showLoader && tickerProvider != null)
    Utils.showLoaderDialogNew(tickerProvider);
  try {
    Utils.print('request url: ' + url);

    Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      'clientId': AppConstants.clientId,
    };
    headers.addIf(token.isNotEmpty, "Authorization", "$authPrefix $token");
    print('Request headers: ' + headers.toString());
    Utils.print('headers: ' + json.encode(headers));

    final http.Response response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 30));

    return await _returnResponse(
      response,
      onResponse,
      onError,
      hideLoader,
      shouldLogoutOn401,
    );
  } on SocketException catch (e) {
    Utils.print('SocketException: ${e.toString()}');
    if (onError != null) {
      onError(e);
    }
    Utils.showToast('No Internet Connection');
    if (hideLoader) Utils.hideLoader();
    return;
  } on TimeoutException catch (e) {
    Utils.print('TimeoutException: ${e.toString()}');
    if (onError != null) {
      onError(e);
    }
    Utils.showToast('Server is taking too long to respond. Please try again.');
    if (hideLoader) Utils.hideLoader();
    return;
  } on http.ClientException catch (e) {
    Utils.print('ClientException: ${e.toString()}');
    if (onError != null) {
      onError(e);
    }
    if (e.message.contains('Failed host lookup') ||
        e.message.contains('No address associated')) {
      Utils.showToast('No Internet Connection');
    } else {
      Utils.showToast('Connection Error: ${e.message}');
    }
    if (hideLoader) Utils.hideLoader();
    return;
  } catch (e) {
    if (onError != null) {
      onError(e);
    }
    if (e is! UnauthorisedException) {
      Utils.print('Error: ${e.toString()}');
      // Utils.showToast(
      //   'We are facing some technical issues. Please try again later.',
      // );
    }
    if (hideLoader) Utils.hideLoader();
  }
}

Future<dynamic> callWebApiPut(
  TickerProvider? tickerProvider,
  String url,
  Map data, {
  required Function onResponse,
  Function? onError,
  String token = "",
  bool showLoader = true,
  bool hideLoader = true,
  String authPrefix = "Bearer",
  bool shouldLogoutOn401 = true,
}) async {
  if (showLoader && tickerProvider != null)
    Utils.showLoaderDialogNew(tickerProvider);
  try {
    Utils.print('request url: ' + url);
    Utils.print('request data: ' + json.encode(data).toString());

    Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      'clientId': AppConstants.clientId,
    };
    headers.addIf(token.isNotEmpty, "Authorization", "$authPrefix $token");
    Utils.print('headers: ' + json.encode(headers));

    final http.Response response = await http
        .put(Uri.parse(url), headers: headers, body: json.encode(data))
        .timeout(const Duration(seconds: 30));

    return await _returnResponse(
      response,
      onResponse,
      onError,
      hideLoader,
      shouldLogoutOn401,
    );
  } on SocketException catch (e) {
    Utils.print('SocketException: ${e.toString()}');
    if (onError != null) {
      onError(e);
    }
    Utils.showToast('No Internet Connection');
    if (hideLoader) Utils.hideLoader();
    return;
  } on TimeoutException catch (e) {
    Utils.print('TimeoutException: ${e.toString()}');
    if (onError != null) {
      onError(e);
    }
    Utils.showToast('Server is taking too long to respond. Please try again.');
    if (hideLoader) Utils.hideLoader();
    return;
  } on http.ClientException catch (e) {
    Utils.print('ClientException: ${e.toString()}');
    if (onError != null) {
      onError(e);
    }
    if (e.message.contains('Failed host lookup') ||
        e.message.contains('No address associated')) {
      Utils.showToast('No Internet Connection');
    } else {
      Utils.showToast('Connection Error: ${e.message}');
    }
    if (hideLoader) Utils.hideLoader();
    return;
  } catch (e) {
    if (onError != null) {
      onError(e);
    }
    if (e is! UnauthorisedException) {
      Utils.print('Error: ${e.toString()}');
      // Utils.showToast(
      //   'We are facing some technical issues. Please try again later.',
      // );
    }
    if (hideLoader) Utils.hideLoader();
  }
}

Future<dynamic> callWebApiPatch(
  TickerProvider? tickerProvider,
  String url,
  Map data, {
  required Function onResponse,
  Function? onError,
  String token = "",
  bool showLoader = true,
  bool hideLoader = true,
  String authPrefix = "Bearer",
  bool shouldLogoutOn401 = true,
}) async {
  if (showLoader && tickerProvider != null)
    Utils.showLoaderDialogNew(tickerProvider);
  try {
    Utils.print('request url: ' + url);
    Utils.print('request data: ' + json.encode(data).toString());

    Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      'clientId': AppConstants.clientId,
    };
    headers.addIf(token.isNotEmpty, "Authorization", "$authPrefix $token");
    Utils.print('headers: ' + json.encode(headers));

    final http.Response response = await http
        .patch(Uri.parse(url), headers: headers, body: json.encode(data))
        .timeout(const Duration(seconds: 30));

    return await _returnResponse(
      response,
      onResponse,
      onError,
      hideLoader,
      shouldLogoutOn401,
    );
  } on SocketException catch (e) {
    Utils.print('SocketException: ${e.toString()}');
    if (onError != null) {
      onError(e);
    }
    Utils.showToast('No Internet Connection');
    if (hideLoader) Utils.hideLoader();
    return;
  } on TimeoutException catch (e) {
    Utils.print('TimeoutException: ${e.toString()}');
    if (onError != null) {
      onError(e);
    }
    Utils.showToast('Server is taking too long to respond. Please try again.');
    if (hideLoader) Utils.hideLoader();
    return;
  } on http.ClientException catch (e) {
    Utils.print('ClientException: ${e.toString()}');
    if (onError != null) {
      onError(e);
    }
    if (e.message.contains('Failed host lookup') ||
        e.message.contains('No address associated')) {
      Utils.showToast('No Internet Connection');
    } else {
      Utils.showToast('Connection Error: ${e.message}');
    }
    if (hideLoader) Utils.hideLoader();
    return;
  } catch (e) {
    if (onError != null) {
      onError(e);
    }
    if (e is! UnauthorisedException) {
      Utils.print('Error: ${e.toString()}');
      // Utils.showToast(
      //   'We are facing some technical issues. Please try again later.',
      // );
    }
    if (hideLoader) Utils.hideLoader();
  }
}

Future<dynamic> callWebApiDelete(
  TickerProvider? tickerProvider,
  String url, {
  required Function onResponse,
  Function? onError,
  String token = "",
  bool showLoader = true,
  bool hideLoader = true,
  String authPrefix = "Bearer",
  bool shouldLogoutOn401 = true,
}) async {
  if (showLoader && tickerProvider != null)
    Utils.showLoaderDialogNew(tickerProvider);
  try {
    Utils.print('request url: ' + url);

    Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      'clientId': AppConstants.clientId,
    };
    headers.addIf(token.isNotEmpty, "Authorization", "$authPrefix $token");
    Utils.print('headers: ' + json.encode(headers));

    final http.Response response = await http
        .delete(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 30));

    return await _returnResponse(
      response,
      onResponse,
      onError,
      hideLoader,
      shouldLogoutOn401,
    );
  } on SocketException catch (e) {
    Utils.print('SocketException: ${e.toString()}');
    if (onError != null) {
      onError(e);
    }
    Utils.showToast('No Internet Connection');
    if (hideLoader) Utils.hideLoader();
    return;
  } on TimeoutException catch (e) {
    Utils.print('TimeoutException: ${e.toString()}');
    if (onError != null) {
      onError(e);
    }
    Utils.showToast('Server is taking too long to respond. Please try again.');
    if (hideLoader) Utils.hideLoader();
    return;
  } on http.ClientException catch (e) {
    Utils.print('ClientException: ${e.toString()}');
    if (onError != null) {
      onError(e);
    }
    if (e.message.contains('Failed host lookup') ||
        e.message.contains('No address associated')) {
      Utils.showToast('No Internet Connection');
    } else {
      Utils.showToast('Connection Error: ${e.message}');
    }
    if (hideLoader) Utils.hideLoader();
    return;
  } catch (e) {
    if (onError != null) {
      onError(e);
    }
    if (e is! UnauthorisedException) {
      Utils.print('Error: ${e.toString()}');
      // Utils.showToast(
      //   'We are facing some technical issues. Please try again later.',
      // );
    }
    if (hideLoader) Utils.hideLoader();
  }
}

_returnResponse(
  http.Response response,
  Function onResponse,
  Function? onError,
  bool hideLoader,
  bool shouldLogoutOn401,
) async {
  if (hideLoader) Utils.hideLoader();

  Utils.print('response code:' + response.statusCode.toString());
  Utils.print('response :' + response.body.toString());

  Map? responseJson = {};
  try {
    responseJson = jsonDecode(response.body);
  } catch (exception) {
    responseJson = {};
    Utils.print("Error parsing response: " + exception.toString());
  }

  switch (response.statusCode) {
    case 200:
    case 201: // Created - for successful registration
      await onResponse(response);
      return 'responseJson';
    case 405:
      if (onError != null) {
        onError(response);
      }
      Utils.showToast(
        'Method Not Allowed (405). Check endpoint and HTTP method.',
      );
      return;
    case 400:
      Utils.showToast(
        responseJson?['message'] ??
            "You've reached the maximum number of OTP requests. Please try again later.",
      );
      if (onError != null) {
        onError(response);
      }
      throw BadRequestException(response.body.toString());
    case 404:
      if (onError != null) {
        onError(response);
      }
      throw InvalidInputException(response.body.toString());
    case 401:
      if (onError != null) {
        onError(response);
      }
      Utils.print('⚠️ 401 Unauthorized for URL: ${response.request?.url}');

      if (shouldLogoutOn401) {
        Utils.showToast('Session expired, please login again');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Get.offAllNamed(AppConstants.routeLogin);
      }
      throw UnauthorisedException(response.body.toString());
    case 403:
      if (onError != null) {
        onError(response);
      }
      Utils.showToast(responseJson?['message'] ?? 'Access denied');
      throw UnauthorisedException(response.body.toString());
    case 500:
    default:
      Utils.showToast(responseJson?['message'] ?? "Internal server error");
      if (onError != null) {
        onError(response);
      }
      throw FetchDataException(
        'Error occurred while Communication with Server with StatusCode : ${response.statusCode}',
      );
  }
}

Future<dynamic> callMultipartWebApi(
  TickerProvider? tickerProvider,
  String url,
  Map<String, String> data,
  List<http.MultipartFile> files, {
  required Function onResponse,
  Function? onError,
  required String token,
  bool showLoader = true,
  bool hideLoader = true,
  String authPrefix = "Bearer",
  bool shouldLogoutOn401 = true,
}) async {
  if (showLoader && tickerProvider != null)
    Utils.showLoaderDialogNew(tickerProvider);

  var request = http.MultipartRequest("POST", Uri.parse(url));

  Map<String, String> headers = <String, String>{
    'Content-Type': 'application/json',
    'Authorization': '$authPrefix $token',
    'clientId': AppConstants.clientId,
  };

  Utils.print('request url: ' + url);
  Utils.print('request data: ' + data.toString());
  Utils.print('headers: ' + json.encode(headers));

  request.headers.addAll(headers);

  try {
    request.fields.addAll(data);
    for (http.MultipartFile file in files) {
      request.files.add(file);
      Utils.print('request file: ' + file.filename!);
    }
  } catch (e) {
    Utils.print("Error adding request : " + e.toString());
    if (hideLoader) Utils.hideLoader();
  }

  try {
    var response = await request.send();
    return returnMutipartResponse(
      response,
      onResponse,
      onError,
      hideLoader,
      shouldLogoutOn401,
    );
  } on SocketException catch (e) {
    Utils.print('SocketException: ${e.toString()}');
    if (onError != null) {
      onError(e);
    }
    Utils.showToast('No Internet Connection');
    if (hideLoader) Utils.hideLoader();
    return;
  } on http.ClientException catch (e) {
    Utils.print('ClientException: ${e.toString()}');
    if (onError != null) {
      onError(e);
    }
    if (e.message.contains('Failed host lookup') ||
        e.message.contains('No address associated')) {
      Utils.showToast('No Internet Connection');
    } else {
      Utils.showToast('Connection Error: ${e.message}');
    }
    if (hideLoader) Utils.hideLoader();
    return;
  } catch (e) {
    if (onError != null) {
      onError(e);
    }
    if (e is! UnauthorisedException) {
      Utils.print('Error: ${e.toString()}');
      Utils.showToast('Something went wrong');
    }
    if (hideLoader) Utils.hideLoader();
  }
}

returnMutipartResponse(
  http.StreamedResponse response,
  Function onResponse,
  Function? onError,
  bool hideLoader,
  bool shouldLogoutOn401,
) async {
  Utils.print('response code:' + response.statusCode.toString());
  Map? responseJson = {};
  try {
    responseJson = json.decode(await response.stream.bytesToString());
    Utils.print('response :' + responseJson.toString());
  } catch (exception) {
    responseJson!['message'] = "Something went wrong";
    Utils.print(exception.toString());
  }
  switch (response.statusCode) {
    case 200:
      if (hideLoader) Utils.hideLoader();
      onResponse(responseJson);
      return 'responseJson';
    case 400:
      Utils.showToast(responseJson!['message']);
      if (onError != null) {
        onError(response);
      }
      if (hideLoader) Utils.hideLoader();
      throw BadRequestException(responseJson.toString());
    case 404:
      if (onError != null) {
        onError(response);
      }
      Utils.hideLoader();
      Utils.showToast(responseJson!['message']);
      throw InvalidInputException(responseJson.toString());
    case 401:
      if (onError != null) {
        onError(response);
      }
      Utils.print('⚠️ 401 Unauthorized for Multipart Request');

      if (shouldLogoutOn401) {
        Utils.showToast('Session expired, please login again');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Get.offAllNamed(AppConstants.routeLogin);
      }
      throw UnauthorisedException(responseJson.toString());
    case 403:
      if (onError != null) {
        onError(response);
      }
      Utils.showToast(responseJson!['message']);
      if (hideLoader) Utils.hideLoader();
      throw UnauthorisedException(responseJson.toString());
    case 500:
    default:
      Utils.showToast(responseJson!['message']);
      if (onError != null) {
        onError(response);
      }
      if (hideLoader) Utils.hideLoader();
      throw FetchDataException(responseJson.toString());
  }
}

Future<TestimonialModel?> getTestimonials(
  TickerProvider? tickerProvider,
) async {
  TestimonialModel? testimonials;
  final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
  await callWebApiGet(
    tickerProvider,
    ApiUrls.testimonials,
    token: token,
    onResponse: (response) {
      testimonials = TestimonialModel.fromJson(jsonDecode(response.body));
    },
    onError: (error) {
      Utils.print('Error fetching testimonials: $error');
    },
    showLoader: false,
    shouldLogoutOn401: false,
  );
  return testimonials;
}

Future<FounderMessageModel?> getFounderMessages(
  TickerProvider? tickerProvider,
) async {
  FounderMessageModel? founderMessages;
  final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
  await callWebApiGet(
    tickerProvider,
    ApiUrls.founderMessages,
    token: token,
    onResponse: (response) {
      founderMessages = FounderMessageModel.fromJson(jsonDecode(response.body));
    },
    onError: (error) {
      Utils.print('Error fetching founder messages: $error');
    },
    showLoader: false,
    shouldLogoutOn401: false,
  );
  return founderMessages;
}

Future<SponsorModel?> getSponsors(TickerProvider? tickerProvider) async {
  SponsorModel? sponsorModel;
  final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
  await callWebApiGet(
    tickerProvider,
    ApiUrls.sponsors,
    token: token,
    onResponse: (response) {
      sponsorModel = SponsorModel.fromJson(jsonDecode(response.body));
    },
    onError: (error) {
      Utils.print('Error fetching sponsors: $error');
    },
    showLoader: false,
    shouldLogoutOn401: false,
  );
  return sponsorModel;
}

Future<ChantingMantra?> getChantingMantras(
  TickerProvider? tickerProvider,
) async {
  ChantingMantra? chantingMantra;
  final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
  await callWebApiGet(
    tickerProvider,
    ApiUrls.chantings,
    token: token,
    onResponse: (response) {
      chantingMantra = ChantingMantra.fromJson(jsonDecode(response.body));
    },
    onError: (error) {
      Utils.print('Error fetching chanting mantras: $error');
    },
    showLoader: false,
    shouldLogoutOn401: false,
  );
  return chantingMantra;
}

Future<AvtarList?> getLiveAvatars(TickerProvider? tickerProvider) async {
  AvtarList? avtarList;
  final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
  await callWebApiGet(
    tickerProvider,
    ApiUrls.liveAvatars,
    token: token,
    onResponse: (response) {
      Utils.print('Live Avatars Response: ' + response.body);
      avtarList = AvtarList.fromJson(jsonDecode(response.body));
    },
    onError: (error) {
      Utils.print('Error fetching live avatars: $error');
    },
    showLoader: false,
    shouldLogoutOn401: false,
  );
  return avtarList;
}

Future<DoshaDashaModel?> getDoshaDasha(
  TickerProvider? tickerProvider,
  String userId,
) async {
  DoshaDashaModel? doshaDashaData;
  final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
  // Construct URL: {{base_url}}/api/client/users/{{user_id}}/doshas
  final url = "${ApiUrls.doshaDasha}/$userId/doshas";

  await callWebApiGet(
    tickerProvider,
    url,
    token: token,
    onResponse: (response) {
      Utils.print('--- DOSHA DASHA RAW API RESPONSE ---');
      Utils.print(response.body);
      doshaDashaData = DoshaDashaModel.fromJson(jsonDecode(response.body));
      Utils.print('--- PARSED DOSHA DASHA DATA ---');
      Utils.print('Has data: ${doshaDashaData?.data != null}');
      Utils.print('Has doshas: ${doshaDashaData?.data?.doshas != null}');
      Utils.print('Has dashas: ${doshaDashaData?.data?.dashas != null}');
    },
    onError: (error) {
      Utils.print('Error fetching dosha dasha data: $error');
    },
    showLoader: false, // Background fetch usually
    shouldLogoutOn401: false,
  );
  return doshaDashaData;
}

Future<BrahmReel?> getBrahmReels(TickerProvider? tickerProvider) async {
  BrahmReel? brahmReel;
  final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
  await callWebApiGet(
    tickerProvider,
    ApiUrls.brahmAvatars,
    token: token,
    onResponse: (response) {
      brahmReel = BrahmReel.fromJson(jsonDecode(response.body));
    },
    onError: (error) {
      Utils.print('Error fetching brahm reels: $error');
    },
    showLoader: false,
    shouldLogoutOn401: false,
  );
  return brahmReel;
}

Future<void> updateUserLocation(
  TickerProvider? tickerProvider,
  double latitude,
  double longitude,
) async {
  final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
  Map data = {"latitude": latitude, "longitude": longitude};
  await callWebApi(
    tickerProvider,
    ApiUrls.updateLocation,
    data,
    token: token,
    showLoader: false,
    onResponse: (response) {
      Utils.print('Location updated successfully');
    },
    onError: (error) {
      Utils.print('Error updating location: $error');
    },
    shouldLogoutOn401: false,
  );
}

Future<GetCurrentLoc?> getReverseGeocode(
  TickerProvider? tickerProvider,
  double latitude,
  double longitude,
) async {
  GetCurrentLoc? result;
  final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
  final url = "${ApiUrls.reverseGeocode}?lat=$latitude&lon=$longitude";

  await callWebApiGet(
    tickerProvider,
    url,
    token: token,
    onResponse: (response) {
      print('DEBUG: getReverseGeocode Raw Response Body: ${response.body}');
      Utils.print('getReverseGeocode Raw Response: ${response.body}');
      result = GetCurrentLoc.fromJson(jsonDecode(response.body));
    },
    onError: (error) {
      Utils.print('Error fetching reverse geocode: $error');
    },
    showLoader: false,
    shouldLogoutOn401: false,
  );
  return result;
}

Future<SpiritualCheckinResponse?> getSpiritualCheckin(
  TickerProvider? tickerProvider,
) async {
  SpiritualCheckinResponse? checkinResponse;
  final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
  await callWebApiGet(
    tickerProvider,
    ApiUrls.spiritualCheckin,
    token: token,
    onResponse: (response) {
      checkinResponse = SpiritualCheckinResponse.fromJson(
        jsonDecode(response.body),
      );
    },
    onError: (error) {
      Utils.print('Error fetching spiritual checkin: $error');
    },
    showLoader: false,
    shouldLogoutOn401: false,
  );
  return checkinResponse;
}

Future<SpiritualConfigurationResponse?> getSpiritualConfigurations(
  TickerProvider? tickerProvider,
  String categoryId,
) async {
  SpiritualConfigurationResponse? configResponse;
  final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
  final url = "${ApiUrls.spiritualConfigurations}?categoryId=$categoryId";

  print("🔍 DEBUG_SPIRITUAL_Configuration: Requesting URL: $url");
  print("🔍 DEBUG_SPIRITUAL_Configuration: CategoryId: $categoryId");

  await callWebApiGet(
    tickerProvider,
    url,
    token: token,
    onResponse: (response) {
      print("✅ DEBUG_SPIRITUAL: Response Status: ${response.statusCode}");
      print("✅ DEBUG_SPIRITUAL: Response Body: ${response.body}");
      try {
        configResponse = SpiritualConfigurationResponse.fromJson(
          jsonDecode(response.body),
        );
        print(
          "✅ DEBUG_SPIRITUAL: Parsed count: ${configResponse?.data?.length}",
        );
      } catch (e) {
        print("❌ DEBUG_SPIRITUAL: Parsing Error: $e");
      }
    },
    onError: (error) {
      print("❌ DEBUG_SPIRITUAL: Error: $error");
      Utils.print('Error fetching spiritual configurations: $error');
    },
    showLoader: false, // Independent loader in controller
    shouldLogoutOn401: false,
  );
  return configResponse;
}

Future<SpiritualClipResponse?> getClipsByConfigurationId(
  TickerProvider? tickerProvider,
  String configurationId,
) async {
  SpiritualClipResponse? clipResponse;
  final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
  final url = "${ApiUrls.spiritualClipsByConfig}/$configurationId";

  print("🔍 DEBUG_CLIPS: Requesting URL: $url");

  await callWebApiGet(
    tickerProvider,
    url,
    token: token,
    onResponse: (response) {
      print("✅ DEBUG_CLIPS: Response Status: ${response.statusCode}");
      print("✅ DEBUG_CLIPS: Response Body: ${response.body}");
      try {
        clipResponse = SpiritualClipResponse.fromJson(
          jsonDecode(response.body),
        );
        print("✅ DEBUG_CLIPS: Parsed count: ${clipResponse?.count}");
      } catch (e) {
        print("❌ DEBUG_CLIPS: Parsing Error: $e");
      }
    },
    onError: (error) {
      print("❌ DEBUG_CLIPS: Error: $error");
      Utils.print('Error fetching spiritual clips: $error');
    },
    showLoader: true,

    shouldLogoutOn401: false,
  );
  return clipResponse;
}

Future<void> saveSpiritualSession(
  TickerProvider? tickerProvider,
  SpiritualSessionRequest request, {
  required Function(Map<String, dynamic>) onSuccess,
  required Function(String) onError,
}) async {
  final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
  final url = ApiUrls.saveSpiritualSession;

  print("🔍 DEBUG_SESSION_SAVE [REQUEST]: URL: $url");
  print(
    "🔍 DEBUG_SESSION_SAVE [REQUEST]: BODY: ${jsonEncode(request.toJson())}",
  );

  await callWebApi(
    tickerProvider,
    url,
    request.toJson(),
    token: token,
    onResponse: (response) {
      print("✅ DEBUG_SESSION_SAVE [RESPONSE]: STATUS: ${response.statusCode}");
      print("✅ DEBUG_SESSION_SAVE [RESPONSE]: BODY: ${response.body}");
      try {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          onSuccess(body);
        } else {
          onError(body['message'] ?? 'Failed to save session');
        }
      } catch (e) {
        onError('Error parsing response');
      }
    },
    onError: (error) {
      if (error is http.Response) {
        try {
          final body = jsonDecode(error.body);
          onError(body['message'] ?? 'Error saving session');
        } catch (_) {
          onError('Error saving session');
        }
      } else {
        onError(error.toString());
      }
    },
    showLoader: true,
    shouldLogoutOn401: false,
  );
}

Future<dynamic> getPanchang(
  TickerProvider? tickerProvider,
  String userId,
) async {
  final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
  final url = "${ApiUrls.panchang}/$userId/panchang";

  Utils.print("🔮 PANCHANG API REQUEST URL: $url");

  dynamic result;
  await callWebApiGet(
    tickerProvider,
    url,
    token: token,
    onResponse: (response) {
      print("📥 Panchang status: ${response.statusCode}");
      print("📥 Panchang body: ${response.body}");
      Utils.print("✅ PANCHANG API RESPONSE: ${response.body}");
      result = jsonDecode(response.body);
    },
    onError: (error) {
      Utils.print("❌ PANCHANG API ERROR: $error");
      if (error is http.Response) {
        print("📥 Panchang status: ${error.statusCode}");
        print("📥 Panchang body: ${error.body}");
        Utils.print("❌ ERROR BODY: ${error.body}");
      }
    },
    showLoader: false,
    shouldLogoutOn401: false,
  );
  return result;
}

Future<UserCompleteDetailsModel?> getUserCompleteDetails(
  TickerProvider? tickerProvider,
  String userId,
) async {
  UserCompleteDetailsModel? userDetails;
  final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
  final url = "${ApiUrls.completeUserDetails}/$userId/complete-details";

  await callWebApiGet(
    tickerProvider,
    url,
    token: token,
    onResponse: (response) {
      debugPrint('************************************************');
      debugPrint('🚀 ASTROLOGY DATA RESPONSE (Complete Details): $url');
      // Print in chunks to avoid console truncation
      // Print the full response using developer log to avoid truncation
      log(response.body, name: 'ASTROLOGY_DATA');
      debugPrint('************************************************');

      try {
        userDetails = UserCompleteDetailsModel.fromJson(
          jsonDecode(response.body),
        );
        debugPrint('✅ Parsed UserCompleteDetailsModel successfully');
        debugPrint('   - Has Doshas: ${userDetails?.data?.doshas != null}');
        debugPrint('   - Has Dashas: ${userDetails?.data?.dashas != null}');
      } catch (e, stack) {
        debugPrint('❌ ERROR parsing UserCompleteDetailsModel: $e');
        debugPrint(stack.toString());
      }
    },
    onError: (error) {
      Utils.print('Error fetching user complete details: $error');
    },
    showLoader: false,
    shouldLogoutOn401: false,
  );
  return userDetails;
}

Future<NumerologyHistoryResponse?> getNumerologyHistory(
  TickerProvider? tickerProvider,
  String userId, {
  int limit = 10,
  int skip = 0,
}) async {
  NumerologyHistoryResponse? responseModel;
  final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
  final url =
      "${ApiUrls.numerologyHistory}/$userId/numerology/history?limit=$limit&skip=$skip";

  Utils.print("🔮 NUMEROLOGY HISTORY API REQUEST URL: $url");

  await callWebApiGet(
    tickerProvider,
    url,
    token: token,
    onResponse: (response) {
      Utils.print("✅ NUMEROLOGY HISTORY API RESPONSE: ${response.body}");
      responseModel = NumerologyHistoryResponse.fromJson(
        jsonDecode(response.body),
      );
    },
    onError: (error) {
      Utils.print("❌ NUMEROLOGY HISTORY API ERROR: $error");
    },
    showLoader: false,
    shouldLogoutOn401: false,
  );
  return responseModel;
}

Future<NumerologyDetailResponse?> getNumerologyDetail(
  TickerProvider? tickerProvider,
  String userId,
) async {
  NumerologyDetailResponse? responseModel;
  final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
  final url = "${ApiUrls.numerologyDetail}/$userId/numerology";

  Utils.print("🔮 NUMEROLOGY DETAIL API REQUEST URL: $url");

  await callWebApiGet(
    tickerProvider,
    url,
    token: token,
    onResponse: (response) {
      Utils.print("✅ NUMEROLOGY DETAIL API RESPONSE: ${response.body}");
      responseModel = NumerologyDetailResponse.fromJson(
        jsonDecode(response.body),
      );
    },
    onError: (error) {
      Utils.print("❌ NUMEROLOGY DETAIL API ERROR: $error");
    },
    showLoader: false,
    shouldLogoutOn401: false,
  );
  return responseModel;
}

Future<RemediesModel?> getRemedies(
  TickerProvider? tickerProvider,
  String userId,
) async {
  RemediesModel? remediesModel;
  final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
  final url =
      "${ApiUrls.baseUrl}/api/client/users/$userId/remedies"; // Construct URL dynamically
  await callWebApiGet(
    tickerProvider,
    url,
    token: token,
    onResponse: (response) {
      remediesModel = RemediesModel.fromJson(jsonDecode(response.body));
    },
    onError: (error) {
      Utils.print('Error fetching remedies: $error');
    },
    showLoader: false,
    shouldLogoutOn401: false,
  );
  return remediesModel;
}
