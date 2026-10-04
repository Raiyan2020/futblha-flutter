import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/pages/auth/bloc/authentication_bloc.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/data/models/response_model/playgrounds/playground_model.dart';
import 'package:futblha/presentation/pages/playgrounds/bloc/playgrounds_bloc.dart';
import 'package:futblha/presentation/pages/bookings/bloc/bookings_bloc.dart';
import 'package:futblha/presentation/pages/games/bloc/games_bloc.dart';
import 'package:futblha/domain/entities/payment_method_entity.dart';
import 'package:futblha/presentation/pages/playgrounds/payment_method_bottom_sheet.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:futblha/presentation/pages/settings/bloc/settings_bloc.dart';
import 'package:futblha/data/models/request_model/playgrounds/booking_request_model.dart';
import 'package:futblha/data/models/request_model/playgrounds/voucher_request_model.dart';
import 'package:futblha/data/models/request_model/games/update_game_booking_request_model.dart';
import 'package:futblha/data/models/request_model/games/confirm_game_booking_request_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:intl/intl.dart';

@RoutePage()
class ConfirmBookingPage extends StatefulWidget {
  final PlaygroundModel playground;
  final DateTime date;
  final String timeSlot;
  final int? gameId; // Optional: if provided, use game booking flow
  final bool
  skipUpdate; // If true, directly call confirm-booking API (when booking is already available)

  const ConfirmBookingPage({
    super.key,
    required this.playground,
    required this.date,
    required this.timeSlot,
    this.gameId,
    this.skipUpdate = false,
  });

  @override
  State<ConfirmBookingPage> createState() => _ConfirmBookingPageState();
}

class _ConfirmBookingPageState extends State<ConfirmBookingPage> {
  final bookingsBloc = locator<BookingsBloc>();
  final gamesBloc = locator<GamesBloc>();
  final playgroundsBloc = locator<PlaygroundsBloc>();
  final settingsBloc = locator<SettingsBloc>();

  PaymentMethodEntity? _selectedPaymentMethod;
  bool _useWalletBalance = false;
  final TextEditingController _voucherController = TextEditingController();

  /// Voucher discount as percentage from API (e.g. 10 means 10%).
  double _voucherDiscountPercentage = 0.0;
  String? _voucherCode;
  final _walletBalance = locator<AuthenticationBloc>().user?.balance ?? '0';
  bool _isUpdating = false; // For game booking flow
  final String? _walletUsagePercentage =
      locator<SettingsBloc>().settingsResponseMod?.walletUsagePercentage;

  double get _bookingFee {
    final priceStr = (widget.playground.price ?? '0').replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(priceStr) ?? 0.0;
  }

  double get _walletBalanceValue {
    final balanceStr = _walletBalance.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(balanceStr) ?? 0.0;
  }

  /// Voucher discount amount in KWD (computed from percentage of booking subtotal).
  double get _voucherDiscount {
    final subtotalBeforeVoucher = _bookingFee * _timeSlotsList.length;
    if (subtotalBeforeVoucher <= 0 || _voucherDiscountPercentage <= 0) return 0.0;
    return (subtotalBeforeVoucher * _voucherDiscountPercentage) / 100;
  }

  double get _walletDiscount {
    if (!_useWalletBalance) return 0.0;

    final subtotal = (_bookingFee * _timeSlotsList.length) - _voucherDiscount;
    if (subtotal <= 0) return 0.0;

    final walletBalance = _walletBalanceValue;

    // Calculate wallet discount based on percentage from settings
    // Example: If wallet_usage_percentage = 10 and subtotal = 100, discount = 10
    double walletDiscountAmount = 0.0;

    if (_walletUsagePercentage != null && _walletUsagePercentage.isNotEmpty) {
      // Parse the percentage value (remove any non-numeric characters except decimal point)
      final percentageStr = _walletUsagePercentage.replaceAll(RegExp(r'[^\d.]'), '');
      final percentage = double.tryParse(percentageStr) ?? 0.0;

      if (percentage > 0) {
        // Calculate discount as percentage of subtotal
        // Example: subtotal = 100, percentage = 10 -> discount = (100 * 10) / 100 = 10
        walletDiscountAmount = (subtotal * percentage) / 100;

        // Cap discount to not exceed available wallet balance
        // If wallet doesn't have enough, use what's available
        if (walletDiscountAmount > walletBalance) {
          walletDiscountAmount = walletBalance;
        }

        // Cap discount to not exceed subtotal (to prevent negative total)
        if (walletDiscountAmount > subtotal) {
          walletDiscountAmount = subtotal;
        }
      }
    }
    // If percentage is not set or is 0, no wallet discount is applied

    return walletDiscountAmount;
  }

  List<String> get _timeSlotsList =>
      widget.timeSlot.split(', ').where((s) => s.isNotEmpty).toList();

  double get _total {
    final subtotal = (_bookingFee * _timeSlotsList.length) - _voucherDiscount;
    final total = subtotal - _walletDiscount;
    // Ensure total never goes negative
    return total < 0 ? 0.0 : total;
  }

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

  void _applyVoucher() {
    if (_voucherController.text.isNotEmpty) {
      bookingsBloc.add(
        CheckVoucherEvent(request: VoucherRequestModel(code: _voucherController.text)),
      );
    }
  }

  void _clearVoucher() {
    setState(() {
      _voucherDiscountPercentage = 0.0;
      _voucherCode = null;
      _voucherController.clear();
    });
  }

  void _confirmBooking() {
    // If gameId is provided, use game booking flow
    if (widget.gameId != null) {
      // If skipUpdate is true, directly confirm booking (booking is already available)
      if (widget.skipUpdate) {
        setState(() {
          _voucherCode = _voucherController.text.isNotEmpty ? _voucherController.text : null;
        });
        _confirmGameBooking();
      } else {
        // Otherwise, update booking first, then confirm
        _updateGameBooking();
      }
      return;
    }

    // Regular booking flow
    final playgroundId = _findPlaygroundId();
    if (playgroundId == null) {
      context.showMessage(isError: true, LocaleKeys.playground_not_found.tr());
      return;
    }

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

    final bookingRequest = BookingRequestModel(
      code: _voucherCode,
      playgroundId: playgroundId,
      bookingDate: DateFormat('yyyy-MM-dd').format(widget.date),
      periods: periods,
      paymentMethod: _selectedPaymentMethod?.key ?? 'kent',
      useWallet: _useWalletBalance,
    );

    bookingsBloc.add(CreateBookingEvent(request: bookingRequest));
  }

  void _updateGameBooking() {
    final playgroundId = _findPlaygroundId();
    if (playgroundId == null) {
      context.showMessage(isError: true, LocaleKeys.playground_not_found.tr());
      return;
    }

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

    gamesBloc.add(UpdateGameBookingEvent(gameId: widget.gameId!, request: updateRequest));
  }

  void _confirmGameBooking() {
    final confirmRequest = ConfirmGameBookingRequestModel(
      paymentMethod: _selectedPaymentMethod?.key ?? 'kent',
      useWallet: _useWalletBalance,
      code: _voucherCode,
    );

    gamesBloc.add(ConfirmGameBookingEvent(gameId: widget.gameId!, request: confirmRequest));
  }

  int? _findPlaygroundId() {
    // Use playground ID directly from the model
    return widget.playground.id;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  Widget _buildBookingContent() {
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.playground.name ?? '',
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${widget.playground.price ?? '0'} ${LocaleKeys.kwd.tr()}',
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.w,
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
                          const Icon(Icons.calendar_today, size: 14, color: AppColors.primaryColor),
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
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.access_time, size: 14, color: AppColors.primaryColor),
                          6.widthBox(),
                          Flexible(
                            child: Text(
                              widget.timeSlot,
                              style: const TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
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
                    _selectedPaymentMethod?.name ?? _selectedPaymentMethod?.key ?? 'Apple Pay',
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
                const Icon(Icons.account_balance_wallet, size: 20, color: AppColors.primaryColor),
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
                        '${_walletBalanceValue.toStringAsFixed(2)} ${LocaleKeys.kwd.tr()}',
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          12.heightBox(),
          Row(
            children: [
              Expanded(
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
              12.widthBox(),
              if (_voucherDiscount > 0) ...[
                TextButton(
                  onPressed: _clearVoucher,
                  child: Text(
                    LocaleKeys.clear_all.tr(),
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                12.widthBox(),
              ],
              ElevatedButton(
                onPressed: _applyVoucher,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  LocaleKeys.apply.tr(),
                  style: const TextStyle(
                    color: AppColors.primaryWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
                      '${_bookingFee.toStringAsFixed(2)} ${LocaleKeys.kwd.tr()}',
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (_voucherDiscount > 0) ...[
                  8.heightBox(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LocaleKeys.voucher_discount.tr(),
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        '($_voucherDiscountPercentage%) - ${_voucherDiscount.toStringAsFixed(2)} ${LocaleKeys.kwd.tr()}',
                        style: const TextStyle(
                          color: AppColors.primaryRed,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                if (_walletDiscount > 0) ...[
                  8.heightBox(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LocaleKeys.wallet_discount.tr(),
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        '- ${_walletDiscount.toStringAsFixed(2)} ${LocaleKeys.kwd.tr()}',
                        style: const TextStyle(
                          color: AppColors.primaryRed,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
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
                      '${_total.toStringAsFixed(2)} ${LocaleKeys.kwd.tr()}',
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.gameId != null
              ? LocaleKeys.confirm_game_booking.tr()
              : LocaleKeys.confirm_booking.tr(),
        ),
      ),
      body: widget.gameId != null
          ? MultiBlocListener(
              listeners: [
                BlocListener<BookingsBloc, BookingsState>(
                  bloc: bookingsBloc,
                  listener: (context, state) {
                    if (state is BookingsError) {
                      context.showMessage(isError: true, state.message);
                    } else if (state is BookingsSuccess) {
                      if (bookingsBloc.voucherDetails != null &&
                          _voucherController.text.isNotEmpty) {
                        final discountPercentage = double.tryParse(
                              bookingsBloc.voucherDetails!.discount
                                  ?.replaceAll(RegExp(r'[^\d.]'), '') ??
                                  '0',
                            ) ??
                            0.0;
                        setState(() {
                          _voucherDiscountPercentage = discountPercentage;
                          _voucherCode = _voucherController.text;
                        });
                        context.showMessage(
                          isError: false,
                          LocaleKeys.voucher_applied_successfully.tr(),
                        );
                      }
                    }
                  },
                ),
                BlocListener<GamesBloc, GamesState>(
                  bloc: gamesBloc,
                  listener: (context, state) {
                    if (state is GamesError) {
                      context.showMessage(isError: true, state.message);
                      setState(() {
                        _isUpdating = false;
                      });
                    } else if (state is GamesSuccess) {
                      if (_isUpdating) {
                        setState(() {
                          _isUpdating = false;
                        });
                        _confirmGameBooking();
                      } else {
                        final paymentUrl =
                            gamesBloc.gameDetails?.booking?.paymentUrl;
                        if (paymentUrl != null && paymentUrl.isNotEmpty) {
                          context.router
                              .push(PaymentWebViewRoute(paymentUrl: paymentUrl));
                        } else {
                          showDialog(
                            context: context,
                            barrierColor: Colors.black.withValues(alpha: 0.7),
                            builder: (context) =>
                                _BookingSuccessDialog(isGameBooking: true),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
              child: BlocBuilder<GamesBloc, GamesState>(
                bloc: gamesBloc,
                builder: (context, state) => _buildBookingContent(),
              ),
            )
          : CustomBlocConsumer<BookingsBloc, BookingsState>(
              bloc: bookingsBloc,
              listener: (context, state) {
                if (state is BookingsError) {
                  context.showMessage(isError: true, state.message);
                } else if (state is BookingsSuccess) {
                  if (bookingsBloc.voucherDetails != null && _voucherController.text.isNotEmpty) {
                    // API returns discount as percentage (e.g. 10 means 10%)
                    final discountPercentage =
                        double.tryParse(
                          bookingsBloc.voucherDetails!.discount?.replaceAll(
                                RegExp(r'[^\d.]'),
                                '',
                              ) ??
                              '0',
                        ) ??
                        0.0;
                    setState(() {
                      _voucherDiscountPercentage = discountPercentage;
                      _voucherCode = _voucherController.text;
                    });
                    context.showMessage(
                      isError: false,
                      LocaleKeys.voucher_applied_successfully.tr(),
                    );
                  }
                  if (bookingsBloc.bookingDetails != null) {
                    showDialog(
                      context: context,
                      barrierColor: Colors.black.withValues(alpha: 0.7),
                      builder: (context) => _BookingSuccessDialog(
                        paymentUrl: bookingsBloc.bookingDetails?.paymentUrl,
                        isGameBooking: false,
                      ),
                    );
                  }
                }
              },
              builder: (context, state) => _buildBookingContent(),
            ),
      bottomNavigationBar: widget.gameId != null
          ? CustomBlocConsumer<GamesBloc, GamesState>(
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
                      onPressed: state is GamesLoading ? null : _confirmBooking,
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
            )
          : CustomBlocConsumer<BookingsBloc, BookingsState>(
              bloc: bookingsBloc,
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
                      onPressed: state is BookingsLoading ? null : _confirmBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: state is BookingsLoading
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
  final String? paymentUrl;
  final bool isGameBooking;

  const _BookingSuccessDialog({this.paymentUrl, required this.isGameBooking});

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
              isGameBooking
                  ? LocaleKeys.game_booking_confirmed_successfully.tr()
                  : LocaleKeys.booking_done_successfully.tr(),
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            8.heightBox(),
            Text(
              'Have a fun game!',
              style: TextStyle(
                color: AppColors.lightTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            24.heightBox(),
            if (!isGameBooking && paymentUrl != null && paymentUrl!.isNotEmpty) ...[
              Text(
                LocaleKeys.complete_payment_message.tr(),
                style: TextStyle(
                  color: AppColors.lightTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              20.heightBox(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.router.push(PaymentWebViewRoute(paymentUrl: paymentUrl!));
                  },
                  icon: const Icon(Icons.payment, color: AppColors.primaryWhite, size: 20),
                  label: Text(
                    LocaleKeys.proceed_to_payment.tr(),
                    style: const TextStyle(
                      color: AppColors.primaryWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                ),
              ),
              // 12.heightBox(),
              // TextButton(
              //   onPressed: () {
              //     Navigator.of(context).pop();
              //     context.router.popUntilRoot();
              //   },
              //   child: Text(
              //     'Pay Later',
              //     style: TextStyle(
              //       color: AppColors.lightTextColor,
              //       fontSize: 14,
              //       fontWeight: FontWeight.w500,
              //     ),
              //   ),
              // ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.router.popUntilRoot();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
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
          ],
        ),
      ),
    );
  }
}
