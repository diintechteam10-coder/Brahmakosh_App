class ApiUrls {
  /// 🔹 Base URL
  //static const String baseUrl = 'https://backend-jfg8.onrender.com';
  //static const String baseUrl = 'https://stage.brahmakosh.com';
  static const String baseUrl = 'https://prod.brahmakosh.com';

  /// 🔹 Common API path
  static const String apiUrl = '$baseUrl/api/mobile';
  static const String chatApiUrl = '$baseUrl/api/chat';
  static const String socketUrl = '$baseUrl/';

  /// 🔹 Auth APIs
  static const String register = '$apiUrl/user/register';
  static const String login = '$apiUrl/user/login';
  static const String emailRegister = '$apiUrl/user/register/step1';
  static const String mobileRegister = '$apiUrl/user/register/step2';
  static const String mobileVerify = '$apiUrl/user/register/step2/verify';
  static const String completeProfile = '$apiUrl/user/register/step3';
  static const String checkUser = '$apiUrl/user/check-email';

  ///
  static const String getProfile = '$apiUrl/user/profile';
  static const String uploadProfileImage = '$apiUrl/user/profile/image';

  /// 🔹 Forgot Password APIs
  static const String forgotPassword = '$baseUrl/api/auth/user/forgot-password';
  static const String verifyResetOtp =
      '$baseUrl/api/auth/user/verify-reset-otp';
  static const String resetPassword = '$baseUrl/api/auth/user/reset-password';

  /// 🔹 Testimonials
  static const String testimonials = '$baseUrl/api/testimonials';
  static const String founderMessages = '$baseUrl/api/founder-messages';
  static const String sponsors = '$baseUrl/api/sponsors';
  static const String chantings = '$baseUrl/api/chantings';
  static const String liveAvatars = '$baseUrl/api/live-avatars';

  ///Sadhna APIs
  static const String sadhnaServices = '$baseUrl/api/expert-categories';
  static const String experts = '$baseUrl/api/experts';
  static const String brahmAvatars = '$baseUrl/api/brahm-avatars';
  static const String updateLocation = '$apiUrl/user/get-location';
  static const String reverseGeocode = '$apiUrl/user/reverse-geocode';
  static const String spiritualCheckin = '$apiUrl/content/spiritual-checkin';
  static const String spiritualConfigurations =
      '$baseUrl/api/spiritual-configurations';
  static const String spiritualClipsByConfig =
      '$baseUrl/api/spiritual-clips/configuration';
  static const String saveSpiritualSession =
      '$baseUrl/api/spiritual-stats/save-session';
  static const String spiritualStatsUser = '$baseUrl/api/spiritual-stats/user';
  static const String panchang = '$baseUrl/api/client/users';
  static const String completeUserDetails = '$baseUrl/api/client/users';
  static const String numerologyHistory = '$baseUrl/api/client/users';
  static const String numerologyDetail = '$baseUrl/api/client/users';
  static const String doshaDasha = '$baseUrl/api/client/users';

  /// 🔹 Gita APIs
  static const String gitaChapters = '$baseUrl/api/chapters';
  static const String gitaVerses = '$baseUrl/api/shlokas/chapter';
  static const String gitaVerseDetail = '$baseUrl/api/shlokas';

  /// 🔹 Spiritual Rewards
  static const String spiritualRewards = '$baseUrl/api/spiritual-rewards';
  static const String redeemReward = '$baseUrl/api/reward-redemptions/redeem';
  static const String redemptionHistory =
      '$baseUrl/api/reward-redemptions/history';

  /// 🔹 Pooja APIs
  static const String poojaList = '$baseUrl/api/puja-padhati';

  /// 🔹 Sankalp APIs
  static const String sankalpList = '$baseUrl/api/sankalp';
  static const String userSankalps = '$baseUrl/api/user-sankalp/my-sankalpas';
  static const String joinSankalp = '$baseUrl/api/user-sankalp/join';
  static const String userSankalpBase = '$baseUrl/api/user-sankalp';

  /// 🔹 Chat & Socket APIs
  static const String chatPartners = '$chatApiUrl/partners';
  static const String chatHistory =
      '$chatApiUrl/partner/requests'; // Added for history
  static const String callHistory =
      '$chatApiUrl/voice/calls/history/user'; // Added for voice call history
  static const String createConversation = '$chatApiUrl/conversations';
  static const String getConversations = '$chatApiUrl/conversations';
  static const String getChatMessages =
      '$chatApiUrl/conversations'; // /{conversationId}/messages
  static const String endConversation =
      '$chatApiUrl/conversations'; // /{conversationId}/end
  static const String userCreditBalance = '$chatApiUrl/credits/balance/user';
  static const String markConversationRead =
      '$chatApiUrl/conversations'; // /{conversationId}/read
  static const String submitFeedback =
      '$chatApiUrl/conversations'; // /{id}/feedback
  static const String unreadCount = '$chatApiUrl/unread-count';
  static const String creditHistory = '$chatApiUrl/credits/history/user';
  static const String voiceRecordingUploadUrl =
      '$chatApiUrl/voice/recording/upload-url';
  static const String voiceRecordingAttach =
      '$chatApiUrl/conversations'; // /:conversationId/voice-recording
  static const String presignedUrl = '$baseUrl/api/upload/presigned-url';
  static const String notifications = '$baseUrl/api/notifications';

  /// 🔹 Swapna Decoder APIs
  static const String swapnaDecoder = '$baseUrl/api/swapna-decoder';
  static const String dreamRequests = '$baseUrl/api/dream-requests';
}
