import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/build_context_extentions.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';
import '../../../garden/domain/entities/garden_entity.dart';
import '../../../garden/domain/usecases/get_all_gardens.dart';
import '../../../garden/domain/usecases/send_garden_action.dart';
import '../../../garden/presentation/providers/garden_provider.dart';
import '../../../water_routine/domain/usecases/get_all_water_routines.dart';
import '../../../water_routine/presentation/providers/water_routine_provider.dart';
import '../../../zone/presentation/providers/zone_provider.dart';

enum GardenAction { edit, delete }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    EasyLoading.dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gardenState = ref.watch(gardenProvider);
    ref.listen(gardenProvider.select((state) => state.isSendingAction), (
      previousLoading,
      nextLoading,
    ) {
      if (nextLoading == true) {
        EasyLoading.show(status: 'Loading...');
      } else if (nextLoading == false && previousLoading == true) {
        EasyLoading.dismiss();
      }
    });

    ref.listen(gardenProvider, (previous, next) async {
      if (previous?.isSendingAction == true && next.isSendingAction == false) {
        if (next.errSendingAction.isNotEmpty) {
          EasyLoading.showError(next.errSendingAction);
        } else {
          EasyLoading.showSuccess(next.responseMsg ?? 'Garden action sent');
          context.goBack();
        }
      }
    });

    ref.listen(gardenProvider.select((state) => state.isDeletingGarden), (
      previousLoading,
      nextLoading,
    ) {
      if (nextLoading == true) {
        EasyLoading.show(status: 'Loading...');
      } else if (nextLoading == false && previousLoading == true) {
        EasyLoading.dismiss();
      }
    });

    ref.listen(gardenProvider, (previous, next) async {
      if (previous?.isDeletingGarden == true &&
          next.isDeletingGarden == false) {
        if (next.errDeletingGarden.isNotEmpty) {
          EasyLoading.showError(next.errDeletingGarden);
        } else {
          EasyLoading.showSuccess(next.responseMsg ?? 'Garden deleted');
          // refresh garden list
          ref.read(gardenProvider.notifier).getAllGarden(GetAllGardenParams());
          // refresh water routine list
          ref
              .read(waterRoutineProvider.notifier)
              .getAllWaterRoutine(GetAllWRParams());
        }
      }
    });

    ref.listen(zoneProvider.select((state) => state.isSendingAction), (
      previousLoading,
      nextLoading,
    ) {
      if (nextLoading == true) {
        EasyLoading.show(status: 'Loading...');
      } else if (nextLoading == false && previousLoading == true) {
        EasyLoading.dismiss();
      }
    });

    ref.listen(zoneProvider, (previous, next) async {
      if (previous?.isSendingAction == true && next.isSendingAction == false) {
        if (next.errSendingAction.isNotEmpty) {
          EasyLoading.showError(next.errSendingAction);
        } else {
          EasyLoading.showSuccess(next.responseMsg ?? 'Zone action sent');
          // context.goBack();
        }
      }
    });

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(gardenProvider.notifier).getAllGarden(GetAllGardenParams());
      },
      child: SafeArea(
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                scrolledUnderElevation: 0,
                floating: true,
                pinned: false,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                leadingWidth: 120,
                leading: Padding(
                  padding: const EdgeInsets.only(left: AppConstants.paddingSm),
                  child: Image.asset(Assets.logo),
                ),
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
                    onPressed: () => context.goSettings(),
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
                    leading: const Icon(
                      Icons.search_rounded,
                      color: Colors.grey,
                    ),
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
                sliver: _buildSliverContent(gardenState),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 150)),
            ],
          ),
        ),
      ),
    );
  }

  // Tách hàm để quản lý logic Sliver dễ hơn
  Widget _buildSliverContent(GardenState gardenState) {
    if (gardenState.isLoadingGardens) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (gardenState.errLoadingGardens.isNotEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text(gardenState.errLoadingGardens)),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final garden = gardenState.gardens[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppConstants.paddingMd),
          child: InkWell(
            onTap: () => context.goGardenDetail(garden.id!),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.neutral50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context, garden),
                  _buildGridContent(context, garden),
                  _buildFooter(context, garden),
                ],
              ),
            ),
          ),
        );
      }, childCount: gardenState.gardens.length),
    );
  }

  // Tiêu đề: Front yard
  Widget _buildHeader(BuildContext context, GardenEntity garden) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const SizedBox(width: 48),
      title: Center(
        child: Text(
          garden.name ?? "",
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: PopupMenuButton<GardenAction>(
        onSelected: (GardenAction item) {
          switch (item) {
            case GardenAction.edit:
              context.goEditGarden(garden.id!);
              break;
            case GardenAction.delete:
              context.showConfirmDialog(
                title: 'Delete Garden',
                content:
                    'Are you sure you want to delete the garden "${garden.name}"?',
                confirmText: 'Delete',
                confirmColor: AppColors.error,
                onConfirm: () {
                  ref.read(gardenProvider.notifier).deleteGarden(garden.id!);
                },
              );
              break;
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<GardenAction>>[
          const PopupMenuItem<GardenAction>(
            value: GardenAction.edit,
            child: ListTile(
              leading: Icon(Icons.edit_square),
              title: Text('Edit'),
              iconColor: Colors.blue,
            ),
          ),
          const PopupMenuItem<GardenAction>(
            value: GardenAction.delete,
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
    );
  }

  // Nội dung chính: Các thẻ thông số
  Widget _buildGridContent(BuildContext context, GardenEntity garden) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMd),
      child: Column(
        children: [
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Temperature',
                  '${garden.tempHumData?.temperatureCelsius?.toStringAsFixed(1) ?? '- '}°C',
                  Icons.thermostat,
                  Colors.teal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Humidity',
                  '${garden.tempHumData?.humidityPercentage?.toStringAsFixed(1) ?? '- '}%',
                  Icons.air,
                  Colors.teal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Connectivity',
                  garden.health?.status == 'UP' ? 'Online' : 'Offline',
                  Icons.wifi,
                  Colors.teal,
                  isOnline: garden.health?.status == 'UP',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildStatusCard(context, garden)),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Next Light Action',
                  garden.nextLightAction?.action ?? '',
                  Icons.lightbulb_outline,
                  Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  // Widget cho các thẻ nhỏ (Humidity, Temperature, Connectivity, Light)
  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isOnline = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withOpacity(0.6), size: 30),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey[800],
                ),
              ),
              if (isOnline) ...[
                const SizedBox(width: 4),
                const Icon(Icons.circle, color: Colors.green, size: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Widget cho thẻ Status (6 plants growing, 2 Zones)
  Widget _buildStatusCard(BuildContext context, GardenEntity garden) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          _buildStatusItem(
            context,
            Icons.local_florist_outlined,
            '${garden.numPlants} Plants',
          ),
          const SizedBox(height: 8),
          _buildStatusItem(
            context,
            Icons.explore_outlined,
            '${garden.numZones} Zones',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal[300], size: 24),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green[900],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
    // return RichText(
    //   overflow: TextOverflow.ellipsis,
    //   text: TextSpan(
    //     children: [
    //       WidgetSpan(
    //         alignment: PlaceholderAlignment.middle,
    //         child: Icon(icon, color: Colors.teal[300], size: 24),
    //       ),
    //       const WidgetSpan(child: SizedBox(width: 6)),
    //       TextSpan(
    //         text: text,
    //         style: Theme.of(context).textTheme.bodyMedium!.copyWith(
    //           fontWeight: FontWeight.bold,
    //           color: Colors.green[900],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  // Phần chân trang với nút Actions
  Widget _buildFooter(BuildContext context, GardenEntity garden) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Tooltip(
            triggerMode: TooltipTriggerMode.tap,
            message: 'Topic prefix: ${garden.topicPrefix ?? ''}',
            child: const Icon(Icons.info_rounded, color: Colors.blue),
          ),
          SizedBox(
            height: AppConstants.buttonSm,
            child: ElevatedButton(
              onPressed: () {
                showGardenActions(
                  context: context,
                  garden: garden,
                  onToggleLight: (isOn) {
                    ref
                        .read(gardenProvider.notifier)
                        .sendGardenAction(
                          GardenActionParams(
                            gardenId: garden.id,
                            light: LightAction(
                              state: isOn ? 'ON' : 'OFF',
                              forDuration: null,
                            ),
                          ),
                        );
                  },
                  onStopAll: () {
                    ref
                        .read(gardenProvider.notifier)
                        .sendGardenAction(
                          GardenActionParams(
                            gardenId: garden.id,
                            stop: StopAction(all: true),
                          ),
                        );
                  },
                  onUpdateConfig: () {
                    ref
                        .read(gardenProvider.notifier)
                        .sendGardenAction(
                          GardenActionParams(
                            gardenId: garden.id,
                            update: UpdateAction(config: true),
                          ),
                        );
                  },
                );
              },
              child: const Text('ACTIONS'),
            ),
          ),
        ],
      ),
    );
  }

  // Định dạng chung cho các Card
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

void showGardenActions({
  required BuildContext context,
  required GardenEntity garden,
  required Function(bool) onToggleLight,
  required VoidCallback onStopAll,
  required VoidCallback onUpdateConfig,
}) {
  showModalBottomSheet(
    useRootNavigator: true,
    context: context,
    showDragHandle: true,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Garden Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMd,
            ),
            title: const Text(
              'Lights',
              style: TextStyle(
                color: AppColors.primary700,
                fontWeight: FontWeight.bold,
              ),
            ),
            // subtitle: Text(
            //   "Status: ${garden.nextLightAction?.action == 'OFF' ? 'ON' : 'OFF'}",
            // ),
            // trailing: Switch(
            //   value: garden.nextLightAction?.action == 'OFF' ? true : false,
            //   onChanged: onToggleLight,
            //   activeColor: Colors.white,
            //   activeTrackColor: AppColors.primary,
            // ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    onToggleLight(true);
                  },
                  icon: const Icon(
                    Icons.lightbulb,
                    size: AppConstants.iconMd,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Turn ON',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    onToggleLight(false);
                  },
                  icon: const Icon(
                    Icons.lightbulb_outline,
                    size: AppConstants.iconMd,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Turn OFF',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMd,
            ),
            title: const Text(
              'Watering',
              style: TextStyle(
                color: AppColors.primary700,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: ElevatedButton.icon(
              onPressed: onStopAll,
              icon: const Icon(
                Icons.block,
                size: AppConstants.iconMd,
                color: Colors.white,
              ),
              label: const Text(
                'Stop all',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error, // Màu đỏ/cam nhạt
              ),
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMd,
            ),
            title: const Text(
              'Configuration',
              style: TextStyle(
                color: AppColors.primary700,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: ElevatedButton.icon(
              onPressed: onUpdateConfig,
              icon: const Icon(
                Icons.upload_rounded,
                size: AppConstants.iconMd,
                color: Colors.white,
              ),
              label: const Text(
                'Update',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    },
  );
}
