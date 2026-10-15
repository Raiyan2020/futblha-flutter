import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/data/models/response_model/games/game_model.dart';
import 'package:futblha/data/models/response_model/games/team_payment_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';

/// Booking payment state exactly as the backend reports it: `booking.status`,
/// and for private games each Diwaniya's share from `booking.team_payments`.
/// Nothing here is derived on the device.
class GameBookingStatusCard extends StatelessWidget {
  const GameBookingStatusCard({super.key, required this.game});

  final GameModel game;

  /// Whether the card has anything to show for [game].
  static bool hasContent(GameModel game) {
    final booking = game.booking;
    return booking != null && (booking.teamPayments != null || booking.status != null);
  }

  static String? bookingStatusKey(String? status) => switch (status) {
    'unpaid' => LocaleKeys.booking_status_unpaid,
    'pending_payment' => LocaleKeys.booking_status_pending_payment,
    'awaiting_payment' => LocaleKeys.booking_status_awaiting_payment,
    'paid' => LocaleKeys.booking_status_paid,
    'failed' => LocaleKeys.booking_status_failed,
    'expired' => LocaleKeys.booking_status_expired,
    _ => null,
  };

  static String? teamPaymentStatusKey(String? status) => switch (status) {
    'unpaid' => LocaleKeys.team_payment_unpaid,
    'pending' => LocaleKeys.team_payment_pending,
    'paid' => LocaleKeys.team_payment_paid,
    'failed' => LocaleKeys.team_payment_failed,
    'refunded' => LocaleKeys.team_payment_refunded,
    _ => null,
  };

  static Color _statusColor(String? status) => switch (status) {
    'paid' => AppColors.primaryColor,
    'pending' || 'pending_payment' || 'awaiting_payment' => AppColors.primaryOrange,
    'failed' || 'expired' => AppColors.primaryRed,
    _ => AppColors.lightTextColor,
  };

  String _teamName(TeamPaymentModel payment) {
    final diwaniya = payment.team == 'host' ? game.creatorDiwaniya : game.opponentDiwaniya;
    return diwaniya?.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final booking = game.booking!;
    final statusKey = bookingStatusKey(booking.status);
    final teamPayments = booking.teamPayments;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, size: 18, color: context.brandOnSurface),
              8.widthBox(),
              Expanded(
                child: Text(
                  LocaleKeys.booking_status_title.tr(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (statusKey != null)
                Flexible(
                  child: _StatusChip(text: statusKey.tr(), color: _statusColor(booking.status)),
                ),
            ],
          ),
          if (teamPayments != null && teamPayments.isNotEmpty) ...[
            12.heightBox(),
            for (final payment in teamPayments)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _teamName(payment),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: context.textSecondary, fontSize: 13),
                      ),
                    ),
                    if (payment.amount != null) ...[
                      Text(
                        '${payment.amount} ${LocaleKeys.kwd.tr()}',
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      8.widthBox(),
                    ],
                    if (teamPaymentStatusKey(payment.status) != null)
                      _StatusChip(
                        text: teamPaymentStatusKey(payment.status)!.tr(),
                        color: _statusColor(payment.status),
                      ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
