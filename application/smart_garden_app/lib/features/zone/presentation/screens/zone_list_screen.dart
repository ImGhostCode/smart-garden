import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/build_context_extentions.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';
import '../../../garden/presentation/screens/garden_detail_screen.dart'
    show showZoneActions;
import '../../../plant/domain/usecases/get_all_plants.dart';
import '../../../plant/presentation/providers/plant_provider.dart';
import '../../../water_routine/domain/usecases/get_all_water_routines.dart';
import '../../../water_routine/presentation/providers/water_routine_provider.dart';
import '../../domain/entities/zone_entity.dart';
import '../../domain/usecases/delete_zone.dart';
import '../../domain/usecases/get_all_zones.dart';
import '../../domain/usecases/send_zone_action.dart';
import '../providers/zone_provider.dart';

enum ZoneAction { edit, delete }

class ZoneListScreen extends ConsumerStatefulWidget {
  final String gardenId;
  const ZoneListScreen({super.key, required this.gardenId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ZoneListScreenState();
}

class _ZoneListScreenState extends ConsumerState<ZoneListScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(zoneProvider).zones.isEmpty) {
        ref
            .read(zoneProvider.notifier)
            .getAllZone(GetAllZoneParams(gardenId: widget.gardenId));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final zoneState = ref.watch(zoneProvider);

    ref.listen(zoneProvider.select((state) => state.isDeletingZone), (
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
      if (previous?.isDeletingZone == true && next.isDeletingZone == false) {
        if (next.errDeletingZone.isNotEmpty) {
          EasyLoading.showError(next.errDeletingZone);
        } else {
          EasyLoading.showSuccess(next.responseMsg ?? 'Zone deleted');
          // refresh zone list
          ref
              .read(zoneProvider.notifier)
              .getAllZone(GetAllZoneParams(gardenId: widget.gardenId));
          // refresh plant list
          ref
              .read(plantProvider.notifier)
              .getAllPlant(GetAllPlantParams(gardenId: widget.gardenId));
          // refresh water routine list
          ref
              .read(waterRoutineProvider.notifier)
              .getAllWaterRoutine(GetAllWRParams());
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Zones"),
        actions: [
          TextButton(
            onPressed: () {
              context.goAddZone(widget.gardenId);
            },
            child: const Text("Add zone"),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
              .read(zoneProvider.notifier)
              .getAllZone(GetAllZoneParams(gardenId: widget.gardenId));
        },
        child: zoneState.isLoadingZones
            ? const Center(child: CircularProgressIndicator())
            : zoneState.errLoadingZones.isNotEmpty
            ? Center(child: Text(zoneState.errLoadingZones))
            : zoneState.zones.isEmpty
            ? const Center(child: Text('No zones found'))
            : ListView.separated(
                padding: const EdgeInsets.all(AppConstants.paddingMd),
                itemCount: zoneState.zones.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return ZoneListItem(
                    data: zoneState.zones[index],
                    onWater: (durationMs) {
                      ref
                          .read(zoneProvider.notifier)
                          .sendZoneAction(
                            ZoneActionParams(
                              gardenId: widget.gardenId,
                              zoneId: zoneState.zones[index].id,
                              water: WaterAction(durationMs: durationMs),
                            ),
                          );
                    },
                    onDelete: () {
                      ref
                          .read(zoneProvider.notifier)
                          .deleteZone(
                            DeleteZoneParams(
                              gardenId: widget.gardenId,
                              id: zoneState.zones[index].id,
                            ),
                          );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class ZoneListItem extends ConsumerWidget {
  final ZoneEntity data;
  final Function(int) onWater;
  final VoidCallback? onDelete;

  const ZoneListItem({
    super.key,
    required this.data,
    required this.onWater,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        context.goZoneDetail(data.garden!.id!, data.id!);
      },
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: AppConstants.paddingMd,
            bottom: AppConstants.paddingMd,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Left picture
              Container(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.only(top: AppConstants.paddingMd),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Image.asset(
                  Assets.zone,
                  width: 100,
                  height: 90,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 90,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // 2. Right content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppConstants.paddingMd),
                    Text(
                      data.name ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Description
                    Text(
                      data.details?.description ?? '',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    // Action
                    SizedBox(
                      height: AppConstants.buttonSm,
                      child: ElevatedButton(
                        onPressed: () {
                          showZoneActions(context: context, onWater: onWater);
                        },
                        child: const Text(
                          "QUICK WATER",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<ZoneAction>(
                onSelected: (ZoneAction item) {
                  switch (item) {
                    case ZoneAction.edit:
                      context.goEditZone(data.garden!.id!, data.id!, data);
                      break;
                    case ZoneAction.delete:
                      context.showConfirmDialog(
                        title: 'Delete Zone',
                        content:
                            'Are you sure you want to delete the zone "${data.name}"?',
                        confirmText: 'Delete',
                        confirmColor: AppColors.error,
                        onConfirm: onDelete,
                      );
                  }
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<ZoneAction>>[
                      const PopupMenuItem<ZoneAction>(
                        value: ZoneAction.edit,
                        child: ListTile(
                          leading: Icon(Icons.edit_square),
                          title: Text('Edit'),
                          iconColor: Colors.blue,
                        ),
                      ),
                      const PopupMenuItem<ZoneAction>(
                        value: ZoneAction.delete,

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
            ],
          ),
        ),
      ),
    );
  }
}
