import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/pages/playgrounds/bloc/playgrounds_bloc.dart';
import 'package:futblha/presentation/pages/general/bloc/general_bloc.dart';
import 'package:futblha/data/models/request_model/playgrounds/playground_filter_request_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';

class PlaygroundFilterBottomSheet {
  static void show(BuildContext context, PlaygroundsBloc playgroundsBloc, GeneralBloc generalBloc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      builder: (context) => _PlaygroundFilterBottomSheetContent(
        playgroundsBloc: playgroundsBloc,
        generalBloc: generalBloc,
      ),
    );
  }
}

class _PlaygroundFilterBottomSheetContent extends StatefulWidget {
  final PlaygroundsBloc playgroundsBloc;
  final GeneralBloc generalBloc;

  const _PlaygroundFilterBottomSheetContent({
    required this.playgroundsBloc,
    required this.generalBloc,
  });

  @override
  State<_PlaygroundFilterBottomSheetContent> createState() =>
      _PlaygroundFilterBottomSheetContentState();
}

class _PlaygroundFilterBottomSheetContentState extends State<_PlaygroundFilterBottomSheetContent> {
  List<int>? selectedCityIds;
  List<int>? selectedCapacityIds;
  List<int>? selectedFacilityIds;
  List<String>? selectedLandTypes;

  @override
  void initState() {
    super.initState();
    // Load filter options if not already loaded
    if (widget.generalBloc.cities.isEmpty) {
      widget.generalBloc.add(GetCitiesEvent());
    }
    if (widget.playgroundsBloc.capacities.isEmpty) {
      widget.playgroundsBloc.add(GetCapacitiesEvent());
    }
    if (widget.playgroundsBloc.facilities.isEmpty) {
      widget.playgroundsBloc.add(GetFacilitiesEvent());
    }
    if (widget.playgroundsBloc.landTypes.isEmpty) {
      widget.playgroundsBloc.add(GetLandTypesEvent());
    }
  }

  InputDecoration _filterFieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: CustomBlocConsumer<GeneralBloc, GeneralState>(
          bloc: widget.generalBloc,
          listener: (context, state) {},
          builder: (context, generalState) {
            return CustomBlocConsumer<PlaygroundsBloc, PlaygroundsState>(
              bloc: widget.playgroundsBloc,
              listener: (context, state) {},
              builder: (context, playgroundsState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.close, color: Colors.transparent),
                        ),
                        Text(
                          LocaleKeys.filter.tr(),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    20.heightBox(),
                    Text(
                      LocaleKeys.city.tr(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    6.heightBox(),
                    DropdownButtonFormField<int>(
                      decoration: _filterFieldDecoration(LocaleKeys.select_city.tr()),
                      items: widget.generalBloc.cities
                          .map(
                            (city) => DropdownMenuItem<int>(value: city.id, child: Text(city.name)),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCityIds = value != null ? [value] : null;
                        });
                      },
                    ),
                    12.heightBox(),
                    Text(
                      LocaleKeys.playground_capacity.tr(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    6.heightBox(),
                    DropdownButtonFormField<int>(
                      decoration: _filterFieldDecoration(LocaleKeys.select_capacity.tr()),
                      items: widget.playgroundsBloc.capacities
                          .where((capacity) => capacity.id != null)
                          .map(
                            (capacity) => DropdownMenuItem<int>(
                              value: capacity.id!,
                              child: Text(capacity.name ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCapacityIds = value != null ? [value] : null;
                        });
                      },
                    ),
                    12.heightBox(),
                    Text(
                      LocaleKeys.facilities.tr(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    6.heightBox(),
                    DropdownButtonFormField<int>(
                      decoration: _filterFieldDecoration(LocaleKeys.select_facilities.tr()),
                      items: widget.playgroundsBloc.facilities
                          .where((facility) => facility.id != null)
                          .map(
                            (facility) => DropdownMenuItem<int>(
                              value: facility.id!,
                              child: Text(facility.name ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedFacilityIds = value != null ? [value] : null;
                        });
                      },
                    ),
                    12.heightBox(),
                    Text(
                      LocaleKeys.land_type.tr(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    6.heightBox(),
                    DropdownButtonFormField<String>(
                      decoration: _filterFieldDecoration(LocaleKeys.select_land_type.tr()),
                      items: widget.playgroundsBloc.landTypes
                          .where((landType) => landType.key != null)
                          .map(
                            (landType) => DropdownMenuItem<String>(
                              value: landType.key!,
                              child: Text(landType.name ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedLandTypes = value != null ? [value] : null;
                        });
                      },
                    ),
                    20.heightBox(),
                    Row(
                      children: [
                        if (widget.playgroundsBloc.hasActiveFilters())
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                widget.playgroundsBloc.add(const GetPlaygroundsEvent());
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primaryColor),
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                LocaleKeys.clear_all.tr(),
                                style: TextStyle(
                                  color: context.brandOnSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        if (widget.playgroundsBloc.hasActiveFilters()) 12.widthBox(),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              widget.playgroundsBloc.add(
                                GetPlaygroundsEvent(
                                  filters: PlaygroundFilterRequestModel(
                                    cityIds: selectedCityIds,
                                    capacityIds: selectedCapacityIds,
                                    facilityIds: selectedFacilityIds,
                                    landTypes: selectedLandTypes,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              LocaleKeys.show_results.tr(),
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
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
