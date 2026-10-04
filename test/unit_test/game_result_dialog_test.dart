import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futblha/application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/data/datasources/games_remote_datasource/games_remote_datasource.dart';
import 'package:futblha/data/models/request_model/games/add_game_result_request_model.dart';
import 'package:futblha/data/models/response_model/diwaniya/diwaniya_model.dart';
import 'package:futblha/data/models/response_model/games/game_model.dart';
import 'package:futblha/presentation/pages/games/bloc/games_bloc.dart';
import 'package:futblha/presentation/pages/home/widgets/game_result_dialog.dart';
import 'package:futblha/presentation/widgets/game_result_bottom_sheet.dart';

void main() {
  late List<PageRouteInfo> pushedRoutes;
  late List<GamesEvent> addedEvents;
  late GamesBloc gamesBloc;

  /// Dummy game with both diwaniyas for full-cycle tests (navigation + bloc).
  GameModel dummyGame() => GameModel(
        id: 42,
        type: 'public',
        creatorDiwaniya: DiwaniyaModel(name: 'Team1', image: 'https://team1.png'),
        opponentDiwaniya: DiwaniyaModel(name: 'Team2', image: 'https://team2.png'),
      );

  setUp(() {
    pushedRoutes = [];
    addedEvents = [];
    // Use a minimal fake that only records; bloc is not used for processing in these tests.
    gamesBloc = _RecordingGamesBloc(addedEvents);
  });

  group('GameResultDialog.applyResultAfterSelection', () {
    const team1Name = 'Team1';
    const team1Image = 'https://team1.png';
    const team2Name = 'Team2';
    const team2Image = 'https://team2.png';

    Future<T?> pushRoute<T extends Object?>(PageRouteInfo<T> route) async {
      pushedRoutes.add(route);
      return null;
    }

    test('team1Win: pushes HowWasOpposingTeamRoute with team2 and adds win event', () async {
      await GameResultDialog.applyResultAfterSelection(
        game: dummyGame(),
        result: GameResult.team1Win,
        team1Name: team1Name,
        team1Image: team1Image,
        team2Name: team2Name,
        team2Image: team2Image,
        pushRoute: pushRoute,
        gamesBloc: gamesBloc,
      );

      expect(pushedRoutes.length, 1);
      expect(pushedRoutes.first, isA<HowWasOpposingTeamRoute>());
      final route = pushedRoutes.first as HowWasOpposingTeamRoute;
      expect(route.args!.teamName, team2Name);
      expect(route.args!.teamImage, team2Image);
      expect(route.args!.gameId, 42);

      expect(addedEvents.length, 1);
      expect(addedEvents.first, isA<AddGameResultEvent>());
      final event = addedEvents.first as AddGameResultEvent;
      expect(event.gameId, 42);
      expect(event.request.result, 'win');
    });

    test('tie: pushes HowWasOpposingTeamRoute with team2 and adds draw event', () async {
      await GameResultDialog.applyResultAfterSelection(
        game: dummyGame(),
        result: GameResult.tie,
        team1Name: team1Name,
        team1Image: team1Image,
        team2Name: team2Name,
        team2Image: team2Image,
        pushRoute: pushRoute,
        gamesBloc: gamesBloc,
      );

      expect(pushedRoutes.length, 1);
      final route = pushedRoutes.first as HowWasOpposingTeamRoute;
      expect(route.args!.teamName, team2Name);
      expect(route.args!.teamImage, team2Image);

      expect(addedEvents.length, 1);
      expect((addedEvents.first as AddGameResultEvent).request.result, 'draw');
    });

    test('team2Win: pushes HowWasOpposingTeamRoute with team1 and adds lose event', () async {
      await GameResultDialog.applyResultAfterSelection(
        game: dummyGame(),
        result: GameResult.team2Win,
        team1Name: team1Name,
        team1Image: team1Image,
        team2Name: team2Name,
        team2Image: team2Image,
        pushRoute: pushRoute,
        gamesBloc: gamesBloc,
      );

      expect(pushedRoutes.length, 1);
      final route = pushedRoutes.first as HowWasOpposingTeamRoute;
      expect(route.args!.teamName, team1Name);
      expect(route.args!.teamImage, team1Image);

      expect(addedEvents.length, 1);
      expect((addedEvents.first as AddGameResultEvent).request.result, 'lose');
    });

    test('when opponentDiwaniya is null: does not push route but still adds event', () async {
      final gameNoOpponent = GameModel(
        id: 99,
        type: 'public',
        creatorDiwaniya: DiwaniyaModel(name: 'Team1', image: null),
        opponentDiwaniya: null,
      );

      await GameResultDialog.applyResultAfterSelection(
        game: gameNoOpponent,
        result: GameResult.team1Win,
        team1Name: 'Team1',
        team1Image: null,
        team2Name: 'Opposing',
        team2Image: null,
        pushRoute: pushRoute,
        gamesBloc: gamesBloc,
      );

      expect(pushedRoutes, isEmpty);
      expect(addedEvents.length, 1);
      expect((addedEvents.first as AddGameResultEvent).gameId, 99);
      expect((addedEvents.first as AddGameResultEvent).request.result, 'win');
    });

    test('when game id is null: does not add event but still pushes if both diwaniyas present',
        () async {
      final gameNoId = GameModel(
        id: null,
        type: 'public',
        creatorDiwaniya: DiwaniyaModel(name: 'A', image: null),
        opponentDiwaniya: DiwaniyaModel(name: 'B', image: null),
      );

      await GameResultDialog.applyResultAfterSelection(
        game: gameNoId,
        result: GameResult.tie,
        team1Name: 'A',
        team1Image: null,
        team2Name: 'B',
        team2Image: null,
        pushRoute: pushRoute,
        gamesBloc: gamesBloc,
      );

      expect(pushedRoutes.length, 1);
      expect(addedEvents, isEmpty);
    });
  });
}

/// Minimal GamesBloc that records added events; used only in tests.
class _RecordingGamesBloc extends GamesBloc {
  _RecordingGamesBloc(this._recorded) : super(_FakeGamesRemoteDataSource());

  final List<GamesEvent> _recorded;

  @override
  void add(GamesEvent event) {
    _recorded.add(event);
    super.add(event);
  }
}

/// Minimal data source so _RecordingGamesBloc can process AddGameResultEvent.
class _FakeGamesRemoteDataSource implements GamesRemoteDataSource {
  @override
  Future<ApiResultModel<String?>> addGameResult({
    required int gameId,
    required AddGameResultRequestModel request,
  }) async =>
      ApiResultModel.success(data: 'ok');

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
