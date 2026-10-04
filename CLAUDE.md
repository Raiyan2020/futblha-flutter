# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Futblha is a Flutter app (Dart SDK ^3.10) for organizing football "Diwaniyat" (groups), games, playground bookings, wallet payments, and chat. Supports Arabic and English (RTL/LTR) and light/dark themes. Backend is a REST API at `https://futblha.com/api`.

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # required after changing any annotated class (see below)
flutter run
flutter analyze
flutter test                                               # all tests
flutter test test/unit_test/calculator_test.dart           # single file
flutter test --plain-name "test name"                      # single test by name
./test_deep_link.sh [android|ios]                          # fire a diwaniya deep link at a running emulator/simulator
```

Regenerate locale keys after editing `assets/l10n/en.json` / `ar.json`:
```bash
dart run easy_localization:generate -S assets/l10n -f keys -O lib/generated -o locale_keys.g.dart
```

## Code generation

Never hand-edit generated files; rerun build_runner instead:
- `app_component.config.dart` — injectable/get_it registrations. Any new `@injectable` / `@singleton` / `@Injectable(as: ...)` class won't be resolvable from `locator` until regenerated.
- `app_router.gr.dart` — auto_route routes from `@RoutePage()` pages. New pages must also be added to the routes list in `app_router.dart`.
- `*.freezed.dart`, `*.g.dart` — freezed unions and json_serializable models.
- `lib/generated/locale_keys.g.dart` — easy_localization keys (`LocaleKeys.xxx.tr()`).

## Architecture

Folders follow a Clean Architecture layout (`application/`, `data/`, `domain/`, `presentation/`), but in practice there is **no repository or use-case layer in use**: Blocs inject the remote datasource directly.

Request flow for a feature (e.g. wallet):

1. **Endpoint constant** — path strings live in `lib/application/core/utils/constants/app_constants.dart` (grouped by feature comments, e.g. `AddBalance = '/add-balance'`). Base URLs per flavor are also here.
2. **Datasource** — `lib/data/datasources/<feature>_remote_datasource/` has an abstract interface plus `*_impl.dart` annotated `@Injectable(as: Interface)`. It calls `DioRequestContext.makeRequest(uri:, dioRequestStrategy: locator<PostRequestStrategy>(), requestData:/formData:)` and maps `response.data['data']` into a response model.
3. **Networking** — `lib/data/network/dio_strategy_helper/` uses a strategy per HTTP verb (Get/Post/Put/Delete). `DioRequestContext` adds auth bearer token and `Accept-Language` from `CacheManager`, converts all exceptions into `ApiResultModel.failure(ErrorResultModel)`, and on 401 dispatches `LogoutEvent` to the singleton `AuthenticationBloc`.
4. **Result type** — `ApiResultModel<T>` (freezed: `success(data)` / `failure(errorResultEntity)`) in `lib/application/core/commundomain/entitties/based_api_result/`, consumed with `.when(...)`.
5. **Models** — request models in `lib/data/models/request_model/<feature>/`, response models in `lib/data/models/response_model/<feature>/` (json_serializable).
6. **Bloc** — `lib/presentation/pages/<feature>/bloc/` with `part` files for events/states. Blocs commonly hold fetched data as public fields (e.g. `walletBloc.transactions`) and emit lightweight Loading/Success/Error states; widgets read the fields after a Success state.
7. **Page** — obtains blocs via `locator<XBloc>()`. Most blocs are `@injectable` (new instance per lookup); `AuthenticationBloc`, `SettingsBloc`, `NotificationsBloc` are app-wide singletons. `CustomBlocConsumer` (`lib/application/core/basecomponents/base_view_model_view.dart`) wraps `BlocConsumer` with an `onInitState` hook for triggering initial events.

Other cross-cutting pieces:
- **DI** — `locator` (GetIt) in `lib/application/core/di/app_component/app_component.dart`; Dio setup in `dio_module.dart`. `initAppComponentLocator()` runs first in `main()`.
- **Flavors** — `AppFlavorsHelper` + `EnvironmentConfig`; currently hard-wired to `DEV_VARIANT` in both `main.dart` and the DI `baseUrl` module (all flavor URLs point to the same host).
- **Local state** — `CacheManager.instance` (shared_preferences/Hive) for token, language, theme, locale; `ThemeNotifier.instance` drives theme mode.
- **Deep links** — `AppLinksService` handles `https://futblha.com/diwaniya/<encoded id>` (ids encoded via `id_encryption.dart`). The router's `deepLinkBuilder` always returns `/`, and navigation happens after app init to avoid initial-route resolution errors.
- **Realtime** — Pusher services in `lib/application/core/utils/pusher/` (chat + general events).
- **Firebase/FCM** — initialization is currently commented out in `main.dart`; handlers live in `lib/application/core/utils/fcm/`.
- **UI** — design system/theme in `lib/application/config/design_system/`; responsive sizing via `ResponsiveUiConfig` (initialized in `MyApp.build`); shared widgets in `lib/presentation/widgets/`. Fonts are SF Arabic.

## Lint

`flutter_lints` with `constant_identifier_names` and `non_constant_identifier_names` disabled — endpoint constants intentionally use PascalCase (`AddBalance`).
