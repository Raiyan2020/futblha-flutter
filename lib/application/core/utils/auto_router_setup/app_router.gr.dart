// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AboutPage]
class AboutRoute extends PageRouteInfo<AboutRouteArgs> {
  AboutRoute({
    Key? key,
    required String title,
    required String content,
    List<PageRouteInfo>? children,
  }) : super(
         AboutRoute.name,
         args: AboutRouteArgs(key: key, title: title, content: content),
         initialChildren: children,
       );

  static const String name = 'AboutRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AboutRouteArgs>();
      return AboutPage(key: args.key, title: args.title, content: args.content);
    },
  );
}

class AboutRouteArgs {
  const AboutRouteArgs({this.key, required this.title, required this.content});

  final Key? key;

  final String title;

  final String content;

  @override
  String toString() {
    return 'AboutRouteArgs{key: $key, title: $title, content: $content}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AboutRouteArgs) return false;
    return key == other.key && title == other.title && content == other.content;
  }

  @override
  int get hashCode => key.hashCode ^ title.hashCode ^ content.hashCode;
}

/// generated route for
/// [ActiveGamesPage]
class ActiveGamesRoute extends PageRouteInfo<void> {
  const ActiveGamesRoute({List<PageRouteInfo>? children})
    : super(ActiveGamesRoute.name, initialChildren: children);

  static const String name = 'ActiveGamesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ActiveGamesPage();
    },
  );
}

/// generated route for
/// [BookPlaygroundPage]
class BookPlaygroundRoute extends PageRouteInfo<BookPlaygroundRouteArgs> {
  BookPlaygroundRoute({
    Key? key,
    required PlaygroundModel playground,
    int? gameId,
    List<PageRouteInfo>? children,
  }) : super(
         BookPlaygroundRoute.name,
         args: BookPlaygroundRouteArgs(
           key: key,
           playground: playground,
           gameId: gameId,
         ),
         initialChildren: children,
       );

  static const String name = 'BookPlaygroundRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BookPlaygroundRouteArgs>();
      return BookPlaygroundPage(
        key: args.key,
        playground: args.playground,
        gameId: args.gameId,
      );
    },
  );
}

class BookPlaygroundRouteArgs {
  const BookPlaygroundRouteArgs({
    this.key,
    required this.playground,
    this.gameId,
  });

  final Key? key;

  final PlaygroundModel playground;

  final int? gameId;

  @override
  String toString() {
    return 'BookPlaygroundRouteArgs{key: $key, playground: $playground, gameId: $gameId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BookPlaygroundRouteArgs) return false;
    return key == other.key &&
        playground == other.playground &&
        gameId == other.gameId;
  }

  @override
  int get hashCode => key.hashCode ^ playground.hashCode ^ gameId.hashCode;
}

/// generated route for
/// [BookingDetailsPage]
class BookingDetailsRoute extends PageRouteInfo<BookingDetailsRouteArgs> {
  BookingDetailsRoute({
    Key? key,
    required BookingItem booking,
    List<PageRouteInfo>? children,
  }) : super(
         BookingDetailsRoute.name,
         args: BookingDetailsRouteArgs(key: key, booking: booking),
         initialChildren: children,
       );

  static const String name = 'BookingDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BookingDetailsRouteArgs>();
      return BookingDetailsPage(key: args.key, booking: args.booking);
    },
  );
}

class BookingDetailsRouteArgs {
  const BookingDetailsRouteArgs({this.key, required this.booking});

  final Key? key;

  final BookingItem booking;

  @override
  String toString() {
    return 'BookingDetailsRouteArgs{key: $key, booking: $booking}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BookingDetailsRouteArgs) return false;
    return key == other.key && booking == other.booking;
  }

  @override
  int get hashCode => key.hashCode ^ booking.hashCode;
}

/// generated route for
/// [ChargeWalletPage]
class ChargeWalletRoute extends PageRouteInfo<ChargeWalletRouteArgs> {
  ChargeWalletRoute({
    Key? key,
    required double amount,
    List<PageRouteInfo>? children,
  }) : super(
         ChargeWalletRoute.name,
         args: ChargeWalletRouteArgs(key: key, amount: amount),
         initialChildren: children,
       );

  static const String name = 'ChargeWalletRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChargeWalletRouteArgs>();
      return ChargeWalletPage(key: args.key, amount: args.amount);
    },
  );
}

class ChargeWalletRouteArgs {
  const ChargeWalletRouteArgs({this.key, required this.amount});

  final Key? key;

  final double amount;

  @override
  String toString() {
    return 'ChargeWalletRouteArgs{key: $key, amount: $amount}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChargeWalletRouteArgs) return false;
    return key == other.key && amount == other.amount;
  }

  @override
  int get hashCode => key.hashCode ^ amount.hashCode;
}

/// generated route for
/// [ChatPage]
class ChatRoute extends PageRouteInfo<ChatRouteArgs> {
  ChatRoute({
    Key? key,
    int? gameId,
    DiwaniyaBloc? diwaniyaBloc,
    List<PageRouteInfo>? children,
  }) : super(
         ChatRoute.name,
         args: ChatRouteArgs(
           key: key,
           gameId: gameId,
           diwaniyaBloc: diwaniyaBloc,
         ),
         initialChildren: children,
       );

  static const String name = 'ChatRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatRouteArgs>(
        orElse: () => const ChatRouteArgs(),
      );
      return ChatPage(
        key: args.key,
        gameId: args.gameId,
        diwaniyaBloc: args.diwaniyaBloc,
      );
    },
  );
}

class ChatRouteArgs {
  const ChatRouteArgs({this.key, this.gameId, this.diwaniyaBloc});

  final Key? key;

  final int? gameId;

  final DiwaniyaBloc? diwaniyaBloc;

  @override
  String toString() {
    return 'ChatRouteArgs{key: $key, gameId: $gameId, diwaniyaBloc: $diwaniyaBloc}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatRouteArgs) return false;
    return key == other.key &&
        gameId == other.gameId &&
        diwaniyaBloc == other.diwaniyaBloc;
  }

  @override
  int get hashCode => key.hashCode ^ gameId.hashCode ^ diwaniyaBloc.hashCode;
}

/// generated route for
/// [CompleteProfilePage]
class CompleteProfileRoute extends PageRouteInfo<void> {
  const CompleteProfileRoute({List<PageRouteInfo>? children})
    : super(CompleteProfileRoute.name, initialChildren: children);

  static const String name = 'CompleteProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CompleteProfilePage();
    },
  );
}

/// generated route for
/// [ConfirmBookingPage]
class ConfirmBookingRoute extends PageRouteInfo<ConfirmBookingRouteArgs> {
  ConfirmBookingRoute({
    Key? key,
    required PlaygroundModel playground,
    required DateTime date,
    required String timeSlot,
    int? gameId,
    bool skipUpdate = false,
    List<PageRouteInfo>? children,
  }) : super(
         ConfirmBookingRoute.name,
         args: ConfirmBookingRouteArgs(
           key: key,
           playground: playground,
           date: date,
           timeSlot: timeSlot,
           gameId: gameId,
           skipUpdate: skipUpdate,
         ),
         initialChildren: children,
       );

  static const String name = 'ConfirmBookingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ConfirmBookingRouteArgs>();
      return ConfirmBookingPage(
        key: args.key,
        playground: args.playground,
        date: args.date,
        timeSlot: args.timeSlot,
        gameId: args.gameId,
        skipUpdate: args.skipUpdate,
      );
    },
  );
}

class ConfirmBookingRouteArgs {
  const ConfirmBookingRouteArgs({
    this.key,
    required this.playground,
    required this.date,
    required this.timeSlot,
    this.gameId,
    this.skipUpdate = false,
  });

  final Key? key;

  final PlaygroundModel playground;

  final DateTime date;

  final String timeSlot;

  final int? gameId;

  final bool skipUpdate;

  @override
  String toString() {
    return 'ConfirmBookingRouteArgs{key: $key, playground: $playground, date: $date, timeSlot: $timeSlot, gameId: $gameId, skipUpdate: $skipUpdate}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ConfirmBookingRouteArgs) return false;
    return key == other.key &&
        playground == other.playground &&
        date == other.date &&
        timeSlot == other.timeSlot &&
        gameId == other.gameId &&
        skipUpdate == other.skipUpdate;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      playground.hashCode ^
      date.hashCode ^
      timeSlot.hashCode ^
      gameId.hashCode ^
      skipUpdate.hashCode;
}

/// generated route for
/// [ConfirmGameBookingPage]
class ConfirmGameBookingRoute
    extends PageRouteInfo<ConfirmGameBookingRouteArgs> {
  ConfirmGameBookingRoute({
    Key? key,
    required int gameId,
    required PlaygroundModel playground,
    required DateTime date,
    required String timeSlot,
    List<PageRouteInfo>? children,
  }) : super(
         ConfirmGameBookingRoute.name,
         args: ConfirmGameBookingRouteArgs(
           key: key,
           gameId: gameId,
           playground: playground,
           date: date,
           timeSlot: timeSlot,
         ),
         initialChildren: children,
       );

  static const String name = 'ConfirmGameBookingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ConfirmGameBookingRouteArgs>();
      return ConfirmGameBookingPage(
        key: args.key,
        gameId: args.gameId,
        playground: args.playground,
        date: args.date,
        timeSlot: args.timeSlot,
      );
    },
  );
}

class ConfirmGameBookingRouteArgs {
  const ConfirmGameBookingRouteArgs({
    this.key,
    required this.gameId,
    required this.playground,
    required this.date,
    required this.timeSlot,
  });

  final Key? key;

  final int gameId;

  final PlaygroundModel playground;

  final DateTime date;

  final String timeSlot;

  @override
  String toString() {
    return 'ConfirmGameBookingRouteArgs{key: $key, gameId: $gameId, playground: $playground, date: $date, timeSlot: $timeSlot}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ConfirmGameBookingRouteArgs) return false;
    return key == other.key &&
        gameId == other.gameId &&
        playground == other.playground &&
        date == other.date &&
        timeSlot == other.timeSlot;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      gameId.hashCode ^
      playground.hashCode ^
      date.hashCode ^
      timeSlot.hashCode;
}

/// generated route for
/// [CreateDiwaniyaPage]
class CreateDiwaniyaRoute extends PageRouteInfo<void> {
  const CreateDiwaniyaRoute({List<PageRouteInfo>? children})
    : super(CreateDiwaniyaRoute.name, initialChildren: children);

  static const String name = 'CreateDiwaniyaRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CreateDiwaniyaPage();
    },
  );
}

/// generated route for
/// [CreateGamePage]
class CreateGameRoute extends PageRouteInfo<CreateGameRouteArgs> {
  CreateGameRoute({
    Key? key,
    required GameType gameType,
    List<PageRouteInfo>? children,
  }) : super(
         CreateGameRoute.name,
         args: CreateGameRouteArgs(key: key, gameType: gameType),
         initialChildren: children,
       );

  static const String name = 'CreateGameRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreateGameRouteArgs>();
      return CreateGamePage(key: args.key, gameType: args.gameType);
    },
  );
}

class CreateGameRouteArgs {
  const CreateGameRouteArgs({this.key, required this.gameType});

  final Key? key;

  final GameType gameType;

  @override
  String toString() {
    return 'CreateGameRouteArgs{key: $key, gameType: $gameType}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreateGameRouteArgs) return false;
    return key == other.key && gameType == other.gameType;
  }

  @override
  int get hashCode => key.hashCode ^ gameType.hashCode;
}

/// generated route for
/// [CustomSuccessPage]
class CustomSuccessRoute extends PageRouteInfo<CustomSuccessRouteArgs> {
  CustomSuccessRoute({
    Key? key,
    required String iconPath,
    required String title,
    required String message,
    VoidCallback? onButtonPress,
    Duration autoNavigateDuration = const Duration(seconds: 3),
    dynamic Function()? navigationCallback,
    List<PageRouteInfo>? children,
  }) : super(
         CustomSuccessRoute.name,
         args: CustomSuccessRouteArgs(
           key: key,
           iconPath: iconPath,
           title: title,
           message: message,
           onButtonPress: onButtonPress,
           autoNavigateDuration: autoNavigateDuration,
           navigationCallback: navigationCallback,
         ),
         initialChildren: children,
       );

  static const String name = 'CustomSuccessRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CustomSuccessRouteArgs>();
      return CustomSuccessPage(
        key: args.key,
        iconPath: args.iconPath,
        title: args.title,
        message: args.message,
        onButtonPress: args.onButtonPress,
        autoNavigateDuration: args.autoNavigateDuration,
        navigationCallback: args.navigationCallback,
      );
    },
  );
}

class CustomSuccessRouteArgs {
  const CustomSuccessRouteArgs({
    this.key,
    required this.iconPath,
    required this.title,
    required this.message,
    this.onButtonPress,
    this.autoNavigateDuration = const Duration(seconds: 3),
    this.navigationCallback,
  });

  final Key? key;

  final String iconPath;

  final String title;

  final String message;

  final VoidCallback? onButtonPress;

  final Duration autoNavigateDuration;

  final dynamic Function()? navigationCallback;

  @override
  String toString() {
    return 'CustomSuccessRouteArgs{key: $key, iconPath: $iconPath, title: $title, message: $message, onButtonPress: $onButtonPress, autoNavigateDuration: $autoNavigateDuration, navigationCallback: $navigationCallback}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CustomSuccessRouteArgs) return false;
    return key == other.key &&
        iconPath == other.iconPath &&
        title == other.title &&
        message == other.message &&
        onButtonPress == other.onButtonPress &&
        autoNavigateDuration == other.autoNavigateDuration;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      iconPath.hashCode ^
      title.hashCode ^
      message.hashCode ^
      onButtonPress.hashCode ^
      autoNavigateDuration.hashCode;
}

/// generated route for
/// [DiwaniyaDetailsPage]
class DiwaniyaDetailsRoute extends PageRouteInfo<DiwaniyaDetailsRouteArgs> {
  DiwaniyaDetailsRoute({
    Key? key,
    required String diwaniyaId,
    String? diwaniyaName,
    String? diwaniyaRank,
    String? description,
    int levelReview = 0,
    int clearGame = 0,
    int wins = 0,
    int draws = 0,
    int loses = 0,
    String? imagePath,
    bool isMember = false,
    List<PageRouteInfo>? children,
  }) : super(
         DiwaniyaDetailsRoute.name,
         args: DiwaniyaDetailsRouteArgs(
           key: key,
           diwaniyaId: diwaniyaId,
           diwaniyaName: diwaniyaName,
           diwaniyaRank: diwaniyaRank,
           description: description,
           levelReview: levelReview,
           clearGame: clearGame,
           wins: wins,
           draws: draws,
           loses: loses,
           imagePath: imagePath,
           isMember: isMember,
         ),
         initialChildren: children,
       );

  static const String name = 'DiwaniyaDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DiwaniyaDetailsRouteArgs>();
      return DiwaniyaDetailsPage(
        key: args.key,
        diwaniyaId: args.diwaniyaId,
        diwaniyaName: args.diwaniyaName,
        diwaniyaRank: args.diwaniyaRank,
        description: args.description,
        levelReview: args.levelReview,
        clearGame: args.clearGame,
        wins: args.wins,
        draws: args.draws,
        loses: args.loses,
        imagePath: args.imagePath,
        isMember: args.isMember,
      );
    },
  );
}

class DiwaniyaDetailsRouteArgs {
  const DiwaniyaDetailsRouteArgs({
    this.key,
    required this.diwaniyaId,
    this.diwaniyaName,
    this.diwaniyaRank,
    this.description,
    this.levelReview = 0,
    this.clearGame = 0,
    this.wins = 0,
    this.draws = 0,
    this.loses = 0,
    this.imagePath,
    this.isMember = false,
  });

  final Key? key;

  final String diwaniyaId;

  final String? diwaniyaName;

  final String? diwaniyaRank;

  final String? description;

  final int levelReview;

  final int clearGame;

  final int wins;

  final int draws;

  final int loses;

  final String? imagePath;

  final bool isMember;

  @override
  String toString() {
    return 'DiwaniyaDetailsRouteArgs{key: $key, diwaniyaId: $diwaniyaId, diwaniyaName: $diwaniyaName, diwaniyaRank: $diwaniyaRank, description: $description, levelReview: $levelReview, clearGame: $clearGame, wins: $wins, draws: $draws, loses: $loses, imagePath: $imagePath, isMember: $isMember}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DiwaniyaDetailsRouteArgs) return false;
    return key == other.key &&
        diwaniyaId == other.diwaniyaId &&
        diwaniyaName == other.diwaniyaName &&
        diwaniyaRank == other.diwaniyaRank &&
        description == other.description &&
        levelReview == other.levelReview &&
        clearGame == other.clearGame &&
        wins == other.wins &&
        draws == other.draws &&
        loses == other.loses &&
        imagePath == other.imagePath &&
        isMember == other.isMember;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      diwaniyaId.hashCode ^
      diwaniyaName.hashCode ^
      diwaniyaRank.hashCode ^
      description.hashCode ^
      levelReview.hashCode ^
      clearGame.hashCode ^
      wins.hashCode ^
      draws.hashCode ^
      loses.hashCode ^
      imagePath.hashCode ^
      isMember.hashCode;
}

/// generated route for
/// [DiwaniyaRankingPage]
class DiwaniyaRankingRoute extends PageRouteInfo<void> {
  const DiwaniyaRankingRoute({List<PageRouteInfo>? children})
    : super(DiwaniyaRankingRoute.name, initialChildren: children);

  static const String name = 'DiwaniyaRankingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DiwaniyaRankingPage();
    },
  );
}

/// generated route for
/// [DiwaniyaSettingsPage]
class DiwaniyaSettingsRoute extends PageRouteInfo<DiwaniyaSettingsRouteArgs> {
  DiwaniyaSettingsRoute({
    Key? key,
    required DiwaniyaBloc bloc,
    List<PageRouteInfo>? children,
  }) : super(
         DiwaniyaSettingsRoute.name,
         args: DiwaniyaSettingsRouteArgs(key: key, bloc: bloc),
         initialChildren: children,
       );

  static const String name = 'DiwaniyaSettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DiwaniyaSettingsRouteArgs>();
      return DiwaniyaSettingsPage(key: args.key, bloc: args.bloc);
    },
  );
}

class DiwaniyaSettingsRouteArgs {
  const DiwaniyaSettingsRouteArgs({this.key, required this.bloc});

  final Key? key;

  final DiwaniyaBloc bloc;

  @override
  String toString() {
    return 'DiwaniyaSettingsRouteArgs{key: $key, bloc: $bloc}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DiwaniyaSettingsRouteArgs) return false;
    return key == other.key && bloc == other.bloc;
  }

  @override
  int get hashCode => key.hashCode ^ bloc.hashCode;
}

/// generated route for
/// [DiwaniyatPage]
class DiwaniyatRoute extends PageRouteInfo<void> {
  const DiwaniyatRoute({List<PageRouteInfo>? children})
    : super(DiwaniyatRoute.name, initialChildren: children);

  static const String name = 'DiwaniyatRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DiwaniyatPage();
    },
  );
}

/// generated route for
/// [EditPositionsPage]
class EditPositionsRoute extends PageRouteInfo<EditPositionsRouteArgs> {
  EditPositionsRoute({
    Key? key,
    List<String>? initialPositions,
    bool? initialIsJocker,
    List<PageRouteInfo>? children,
  }) : super(
         EditPositionsRoute.name,
         args: EditPositionsRouteArgs(
           key: key,
           initialPositions: initialPositions,
           initialIsJocker: initialIsJocker,
         ),
         initialChildren: children,
       );

  static const String name = 'EditPositionsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditPositionsRouteArgs>(
        orElse: () => const EditPositionsRouteArgs(),
      );
      return EditPositionsPage(
        key: args.key,
        initialPositions: args.initialPositions,
        initialIsJocker: args.initialIsJocker,
      );
    },
  );
}

class EditPositionsRouteArgs {
  const EditPositionsRouteArgs({
    this.key,
    this.initialPositions,
    this.initialIsJocker,
  });

  final Key? key;

  final List<String>? initialPositions;

  final bool? initialIsJocker;

  @override
  String toString() {
    return 'EditPositionsRouteArgs{key: $key, initialPositions: $initialPositions, initialIsJocker: $initialIsJocker}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditPositionsRouteArgs) return false;
    return key == other.key &&
        const ListEquality<String>().equals(
          initialPositions,
          other.initialPositions,
        ) &&
        initialIsJocker == other.initialIsJocker;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const ListEquality<String>().hash(initialPositions) ^
      initialIsJocker.hashCode;
}

/// generated route for
/// [EditProfilePage]
class EditProfileRoute extends PageRouteInfo<void> {
  const EditProfileRoute({List<PageRouteInfo>? children})
    : super(EditProfileRoute.name, initialChildren: children);

  static const String name = 'EditProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const EditProfilePage();
    },
  );
}

/// generated route for
/// [FaqPage]
class FaqRoute extends PageRouteInfo<FaqRouteArgs> {
  FaqRoute({
    Key? key,
    required String title,
    required String content,
    List<PageRouteInfo>? children,
  }) : super(
         FaqRoute.name,
         args: FaqRouteArgs(key: key, title: title, content: content),
         initialChildren: children,
       );

  static const String name = 'FaqRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FaqRouteArgs>();
      return FaqPage(key: args.key, title: args.title, content: args.content);
    },
  );
}

class FaqRouteArgs {
  const FaqRouteArgs({this.key, required this.title, required this.content});

  final Key? key;

  final String title;

  final String content;

  @override
  String toString() {
    return 'FaqRouteArgs{key: $key, title: $title, content: $content}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FaqRouteArgs) return false;
    return key == other.key && title == other.title && content == other.content;
  }

  @override
  int get hashCode => key.hashCode ^ title.hashCode ^ content.hashCode;
}

/// generated route for
/// [GameDetailsPage]
class GameDetailsRoute extends PageRouteInfo<GameDetailsRouteArgs> {
  GameDetailsRoute({
    Key? key,
    required GamesBloc bloc,
    bool isFromHistory = false,
    List<PageRouteInfo>? children,
  }) : super(
         GameDetailsRoute.name,
         args: GameDetailsRouteArgs(
           key: key,
           bloc: bloc,
           isFromHistory: isFromHistory,
         ),
         initialChildren: children,
       );

  static const String name = 'GameDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<GameDetailsRouteArgs>();
      return GameDetailsPage(
        key: args.key,
        bloc: args.bloc,
        isFromHistory: args.isFromHistory,
      );
    },
  );
}

class GameDetailsRouteArgs {
  const GameDetailsRouteArgs({
    this.key,
    required this.bloc,
    this.isFromHistory = false,
  });

  final Key? key;

  final GamesBloc bloc;

  final bool isFromHistory;

  @override
  String toString() {
    return 'GameDetailsRouteArgs{key: $key, bloc: $bloc, isFromHistory: $isFromHistory}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GameDetailsRouteArgs) return false;
    return key == other.key &&
        bloc == other.bloc &&
        isFromHistory == other.isFromHistory;
  }

  @override
  int get hashCode => key.hashCode ^ bloc.hashCode ^ isFromHistory.hashCode;
}

/// generated route for
/// [GameTypeSelectionPage]
class GameTypeSelectionRoute extends PageRouteInfo<void> {
  const GameTypeSelectionRoute({List<PageRouteInfo>? children})
    : super(GameTypeSelectionRoute.name, initialChildren: children);

  static const String name = 'GameTypeSelectionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const GameTypeSelectionPage();
    },
  );
}

/// generated route for
/// [GamesHistoryPage]
class GamesHistoryRoute extends PageRouteInfo<GamesHistoryRouteArgs> {
  GamesHistoryRoute({
    Key? key,
    required int diwaniyaId,
    List<PageRouteInfo>? children,
  }) : super(
         GamesHistoryRoute.name,
         args: GamesHistoryRouteArgs(key: key, diwaniyaId: diwaniyaId),
         initialChildren: children,
       );

  static const String name = 'GamesHistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<GamesHistoryRouteArgs>();
      return GamesHistoryPage(key: args.key, diwaniyaId: args.diwaniyaId);
    },
  );
}

class GamesHistoryRouteArgs {
  const GamesHistoryRouteArgs({this.key, required this.diwaniyaId});

  final Key? key;

  final int diwaniyaId;

  @override
  String toString() {
    return 'GamesHistoryRouteArgs{key: $key, diwaniyaId: $diwaniyaId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GamesHistoryRouteArgs) return false;
    return key == other.key && diwaniyaId == other.diwaniyaId;
  }

  @override
  int get hashCode => key.hashCode ^ diwaniyaId.hashCode;
}

/// generated route for
/// [GamesInvitationsPage]
class GamesInvitationsRoute extends PageRouteInfo<void> {
  const GamesInvitationsRoute({List<PageRouteInfo>? children})
    : super(GamesInvitationsRoute.name, initialChildren: children);

  static const String name = 'GamesInvitationsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const GamesInvitationsPage();
    },
  );
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [HowWasOpposingTeamPage]
class HowWasOpposingTeamRoute
    extends PageRouteInfo<HowWasOpposingTeamRouteArgs> {
  HowWasOpposingTeamRoute({
    Key? key,
    required String teamName,
    String? teamImage,
    int? gameId,
    List<PageRouteInfo>? children,
  }) : super(
         HowWasOpposingTeamRoute.name,
         args: HowWasOpposingTeamRouteArgs(
           key: key,
           teamName: teamName,
           teamImage: teamImage,
           gameId: gameId,
         ),
         initialChildren: children,
       );

  static const String name = 'HowWasOpposingTeamRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HowWasOpposingTeamRouteArgs>();
      return HowWasOpposingTeamPage(
        key: args.key,
        teamName: args.teamName,
        teamImage: args.teamImage,
        gameId: args.gameId,
      );
    },
  );
}

class HowWasOpposingTeamRouteArgs {
  const HowWasOpposingTeamRouteArgs({
    this.key,
    required this.teamName,
    this.teamImage,
    this.gameId,
  });

  final Key? key;

  final String teamName;

  final String? teamImage;

  final int? gameId;

  @override
  String toString() {
    return 'HowWasOpposingTeamRouteArgs{key: $key, teamName: $teamName, teamImage: $teamImage, gameId: $gameId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HowWasOpposingTeamRouteArgs) return false;
    return key == other.key &&
        teamName == other.teamName &&
        teamImage == other.teamImage &&
        gameId == other.gameId;
  }

  @override
  int get hashCode =>
      key.hashCode ^ teamName.hashCode ^ teamImage.hashCode ^ gameId.hashCode;
}

/// generated route for
/// [JoinGamePage]
class JoinGameRoute extends PageRouteInfo<JoinGameRouteArgs> {
  JoinGameRoute({
    Key? key,
    required GamesBloc gamesBloc,
    List<PageRouteInfo>? children,
  }) : super(
         JoinGameRoute.name,
         args: JoinGameRouteArgs(key: key, gamesBloc: gamesBloc),
         initialChildren: children,
       );

  static const String name = 'JoinGameRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<JoinGameRouteArgs>();
      return JoinGamePage(key: args.key, gamesBloc: args.gamesBloc);
    },
  );
}

class JoinGameRouteArgs {
  const JoinGameRouteArgs({this.key, required this.gamesBloc});

  final Key? key;

  final GamesBloc gamesBloc;

  @override
  String toString() {
    return 'JoinGameRouteArgs{key: $key, gamesBloc: $gamesBloc}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JoinGameRouteArgs) return false;
    return key == other.key && gamesBloc == other.gamesBloc;
  }

  @override
  int get hashCode => key.hashCode ^ gamesBloc.hashCode;
}

/// generated route for
/// [JoinRequestsPage]
class JoinRequestsRoute extends PageRouteInfo<JoinRequestsRouteArgs> {
  JoinRequestsRoute({
    Key? key,
    required DiwaniyaBloc diwaniyaBloc,
    List<PageRouteInfo>? children,
  }) : super(
         JoinRequestsRoute.name,
         args: JoinRequestsRouteArgs(key: key, diwaniyaBloc: diwaniyaBloc),
         initialChildren: children,
       );

  static const String name = 'JoinRequestsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<JoinRequestsRouteArgs>();
      return JoinRequestsPage(key: args.key, diwaniyaBloc: args.diwaniyaBloc);
    },
  );
}

class JoinRequestsRouteArgs {
  const JoinRequestsRouteArgs({this.key, required this.diwaniyaBloc});

  final Key? key;

  final DiwaniyaBloc diwaniyaBloc;

  @override
  String toString() {
    return 'JoinRequestsRouteArgs{key: $key, diwaniyaBloc: $diwaniyaBloc}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JoinRequestsRouteArgs) return false;
    return key == other.key && diwaniyaBloc == other.diwaniyaBloc;
  }

  @override
  int get hashCode => key.hashCode ^ diwaniyaBloc.hashCode;
}

/// generated route for
/// [JoinedPlayersPage]
class JoinedPlayersRoute extends PageRouteInfo<JoinedPlayersRouteArgs> {
  JoinedPlayersRoute({
    Key? key,
    required int gameId,
    required GamesBloc bloc,
    List<PageRouteInfo>? children,
  }) : super(
         JoinedPlayersRoute.name,
         args: JoinedPlayersRouteArgs(key: key, gameId: gameId, bloc: bloc),
         initialChildren: children,
       );

  static const String name = 'JoinedPlayersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<JoinedPlayersRouteArgs>();
      return JoinedPlayersPage(
        key: args.key,
        gameId: args.gameId,
        bloc: args.bloc,
      );
    },
  );
}

class JoinedPlayersRouteArgs {
  const JoinedPlayersRouteArgs({
    this.key,
    required this.gameId,
    required this.bloc,
  });

  final Key? key;

  final int gameId;

  final GamesBloc bloc;

  @override
  String toString() {
    return 'JoinedPlayersRouteArgs{key: $key, gameId: $gameId, bloc: $bloc}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JoinedPlayersRouteArgs) return false;
    return key == other.key && gameId == other.gameId && bloc == other.bloc;
  }

  @override
  int get hashCode => key.hashCode ^ gameId.hashCode ^ bloc.hashCode;
}

/// generated route for
/// [LandingPage]
class LandingRoute extends PageRouteInfo<void> {
  const LandingRoute({List<PageRouteInfo>? children})
    : super(LandingRoute.name, initialChildren: children);

  static const String name = 'LandingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LandingPage();
    },
  );
}

/// generated route for
/// [LanguageScreen]
class LanguageRoute extends PageRouteInfo<void> {
  const LanguageRoute({List<PageRouteInfo>? children})
    : super(LanguageRoute.name, initialChildren: children);

  static const String name = 'LanguageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LanguageScreen();
    },
  );
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginPage();
    },
  );
}

/// generated route for
/// [MaintenanceScreen]
class MaintenanceRoute extends PageRouteInfo<void> {
  const MaintenanceRoute({List<PageRouteInfo>? children})
    : super(MaintenanceRoute.name, initialChildren: children);

  static const String name = 'MaintenanceRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MaintenanceScreen();
    },
  );
}

/// generated route for
/// [MembersPage]
class MembersRoute extends PageRouteInfo<MembersRouteArgs> {
  MembersRoute({
    Key? key,
    required DiwaniyaBloc bloc,
    List<PageRouteInfo>? children,
  }) : super(
         MembersRoute.name,
         args: MembersRouteArgs(key: key, bloc: bloc),
         initialChildren: children,
       );

  static const String name = 'MembersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MembersRouteArgs>();
      return MembersPage(key: args.key, bloc: args.bloc);
    },
  );
}

class MembersRouteArgs {
  const MembersRouteArgs({this.key, required this.bloc});

  final Key? key;

  final DiwaniyaBloc bloc;

  @override
  String toString() {
    return 'MembersRouteArgs{key: $key, bloc: $bloc}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MembersRouteArgs) return false;
    return key == other.key && bloc == other.bloc;
  }

  @override
  int get hashCode => key.hashCode ^ bloc.hashCode;
}

/// generated route for
/// [MyBookingsPage]
class MyBookingsRoute extends PageRouteInfo<void> {
  const MyBookingsRoute({List<PageRouteInfo>? children})
    : super(MyBookingsRoute.name, initialChildren: children);

  static const String name = 'MyBookingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MyBookingsPage();
    },
  );
}

/// generated route for
/// [MyGamesHistoryPage]
class MyGamesHistoryRoute extends PageRouteInfo<void> {
  const MyGamesHistoryRoute({List<PageRouteInfo>? children})
    : super(MyGamesHistoryRoute.name, initialChildren: children);

  static const String name = 'MyGamesHistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MyGamesHistoryPage();
    },
  );
}

/// generated route for
/// [MyUpcomingGamesPage]
class MyUpcomingGamesRoute extends PageRouteInfo<void> {
  const MyUpcomingGamesRoute({List<PageRouteInfo>? children})
    : super(MyUpcomingGamesRoute.name, initialChildren: children);

  static const String name = 'MyUpcomingGamesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MyUpcomingGamesPage();
    },
  );
}

/// generated route for
/// [NotificationsPage]
class NotificationsRoute extends PageRouteInfo<NotificationsRouteArgs> {
  NotificationsRoute({Key? key, List<PageRouteInfo>? children})
    : super(
        NotificationsRoute.name,
        args: NotificationsRouteArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'NotificationsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NotificationsRouteArgs>(
        orElse: () => const NotificationsRouteArgs(),
      );
      return NotificationsPage(key: args.key);
    },
  );
}

class NotificationsRouteArgs {
  const NotificationsRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'NotificationsRouteArgs{key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NotificationsRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [OpposingDiwaniyaSelectionPage]
class OpposingDiwaniyaSelectionRoute
    extends PageRouteInfo<OpposingDiwaniyaSelectionRouteArgs> {
  OpposingDiwaniyaSelectionRoute({
    Key? key,
    required PlaygroundModel playground,
    required DateTime date,
    required String timeSlot,
    List<PageRouteInfo>? children,
  }) : super(
         OpposingDiwaniyaSelectionRoute.name,
         args: OpposingDiwaniyaSelectionRouteArgs(
           key: key,
           playground: playground,
           date: date,
           timeSlot: timeSlot,
         ),
         initialChildren: children,
       );

  static const String name = 'OpposingDiwaniyaSelectionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OpposingDiwaniyaSelectionRouteArgs>();
      return OpposingDiwaniyaSelectionPage(
        key: args.key,
        playground: args.playground,
        date: args.date,
        timeSlot: args.timeSlot,
      );
    },
  );
}

class OpposingDiwaniyaSelectionRouteArgs {
  const OpposingDiwaniyaSelectionRouteArgs({
    this.key,
    required this.playground,
    required this.date,
    required this.timeSlot,
  });

  final Key? key;

  final PlaygroundModel playground;

  final DateTime date;

  final String timeSlot;

  @override
  String toString() {
    return 'OpposingDiwaniyaSelectionRouteArgs{key: $key, playground: $playground, date: $date, timeSlot: $timeSlot}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OpposingDiwaniyaSelectionRouteArgs) return false;
    return key == other.key &&
        playground == other.playground &&
        date == other.date &&
        timeSlot == other.timeSlot;
  }

  @override
  int get hashCode =>
      key.hashCode ^ playground.hashCode ^ date.hashCode ^ timeSlot.hashCode;
}

/// generated route for
/// [PaymentWebViewPage]
class PaymentWebViewRoute extends PageRouteInfo<PaymentWebViewRouteArgs> {
  PaymentWebViewRoute({
    Key? key,
    required String paymentUrl,
    List<PageRouteInfo>? children,
  }) : super(
         PaymentWebViewRoute.name,
         args: PaymentWebViewRouteArgs(key: key, paymentUrl: paymentUrl),
         initialChildren: children,
       );

  static const String name = 'PaymentWebViewRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PaymentWebViewRouteArgs>();
      return PaymentWebViewPage(key: args.key, paymentUrl: args.paymentUrl);
    },
  );
}

class PaymentWebViewRouteArgs {
  const PaymentWebViewRouteArgs({this.key, required this.paymentUrl});

  final Key? key;

  final String paymentUrl;

  @override
  String toString() {
    return 'PaymentWebViewRouteArgs{key: $key, paymentUrl: $paymentUrl}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaymentWebViewRouteArgs) return false;
    return key == other.key && paymentUrl == other.paymentUrl;
  }

  @override
  int get hashCode => key.hashCode ^ paymentUrl.hashCode;
}

/// generated route for
/// [PinCodeVerificationPage]
class PinCodeVerificationRoute
    extends PageRouteInfo<PinCodeVerificationRouteArgs> {
  PinCodeVerificationRoute({
    Key? key,
    required String phoneNumber,
    required String countryCode,
    List<PageRouteInfo>? children,
  }) : super(
         PinCodeVerificationRoute.name,
         args: PinCodeVerificationRouteArgs(
           key: key,
           phoneNumber: phoneNumber,
           countryCode: countryCode,
         ),
         initialChildren: children,
       );

  static const String name = 'PinCodeVerificationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PinCodeVerificationRouteArgs>();
      return PinCodeVerificationPage(
        key: args.key,
        phoneNumber: args.phoneNumber,
        countryCode: args.countryCode,
      );
    },
  );
}

class PinCodeVerificationRouteArgs {
  const PinCodeVerificationRouteArgs({
    this.key,
    required this.phoneNumber,
    required this.countryCode,
  });

  final Key? key;

  final String phoneNumber;

  final String countryCode;

  @override
  String toString() {
    return 'PinCodeVerificationRouteArgs{key: $key, phoneNumber: $phoneNumber, countryCode: $countryCode}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PinCodeVerificationRouteArgs) return false;
    return key == other.key &&
        phoneNumber == other.phoneNumber &&
        countryCode == other.countryCode;
  }

  @override
  int get hashCode =>
      key.hashCode ^ phoneNumber.hashCode ^ countryCode.hashCode;
}

/// generated route for
/// [PlaygroundDetailsPage]
class PlaygroundDetailsRoute extends PageRouteInfo<PlaygroundDetailsRouteArgs> {
  PlaygroundDetailsRoute({
    Key? key,
    required PlaygroundModel playground,
    List<PageRouteInfo>? children,
  }) : super(
         PlaygroundDetailsRoute.name,
         args: PlaygroundDetailsRouteArgs(key: key, playground: playground),
         initialChildren: children,
       );

  static const String name = 'PlaygroundDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PlaygroundDetailsRouteArgs>();
      return PlaygroundDetailsPage(key: args.key, playground: args.playground);
    },
  );
}

class PlaygroundDetailsRouteArgs {
  const PlaygroundDetailsRouteArgs({this.key, required this.playground});

  final Key? key;

  final PlaygroundModel playground;

  @override
  String toString() {
    return 'PlaygroundDetailsRouteArgs{key: $key, playground: $playground}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PlaygroundDetailsRouteArgs) return false;
    return key == other.key && playground == other.playground;
  }

  @override
  int get hashCode => key.hashCode ^ playground.hashCode;
}

/// generated route for
/// [PlaygroundSelectionPage]
class PlaygroundSelectionRoute extends PageRouteInfo<void> {
  const PlaygroundSelectionRoute({List<PageRouteInfo>? children})
    : super(PlaygroundSelectionRoute.name, initialChildren: children);

  static const String name = 'PlaygroundSelectionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PlaygroundSelectionPage();
    },
  );
}

/// generated route for
/// [PlaygroundsListPage]
class PlaygroundsListRoute extends PageRouteInfo<void> {
  const PlaygroundsListRoute({List<PageRouteInfo>? children})
    : super(PlaygroundsListRoute.name, initialChildren: children);

  static const String name = 'PlaygroundsListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PlaygroundsListPage();
    },
  );
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfilePage();
    },
  );
}

/// generated route for
/// [RegisterPage]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterPage();
    },
  );
}

/// generated route for
/// [SettingsPage]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsPage();
    },
  );
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}

/// generated route for
/// [SupportPage]
class SupportRoute extends PageRouteInfo<void> {
  const SupportRoute({List<PageRouteInfo>? children})
    : super(SupportRoute.name, initialChildren: children);

  static const String name = 'SupportRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SupportPage();
    },
  );
}

/// generated route for
/// [WalletPage]
class WalletRoute extends PageRouteInfo<void> {
  const WalletRoute({List<PageRouteInfo>? children})
    : super(WalletRoute.name, initialChildren: children);

  static const String name = 'WalletRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WalletPage();
    },
  );
}
