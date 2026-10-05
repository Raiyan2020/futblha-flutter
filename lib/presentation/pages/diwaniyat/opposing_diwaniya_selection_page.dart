import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/app_assets.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/debouncer.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/widgets/pagination_list.dart';
import 'package:futblha/data/models/response_model/playgrounds/playground_model.dart';
import 'package:futblha/presentation/widgets/diwaniya_filter_bottom_sheet.dart';
import 'package:futblha/presentation/pages/diwaniyat/bloc/diwaniya_bloc.dart';
import 'package:futblha/data/models/response_model/diwaniya/diwaniya_model.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:futblha/generated/locale_keys.g.dart';

@RoutePage()
class OpposingDiwaniyaSelectionPage extends StatefulWidget {
  final PlaygroundModel playground;
  final DateTime date;
  final String timeSlot;

  const OpposingDiwaniyaSelectionPage({
    super.key,
    required this.playground,
    required this.date,
    required this.timeSlot,
  });

  @override
  State<OpposingDiwaniyaSelectionPage> createState() => _OpposingDiwaniyaSelectionPageState();
}

class _OpposingDiwaniyaSelectionPageState extends State<OpposingDiwaniyaSelectionPage> {
  final bloc = locator<DiwaniyaBloc>();
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _searchDebouncer = Debouncer(milliseconds: 500);

  static const int _perPage = 20;
  int _currentPage = 1;
  int? _selectedDiwaniyaId;
  String _searchQuery = '';

  List<DiwaniyaModel> _getFilteredDiwaniyas() {
    final items = bloc.otherDiwaniyas?.items ?? [];
    if (_searchQuery.trim().isEmpty) return items;
    final query = _searchQuery.toLowerCase();
    return items.where((d) => d.name?.toLowerCase().contains(query) ?? false).toList();
  }

  bool _hasMorePages() {
    final paginate = bloc.otherDiwaniyas?.paginate;
    if (paginate == null) return false;
    return paginate.nextPageUrl != null && paginate.nextPageUrl!.isNotEmpty ||
        (paginate.currentPage != null &&
            paginate.totalPages != null &&
            paginate.currentPage! < paginate.totalPages!);
  }

  @override
  void initState() {
    super.initState();
    _loadDiwaniyas();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
      _searchDebouncer.run(() {
        _currentPage = 1;
        _loadDiwaniyas();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadDiwaniyas() {
    _currentPage = 1;
    final name = _searchQuery.trim().isEmpty ? null : _searchQuery.trim();
    bloc.add(
      GetDiwaniyasOverviewEvent(
        page: 1,
        perPage: _perPage,
        loadMore: false,
        name: name,
      ),
    );
  }

  void _loadMoreDiwaniyas() {
    if (!_hasMorePages()) return;
    _currentPage++;
    final name = _searchQuery.trim().isEmpty ? null : _searchQuery.trim();
    bloc.add(
      GetDiwaniyasOverviewEvent(
        page: _currentPage,
        perPage: _perPage,
        loadMore: true,
        name: name,
      ),
    );
  }

  void _sendInvitation() {
    if (_selectedDiwaniyaId == null) {
      context.showMessage(isError: true, LocaleKeys.please_select_opposing_diwaniya.tr());
      return;
    }

    // Return the selected diwaniya ID to CreateGamePage
    // The game creation (which includes invitation) will happen in CreateGamePage
    context.router.pop(_selectedDiwaniyaId);
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<DiwaniyaBloc, DiwaniyaState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is DiwaniyaError) {
          context.showMessage(isError: true, state.message);
        }
      },
      builder: (context, state) {
        final diwaniyas = _getFilteredDiwaniyas();

        return Scaffold(
          backgroundColor: context.scaffoldBackground,
          appBar: AppBar(
            backgroundColor: context.scaffoldBackground,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              onPressed: () => context.router.maybePop(),
              icon: Icon(Icons.arrow_back_ios_new, color: context.textPrimary),
            ),
            title: Text(
              LocaleKeys.select_opposing_diwaniya.tr(),
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.select_opposing_diwaniya.tr(),
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    12.heightBox(),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48.h,
                            decoration: BoxDecoration(
                              color: context.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.borderColor, width: 1),
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: LocaleKeys.search.tr(),
                                hintStyle: TextStyle(color: AppColors.lightTextColor, fontSize: 14),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: AppColors.lightTextColor,
                                  size: 20,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                              ),
                            ),
                          ),
                        ),
                        12.widthBox(),
                        Container(
                          width: 48.w,
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: context.chipBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () {
                              DiwaniyaFilterBottomSheet.show(context);
                            },
                            icon: Icon(Icons.filter_list, color: context.brandOnSurface, size: 24),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state is DiwaniyaLoading && diwaniyas.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : diwaniyas.isEmpty
                    ? Center(
                        child: Text(
                          LocaleKeys.no_diwaniyas_found.tr(),
                          style: TextStyle(color: AppColors.lightTextColor, fontSize: 16),
                        ),
                      )
                    : PaginationList(
                        itemCount: diwaniyas.length,
                        onReachBottom: _loadMoreDiwaniyas,
                        reachedMax: !_hasMorePages(),
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        separator: 12.heightBox(),
                        itemBuilder: (context, index) => _buildDiwaniyaCard(diwaniyas[index]),
                      ),
              ),
            ],
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
                onPressed: _selectedDiwaniyaId == null ? null : _sendInvitation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: context.mutedBackground,
                ),
                child: Text(
                  LocaleKeys.select.tr(),
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
  }

  Widget _buildDiwaniyaCard(DiwaniyaModel diwaniya) {
    final isSelected = _selectedDiwaniyaId == diwaniya.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDiwaniyaId = diwaniya.id;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? context.chipBackground : context.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: diwaniya.image != null && diwaniya.image!.startsWith('http')
                  ? NetworkImage(diwaniya.image!) as ImageProvider
                  : const AssetImage(AppAssets.ic_profile),
              backgroundColor: context.mutedBackground,
              onBackgroundImageError: (_, _) {},
            ),
            16.widthBox(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    diwaniya.name ?? '',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // if (diwaniya.description != null && diwaniya.description!.isNotEmpty) ...[
                  //   4.heightBox(),
                  //   Text(
                  //     diwaniya.description!,
                  //     style: const TextStyle(
                  //       color: AppColors.lightTextColor,
                  //       fontSize: 12,
                  //       fontWeight: FontWeight.w400,
                  //     ),
                  //     maxLines: 1,
                  //     overflow: TextOverflow.ellipsis,
                  //   ),
                  // ],
                  8.heightBox(),
                  Row(
                    children: [
                      Text(
                        LocaleKeys.level_review.tr(),
                        style: TextStyle(
                          color: AppColors.lightTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      8.widthBox(),
                      _buildStarRating(double.parse(diwaniya.level_rating ?? '0').round()),
                    ],
                  ),
                  4.heightBox(),
                  Row(
                    children: [
                      Text(
                        LocaleKeys.clean_game.tr(),
                        style: TextStyle(
                          color: AppColors.lightTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      8.widthBox(),
                      _buildStarRating(double.parse(diwaniya.clean_game_rating ?? '0').round()),
                    ],
                  ),
                ],
              ),
            ),
            12.widthBox(),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryColor : AppColors.primaryGrey,
                  width: 2,
                ),
                color: isSelected ? AppColors.primaryColor : context.cardBackground,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: AppColors.primaryWhite)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: 14,
          color: index < rating ? AppColors.primaryYellow : AppColors.primaryGrey,
        ),
      ),
    );
  }
}
