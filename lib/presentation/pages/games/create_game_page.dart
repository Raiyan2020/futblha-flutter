import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
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

enum GameType { myDiwaniyaOnly, privateGame, publicGame }

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

  int? _findPlaygroundId() {
    // Use playground ID directly from the model
    return _selectedPlayground?.id;
  }

  /// Get available time slots from playground details
  List<String> get _availableTimeSlots {
    final slots = playgroundsBloc.playgroundDetails?.availableSlots ?? [];
    return slots
        .where((slot) => slot.available == true)
        .map((slot) => '${slot.startAt ?? ''} - ${slot.endAt ?? ''}')
        .where((slot) => slot.isNotEmpty && slot != ' - ')
        .toList();
  }

  /// Fetch playground details when playground and date are selected
  void _fetchPlaygroundDetails() {
    final playgroundId = _findPlaygroundId();
    if (playgroundId != null && _selectedDate != null) {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
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
    if (_selectedPlayground == null ||
        _selectedDate == null ||
        _selectedTimeSlot == null ||
        _selectedPlayers == null ||
        _selectedPosition == null) {
      context.showMessage(isError: true, LocaleKeys.please_fill_all_required_fields.tr());
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
      bookingDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      periods: periods,
      type: gameType,
      players: _selectedPlayers!,
      position: _selectedPosition!.key,
      opponentDiwaniyaId: widget.gameType == GameType.privateGame ? _opponentDiwaniyaId : null,
      slotIndex: predictedSlot,
    );

    bloc.add(CreateGameEvent(request: request));
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
          context.showMessage(isError: true, state.message);
        } else if (state is GamesSuccess && bloc.createdGame != null) {
          _showSuccessDialog();
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
                        color: AppColors.secondaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getGameTypeText(),
                        style: const TextStyle(
                          color: AppColors.primaryColor,
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
                          color: AppColors.primaryWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderGrey, width: 1),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedPlayground?.name ?? LocaleKeys.select_playground.tr(),
                                style: TextStyle(
                                  color: _selectedPlayground != null
                                      ? AppColors.primaryBlack
                                      : AppColors.lightTextColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.primaryColor,
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
                          color: AppColors.primaryLiteGrey,
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
                          color: AppColors.primaryLiteGrey,
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
                                    : AppColors.primaryLiteGrey,
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
                                        : AppColors.primaryDark,
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
                  ],
                ),
              ),
              bottomNavigationBar: Container(
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
                    onPressed: state is GamesLoading ? null : _createGame,
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
              LocaleKeys.game_created_successfully.tr(),
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
