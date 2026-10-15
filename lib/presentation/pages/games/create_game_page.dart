import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/data/models/response_model/playgrounds/playground_model.dart';
import 'package:futblha/presentation/pages/games/bloc/games_bloc.dart';
import 'package:futblha/presentation/pages/playgrounds/bloc/playgrounds_bloc.dart';
import 'package:futblha/data/models/request_model/games/create_game_request_model.dart';
import 'package:futblha/presentation/pages/games/utils/game_formation_utils.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:intl/intl.dart';
import 'package:futblha/data/models/enums/position_enum.dart';
import 'package:futblha/presentation/widgets/app_date_picker.dart';
import 'package:futblha/presentation/pages/playgrounds/utils/booking_slot_utils.dart';

enum GameType { myDiwaniyaOnly, privateGame, publicGame }

/// When the creator pays for the playground.
enum GamePaymentTiming {
  /// Pay right after creating the game, on the existing payment screen.
  immediate,

  /// Pay later from the game page, once all players have joined (the
  /// existing flow).
  afterPlayersComplete,
}

@RoutePage()
class CreateGamePage extends StatefulWidget {
  final GameType gameType;

  const CreateGamePage({super.key, required this.gameType});

  @override
  State<CreateGamePage> createState() => _CreateGamePageState();
}

class _CreateGamePageState extends State<CreateGamePage> {
  final bloc = locator<GamesBloc>();
  final playgroundsBloc = locator<PlaygroundsBloc>();
  PlaygroundModel? _selectedPlayground;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  final TextEditingController _dateController = TextEditingController();
  int? _opponentDiwaniyaId; // For private games
  int? _selectedPlayers; // Number of players
  Position? _selectedPosition; // Playing position
  GamePaymentTiming? _paymentTiming;
  // Set when the create request is sent, so a double tap can't create two games.
  bool _isSubmitting = false;

  // Game types that offer a payment timing choice. Private games keep their
  // existing flow (the opponent Diwaniya must accept first).
  static const _paymentTimingGameTypes = {GameType.publicGame, GameType.myDiwaniyaOnly};

  bool get _supportsPaymentTiming => _paymentTimingGameTypes.contains(widget.gameType);

  int? _findPlaygroundId() {
    // Use playground ID directly from the model
    return _selectedPlayground?.id;
  }

  /// Get available time slots from playground details
  List<String> get _availableTimeSlots {
    final date = _selectedDate;
    // Ignore slots loaded for another playground or date.
    if (date == null ||
        playgroundsBloc.playgroundDetailsPlaygroundId != _findPlaygroundId() ||
        playgroundsBloc.playgroundDetailsDate != DateFormat('yyyy-MM-dd', 'en').format(date)) {
      return [];
    }
    final now = DateTime.now();
    final slots = playgroundsBloc.playgroundDetails?.availableSlots ?? [];
    return slots
        .where((slot) => slot.available == true)
        .where((slot) => !BookingSlotUtils.hasStarted(date, slot.startAt, slot.endAt, now))
        .map((slot) => '${slot.startAt ?? ''} - ${slot.endAt ?? ''}')
        .where((slot) => slot.isNotEmpty && slot != ' - ')
        .toList();
  }

  /// Fetch playground details when playground and date are selected
  void _fetchPlaygroundDetails() {
    final playgroundId = _findPlaygroundId();
    if (playgroundId != null && _selectedDate != null) {
      final dateStr = DateFormat('yyyy-MM-dd', 'en').format(_selectedDate!);
      playgroundsBloc.add(GetPlaygroundDetailsEvent(playgroundId: playgroundId, date: dateStr));
    }
  }

  // Available player counts
  final List<int> _playerCounts = [8, 10, 12, 14, 16, 18, 20, 22];

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
        _dateController.text = DateFormat('dd MMM yyyy').format(picked);
        _selectedTimeSlot = null; // Reset selected slot when date changes
      });
      // Fetch available slots for the new date
      _fetchPlaygroundDetails();
    }
  }

  Future<void> _selectPlayground() async {
    final result = await context.router.push<PlaygroundModel>(const PlaygroundSelectionRoute());
    if (result != null) {
      setState(() {
        _selectedPlayground = result;
        _selectedTimeSlot = null; // Reset selected slot when playground changes
      });
      // Fetch available slots if date is already selected
      if (_selectedDate != null) {
        _fetchPlaygroundDetails();
      }
    }
  }

  Future<void> _createGame() async {
    if (_isSubmitting) return;
    if (_selectedPlayground == null ||
        _selectedDate == null ||
        _selectedTimeSlot == null ||
        _selectedPlayers == null ||
        _selectedPosition == null) {
      context.showMessage(isError: true, LocaleKeys.please_fill_all_required_fields.tr());
      return;
    }
    if (_supportsPaymentTiming && _paymentTiming == null) {
      context.showMessage(isError: true, LocaleKeys.please_select_payment_method.tr());
      return;
    }

    if (widget.gameType == GameType.privateGame && _opponentDiwaniyaId == null) {
      // Navigate to opposing diwaniya selection
      final result = await context.router.push<int>(
        OpposingDiwaniyaSelectionRoute(
          playground: _selectedPlayground!,
          date: _selectedDate!,
          timeSlot: _selectedTimeSlot!,
        ),
      );
      if (result != null) {
        setState(() {
          _opponentDiwaniyaId = result;
        });
        // Create game after selection
        _submitGame();
      }
    } else {
      // Create game directly
      _submitGame();
    }
  }

  void _submitGame() {
    if (_selectedPlayground == null ||
        _selectedDate == null ||
        _selectedTimeSlot == null ||
        _selectedPlayers == null ||
        _selectedPosition == null) {
      return;
    }

    // Parse time slot to periods
    final periods = _parseTimeSlotToPeriods(_selectedTimeSlot!);
    if (periods.isEmpty) {
      context.showMessage(isError: true, LocaleKeys.invalid_time_slot_format.tr());
      return;
    }

    // Determine game type string
    String gameType;
    switch (widget.gameType) {
      case GameType.myDiwaniyaOnly:
        gameType = 'my_diwanya';
        break;
      case GameType.privateGame:
        gameType = 'private';
        break;
      case GameType.publicGame:
        gameType = 'public';
        break;
    }

    // Find playground ID
    final playgroundId = _findPlaygroundId();
    if (playgroundId == null) {
      context.showMessage(isError: true, LocaleKeys.playground_not_found_select_again.tr());
      return;
    }

    // Create request
    // _selectedPlayers is total players, API expects players per team, so divide by 2

    final playersPerTeam = _selectedPlayers! ~/ 2;
    final predictedSlot = getSlotIndexForPosition(_selectedPosition!.key, playersPerTeam);

    final request = CreateGameRequestModel(
      playgroundId: playgroundId,
      bookingDate: DateFormat('yyyy-MM-dd', 'en').format(_selectedDate!),
      periods: periods,
      type: gameType,
      players: _selectedPlayers!,
      position: _selectedPosition!.key,
      opponentDiwaniyaId: widget.gameType == GameType.privateGame ? _opponentDiwaniyaId : null,
      slotIndex: predictedSlot,
    );

    setState(() => _isSubmitting = true);
    bloc.add(CreateGameEvent(request: request));
  }

  /// "Pay now": the game exists, so open the existing game payment screen
  /// (confirm-booking). The playground is only booked once the backend
  /// confirms the payment; this page never assumes it.
  Future<void> _openPaymentForCreatedGame() async {
    final gameId = bloc.createdGame?.id;
    if (gameId == null) {
      _showSuccessDialog();
      return;
    }
    await context.router.push(
      ConfirmBookingRoute(
        playground: _selectedPlayground!,
        date: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
        gameId: gameId,
        skipUpdate: true,
      ),
    );
    // A successful payment clears the whole stack, so getting here means the
    // user left the payment without finishing it. The game stays created;
    // close this form so it can't be submitted again.
    if (!mounted) return;
    context.showMessage(isError: true, LocaleKeys.game_created_payment_pending.tr());
    context.router.pop(true);
  }

  List<GamePeriod> _parseTimeSlotToPeriods(String timeSlot) {
    // Format: "10:00 - 11:00" or "10:00-11:00"
    try {
      final parts = timeSlot.split('-');
      if (parts.length == 2) {
        final startTime = parts[0].trim();
        final endTime = parts[1].trim();
        return [GamePeriod(startTime: startTime, endTime: endTime)];
      }
    } catch (e) {
      // Invalid format
    }
    return [];
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => _GameCreatedSuccessDialog(),
    ).then((_) {
      context.router.pop(true);
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<GamesBloc, GamesState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is GamesError) {
          setState(() => _isSubmitting = false);
          context.showMessage(isError: true, state.message);
        } else if (state is GamesSuccess && bloc.createdGame != null) {
          if (_supportsPaymentTiming && _paymentTiming == GamePaymentTiming.immediate) {
            _openPaymentForCreatedGame();
          } else {
            _showSuccessDialog();
          }
        }
      },
      builder: (context, state) {
        // Also listen to playground bloc for available slots
        return CustomBlocConsumer<PlaygroundsBloc, PlaygroundsState>(
          bloc: playgroundsBloc,
          listener: (context, playgroundState) {
            // Reset selected slot if it's no longer available
            if (_selectedTimeSlot != null && !_availableTimeSlots.contains(_selectedTimeSlot)) {
              setState(() {
                _selectedTimeSlot = null;
              });
            }
          },
          builder: (context, playgroundState) {
            return Scaffold(
              appBar: AppBar(title: Text(LocaleKeys.create_game.tr())),
              body: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Game Type Button
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: context.chipBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getGameTypeText(),
                        style: TextStyle(
                          color: context.brandOnSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    24.heightBox(),
                    // Playing Position Section
                    Text(
                      LocaleKeys.playing_position.tr(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    8.heightBox(),
                    DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<Position>(
                        value: _selectedPosition,
                        isExpanded: true,
                        hint: Text(LocaleKeys.select_playing_position.tr()),
                        decoration: InputDecoration(
                          hintText: LocaleKeys.select_playing_position.tr(),
                        ),
                        items: Position.selectablePositions.map((Position position) {
                          return DropdownMenuItem<Position>(
                            value: position,
                            child: Text(position.displayName),
                          );
                        }).toList(),
                        onChanged: (Position? value) {
                          setState(() {
                            _selectedPosition = value;
                          });
                        },
                      ),
                    ),
                    24.heightBox(),
                    // Playground Section
                    Text(
                      LocaleKeys.playground.tr(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    8.heightBox(),
                    GestureDetector(
                      onTap: _selectPlayground,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: context.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.borderColor, width: 1),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedPlayground?.name ?? LocaleKeys.select_playground.tr(),
                                style: TextStyle(
                                  color: _selectedPlayground != null
                                      ? context.textPrimary
                                      : AppColors.lightTextColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: context.brandOnSurface,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                    24.heightBox(),
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
                          suffixIcon: const Icon(Icons.calendar_today, size: 20),
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
                    if (_selectedPlayground == null || _selectedDate == null)
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: context.mutedBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          LocaleKeys.please_select_playground_and_date.tr(),
                          style: TextStyle(color: AppColors.lightTextColor, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else if (playgroundState is PlaygroundsLoading)
                      Container(
                        padding: EdgeInsets.all(16.w),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                          ),
                        ),
                      )
                    else if (_availableTimeSlots.isEmpty)
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: context.mutedBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          LocaleKeys.no_available_time_slots.tr(),
                          style: TextStyle(color: AppColors.lightTextColor, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8.w,
                          mainAxisSpacing: 8.h,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: _availableTimeSlots.length,
                        itemBuilder: (context, index) {
                          final slot = _availableTimeSlots[index];
                          final isSelected = _selectedTimeSlot == slot;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTimeSlot = slot;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : context.mutedBackground,
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected
                                    ? Border.all(color: AppColors.primaryColor, width: 2)
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  slot,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primaryWhite
                                        : context.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    24.heightBox(),
                    // Number of Players Section
                    Text(
                      LocaleKeys.number_of_players.tr(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    8.heightBox(),
                    DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<int>(
                        value: _selectedPlayers,
                        isExpanded: true,
                        hint: Text(
                          LocaleKeys.select_number_of_players.tr(),
                          style: TextStyle(color: AppColors.lightTextColor, fontSize: 14),
                        ),
                        decoration: InputDecoration(
                          hintText: LocaleKeys.select_playing_position.tr(),
                        ),
                        items: _playerCounts.map((int count) {
                          // Display as "X vs X" format (e.g., "10 vs 10" for 20 total players)
                          final playersPerTeam = count ~/ 2;
                          return DropdownMenuItem<int>(
                            value: count,
                            child: Text('$playersPerTeam ${LocaleKeys.vs.tr()} $playersPerTeam'),
                          );
                        }).toList(),
                        onChanged: (int? value) {
                          setState(() {
                            _selectedPlayers = value;
                          });
                        },
                      ),
                    ),
                    if (_supportsPaymentTiming) ...[
                      24.heightBox(),
                      Text(
                        LocaleKeys.payment_method.tr(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      8.heightBox(),
                      Row(
                        children: [
                          Expanded(
                            child: _PaymentTimingOption(
                              icon: Icons.bolt,
                              label: LocaleKeys.pay_immediately.tr(),
                              isSelected: _paymentTiming == GamePaymentTiming.immediate,
                              onTap: () =>
                                  setState(() => _paymentTiming = GamePaymentTiming.immediate),
                            ),
                          ),
                          8.widthBox(),
                          Expanded(
                            child: _PaymentTimingOption(
                              icon: Icons.groups,
                              label: LocaleKeys.pay_after_players_complete.tr(),
                              isSelected:
                                  _paymentTiming == GamePaymentTiming.afterPlayersComplete,
                              onTap: () => setState(
                                () => _paymentTiming = GamePaymentTiming.afterPlayersComplete,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_paymentTiming != null) ...[
                        8.heightBox(),
                        Text(
                          _paymentTiming == GamePaymentTiming.immediate
                              ? LocaleKeys.pay_immediately_description.tr()
                              : LocaleKeys.pay_after_players_complete_description.tr(),
                          style: const TextStyle(color: AppColors.lightTextColor, fontSize: 12),
                        ),
                      ],
                    ],
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
                    onPressed: state is GamesLoading || _isSubmitting ? null : _createGame,
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
                            LocaleKeys.create_game.tr(),
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
          },
        );
      },
    );
  }

  String _getGameTypeText() {
    switch (widget.gameType) {
      case GameType.myDiwaniyaOnly:
        return LocaleKeys.my_diwaniya_only.tr();
      case GameType.privateGame:
        return LocaleKeys.private_game.tr();
      case GameType.publicGame:
        return LocaleKeys.public_game.tr();
    }
  }
}

class _GameCreatedSuccessDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: context.cardBackground,
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
              LocaleKeys.game_created_successfully.tr(),
              style: TextStyle(
                color: context.textSecondary,
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
                  Navigator.of(context).pop(true);
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

class _PaymentTimingOption extends StatelessWidget {
  const _PaymentTimingOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primaryWhite : context.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : context.mutedBackground,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: AppColors.primaryColor, width: 2) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            6.widthBox(),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
