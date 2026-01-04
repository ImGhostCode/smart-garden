import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';
import '../../../garden/presentation/screens/garden_detail_screen.dart'
    show showZoneActions;
import '../../../water_schedule/domain/entities/water_schedule_entity.dart';
import '../../domain/entities/water_history_entity.dart';
import '../../domain/entities/zone_entity.dart';
import '../../domain/usecases/get_water_history.dart';
import '../../domain/usecases/send_zone_action.dart';
import '../providers/zone_provider.dart';

class ZoneDetailScreen extends ConsumerStatefulWidget {
  final String gardenId;
  final String zoneId;
  const ZoneDetailScreen({
    super.key,
    required this.zoneId,
    required this.gardenId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ZoneDetailScreenState();
}

class _ZoneDetailScreenState extends ConsumerState<ZoneDetailScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(zoneProvider.notifier).getZoneById(id: widget.zoneId);
      ref
          .read(zoneProvider.notifier)
          .getWaterHistory(
            GetWaterHistoryParams(
              gardenId: widget.gardenId,
              zoneId: widget.zoneId,
              range: 7,
              limit: 10,
            ),
          );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final zoneState = ref.watch(zoneProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Zone Detail"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 28),
            onPressed: () {
              context.goEditZone(
                '68de7e98ae6796d18a268a40',
                '68de7e98ae6796d18a268a40',
                zoneState.zone!,
              );
            },
          ),
        ],
      ),
      body: zoneState.isLoadingZone
          ? const Center(child: CircularProgressIndicator())
          : zoneState.errLoadingZone != null
          ? Center(child: Text(zoneState.errLoadingZone!))
          : zoneState.zone != null
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header Card ---
                  _buildMainHeaderCard(zoneState.zone!),
                  const SizedBox(height: 12),

                  // --- Details ---
                  const Text(
                    "Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Text(
                  //   zoneState.zone!.details?.description ?? '',
                  //   style: const TextStyle(fontSize: 15, color: Colors.black87),
                  // ),
                  // Container(
                  //   padding: const EdgeInsets.all(AppConstants.paddingMd),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(
                  //       AppConstants.radiusMd,
                  //     ),
                  //     border: Border.all(color: Colors.grey.shade300),
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       const Icon(
                  //         Icons.description_outlined,
                  //         color: Colors.grey,
                  //       ),
                  //       const SizedBox(width: 16),
                  //       Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           const Text(
                  //             'Description',
                  //             style: TextStyle(
                  //               fontSize: 12,
                  //               color: Colors.grey,
                  //             ),
                  //           ),
                  //           const SizedBox(height: 3),
                  //           Text(
                  //             zoneState.zone!.details?.description ?? '',
                  //             style: const TextStyle(
                  //               fontSize: 15,
                  //               fontWeight: FontWeight.w600,
                  //             ),
                  //             overflow: TextOverflow.ellipsis,
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMd,
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMd,
                    ),
                    leading: Icon(
                      Icons.description_outlined,
                      color: Colors.grey.shade700,
                      size: 28,
                    ),
                    title: const Text(
                      'Description',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    subtitle: Text(
                      zoneState.zone!.details?.description ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- Next Water Banner ---
                  if (zoneState.zone!.nextWater != null) ...[
                    _buildNextWaterBanner(zoneState.zone!.nextWater!),
                    const SizedBox(height: 12),
                  ],

                  // --- Weather Section ---
                  if (zoneState.zone!.weatherData != null) ...[
                    const Text(
                      "Weather",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildWeatherRow(
                      icon: Icons.hot_tub_rounded,
                      label: "Temperature",
                      value:
                          "${zoneState.zone!.weatherData?.temperature?.celsius}°C",
                      subValue:
                          "Scale factor: ${zoneState.zone!.weatherData?.temperature?.scaleFactor}",
                      color: Colors.orange,
                      progress:
                          (zoneState.zone!.weatherData?.temperature?.celsius ??
                              0) /
                          150,
                    ),
                    const SizedBox(height: 8),
                    _buildWeatherRow(
                      icon: Icons.water_drop,
                      label: "Humidity",
                      value: "${zoneState.zone!.weatherData?.rain?.mm}mm",
                      subValue:
                          "Scale factor: ${zoneState.zone!.weatherData?.rain?.scaleFactor}",
                      color: Colors.blue,
                      progress:
                          (zoneState.zone!.weatherData?.rain?.mm ?? 0) / 2000,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // --- Water Schedules Section ---
                  if (zoneState.zone!.waterSchedules != null) ...[
                    _buildSectionHeader(
                      "Water schedules",
                      onTap: () {},
                      count: zoneState.zone!.waterSchedules?.length,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 110,
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final schedule =
                              zoneState.zone!.waterSchedules![index];
                          return buildScheduleItem(schedule);
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(width: 8);
                        },
                        itemCount: zoneState.zone!.waterSchedules!.length,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  // --- Water History Section ---
                  _buildSectionHeader("Water History", onTap: () {}),
                  const SizedBox(height: 8),
                  zoneState.isLoadingWHistory
                      ? const Center(child: CircularProgressIndicator())
                      : zoneState.errLoadingWHistory != null
                      ? Center(child: Text(zoneState.errLoadingWHistory!))
                      : _buildHistoryTable(zoneState.waterHistory),
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
              onPressed: zoneState.isLoadingZone == true
                  ? null
                  : () {
                      showZoneActions(
                        context: context,
                        onWater: (durationMs) {
                          ref
                              .read(zoneProvider.notifier)
                              .sendZoneAction(
                                ZoneActionParams(
                                  zoneId: zoneState.zone!.id!,
                                  water: WaterAction(durationMs: durationMs),
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

  // --- Widget: Header Card ---
  Widget _buildMainHeaderCard(ZoneEntity zone) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            child: Image.asset(
              Assets.zone,
              width: 100,
              height: 80,
              fit: BoxFit.cover,
            ),
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
                      zone.name ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Position: ${zone.position ?? ''}",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Text(
                  zone.garden?.name ?? '',
                  style: const TextStyle(color: Colors.black54),
                ),
                Text(
                  "Skip watering: ${zone.skipCount}",
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget: Next Water Banner ---
  Widget _buildNextWaterBanner(NextWaterEntity nextWater) {
    final startTime = AppUtils.utcToLocalString(nextWater.time);
    final duration = AppUtils.msToDurationString(nextWater.durationMs);
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.waves, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Next Water - ${nextWater.waterSchedule?.name ?? ''}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Duration: $duration - Start: $startTime",
                  style: const TextStyle(color: Colors.black87),
                ),
                Text(
                  nextWater.message ?? '',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget: Weather Row ---
  Widget _buildWeatherRow({
    required IconData icon,
    required String label,
    required String value,
    required String subValue,
    required Color color,
    required double progress,
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
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
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
                      label,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(value, style: const TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  color: color,
                  minHeight: 6,
                ),
                const SizedBox(height: 4),
                Text(
                  subValue,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget: History Table ---
  Widget _buildHistoryTable(List<WaterHistoryEntity> waterHistory) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          ...waterHistory.map((history) {
            return Column(
              children: [const Divider(height: 1), _buildTableRow(history)],
            );
          }),
        ],
      ),
    );
  }

  // Table header
  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              "Source",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "Duration",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "Status",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(WaterHistoryEntity history) {
    String source = history.source ?? 'Unknown';
    String startAt = AppUtils.utcToLocalString(history.sentAt);
    String duration = AppUtils.msToDurationString(history.durationMs);
    String? status = history.status ?? 'Unknown';
    Color? statusColor;
    switch (history.status?.toLowerCase() ?? 'unknown') {
      case 'sent':
        statusColor = Colors.black87;
        break;
      case 'start':
        statusColor = Colors.blue;
        break;
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'failed':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.black87;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          //  Source & Start
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  startAt,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          // Duration
          Expanded(flex: 1, child: Text(duration, textAlign: TextAlign.center)),
          // Status
          Expanded(
            flex: 1,
            child: Text(
              status,
              textAlign: TextAlign.end,
              style: TextStyle(color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget: Section Header ---
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
}

// --- Widget: Schedule Item ---
Widget buildScheduleItem(WaterScheduleEntity schedule) {
  return Container(
    padding: const EdgeInsets.all(AppConstants.paddingMd),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      border: Border.all(color: Colors.black12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          schedule.name ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          schedule.description ?? '',
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildScheduleTag(
              Icons.timer_outlined,
              AppUtils.msToDurationString(schedule.durationMs),
            ),
            const SizedBox(width: 8),
            _buildScheduleTag(
              Icons.access_time,
              AppUtils.to12HourFormat(schedule.startTime),
            ),
            const SizedBox(width: 8),
            _buildScheduleTag(
              Icons.cached,
              '${schedule.interval?.toString()} days',
            ),
            if (schedule.activePeriod != null) ...[
              const SizedBox(width: 8),
              _buildScheduleTag(
                Icons.event_available,
                '${schedule.activePeriod!.startMonth} - ${schedule.activePeriod!.endMonth}',
              ),
            ],
          ],
        ),
      ],
    ),
  );
}

Widget _buildScheduleTag(IconData icon, String? text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
    ),
    child: Row(
      children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 4),
        Text(
          text ?? '',
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
