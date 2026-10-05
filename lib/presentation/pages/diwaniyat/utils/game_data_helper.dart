import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/data/models/response_model/games/game_model.dart';
import 'package:futblha/data/models/response_model/playgrounds/booking_period_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:intl/intl.dart';

class GameDataHelper {
  static String getGameTypeLabel(String? type) {
    switch (type) {
      case 'private':
        return LocaleKeys.private.tr();
      case 'public':
        return LocaleKeys.public.tr();
      default:
        return LocaleKeys.my_diwaniya_game_type.tr();
    }
  }

  static String formatDate(String? bookingDate) {
    if (bookingDate == null || bookingDate.isEmpty) return '';
    try {
      final date = DateTime.parse(bookingDate);
      return DateFormat('d MMM yyyy').format(date);
    } catch (e) {
      // If parsing fails, use the raw string (might be Arabic)
      return bookingDate;
    }
  }

  static String formatTime(List<BookingPeriodModel>? periods) {
    if (periods == null || periods.isEmpty) return '';
    final period = periods.first;
    return '${period.startTime ?? ''} - ${period.endTime ?? ''}';
  }

  static String getPlayersString(dynamic playersTarget) {
    if (playersTarget == null) return '';
    final n = (playersTarget is num)
        ? playersTarget.toDouble()
        : int.tryParse(playersTarget.toString())?.toDouble();
    if (n == null) return '';
    final count = (n / 2).round().toString();
    return '$count  ${LocaleKeys.vs.tr()} $count';
  }

  static bool isConfirmed(GameModel game) {
    final status = game.gameStatus?.toLowerCase() ?? '';
    return status == 'confirmed' || status == 'accepted';
  }

  static bool isCancelled(GameModel game) {
    final status = game.gameStatus?.toLowerCase() ?? '';
    return status.contains('cancel') || status == 'rejected';
  }

  /// Upcoming games ordering: confirmed first, then pending, then cancelled.
  /// The API's order is kept within each group.
  static List<GameModel> sortUpcomingGames(List<GameModel> games) {
    return [
      ...games.where(isConfirmed),
      ...games.where((game) => !isConfirmed(game) && !isCancelled(game)),
      ...games.where(isCancelled),
    ];
  }

  static Color getGameStatusColor(GameModel game) {
    if (isConfirmed(game)) return AppColors.primaryColor;
    if (isCancelled(game)) return AppColors.primaryRed;
    final status = game.gameStatus ?? '';
    if (status.isNotEmpty) return getStatusColor(status);
    return getStatusColor(game.gameStatusText ?? game.invitationStatus);
  }

  static Color getStatusColor(String? statusText) {
    if (statusText == null || statusText.isEmpty) return AppColors.primaryColor;
    final lowerStatus = statusText.toLowerCase();
    if (lowerStatus.contains('waiting') || lowerStatus.contains('accepting') || lowerStatus.contains('pending')) {
      return AppColors.primaryOrange;
    } else if (lowerStatus.contains('completed') || lowerStatus.contains('finished')) {
      return AppColors.primaryRed;
    }
    return AppColors.primaryColor;
  }
}
