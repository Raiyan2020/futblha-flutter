import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:futblha/application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import 'package:futblha/application/core/commundomain/entitties/based_api_result/error_result_model.dart';
import 'package:futblha/data/datasources/playgrounds_remote_datasource/playgrounds_remote_datasource.dart';
import 'package:futblha/data/models/response_model/playgrounds/available_slot_model.dart';
import 'package:futblha/data/models/response_model/playgrounds/playground_detail_response_model.dart';
import 'package:futblha/presentation/pages/playgrounds/bloc/playgrounds_bloc.dart';

/// Answers each details request only when the test completes it, so tests
/// can control the order responses arrive in.
class _ControlledDataSource implements PlaygroundsRemoteDataSource {
  final pending = <String, Completer<ApiResultModel<PlaygroundDetailResponseModel?>>>{};

  @override
  Future<ApiResultModel<PlaygroundDetailResponseModel?>> getPlaygroundDetails({
    required int playgroundId,
    String? date,
  }) {
    final completer = Completer<ApiResultModel<PlaygroundDetailResponseModel?>>();
    pending['$playgroundId@$date'] = completer;
    return completer.future;
  }

  void respond(String key, String slotStart) {
    pending[key]!.complete(
      ApiResultModel.success(
        data: PlaygroundDetailResponseModel(
          availableSlots: [AvailableSlotModel(startAt: slotStart, endAt: '23:00', available: true)],
        ),
      ),
    );
  }

  void fail(String key) {
    pending[key]!.complete(
      const ApiResultModel.failure(
        errorResultEntity: ErrorResultModel(message: 'boom', statusCode: 500),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  late _ControlledDataSource dataSource;
  late PlaygroundsBloc bloc;

  setUp(() {
    dataSource = _ControlledDataSource();
    bloc = PlaygroundsBloc(dataSource);
  });

  tearDown(() => bloc.close());

  test('a slow response for an older date does not overwrite the newer date', () async {
    bloc.add(const GetPlaygroundDetailsEvent(playgroundId: 1, date: '2026-10-15'));
    await _flush();
    bloc.add(const GetPlaygroundDetailsEvent(playgroundId: 1, date: '2026-10-16'));
    await _flush();

    // Newer date answers first, then the older one arrives late.
    dataSource.respond('1@2026-10-16', '20:00');
    await _flush();
    dataSource.respond('1@2026-10-15', '17:00');
    await _flush();

    expect(bloc.playgroundDetailsDate, '2026-10-16');
    expect(bloc.playgroundDetails?.availableSlots?.single.startAt, '20:00');
    expect(bloc.state, isA<PlaygroundsSuccess>());
  });

  test('a stale response for another playground is ignored', () async {
    bloc.add(const GetPlaygroundDetailsEvent(playgroundId: 1, date: '2026-10-15'));
    await _flush();
    bloc.add(const GetPlaygroundDetailsEvent(playgroundId: 2, date: '2026-10-15'));
    await _flush();

    dataSource.respond('2@2026-10-15', '20:00');
    await _flush();
    dataSource.respond('1@2026-10-15', '17:00');
    await _flush();

    expect(bloc.playgroundDetailsPlaygroundId, 2);
    expect(bloc.playgroundDetails?.availableSlots?.single.startAt, '20:00');
  });

  test('a stale error does not replace the newer successful result', () async {
    bloc.add(const GetPlaygroundDetailsEvent(playgroundId: 1, date: '2026-10-15'));
    await _flush();
    bloc.add(const GetPlaygroundDetailsEvent(playgroundId: 1, date: '2026-10-16'));
    await _flush();

    dataSource.respond('1@2026-10-16', '20:00');
    await _flush();
    dataSource.fail('1@2026-10-15');
    await _flush();

    expect(bloc.state, isA<PlaygroundsSuccess>());
    expect(bloc.playgroundDetailsDate, '2026-10-16');
  });

  test('a failed load keeps the date of the last successful result', () async {
    bloc.add(const GetPlaygroundDetailsEvent(playgroundId: 1, date: '2026-10-15'));
    await _flush();
    dataSource.respond('1@2026-10-15', '17:00');
    await _flush();

    bloc.add(const GetPlaygroundDetailsEvent(playgroundId: 1, date: '2026-10-16'));
    await _flush();
    dataSource.fail('1@2026-10-16');
    await _flush();

    // The page compares this with the selected date, so old slots aren't shown
    // as if they belonged to the new date.
    expect(bloc.state, isA<PlaygroundsError>());
    expect(bloc.playgroundDetailsDate, '2026-10-15');
  });
}
