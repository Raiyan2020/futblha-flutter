import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import '../../../../presentation/pages/about/about_page.dart';
import '../../../../presentation/pages/chat/chat_page.dart';
import '../../../../presentation/pages/diwaniyat/bloc/diwaniya_bloc.dart';
import '../../../../presentation/pages/diwaniyat/create_diwaniya_page.dart';
import '../../../../presentation/pages/diwaniyat/diwaniya_ranking_page.dart';
import '../../../../presentation/pages/diwaniyat/diwaniyat_settings_page.dart';
import '../../../../presentation/pages/diwaniyat/join_requests_page.dart';
import '../../../../presentation/pages/faq/faq_page.dart';
import '../../../../presentation/pages/games/bloc/games_bloc.dart';
import '../../../../presentation/pages/games/confirm_game_booking_page.dart';
import '../../../../presentation/pages/payment_method/payment_web_view_page.dart';
import '../../../../presentation/pages/auth/complete_profile_page.dart';
import '../../../../presentation/pages/auth/login_page.dart';
import '../../../../presentation/pages/auth/pin_code_page.dart';
import '../../../../presentation/pages/auth/register_page.dart';
import '../../../../presentation/pages/home/home_page.dart';
import '../../../../presentation/pages/landing/landing_page.dart';
import '../../../../presentation/pages/diwaniyat/diwaniyat_page.dart';
import '../../../../presentation/pages/games/game_details_page.dart';
import '../../../../presentation/pages/diwaniyat/games_history_page.dart';
import '../../../../presentation/pages/games/join_game_page.dart';
import '../../../../presentation/pages/games/joined_players.dart';
import '../../../../presentation/pages/diwaniyat/members_page.dart';
import '../../../../presentation/pages/language/language_screen.dart';
import '../../../../presentation/pages/maintenance/maintenance_screen.dart';
import '../../../../presentation/pages/playgrounds/playgrounds_list_page.dart';
import '../../../../presentation/pages/playgrounds/playground_details_page.dart';
import '../../../../presentation/pages/playgrounds/book_playground_page.dart';
import '../../../../presentation/pages/playgrounds/confirm_booking_page.dart';
import '../../../../data/models/response_model/playgrounds/playground_model.dart';
import '../../../../presentation/pages/diwaniyat/game_type_selection_page.dart';
import '../../../../presentation/pages/games/create_game_page.dart';
import '../../../../presentation/pages/diwaniyat/playground_selection_page.dart';
import '../../../../presentation/pages/diwaniyat/opposing_diwaniya_selection_page.dart';
import '../../../../presentation/pages/diwaniyat/diwaniya_details_page.dart';
import '../../../../presentation/pages/games/active_games_page.dart';
import '../../../../presentation/pages/games/games_invitations_page.dart';
import '../../../../presentation/pages/games/how_was_opposing_team_page.dart';
import '../../../../presentation/pages/games/my_games_history_page.dart';
import '../../../../presentation/pages/games/my_upcoming_games_page.dart';
import '../../../../presentation/pages/notifications/notification_page.dart';
import '../../../../presentation/pages/profile/edit_profile_page.dart';
import '../../../../presentation/pages/bookings/my_bookings_page.dart';
import '../../../../presentation/pages/bookings/booking_details_page.dart';
import '../../../../presentation/pages/profile/profile_page.dart';
import '../../../../presentation/pages/profile/edit_positions_page.dart';
import '../../../../presentation/pages/wallet/wallet_page.dart';
import '../../../../presentation/pages/wallet/charge_wallet_page.dart';
import '../../../../presentation/pages/settings/settings_page.dart';
import '../../../../presentation/pages/splash/splash_screen.dart';
import '../../../../presentation/pages/support/support_page.dart';
import '../../../../presentation/widgets/custom_success_screen_widget.dart';

part 'app_router.gr.dart';

@singleton
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: MaintenanceRoute.page),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: RegisterRoute.page),
    AutoRoute(page: PinCodeVerificationRoute.page),
    AutoRoute(page: CompleteProfileRoute.page),
    AutoRoute(page: LanguageRoute.page),
    AutoRoute(
      page: LandingRoute.page,
      children: [
        AutoRoute(page: HomeRoute.page, maintainState: false),
        AutoRoute(page: DiwaniyatRoute.page, maintainState: false),
        AutoRoute(page: ProfileRoute.page, maintainState: false),
      ],
    ),
    AutoRoute(page: PaymentWebViewRoute.page),
    AutoRoute(page: AboutRoute.page),
    AutoRoute(page: FaqRoute.page),
    AutoRoute(page: NotificationsRoute.page),
    AutoRoute(page: SettingsRoute.page),
    AutoRoute(page: SupportRoute.page),
    AutoRoute(page: CustomSuccessRoute.page),
    AutoRoute(page: EditProfileRoute.page),
    AutoRoute(page: CreateDiwaniyaRoute.page),
    AutoRoute(page: DiwaniyaSettingsRoute.page),
    AutoRoute(page: DiwaniyaRankingRoute.page),
    AutoRoute(page: JoinRequestsRoute.page),
    AutoRoute(page: ChatRoute.page),
    AutoRoute(page: GamesHistoryRoute.page),
    AutoRoute(page: MembersRoute.page),
    AutoRoute(page: GameDetailsRoute.page),
    AutoRoute(page: JoinGameRoute.page),
    AutoRoute(page: JoinedPlayersRoute.page),
    AutoRoute(page: PlaygroundsListRoute.page),
    AutoRoute(page: PlaygroundDetailsRoute.page),
    AutoRoute(page: BookPlaygroundRoute.page),
    AutoRoute(page: ConfirmBookingRoute.page),
    AutoRoute(page: GameTypeSelectionRoute.page),
    AutoRoute(page: CreateGameRoute.page),
    AutoRoute(page: PlaygroundSelectionRoute.page),
    AutoRoute(page: OpposingDiwaniyaSelectionRoute.page),
    AutoRoute(page: DiwaniyaDetailsRoute.page),
    AutoRoute(page: ActiveGamesRoute.page),
    AutoRoute(page: GamesInvitationsRoute.page),
    AutoRoute(page: MyUpcomingGamesRoute.page),
    AutoRoute(page: HowWasOpposingTeamRoute.page),
    AutoRoute(page: MyGamesHistoryRoute.page),
    AutoRoute(page: MyBookingsRoute.page),
    AutoRoute(page: BookingDetailsRoute.page),
    AutoRoute(page: WalletRoute.page),
    AutoRoute(page: ChargeWalletRoute.page),
    AutoRoute(page: EditPositionsRoute.page),
  ];
}
