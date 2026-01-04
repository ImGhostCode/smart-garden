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

enum WaterScheduleAction { edit, delete }

class WaterScheduleScreen extends ConsumerStatefulWidget {
  const WaterScheduleScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _WaterScheduleScreenState();
}

class _WaterScheduleScreenState extends ConsumerState<WaterScheduleScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(waterScheduleProvider).waterSchedules.isEmpty) {
        ref
            .read(waterScheduleProvider.notifier)
            .getAllWaterSchedule(GetAllWSParams());
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final waterScheduleState = ref.watch(waterScheduleProvider);

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
          EasyLoading.showError(next.errDeletingWS);
        } else {
          EasyLoading.showSuccess(next.responseMsg ?? 'Water schedule deleted');
          // refresh list
        }
      }
    });

    return SafeArea(
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
                child: SearchBar(
                  leading: const Icon(Icons.search_rounded, color: Colors.grey),
                  hintText: 'Search',
                  trailing: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.clear_rounded,
                        size: AppConstants.iconMd,
                      ),
                    ),
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

    // Dùng SliverList thay cho ListView để tối ưu hiệu năng (không cần shrinkWrap)
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final ws = waterScheduleState.waterSchedules[index];
        return WaterScheduleItem(
          ws: ws,
          onDelete: () {
            ref
                .read(waterScheduleProvider.notifier)
                .deleteWaterSchedule(ws.id!);
          },
        );
      }, childCount: waterScheduleState.waterSchedules.length),
    );
  }
}

class WaterScheduleItem extends StatelessWidget {
  final WaterScheduleEntity ws;
  final VoidCallback? onDelete;
  const WaterScheduleItem({super.key, required this.ws, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final duration = AppUtils.msToDurationString(ws.durationMs);
    final startTime = AppUtils.to12HourFormat(ws.startTime);
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
            trailing: PopupMenuButton<WaterScheduleAction>(
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
  const ScheduleConfig({super.key, this.value, required this.icon});
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
      backgroundColor: AppColors.primary,
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
