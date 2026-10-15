import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/data/models/response_model/playgrounds/available_slot_model.dart';
import 'package:futblha/data/models/response_model/playgrounds/playground_model.dart';
import 'package:futblha/presentation/pages/playgrounds/bloc/playgrounds_bloc.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/widgets/app_date_picker.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';

import 'utils/booking_slot_utils.dart';

@RoutePage()
class BookPlaygroundPage extends StatefulWidget {
  final PlaygroundModel playground;
  final int? gameId; // Optional: if provided, use game booking flow

  const BookPlaygroundPage({super.key, required this.playground, this.gameId});

  @override
  State<BookPlaygroundPage> createState() => _BookPlaygroundPageState();
}

class _BookPlaygroundPageState extends State<BookPlaygroundPage> {
  final playgroundsBloc = locator<PlaygroundsBloc>();
  late DateTime _selectedDate;
  final List<AvailableSlotModel> _selectedSlots = [];
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _dateController.text = DateFormat('dd MMM yyyy').format(_selectedDate);
    _loadSlots();
  }

  String get _selectedDateStr => DateFormat('yyyy-MM-dd', 'en').format(_selectedDate);

  /// True when the bloc holds slots for the selected date and isn't reloading.
  bool _hasSlotsFor(PlaygroundsState state) =>
      state is! PlaygroundsLoading && playgroundsBloc.playgroundDetailsDate == _selectedDateStr;

  List<AvailableSlotModel> get _slots => playgroundsBloc.playgroundDetails?.availableSlots ?? [];

  void _loadSlots() {
    final playgroundId = widget.playground.id;
    if (playgroundId == null) return;
    playgroundsBloc.add(
      GetPlaygroundDetailsEvent(playgroundId: playgroundId, date: _selectedDateStr),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showAppDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.primaryWhite,
              surface: AppColors.primaryWhite,
              onSurface: AppColors.primaryBlack,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    final pickedDay = DateTime(picked.year, picked.month, picked.day);
    if (pickedDay == _selectedDate) return;
    setState(() {
      _selectedDate = pickedDay;
      // Slots are per date, so earlier choices no longer apply.
      _selectedSlots.clear();
      _dateController.text = DateFormat('dd MMM yyyy').format(pickedDay);
    });
    _loadSlots();
  }

  bool _isSameSlot(AvailableSlotModel a, AvailableSlotModel b) =>
      a.startAt == b.startAt && a.endAt == b.endAt;

  bool _isSelected(AvailableSlotModel slot) => _selectedSlots.any((s) => _isSameSlot(s, slot));

  /// A slot can be picked when the API marks it available and it hasn't
  /// started yet (same-day bookings).
  bool _isSelectable(AvailableSlotModel slot) =>
      slot.available == true &&
      !BookingSlotUtils.hasStarted(_selectedDate, slot.startAt, slot.endAt, DateTime.now());

  void _toggleTimeSlot(AvailableSlotModel slot) {
    if (_isSelected(slot)) {
      setState(() => _selectedSlots.removeWhere((s) => _isSameSlot(s, slot)));
      return;
    }
    final overlaps = BookingSlotUtils.overlapsAny(_selectedDate, (
      startAt: slot.startAt,
      endAt: slot.endAt,
    ), _selectedSlots.map((s) => (startAt: s.startAt, endAt: s.endAt)));
    if (overlaps) {
      context.showMessage(isError: true, LocaleKeys.slot_overlaps_selected.tr());
      return;
    }
    setState(() => _selectedSlots.add(slot));
  }

  /// Drops selected slots that the latest availability no longer allows.
  void _pruneSelection() {
    if (_selectedSlots.isEmpty) return;
    final stillValid = _selectedSlots
        .where((selected) => _slots.any((s) => _isSameSlot(s, selected) && _isSelectable(s)))
        .toList();
    if (stillValid.length == _selectedSlots.length) return;
    setState(() {
      _selectedSlots
        ..clear()
        ..addAll(stillValid);
    });
    context.showMessage(isError: true, LocaleKeys.selected_slots_no_longer_available.tr());
  }

  Future<void> _proceed() async {
    // Time may have passed while the user was on the page.
    _pruneSelection();
    if (_selectedSlots.isEmpty) return;

    // Keep periods in the order the API lists them (chronological).
    final ordered = _slots.where(_isSelected).toList();
    final timeSlot = ordered.map((s) => BookingSlotUtils.formatSlot(s.startAt, s.endAt)).join(', ');

    await context.router.push(
      ConfirmBookingRoute(
        playground: widget.playground,
        date: _selectedDate,
        timeSlot: timeSlot,
        gameId: widget.gameId,
      ),
    );
    // Availability may have changed while confirming (another user booked,
    // or the booking was rejected), so always reload on return.
    if (mounted) _loadSlots();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          LocaleKeys.book_playground.tr(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Date Section
            Text(
              LocaleKeys.booking_date.tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            8.heightBox(),
            GestureDetector(
              onTap: _selectDate,
              child: TextField(
                controller: _dateController,
                enabled: false,
                decoration: InputDecoration(
                  hintText: LocaleKeys.select_date.tr(),
                  filled: true,
                  suffixIcon: const Icon(Icons.calendar_today, size: 20),
                  hintStyle: TextStyle(fontSize: 14),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primaryGrey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primaryGrey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primaryGrey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primaryGrey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            24.heightBox(),
            // Booking Period Section
            Text(
              LocaleKeys.booking_period.tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            12.heightBox(),
            CustomBlocConsumer<PlaygroundsBloc, PlaygroundsState>(
              bloc: playgroundsBloc,
              listener: (context, state) {
                if (state is PlaygroundsSuccess && _hasSlotsFor(state)) {
                  _pruneSelection();
                }
              },
              builder: (context, state) {
                if (!_hasSlotsFor(state)) {
                  if (state is PlaygroundsError) {
                    return _SlotsMessage(
                      message: LocaleKeys.failed_to_load_time_slots.tr(),
                      onRetry: _loadSlots,
                    );
                  }
                  return Padding(
                    padding: EdgeInsets.all(16.w),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                      ),
                    ),
                  );
                }

                final availableSlots = _slots;
                if (availableSlots.isEmpty) {
                  return _SlotsMessage(message: LocaleKeys.no_available_time_slots.tr());
                }
                final fullyBooked = !availableSlots.any(_isSelectable);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (fullyBooked) ...[
                      _SlotsMessage(message: LocaleKeys.all_slots_booked.tr()),
                      12.heightBox(),
                    ],
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.w,
                        mainAxisSpacing: 8.h,
                        childAspectRatio: 2.5,
                      ),
                      itemCount: availableSlots.length,
                      itemBuilder: (context, index) {
                        final slot = availableSlots[index];
                        final slotStr = BookingSlotUtils.formatSlot(slot.startAt, slot.endAt);
                        final isAvailable = _isSelectable(slot);
                        final isSelected = isAvailable && _isSelected(slot);

                        return GestureDetector(
                          onTap: isAvailable ? () => _toggleTimeSlot(slot) : null,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : isAvailable
                                  ? context.mutedBackground
                                  : AppColors.primaryGrey.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(color: AppColors.primaryColor, width: 2)
                                  : null,
                            ),
                            child: Center(
                              child: isAvailable
                                  ? Text(
                                      slotStr,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.primaryWhite
                                            : context.textSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  : Stack(
                                      children: [
                                        Text(
                                          slotStr,
                                          style: TextStyle(
                                            color: AppColors.primaryGrey,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Positioned.fill(
                                          child: CustomPaint(painter: _StrikethroughPainter()),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: context.cardBackground,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlack.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: CustomBlocConsumer<PlaygroundsBloc, PlaygroundsState>(
          bloc: playgroundsBloc,
          listener: (context, state) {},
          builder: (context, state) => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // Don't let the user continue on slots that are being refreshed.
              onPressed: _hasSlotsFor(state) && _selectedSlots.isNotEmpty ? _proceed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                disabledBackgroundColor: AppColors.primaryGrey,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                LocaleKeys.proceed_to_payment.tr(),
                style: const TextStyle(
                  color: AppColors.primaryWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SlotsMessage extends StatelessWidget {
  const _SlotsMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.mutedBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            message,
            style: const TextStyle(color: AppColors.lightTextColor, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            8.heightBox(),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(foregroundColor: context.brandOnSurface),
              child: Text(LocaleKeys.retry.tr()),
            ),
          ],
        ],
      ),
    );
  }
}

class _StrikethroughPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryGrey
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
