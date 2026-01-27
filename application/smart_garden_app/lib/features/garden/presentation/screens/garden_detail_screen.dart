// Garden Detail Screen
// Screen that displays details of a specific garden

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../plant/domain/entities/plant_entity.dart';
import '../../../plant/domain/usecases/get_all_plants.dart';
import '../../../plant/presentation/providers/plant_provider.dart';
import '../../../zone/domain/entities/zone_entity.dart';
import '../../../zone/domain/usecases/get_all_zones.dart';
import '../../../zone/domain/usecases/send_zone_action.dart';
import '../../../zone/presentation/providers/zone_provider.dart';
import '../../domain/entities/garden_entity.dart';
import '../../domain/usecases/send_garden_action.dart';
import '../providers/garden_provider.dart';

class GardenDetailScreen extends ConsumerStatefulWidget {
  final String gardenId;
  const GardenDetailScreen({super.key, required this.gardenId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GardenDetailScreenState();
}

class _GardenDetailScreenState extends ConsumerState<GardenDetailScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gardenProvider.notifier).getGardenById(id: widget.gardenId);
      ref
          .read(zoneProvider.notifier)
          .getAllZone(GetAllZoneParams(gardenId: widget.gardenId));
      ref
          .read(plantProvider.notifier)
          .getAllPlant(GetAllPlantParams(gardenId: widget.gardenId));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final gardenState = ref.watch(gardenProvider);
    final zoneState = ref.watch(zoneProvider);
    final plantState = ref.watch(plantProvider);

    // ref.listen(zoneProvider.select((state) => state.isSendingAction), (
    //   previousLoading,
    //   nextLoading,
    // ) {
    //   if (nextLoading == true) {
    //     EasyLoading.show(status: 'Loading...');
    //   } else if (nextLoading == false && previousLoading == true) {
    //     EasyLoading.dismiss();
    //   }
    // });

    // ref.listen(zoneProvider, (previous, next) async {
    //   if (previous?.isSendingAction == true && next.isSendingAction == false) {
    //     if (next.errSendingAction != null) {
    //       EasyLoading.showError(next.errSendingAction ?? 'Error');
    //     } else {
    //       EasyLoading.showSuccess(next.responseMsg ?? 'Zone action sent');
    //       // context.goBack();
    //     }
    //   }
    // });

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Garden Detail",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
            onPressed: () {
              context.goEditGarden(widget.gardenId);
            },
          ),
        ],
      ),
      body: gardenState.isLoadingGarden
          ? const Center(child: CircularProgressIndicator())
          : gardenState.errLoadingGarden.isNotEmpty
          ? Center(child: Text(gardenState.errLoadingGarden))
          : gardenState.garden != null
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header Card
                  _buildHeaderCard(gardenState.garden!),
                  const SizedBox(height: 12),

                  // 2. Details Section
                  const Text(
                    "Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    icon: Icons.thermostat,
                    iconColor: Colors.redAccent,
                    title: "Temperature",
                    value:
                        "${gardenState.garden?.tempHumData?.temperatureCelsius?.toStringAsFixed(1) ?? '-'}°C",
                    progressColor: Colors.amber,
                    progressValue:
                        (gardenState.garden?.tempHumData?.temperatureCelsius ??
                            0) /
                        150,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.water_drop,
                    iconColor: Colors.blue,
                    title: "Humidity",
                    value:
                        "${gardenState.garden?.tempHumData?.humidityPercentage?.toStringAsFixed(1) ?? '-'}%",
                    progressColor: Colors.blue,
                    progressValue:
                        (gardenState.garden?.tempHumData?.humidityPercentage ??
                            0) /
                        100,
                  ),
                  const SizedBox(height: 12),
                  if (gardenState.garden?.lightSchedule != null)
                    _buildLightScheduleCard(
                      gardenState.garden!.lightSchedule!,
                      gardenState.garden!.nextLightAction,
                    ),

                  const SizedBox(height: 12),

                  // 3. Zones Section (Horizontal List)
                  _buildSectionHeader(
                    "Zones",
                    count: zoneState.zones.length,
                    onTap: () {
                      context.goZones(widget.gardenId);
                    },
                  ),
                  const SizedBox(height: 8),
                  zoneState.isLoadingZones
                      ? const Center(child: CircularProgressIndicator())
                      : zoneState.errLoadingZones.isNotEmpty
                      ? Center(child: Text(zoneState.errLoadingZones))
                      : zoneState.zones.isEmpty
                      ? const Center(child: Text('No zones found'))
                      : SizedBox(
                          height: 250,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final zone = zoneState.zones[index];
                              return _buildZoneCard(
                                context: context,
                                zone: zone,
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(width: 12);
                            },
                            itemCount: zoneState.zones.length > 10
                                ? 10
                                : zoneState.zones.length,
                          ),
                        ),
                  const SizedBox(height: 8),

                  // 4. Plants Section
                  _buildSectionHeader(
                    "Plants",
                    count: plantState.plants.length,
                    onTap: () {
                      context.goPlants(widget.gardenId);
                    },
                  ),
                  const SizedBox(height: 8),
                  plantState.isLoadingPlants
                      ? const Center(child: CircularProgressIndicator())
                      : plantState.errLoadingPlants.isNotEmpty
                      ? Center(child: Text(plantState.errLoadingPlants))
                      : plantState.plants.isEmpty
                      ? const Center(child: Text('No plants found'))
                      : SizedBox(
                          height: 210,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final plant = plantState.plants[index];
                              return _buildPlantCard(
                                context: context,
                                plant: plant,
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(width: 12);
                            },
                            itemCount: plantState.plants.length > 10
                                ? 10
                                : plantState.plants.length,
                          ),
                        ),
                  const SizedBox(height: 150),
                ],
              ),
            )
          : const SizedBox.shrink(),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(AppConstants.paddingMd),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: AppConstants.buttonMd,
            child: ElevatedButton(
              onPressed: gardenState.isLoadingGarden == true
                  ? null
                  : () {
                      showGardenActions(
                        context: context,
                        garden: gardenState.garden!,
                        onToggleLight: (isOn) {
                          ref
                              .read(gardenProvider.notifier)
                              .sendGardenAction(
                                GardenActionParams(
                                  gardenId: gardenState.garden!.id,
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
                                  gardenId: gardenState.garden!.id,
                                  stop: StopAction(all: true),
                                ),
                              );
                        },
                      );
                    },
              child: const Text('ACTIONS'),
            ),
          ),
        ),
      ),
    );
  }

  // --- Widget Con: Header Card ---
  Widget _buildHeaderCard(GardenEntity garden) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMd,
        vertical: AppConstants.paddingSm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: AssetImage(Assets.garden)),
            ),
          ),
          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                garden.name ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Topic prefix: ${garden.topicPrefix}",
                style: TextStyle(color: Colors.grey.shade700),
              ),

              Row(
                children: [
                  Text(
                    "Status: ${garden.health?.status == 'UP' ? 'Online' : "Offline"}",
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: garden.health?.status == 'UP'
                          ? Colors.green
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              Text(
                "Max zone: ${garden.maxZones}",
                style: const TextStyle(color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color progressColor,
    required double progressValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(value, style: const TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    backgroundColor: Colors.grey[300],
                    color: progressColor,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLightScheduleCard(
    LightScheduleEntity lightSchedule,
    NextLightActionEntity? nextLightAction,
  ) {
    final nextActionTime = nextLightAction != null
        ? AppUtils.utcToLocalString(nextLightAction.time)
        : "N/A";
    final duration = AppUtils.msToDurationString(lightSchedule.durationMs ?? 0);
    final startTime = AppUtils.to12HourFormat(lightSchedule.startTime);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.lightbulb, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Light Schedule",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Duration: $duration - Start: $startTime",
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                if (nextLightAction != null)
                  Text(
                    "Next action: ${nextLightAction.action} - $nextActionTime",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          // Text(
          //   nextLightAction?.action == "OFF" ? "ON" : "OFF",
          //   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          // ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onTap, int? count}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 40,
          child: TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMd,
              ),
            ),
            child: Text(
              'See all${count != null ? ' ($count)' : ''}',
              style: const TextStyle(color: Colors.blue, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildZoneCard({
    required BuildContext context,
    required ZoneEntity zone,
  }) {
    return InkWell(
      onTap: () {
        context.goZoneDetail(widget.gardenId, zone.id!);
      },
      child: Ink(
        width: 170,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              child: Image.asset(
                Assets.zone,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              zone.name ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              zone.details?.description ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: AppConstants.buttonSm,
              child: ElevatedButton(
                onPressed: () {
                  showZoneActions(
                    context: context,
                    onWater: (durationMs) {
                      ref
                          .read(zoneProvider.notifier)
                          .sendZoneAction(
                            ZoneActionParams(
                              gardenId: widget.gardenId,
                              zoneId: zone.id!,
                              water: WaterAction(durationMs: durationMs),
                            ),
                          );
                    },
                  );
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
    );
  }

  Widget _buildPlantCard({
    required BuildContext context,
    required PlantEntity plant,
  }) {
    return InkWell(
      onTap: () {
        context.goPlantDetail(widget.gardenId, plant.id!);
      },
      child: Ink(
        width: 170,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0XFFC6E4E6),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: Image.asset(
                Assets.plant,
                height: 100,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.name ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  plant.details?.description ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showZoneActions({
  required BuildContext context,
  required Function(int) onWater,
}) {
  int durationMinutes = 15;
  final TextEditingController timeController = TextEditingController(
    text: '${durationMinutes}m',
  );

  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          void updateTime(int newTime) {
            setState(() {
              if (newTime < 1) return;
              if (newTime > 100) return;
              durationMinutes = newTime;
              timeController.text = '${durationMinutes}m';
            });
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Zone Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMd,
                ),
                title: const Text(
                  'Water zone',
                  style: TextStyle(
                    color: AppColors.primary700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => updateTime(durationMinutes - 5),
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: durationMinutes <= 5 ? Colors.grey : Colors.red,
                      ),
                    ),

                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: timeController,
                        textAlign: TextAlign.center,
                        readOnly: true,
                        canRequestFocus: false,
                      ),
                    ),

                    IconButton(
                      onPressed: () => updateTime(durationMinutes + 5),
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: durationMinutes >= 100
                            ? Colors.grey
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMd),
                child: SizedBox(
                  height: AppConstants.buttonMd,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      onWater(durationMinutes * 60 * 1000);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      );
    },
  );
}
