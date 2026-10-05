import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/data/models/response_model/playgrounds/playground_model.dart';
import 'package:futblha/presentation/pages/playgrounds/bloc/playgrounds_bloc.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:intl/intl.dart';
import 'package:futblha/presentation/widgets/app_date_picker.dart';

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
  DateTime? _selectedDate;
  List<String> _selectedTimeSlots = [];
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _dateController.text = DateFormat('dd MMM yyyy').format(_selectedDate!);
    // Find playground ID from the list or use a default
    final playgroundId = _findPlaygroundId();
    if (playgroundId != null) {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      playgroundsBloc.add(GetPlaygroundDetailsEvent(playgroundId: playgroundId, date: dateStr));
    }
  }

  int? _findPlaygroundId() {
    // Use playground ID directly from the model
    return widget.playground.id;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showAppDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlots = [];
        _dateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
      // Fetch available slots for the selected date
      final playgroundId = _findPlaygroundId();
      if (playgroundId != null) {
        final dateStr = DateFormat('yyyy-MM-dd').format(picked);
        playgroundsBloc.add(GetPlaygroundDetailsEvent(playgroundId: playgroundId, date: dateStr));
      }
    }
  }

  String _formatTimeSlot(String? startTime, String? endTime) {
    if (startTime == null || endTime == null) return '';
    return '$startTime - $endTime';
  }

  void _toggleTimeSlot(String slot) {
    setState(() {
      if (_selectedTimeSlots.contains(slot)) {
        _selectedTimeSlots.remove(slot);
      } else {
        _selectedTimeSlots.add(slot);
      }
    });
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            12.heightBox(),
            CustomBlocConsumer<PlaygroundsBloc, PlaygroundsState>(
              bloc: playgroundsBloc,
              listener: (context, state) {},
              builder: (context, state) {
                final details = playgroundsBloc.playgroundDetails;
                final availableSlots = details?.availableSlots ?? [];

                if (availableSlots.isEmpty && _selectedDate == null) {
                  return const Center(
                    child: Text(
                      'Please select a date first',
                      style: TextStyle(color: AppColors.lightTextColor, fontSize: 14),
                    ),
                  );
                }

                return GridView.builder(
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
                    final slotStr = _formatTimeSlot(slot.startAt, slot.endAt);
                    final isAvailable = slot.available ?? false;
                    final isSelected = _selectedTimeSlots.contains(slotStr);

                    return GestureDetector(
                      onTap: isAvailable ? () => _toggleTimeSlot(slotStr) : null,
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_selectedDate != null && _selectedTimeSlots.isNotEmpty)
                ? () {
                    context.router.push(
                      ConfirmBookingRoute(
                        playground: widget.playground,
                        date: _selectedDate!,
                        timeSlot: _selectedTimeSlots.join(', '),
                        gameId: widget.gameId,
                      ),
                    );
                  }
                : null,
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
