import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/pages/bookings/my_bookings_page.dart';
import 'package:futblha/presentation/pages/bookings/bloc/bookings_bloc.dart';
import 'package:futblha/presentation/widgets/custom_loading_widget.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:futblha/generated/locale_keys.g.dart';

@RoutePage()
class BookingDetailsPage extends StatefulWidget {
  final BookingItem booking;

  const BookingDetailsPage({super.key, required this.booking});

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  final bloc = locator<BookingsBloc>();

  @override
  void initState() {
    super.initState();
    // Extract booking ID from bookingId string (e.g., "#28" -> 28)
    final bookingIdStr = widget.booking.bookingId.replaceAll('#', '').trim();
    final bookingId = int.tryParse(bookingIdStr);
    if (bookingId != null) {
      bloc.add(GetBookingDetailsEvent(bookingId: bookingId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,

        title: Text(
          LocaleKeys.booking_details.tr(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: CustomBlocConsumer<BookingsBloc, BookingsState>(
        bloc: bloc,
        listener: (context, state) {
          if (state is BookingsError) {
            context.showMessage(isError: true, state.message);
          }
        },
        builder: (context, state) {
          final bookingData = bloc.bookingDetails;

          final paymentMethod =
              bookingData?.paymentMethodText ?? widget.booking.paymentMethod ?? 'Apple Pay';
          final bookingFee = bookingData != null
              ? double.tryParse(bookingData.total?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ?? 0.0
              : widget.booking.bookingFee ?? 30.0;
          final discount = bookingData != null
              ? (double.tryParse(
                          bookingData.voucherDiscount?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0',
                        ) ??
                        0.0) +
                    (double.tryParse(
                          bookingData.walletDiscount?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0',
                        ) ??
                        0.0)
              : widget.booking.discount ?? 3.0;
          final total = bookingData != null
              ? double.tryParse(bookingData.grandTotal?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ??
                    0.0
              : widget.booking.total ?? 27.0;

          final periods = bookingData?.periods ?? [];
          final timeRange = periods.isNotEmpty
              ? '${periods.first.startTime ?? ''} - ${periods.last.endTime ?? ''}'
              : widget.booking.time;

          return state is BookingsLoading
              ? const LoadingWidget()
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Booking Information Card
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: context.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Booking ID Tag
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: context.chipBackground,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                bookingData?.id != null
                                    ? '#${bookingData!.id}'
                                    : widget.booking.bookingId,
                                style: TextStyle(
                                  color: context.brandOnSurface,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            12.heightBox(),
                            // Location Name
                            Text(
                              bookingData?.playground?.name ?? widget.booking.locationName,
                              style: TextStyle(
                                color: context.brandOnSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            8.heightBox(),
                            // Field Type
                            Row(
                              children: [
                                const Icon(
                                  Icons.grid_view,
                                  size: 16,
                                  color: AppColors.lightTextColor,
                                ),
                                8.widthBox(),
                                Text(
                                  bookingData?.playground != null
                                      ? '${bookingData!.playground!.landType ?? ''} - ${bookingData.playground!.capacity ?? ''}'
                                      : widget.booking.fieldType,
                                  style: const TextStyle(
                                    color: AppColors.lightTextColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            8.heightBox(),
                            // City
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: AppColors.lightTextColor,
                                ),
                                8.widthBox(),
                                Text(
                                  bookingData?.playground?.city ?? widget.booking.city,
                                  style: const TextStyle(
                                    color: AppColors.lightTextColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            12.heightBox(),
                            // Date and Time
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: context.chipBackground,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: context.brandOnSurface,
                                      ),
                                      6.widthBox(),
                                      Text(
                                        bookingData?.bookingDate ?? widget.booking.date,
                                        style: TextStyle(
                                          color: context.brandOnSurface,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (timeRange.isNotEmpty) ...[
                                  8.widthBox(),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: context.chipBackground,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: context.brandOnSurface,
                                        ),
                                        6.widthBox(),
                                        Text(
                                          timeRange,
                                          style: TextStyle(
                                            color: context.brandOnSurface,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: context.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              paymentMethod,
                              style: TextStyle(
                                color: context.brandOnSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (paymentMethod.contains('Apple') || paymentMethod == 'Apple Pay')
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.apple, color: context.textPrimary, size: 20),
                                  4.widthBox(),
                                  Text(
                                    LocaleKeys.pay.tr(),
                                    style: TextStyle(
                                      color: context.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
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
                          color: context.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  LocaleKeys.booking_fees.tr(),
                                  style: TextStyle(
                                    color: context.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  '$bookingFee ${LocaleKeys.kwd.tr()}',
                                  style: TextStyle(
                                    color: context.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            if (discount > 0) ...[
                              8.heightBox(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    LocaleKeys.discount.tr(),
                                    style: TextStyle(
                                      color: context.textSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    '- $discount ${LocaleKeys.kwd.tr()}',
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
                            Divider(color: context.borderColor),
                            12.heightBox(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  LocaleKeys.total.tr(),
                                  style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '$total ${LocaleKeys.kwd.tr()}',
                                  style: TextStyle(
                                    color: context.brandOnSurface,
                                    fontSize: 16,
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
    );
  }
}
