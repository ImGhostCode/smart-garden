import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/extensions/build_context_extentions.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';
import '../../domain/entities/water_schedule_entity.dart';
import '../../domain/usecases/get_all_water_schedules.dart';
import '../providers/water_schedule_provider.dart';
import '../providers/water_schedule_ui_providers.dart';

enum WaterScheduleAction { edit, delete }

class WaterScheduleScreen extends ConsumerStatefulWidget {
  const WaterScheduleScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _WaterScheduleScreenState();
}

class _WaterScheduleScreenState extends ConsumerState<WaterScheduleScreen> {
  late final TextEditingController _searchController;
  @override
  void initState() {
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(waterScheduleProvider).waterSchedules.isEmpty) {
        ref
            .read(waterScheduleProvider.notifier)
            .getAllWaterSchedule(
              GetAllWSParams(
                excludeWeatherData: ref.read(excludeWeatherProvider),
              ),
            );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    EasyLoading.dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waterScheduleState = ref.watch(waterScheduleProvider);

    ref.listen(waterScheduleProvider.select((state) => state.waterSchedules), (
      previous,
      next,
    ) {
      if (previous?.length != next.length) {
        ref.read(wsFilterProvider.notifier).state = '';
      }
    });

    ref.listen(waterScheduleProvider.select((state) => state.isDeletingWS), (
      previousLoading,
      nextLoading,
    ) {
      if (nextLoading == true) {
        EasyLoading.show(status: 'Loading...');
      } else if (nextLoading == false && previousLoading == true) {
        EasyLoading.dismiss();
      }
    });

    ref.listen(waterScheduleProvider, (previous, next) async {
      if (previous?.isDeletingWS == true && next.isDeletingWS == false) {
        if (next.errDeletingWS.isNotEmpty) {
          AppUtils.showError(next.errDeletingWS);
        } else {
          AppUtils.showSuccess(next.responseMsg ?? 'Water schedule deleted');
          // refresh list
          ref
              .read(waterScheduleProvider.notifier)
              .getAllWaterSchedule(
                GetAllWSParams(
                  excludeWeatherData: ref.read(excludeWeatherProvider),
                ),
              );
        }
      }
    });

    return RefreshIndicator(
      onRefresh: () async {
        ref
            .read(waterScheduleProvider.notifier)
            .getAllWaterSchedule(
              GetAllWSParams(
                excludeWeatherData: ref.read(excludeWeatherProvider),
              ),
            );
      },
      child: SafeArea(
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                scrolledUnderElevation: 0,
                floating: true,
                pinned: false,
                centerTitle: false,
                title: const Text('Water Schedule'),
                titleTextStyle: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                // backgroundColor: Colors.white,
                leadingWidth: 120,
                actions: [
                  IconButton.filled(
                    onPressed: () {
                      context.goNotificationClients();
                    },
                    icon: const Icon(Icons.notification_add_rounded),
                    color: AppColors.primary,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary100,
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_rounded),
                    color: AppColors.primary,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary100,
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () {
                      context.goSettings();
                    },
                    icon: const Icon(Icons.settings_rounded),
                    color: AppColors.primary,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary100,
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingSm),
                ],
              ),

              SliverAppBar(
                pinned: true,
                primary: false,
                toolbarHeight: 70,
                automaticallyImplyLeading: false,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMd,
                  ),
                  child: Builder(
                    builder: (context) {
                      final searchQuery = ref.watch(wsFilterProvider);
                      _searchController.text = searchQuery;
                      return SearchBar(
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
                        controller: _searchController,
                        onChanged: (value) {
                          ref.read(wsFilterProvider.notifier).state = value;
                        },
                        leading: const Icon(
                          Icons.search_rounded,
                          color: Colors.grey,
                        ),
                        hintText: 'Search schedules',
                        trailing: [
                          if (searchQuery.isNotEmpty)
                            IconButton(
                              onPressed: () {
                                ref.read(wsFilterProvider.notifier).state = '';
                                _searchController.clear();
                              },
                              icon: const Icon(
                                Icons.clear_rounded,
                                size: AppConstants.iconMd,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // Fliter options
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMd,
                    ),
                    scrollDirection: Axis.horizontal,
                    children: [
                      FilterChip(
                        backgroundColor: Colors.white,
                        label: const Text('Weather Data'),
                        selected: !ref.read(excludeWeatherProvider),
                        onSelected: (selected) {
                          ref.read(excludeWeatherProvider.notifier).state =
                              !selected;
                          ref
                              .read(waterScheduleProvider.notifier)
                              .getAllWaterSchedule(
                                GetAllWSParams(excludeWeatherData: !selected),
                              );
                        },
                      ),
                      // Thêm các filter chip khác nếu cần
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(AppConstants.paddingMd),
                sliver: _buildSliverContent(waterScheduleState),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 150)),
            ],
          ),
        ),
      ),
    );
  }

  // Tách hàm để quản lý logic Sliver dễ hơn
  Widget _buildSliverContent(WaterScheduleState waterScheduleState) {
    if (waterScheduleState.isLoadingWSs) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (waterScheduleState.errLoadingWSs.isNotEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text(waterScheduleState.errLoadingWSs)),
      );
    }

    final filteredWSs = ref.watch(filteredWSProvider);
    final searchQuery = ref.watch(wsFilterProvider);

    if (filteredWSs.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            searchQuery.isEmpty
                ? 'No schedules found'
                : 'No schedules match "$searchQuery"',
          ),
        ),
      );
    }

    // Dùng SliverList thay cho ListView để tối ưu hiệu năng (không cần shrinkWrap)
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final ws = filteredWSs[index];
        return WaterScheduleItem(
          ws: ws,
          onDelete: () {
            ref
                .read(waterScheduleProvider.notifier)
                .deleteWaterSchedule(ws.id!);
          },
        );
      }, childCount: filteredWSs.length),
    );
  }
}

class WaterScheduleItem extends StatelessWidget {
  final WaterScheduleEntity ws;
  final VoidCallback? onDelete;
  final Widget? trailing;
  const WaterScheduleItem({
    super.key,
    required this.ws,
    this.onDelete,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final duration = AppUtils.msToDurationString(ws.durationMs);
    final startTime = AppUtils.to12HourFormat(ws.startTime);

    final nextWaterTime = AppUtils.utcToLocalString(ws.nextWater?.time);
    final nextWaterDuration = ws.nextWater?.durationMs != null
        ? AppUtils.msToDurationString(ws.nextWater!.durationMs!)
        : 'N/A';

    final temp = ws.weatherData?.temperature?.celsius != null
        ? ws.weatherData!.temperature!.celsius!.toStringAsFixed(1)
        : 'N/A';
    final tempScale = ws.weatherData?.temperature?.scaleFactor != null
        ? ws.weatherData!.temperature!.scaleFactor!.toStringAsFixed(1)
        : 'N/A';
    final tempInfo = '$temp°C (Scale: $tempScale)';

    final rain = ws.weatherData?.rain?.mm != null
        ? ws.weatherData!.rain!.mm!.toStringAsFixed(1)
        : 'N/A';
    final rainScale = ws.weatherData?.rain?.scaleFactor != null
        ? ws.weatherData!.rain!.scaleFactor!.toStringAsFixed(1)
        : 'N/A';
    final rainInfo = '$rain mm (Scale: $rainScale)';

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMd),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              ws.name ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            titleTextStyle: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            contentPadding: const EdgeInsets.only(left: AppConstants.paddingMd),
            trailing:
                trailing ??
                PopupMenuButton<WaterScheduleAction>(
                  onSelected: (WaterScheduleAction item) {
                    switch (item) {
                      case WaterScheduleAction.edit:
                        context.goEditWaterSchedule(ws.id!, ws);
                        break;
                      case WaterScheduleAction.delete:
                        context.showConfirmDialog(
                          title: 'Delete Water Schedule',
                          content:
                              'Are you sure you want to delete the water schedule "${ws.name}"?',
                          confirmText: 'Delete',
                          confirmColor: AppColors.error,
                          onConfirm: onDelete,
                        );
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<WaterScheduleAction>>[
                        const PopupMenuItem<WaterScheduleAction>(
                          value: WaterScheduleAction.edit,
                          child: ListTile(
                            leading: Icon(Icons.edit_square),
                            title: Text('Edit'),
                            iconColor: Colors.blue,
                          ),
                        ),
                        const PopupMenuItem<WaterScheduleAction>(
                          value: WaterScheduleAction.delete,
                          child: ListTile(
                            leading: Icon(Icons.delete),
                            title: Text('Delete'),
                            iconColor: Colors.red,
                            textColor: Colors.red,
                          ),
                        ),
                      ],
                  icon: const Icon(Icons.more_vert_rounded),
                ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMd,
            ),
            child: Text(
              ws.description ?? '',
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (ws.nextWater != null) const SizedBox(height: 8),
          if (ws.nextWater != null)
            Row(
              children: [
                const SizedBox(width: AppConstants.paddingMd),
                const Icon(Icons.waves, color: Colors.blue),
                const SizedBox(width: 5),
                Text('$nextWaterTime - $nextWaterDuration'),
              ],
            ),
          if (ws.weatherData != null) const SizedBox(height: 8),
          if (ws.weatherData != null)
            Row(
              children: [
                const SizedBox(width: AppConstants.paddingMd),
                const Icon(Icons.thermostat, color: Colors.orange),
                const SizedBox(width: 5),
                Text(tempInfo),
              ],
            ),
          if (ws.weatherData != null) const SizedBox(height: 8),
          if (ws.weatherData != null)
            Row(
              children: [
                const SizedBox(width: AppConstants.paddingMd),
                const Icon(Icons.water_drop, color: Colors.blue),
                const SizedBox(width: 5),
                Text(rainInfo),
              ],
            ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMd,
            ),
            height: 50,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                ScheduleConfig(icon: Icons.timer_outlined, value: duration),
                const SizedBox(width: 5),
                ScheduleConfig(icon: Icons.access_time, value: startTime),
                const SizedBox(width: 5),
                ScheduleConfig(
                  icon: Icons.cached,
                  value: '${ws.interval} days',
                ),
                const SizedBox(width: 5),
                if (ws.activePeriod != null)
                  ScheduleConfig(
                    enabled: AppUtils.isInActivePeriod(
                      ws.activePeriod!.startMonth,
                      ws.activePeriod!.endMonth,
                    ),
                    icon: Icons.calendar_month_rounded,
                    value:
                        '${ws.activePeriod?.startMonth} - ${ws.activePeriod?.endMonth}',
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingSm),
        ],
      ),
    );
  }
}

class ScheduleConfig extends StatelessWidget {
  const ScheduleConfig({
    super.key,
    this.value,
    required this.icon,
    this.enabled = true,
  });
  final bool enabled;
  final String? value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      elevation: 0,
      padding: const EdgeInsets.all(AppConstants.paddingSm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      backgroundColor: enabled ? AppColors.primary : Colors.grey.shade400,
      labelPadding: EdgeInsets.zero,
      labelStyle: Theme.of(
        context,
      ).textTheme.bodyMedium!.copyWith(color: Colors.white),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            value ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
