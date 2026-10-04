import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/application/core/utils/id_encryption.dart';
import 'package:futblha/application/core/utils/helpers/debouncer.dart';
import 'package:futblha/data/models/response_model/diwaniya/diwaniya_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/widgets/diwaniya_filter_bottom_sheet.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:futblha/presentation/pages/diwaniyat/bloc/diwaniya_bloc.dart';
import 'package:futblha/presentation/pages/diwaniyat/widgets/segmented_button.dart'
    show DiwaniyaSegmentedButton;
import 'package:futblha/presentation/pages/diwaniyat/widgets/team_profile_card.dart';
import 'package:futblha/presentation/pages/diwaniyat/widgets/upcoming_games_section.dart';
import 'package:futblha/presentation/pages/diwaniyat/widgets/other_diwaniyat_content.dart';
import 'package:futblha/presentation/pages/games/bloc/games_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../application/core/utils/helpers/cache/cache_manager.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_loading_widget.dart';

@RoutePage()
class DiwaniyatPage extends StatefulWidget {
  const DiwaniyatPage({super.key});

  @override
  State<DiwaniyatPage> createState() => _DiwaniyatPageState();
}

class _DiwaniyatPageState extends State<DiwaniyatPage> {
  final bloc = locator<DiwaniyaBloc>();
  final gamesBloc = locator<GamesBloc>();
  int _selectedTab = 0; // 0 = My Diwaniya, 1 = Other Diwaniya
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _searchDebouncer = Debouncer(milliseconds: 500);
  String _searchQuery = '';
  DiwaniyaFilterResult? _activeFilters;
  int _currentPage = 1;
  static const int _perPage = 20;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchControllerChanged);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchControllerChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchControllerChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _loadData({String? searchQuery, bool loadMore = false}) {
    if (loadMore) {
      _currentPage++;
    } else {
      _currentPage = 1;
    }

    if (_selectedTab == 0) {
      bloc.add(GetDiwaniyasOverviewEvent());
    } else {
      // Always use GetDiwaniyasOverviewEvent for pagination support
      // It supports name, type, membersCount, rating, page, and per_page parameters
      final hasSearch = searchQuery != null && searchQuery.isNotEmpty;
      bloc.add(
        GetDiwaniyasOverviewEvent(
          name: hasSearch ? searchQuery : null,
          type: _activeFilters?.getApiType(),
          membersCount: _activeFilters?.membersCount,
          rating: _activeFilters?.getApiRating(),
          page: _currentPage,
          perPage: _perPage,
          loadMore: loadMore,
        ),
      );
    }
  }

  void _loadMoreData() {
    if (_selectedTab == 1 && _hasMorePages()) {
      _loadData(searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null, loadMore: true);
    }
  }

  bool _hasMorePages() {
    final paginate = bloc.otherDiwaniyas?.paginate;
    if (paginate == null) return false;
    // Check if there's a next page URL or if current page is less than total pages
    return paginate.nextPageUrl != null && paginate.nextPageUrl!.isNotEmpty ||
        (paginate.currentPage != null &&
            paginate.totalPages != null &&
            paginate.currentPage! < paginate.totalPages!);
  }

  void _onSearchChanged(String query) {
    if (_selectedTab == 1) {
      _searchDebouncer.run(() {
        _currentPage = 1; // Reset to first page on new search
        _loadData(searchQuery: query);
      });
    }
  }

  void _onTabChanged(int tab) {
    setState(() {
      _selectedTab = tab;
      // Clear search and filters when switching tabs
      if (tab == 0) {
        _searchController.clear();
        _activeFilters = null;
        _currentPage = 1;
      }
    });
    _loadData();
  }

  Future<void> _showFilterBottomSheet() async {
    final result = await DiwaniyaFilterBottomSheet.show(context, initialFilters: _activeFilters);
    if (result != null) {
      setState(() {
        _activeFilters = result.hasFilters ? result : null;
        _currentPage = 1; // Reset to first page when filters change
      });
      _loadData(searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null);
    }
  }

  void _shareDiwaniya() {
    if (bloc.myDiwaniya == null) return;

    final diwaniya = bloc.myDiwaniya!;
    final diwaniyaName = diwaniya.name ?? LocaleKeys.diwaniya_default.tr();
    final diwaniyaId = diwaniya.id;
    final rank = diwaniya.rank != null ? '#${diwaniya.rank}' : '';

    if (diwaniyaId == null) return;

    // Encrypt the diwaniya ID before sharing
    final encryptedId = IdEncryption.encrypt(diwaniyaId);

    // Create share message with diwaniya details
    final shareText =
        'Check out this Diwaniya: $diwaniyaName $rank\n\n'
        'Open in Futblha app:\n'
        'https://futblha.com/diwaniya/$encryptedId';

    SharePlus.instance.share(ShareParams(subject: 'Diwaniya', text: shareText));
  }

  Future<void> _onDiwaniyaTap(DiwaniyaModel diwaniya) async {
    if (diwaniya.id != null) {
      final result = await context.router.push(
        DiwaniyaDetailsRoute(
          diwaniyaId: diwaniya.id.toString(),
          diwaniyaName: diwaniya.name ?? '',
          diwaniyaRank: diwaniya.rank != null ? '#${diwaniya.rank}' : '',
          isMember: diwaniya.userPermission?.isMember ?? false,
          levelReview: double.parse(diwaniya.level_rating ?? '0').round(),
          clearGame: double.parse(diwaniya.clean_game_rating ?? '0').round(),
        ),
      );
      if (result == true) {
        bloc.add(GetDiwaniyasOverviewEvent());
        _onTabChanged(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<DiwaniyaBloc, DiwaniyaState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is DiwaniyaError) {
          context.showMessage(isError: true, state.message);
        } else if (state is DiwaniyaSuccess) {
          _selectedTab = bloc.myDiwaniya == null ? 1 : _selectedTab;
        } else if (state is LeaveDiwaniyaSuccess) {
          context.showMessage(state.message);
          setState(() => _selectedTab = 1);
        } else if (state is DeleteDiwaniyaSuccess) {
          context.showMessage(state.message);
          setState(() => _selectedTab = 1);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(LocaleKeys.diwaniyat.tr()),
            actions: [
              if (!CacheManager.instance.isGuestMode())
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      IconButton(
                        onPressed: () {
                          context.router.push(NotificationsRoute());
                        },
                        icon: const Icon(Icons.notifications_none, color: AppColors.primaryColor),
                      ),
                      // Positioned(
                      //   right: 8,
                      //   top: 8,
                      //   child: Container(
                      //     width: 8,
                      //     height: 8,
                      //     decoration: const BoxDecoration(
                      //       color: AppColors.primaryRed,
                      //       shape: BoxShape.circle,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
            ],
          ),
          body: CacheManager.instance.isGuestMode()
              ? Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(LocaleKeys.you_are_a_guest_user.tr()),
                        20.heightBox(),
                        CustomElevatedButton(
                          title: LocaleKeys.sign_in.tr(),
                          onPressed: () {
                            context.router.pushAndPopUntil(
                              const LoginRoute(),
                              predicate: (_) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                )
              : _selectedTab == 0
              ? RefreshIndicator(
                  onRefresh: () async {
                    _loadData();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Segmented Buttons
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                          child: Row(
                            children: [
                              if (bloc.myDiwaniya != null) ...[
                                Expanded(
                                  child: DiwaniyaSegmentedButton(
                                    text: LocaleKeys.my_diwaniya.tr(),
                                    isSelected: _selectedTab == 0,
                                    onTap: () => _onTabChanged(0),
                                  ),
                                ),
                                12.widthBox(),
                              ],
                              Expanded(
                                child: DiwaniyaSegmentedButton(
                                  text: LocaleKeys.other_diwaniya.tr(),
                                  isSelected: _selectedTab == 1,
                                  onTap: () => _onTabChanged(1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        5.heightBox(),
                        // Team Profile Card
                        if (state is! DiwaniyaLoading)
                          TeamProfileCard(bloc: bloc, onShare: _shareDiwaniya),
                        if (state is DiwaniyaLoading)
                          const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: LoadingWidget(),
                          ),
                        10.heightBox(),
                        // Upcoming Games Section
                        if (bloc.myDiwaniya?.memberStatus != 'pending')
                          UpcomingGamesSection(
                            upcomingGames: bloc.myDiwaniya?.upcomingGames ?? [],
                            gamesBloc: gamesBloc,
                            onGameTap: (game) {
                              if (game.id != null) {
                                gamesBloc.gameDetails = game;
                                context.router.push(GameDetailsRoute(bloc: gamesBloc)).then((
                                  value,
                                ) {
                                  if (value == true) {
                                    bloc.add(GetDiwaniyasOverviewEvent());
                                  }
                                });
                              }
                            },
                          ),
                        20.heightBox(),
                        // Create Game Button
                        if (bloc.myDiwaniya?.memberStatus != 'pending')
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final result = await context.router.push(
                                  const GameTypeSelectionRoute(),
                                );
                                if (result == true) {
                                  bloc.add(GetDiwaniyasOverviewEvent());
                                }
                              },
                              icon: const Icon(Icons.add, color: AppColors.primaryWhite),
                              label: Text(
                                LocaleKeys.create_game.tr(),
                                style: const TextStyle(
                                  color: AppColors.primaryWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                minimumSize: Size(double.infinity, 50.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20.w),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(
                              color: Color(0xffAF7D00).withValues(alpha: .4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              LocaleKeys.join_request_pending.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xffAF7D00)),
                            ),
                          ),
                        20.heightBox(),
                      ],
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Segmented Buttons
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      child: Row(
                        children: [
                          if (bloc.myDiwaniya != null) ...[
                            Expanded(
                              child: DiwaniyaSegmentedButton(
                                text: LocaleKeys.my_diwaniya.tr(),
                                isSelected: _selectedTab == 0,
                                onTap: () => _onTabChanged(0),
                              ),
                            ),
                            12.widthBox(),
                          ],
                          Expanded(
                            child: DiwaniyaSegmentedButton(
                              text: LocaleKeys.other_diwaniya.tr(),
                              isSelected: _selectedTab == 1,
                              onTap: () => _onTabChanged(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Other Diwaniyat Content with Pagination
                    if (state is! DiwaniyaLoading)
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            _currentPage = 1;
                            _loadData(searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null);
                          },
                          child: OtherDiwaniyatContent(
                            diwaniyas: bloc.otherDiwaniyas?.items,
                            searchController: _searchController,
                            searchQuery: _searchQuery,
                            hasActiveFilters: _activeFilters?.hasFilters == true,
                            hasMorePages: _hasMorePages(),
                            onSearchChanged: () => _onSearchChanged(_searchQuery),
                            onFilterPressed: _showFilterBottomSheet,
                            onClearSearch: () {
                              _searchController.clear();
                              _loadData();
                            },
                            onLoadMore: _loadMoreData,
                            onDiwaniyaTap: _onDiwaniyaTap,
                          ),
                        ),
                      ),
                    if (state is DiwaniyaLoading)
                      const Expanded(child: LoadingWidget()),
                    // Create Diwaniya Button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.router.push(const CreateDiwaniyaRoute());
                        },
                        icon: const Icon(Icons.add, color: AppColors.primaryWhite),
                        label: Text(
                          LocaleKeys.create_diwaniya.tr(),
                          style: const TextStyle(
                            color: AppColors.primaryWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          minimumSize: Size(double.infinity, 50.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
