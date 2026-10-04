import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/pages/bookings/bloc/bookings_bloc.dart';
import 'package:futblha/presentation/widgets/custom_loading_widget.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/generated/locale_keys.g.dart';

@RoutePage()
class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  final bloc = locator<BookingsBloc>();

  @override
  void initState() {
    super.initState();
    bloc.add(GetBookingsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          LocaleKeys.my_bookings.tr(),
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
          return state is BookingsLoading
              ? const LoadingWidget()
              : bloc.bookings.isEmpty
                  ? Center(
                      child: Text(
                        LocaleKeys.no_bookings_yet.tr(),
                        style: TextStyle(color: AppColors.lightTextColor, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      itemCount: bloc.bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bloc.bookings[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: _buildBookingCard(booking, context),
                        );
                      },
                    );
        },
      ),
    );
  }

  Widget _buildBookingCard(booking, BuildContext context) {
    final bookingId = booking.id != null ? '#${booking.id}' : 'N/A';
    final periods = booking.periods ?? [];
    final timeRange = periods.isNotEmpty
        ? '${periods.first.startTime ?? ''} - ${periods.last.endTime ?? ''}'
        : '';
    
    return GestureDetector(
      onTap: () {
        if (booking.id != null) {
          // Create temporary BookingItem for route compatibility
          final tempItem = BookingItem(
            bookingId: '#${booking.id}',
            locationName: booking.playground?.name ?? '',
            fieldType: booking.playground != null
                ? '${booking.playground!.landType ?? ''} - ${booking.playground!.capacity ?? ''}'
                : '',
            city: booking.playground?.city ?? '',
            date: booking.bookingDate ?? '',
            time: timeRange,
            paymentMethod: booking.paymentMethodText,
            bookingFee: double.tryParse(booking.total?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0'),
            discount: double.tryParse(booking.voucherDiscount?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0'),
            total: double.tryParse(booking.grandTotal?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0'),
          );
          context.router.push(BookingDetailsRoute(booking: tempItem));
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.primaryWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking ID Tag
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                bookingId,
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            12.heightBox(),
            // Location Name
            Text(
              booking.playground?.name ?? '',
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            8.heightBox(),
            // Field Type
            Row(
              children: [
                const Icon(Icons.grid_view, size: 16, color: AppColors.lightTextColor),
                8.widthBox(),
                Text(
                  booking.playground != null
                      ? '${booking.playground!.landType ?? ''} - ${booking.playground!.capacity ?? ''}'
                      : '',
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
                const Icon(Icons.location_on, size: 16, color: AppColors.lightTextColor),
                8.widthBox(),
                Text(
                  booking.playground?.city ?? '',
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
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppColors.primaryColor),
                      6.widthBox(),
                      Text(
                        booking.bookingDate ?? '',
                        style: const TextStyle(
                          color: AppColors.primaryColor,
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
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time, size: 14, color: AppColors.primaryColor),
                        6.widthBox(),
                        Text(
                          timeRange,
                          style: const TextStyle(
                            color: AppColors.primaryColor,
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
    );
  }
}

class BookingItem {
  final String bookingId;
  final String locationName;
  final String fieldType;
  final String city;
  final String date;
  final String time;
  final String? paymentMethod;
  final double? bookingFee;
  final double? discount;
  final double? total;

  const BookingItem({
    required this.bookingId,
    required this.locationName,
    required this.fieldType,
    required this.city,
    required this.date,
    required this.time,
    this.paymentMethod,
    this.bookingFee,
    this.discount,
    this.total,
  });
}
