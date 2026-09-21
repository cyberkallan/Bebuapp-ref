abstract class Api {
  /// server url
  /// Overridable per build: --dart-define=API_BASE_URL=https://example.com/
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://bebu.145.223.79.74.sslip.io/',
  );
  static const secretKey = String.fromEnvironment(
    'API_SECRET_KEY',
    defaultValue: 'de0c55bcc70dbbfdc7c728101da4a786076d95ebc4ab5934',
  );

  // >>>>> >>>>> Login Page Api <<<<< <<<<<
  static const checkUserExit = "${baseUrl}api/user/verifyUserExistence?";
  static const login = "${baseUrl}api/user/authenticateOrRegisterUser";

  // >>>>> >>>>> Login User Profile Api <<<<< <<<<<
  static const loginUserProfile = "${baseUrl}api/user/getUserProfile";

  // >>>>> >>>>>  User  Api <<<<< <<<<<
  static const editProfile = "${baseUrl}api/user/updateUserProfile";
  static const faq = "${baseUrl}api/user/faq/listFaqs?";
  static const identityProofs = "${baseUrl}api/user/identityProof/listIdentityProofs";
  static const getTalkTopics = "${baseUrl}api/user/talkTopic/getTalkTopics";
  static const becomeHost = "${baseUrl}api/user/listener/initiateListenerRequest";
  static const listenersRequestCheck = "${baseUrl}api/user/listener/verifyListenerRequestStatus";
  static const settingAPi = "${baseUrl}api/user/setting/fetchAppSettingsData";
  static const forgotPassword = "${baseUrl}api/user/resetPassword?";
  static const topListeners = "${baseUrl}api/user/listener/fetchTopListeners?";
  static const allListeners = "${baseUrl}api/user/listener/fetchFilteredListeners?";
  static const listenerProfile = "${baseUrl}api/user/listener/getListenerProfile?";
  static const callingHistory = "${baseUrl}api/user/history/getCallRecords?";
  static const chatListApi = "${baseUrl}api/user/chatTopic/getUserChatList?";
  static const personalChatApi = "${baseUrl}api/user/chat/retrieveChatHistory?";
  static const sendImageAudioApi = "${baseUrl}api/user/chat/sendChatMessage";
  static const purchasedCoinPlan = "${baseUrl}api/user/coinplan/recordPurchasedCoinPlan?";
  static const availableListener = "${baseUrl}api/user/listener/retrieveAvailableListener";
  static const paymentHistory = "${baseUrl}api/user/history/getCoinPackagePurchaseHistory?";
  static const coinHistory = "${baseUrl}api/user/history/getCoinWalletRecords?";
  static const userCoin = "${baseUrl}api/user/retrieveUserCoinBalance";
  static const userNotification = "${baseUrl}api/user/notification/getNotificationHistory";
  static const updateUserNotificationPermission = "${baseUrl}api/user/modifyNotificationPermission";

  static const submitCallRate = "${baseUrl}api/user/rating/submitListenerReview?";
  static const searchChatUser = "${baseUrl}api/user/chatTopic/findChattedListenersBySearch?";
  static const notificationClear = "${baseUrl}api/user/notification/clearNotifications";
  static const deleteUserAccount = "${baseUrl}api/user/deleteSelfAccount";
  static const listenerReviewApi = "${baseUrl}api/user/rating/fetchListenerReviews?";
  static const appConfigurationApi = "${baseUrl}api/user/setting/getAppConfiguration";

  // >>>>> >>>>>  Listener  Api <<<<< <<<<<

  static const loginListenerProfile = "${baseUrl}api/listener/fetchListenerProfile?";
  static const listenerEditProfile = "${baseUrl}api/listener/modifyListenerProfile?";
  static const listenerChatListApi = "${baseUrl}api/listener/chatTopic/getChatList?";
  static const listenerPersonalChatListApi = "${baseUrl}api/listener/chat/getChatHistory?";
  static const listenerSendImageAudioApi = "${baseUrl}api/listener/chat/dispatchChatMessage";
  static const listenerCallingHistory = "${baseUrl}api/listener/history/retrieveCallHistory?";
  static const listenerCoinHistory = "${baseUrl}api/listener/history/fetchCoinWalletHistory?";
  static const paymentOptions = "${baseUrl}api/listener/paymentOption/getAvailablePaymentOptions";
  static const withdrawalRecord = "${baseUrl}api/listener/withdrawalRecord/getPayoutRecords?";
  static const addWithdrawalRecord = "${baseUrl}api/listener/withdrawalRecord/addWithdrawalRecord";
  static const updateRandomCallStatus = "${baseUrl}api/listener/toggleListenerCall?";
  static const listenerCoin = "${baseUrl}api/listener/getListenerCoinBalance?";
  static const updateNotifyPermission = "${baseUrl}api/listener/updateNotifyPermission?";
  static const searchChatListener = "${baseUrl}api/listener/chatTopic/searchChattedUsers?";
  static const notificationListener = "${baseUrl}api/listener/notification/fetchNotifications?";
  static const clearNotificationListener = "${baseUrl}api/listener/notification/resetNotificationHistory?";
  static const deleteListenerAccount = "${baseUrl}api/listener/deleteListenerAccount?";
  static const userProfileApi = "${baseUrl}api/listener/getProfileByUserId?";

  static const ipApi = "http://ip-api.com/json";

  // >>>>> >>>>>  Coin Plan <<<<< <<<<<

  static const fetchCoinPlan = "${baseUrl}api/user/coinplan/getAvailableCoinPackage";
}
