import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/data/models/response_model/playgrounds/playground_model.dart';
import 'package:futblha/presentation/pages/playgrounds/bloc/playgrounds_bloc.dart';
import 'package:futblha/presentation/pages/games/bloc/games_bloc.dart';
import 'package:futblha/presentation/pages/playgrounds/payment_method_bottom_sheet.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:futblha/data/models/request_model/games/update_game_booking_request_model.dart';
import 'package:futblha/data/models/request_model/games/confirm_game_booking_request_model.dart';
import 'package:futblha/data/models/request_model/playgrounds/booking_request_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/payment_method_entity.dart';

@RoutePage()
class ConfirmGameBookingPage extends StatefulWidget {
  final int gameId;
  final PlaygroundModel playground;
  final DateTime date;
  final String timeSlot;

  const ConfirmGameBookingPage({
    super.key,
    required this.gameId,
    required this.playground,
    required this.date,
    required this.timeSlot,
  });

  @override
  State<ConfirmGameBookingPage> createState() => _ConfirmGameBookingPageState();
}

class _ConfirmGameBookingPageState extends State<ConfirmGameBookingPage> {
  final gamesBloc = locator<GamesBloc>();
  final playgroundsBloc = locator<PlaygroundsBloc>();

  PaymentMethodEntity? _selectedPaymentMethod;
  bool _useWalletBalance = false;
  final TextEditingController _voucherController = TextEditingController();
  String? _voucherCode;
  final double _walletBalance = 12.000;
  bool _isUpdating = false;

  double get _bookingFee {
    final priceStr = (widget.playground.price ?? '0').replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(priceStr) ?? 0.0;
  }

  List<String> get _timeSlotsList =>
      widget.timeSlot.split(', ').where((s) => s.isNotEmpty).toList();

  double get _total => _bookingFee * _timeSlotsList.length;

  void _showPaymentMethodBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PaymentMethodBottomSheet(
          selectedMethod:
              _selectedPaymentMethod?.key ?? _selectedPaymentMethod?.name ?? 'Apple Pay',
          onMethodSelected: (method) {
            setState(() {
              _selectedPaymentMethod = method;
            });
          },
        );
      },
    );
  }

  void _updateBooking() {
    // Find playground ID
    final playgroundId = _findPlaygroundId();
    if (playgroundId == null) {
      context.showMessage(isError: true, LocaleKeys.playground_not_found.tr());
      return;
    }

    // Parse time slots to periods
    final periods = _timeSlotsList
        .map((slot) {
          final parts = slot.split(' - ');
          if (parts.length == 2) {
            return BookingPeriod(startTime: parts[0].trim(), endTime: parts[1].trim());
          }
          return null;
        })
        .whereType<BookingPeriod>()
        .toList();

    if (periods.isEmpty) {
      context.showMessage(isError: true, LocaleKeys.please_select_time_slot.tr());
      return;
    }

    setState(() {
      _isUpdating = true;
      _voucherCode = _voucherController.text.isNotEmpty ? _voucherController.text : null;
    });

    final updateRequest = UpdateGameBookingRequestModel(
      code: _voucherCode,
      playgroundId: playgroundId,
      bookingDate: DateFormat('yyyy-MM-dd').format(widget.date),
      periods: periods,
      paymentMethod: _selectedPaymentMethod?.key ?? 'kent',
      useWallet: _useWalletBalance,
    );

    gamesBloc.add(UpdateGameBookingEvent(gameId: widget.gameId, request: updateRequest));
  }

  void _confirmBooking() {
    final confirmRequest = ConfirmGameBookingRequestModel(
      paymentMethod: _selectedPaymentMethod?.key ?? 'kent',
      useWallet: _useWalletBalance,
      code: _voucherCode,
    );

    gamesBloc.add(ConfirmGameBookingEvent(gameId: widget.gameId, request: confirmRequest));
  }

  int? _findPlaygroundId() {
    // Use playground ID directly from the model
    return widget.playground.id;
  }

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Confirm Game Booking',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: CustomBlocConsumer<GamesBloc, GamesState>(
        bloc: gamesBloc,
        listener: (context, state) {
          if (state is GamesError) {
            context.showMessage(isError: true, state.message);
            setState(() {
              _isUpdating = false;
            });
          } else if (state is GamesSuccess) {
            // After update succeeds, confirm the booking
            if (_isUpdating) {
              setState(() {
                _isUpdating = false;
              });
              _confirmBooking();
            } else {
              // Booking confirmed successfully
              showDialog(
                context: context,
                barrierColor: Colors.black.withValues(alpha: 0.7),
                builder: (context) => _BookingSuccessDialog(),
              );
            }
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking Details Card
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.playground.name ?? '',
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      12.heightBox(),
                      Row(
                        children: [
                          const Icon(Icons.grid_view, size: 16, color: AppColors.lightTextColor),
                          8.widthBox(),
                          Text(
                            '${widget.playground.landType ?? ''} - ${widget.playground.capacity ?? ''}',
                            style: const TextStyle(
                              color: AppColors.lightTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      8.heightBox(),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: AppColors.lightTextColor),
                          8.widthBox(),
                          Text(
                            widget.playground.city ?? '',
                            style: const TextStyle(
                              color: AppColors.lightTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      12.heightBox(),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: AppColors.primaryColor,
                                ),
                                6.widthBox(),
                                Text(
                                  DateFormat('dd MMM yyyy').format(widget.date),
                                  style: const TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          8.widthBox(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: AppColors.primaryColor,
                                ),
                                6.widthBox(),
                                Text(
                                  widget.timeSlot,
                                  style: const TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${widget.playground.price ?? '0'} KWD',
                            style: const TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                24.heightBox(),
                // Payment Method Section
                Text(
                  LocaleKeys.payment_method.tr(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                12.heightBox(),
                GestureDetector(
                  onTap: _showPaymentMethodBottomSheet,
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryWhite,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _selectedPaymentMethod?.name ??
                              _selectedPaymentMethod?.key ??
                              LocaleKeys.apple_pay.tr(),
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primaryDark),
                      ],
                    ),
                  ),
                ),
                12.heightBox(),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        size: 20,
                        color: AppColors.primaryColor,
                      ),
                      12.widthBox(),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocaleKeys.use_wallet_balance.tr(),
                              style: const TextStyle(
                                color: AppColors.primaryDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '$_walletBalance KWD',
                              style: const TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _useWalletBalance,
                        onChanged: (value) {
                          setState(() {
                            _useWalletBalance = value;
                          });
                        },
                        activeThumbColor: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),
                24.heightBox(),
                // Voucher Discount Section
                Text(
                  LocaleKeys.voucher_discount.tr(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                12.heightBox(),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: AppColors.primaryWhite,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderGrey, width: 1),
                        ),
                        child: TextField(
                          controller: _voucherController,
                          decoration: InputDecoration(
                            hintText: LocaleKeys.enter_voucher_code.tr(),
                            hintStyle: TextStyle(color: AppColors.lightTextColor, fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                24.heightBox(),
                // Price Summary Section
                Text(
                  LocaleKeys.price_summary.tr(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                12.heightBox(),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            LocaleKeys.booking_fees.tr(),
                            style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            '$_total KWD',
                            style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      12.heightBox(),
                      Divider(color: AppColors.borderGrey),
                      12.heightBox(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            LocaleKeys.total.tr(),
                            style: const TextStyle(
                              color: AppColors.primaryBlack,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$_total KWD',
                            style: const TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                32.heightBox(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBlocConsumer<GamesBloc, GamesState>(
        bloc: gamesBloc,
        listener: (context, state) {},
        builder: (context, state) {
          return Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.primaryWhite,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlack.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state is GamesLoading ? null : _updateBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: state is GamesLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryWhite),
                        ),
                      )
                    : Text(
                        LocaleKeys.confirm_booking.tr(),
                        style: const TextStyle(
                          color: AppColors.primaryWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BookingSuccessDialog extends StatelessWidget {
  const _BookingSuccessDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: AppColors.primaryWhite,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: AppColors.primaryWhite, size: 50),
            ),
            24.heightBox(),
            Text(
              LocaleKeys.game_booking_confirmed_successfully.tr(),
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            8.heightBox(),
            Text(
              LocaleKeys.have_a_fun_game.tr(),
              style: TextStyle(
                color: AppColors.lightTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            24.heightBox(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  context.router.popUntilRoot(); // Navigate back to home
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  LocaleKeys.ok_button.tr(),
                  style: const TextStyle(
                    color: AppColors.primaryWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
