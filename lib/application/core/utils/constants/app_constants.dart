// timeout request constants
// ignore_for_file: non_constant_identifier_names

const String commonErrorUnexpectedMessage = 'Something went wrong please try again';
const int timeoutRequestStatusCode = 1000;
const int unAuthorizedStatusCode = 401;
const int badRequestStatusCode = 400;

/// app flavors strings
const String devEnvironmentString = 'DEV';
const String qaEnvironmentString = 'QA';
const String sitEnvironmentString = 'SIT';
const String uatEnvironmentString = 'UAT';
const String prodEnvironmentString = 'PROD';

///  IOException request constants
const String commonConnectionFailedMessage = 'Please check your Internet Connection';
const int ioExceptionStatusCode = 900;

///  Format Exception request constants
const String formatExceptionMessage = 'Invalid JSON format.';
const int formatExceptionStatusCode = 0;

/// http client header constants

const String acceptLanguageKey = 'Accept-Language';
const String acceptKey = 'Accept';
const String authorisationKey = 'Authorization';
const String bearerKey = 'Bearer ';
const String contentTypeKey = 'Content-Type';
const String contentTypeValue = 'application/json';
const String contentMultipartTypeValue = 'multipart/form-data';

///countryCode
const String countryCodeKey = "+965";

///error
const String errorMessage = "error";

///default
const String FontFamily = 'SF Arabic';

///This is the time limit for every api call
const Duration timeOutDuration = Duration(seconds: 20);

const String appStoreLink = 'https://apps.apple.com/eg/app/futblha/id6751204866';
const String playStoreLink = 'https://play.google.com/store/apps/details?id=com.raiyansoft.futblha';

const String devBaseUrl = 'https://futblha.com/api';
const String prodBaseUrl = 'https://futblha.com/api';
const String qaBaseUrl = 'https://futblha.com/api';
const String uatBaseUrl = 'https://futblha.com/api';

const String Login = '/auth/login';
const String Register = '/auth/register';
const String Logout = '/auth/logout';
const String GetProfile = '/auth/profile';
const String UpdateProfile = '/auth/profile';
const String ActivateAccount = '/auth/verify-code';
const String UpdateUserSettings = '/auth/update-setting';
const String CompleteProfile = '/auth/complete-profile';
const String DeleteAccount = '/auth/delete';
const String Settings = '/settings';
const String PaymentMethod = '/payment-methods';

// const String Faqs = '/faqs';
const String Contact = '/contact-us';
// const String SocialLinks = '/get-social-links';

// General
const String Countries = '/countries';
const String Cities = '/cities';
const String Positions = '/positions';
const String Home = '/home';

// Playgrounds
const String LandTypes = '/land-types';
const String Facilities = '/facilities';
const String Capacities = '/capacities';
const String Playgrounds = '/playgrounds';
const String Bookings = '/bookings';
const String Vouchers = '/vouchers';
const String AddRate = '/add-rate';

// Wallet
const String AddBalance = '/add-balance';
const String Transactions = '/transactions';

// Diwaniya
const String DiwaniyaTypes = '/diwaniya-types';
const String Diwaniyas = '/diwaniyas';
const String DiwaniyasOverview = '/diwaniyas-overview';
const String DiwaniyaRanking = '/diwaniya-ranking';
const String Vote = '/vote';

// Games
const String Games = '/games';
const String GamesInvitation = '/games-invitation';
const String GameHistory = '/game-history';
const String GamesResult = '/games-result';
const String ActiveGames = '/active-games';
const String GamesUpcoming = '/games-upcoming';

///notifications
const String GetNotifications = '/notifications';
// const String MarkAllRead = '/mobile/api/DriverTaskNotification/MarkAsRead';
// const String GetUnReadCount = '/mobile/api/DriverTaskNotification/GetUnReadCount';
// const String ClearNotification = '/mobile/api/DriverTaskNotification/Clear';

const String userIdKey = 'userId';
const String customerIdKey = 'customerId';
const String docTypesKey = 'docTypes';
const String appCenterKey = "df7d58fe-0da0-4714-8a92-75f0eb160519";
