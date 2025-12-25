import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';
import '../../../garden/presentation/screens/garden_detail_screen.dart'
    show showZoneActions;

class ZoneDetailScreen extends StatelessWidget {
  final String? zoneId;
  const ZoneDetailScreen({super.key, required this.zoneId});

  @override
  Widget build(BuildContext context) {
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
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Card ---
            _buildMainHeaderCard(),
            const SizedBox(height: 12),

            // --- Details ---
            const Text(
              "Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "This zone has a few shrubs that need water more frequently",
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 12),

            // --- Next Water Banner ---
            _buildNextWaterBanner(),
            const SizedBox(height: 12),

            // --- Weather Section ---
            const Text(
              "Weather",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildWeatherRow(
              icon: Icons.hot_tub_rounded,
              label: "Temperature",
              value: "20°C",
              subValue: "Scale factor: 1.55",
              color: Colors.orange,
              progress: 0.7,
            ),
            const SizedBox(height: 8),
            _buildWeatherRow(
              icon: Icons.water_drop,
              label: "Humidity",
              value: "90%",
              subValue: "Scale factor: 0.5",
              color: Colors.blue,
              progress: 0.9,
            ),
            const SizedBox(height: 8),

            // --- Water Schedules Section ---
            _buildSectionHeader("Water schedules", onTap: () {}),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 110,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return buildScheduleItem();
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 8);
                },
                itemCount: 5,
              ),
            ),
            const SizedBox(height: 8),
            // --- Water History Section ---
            _buildSectionHeader("Water History", onTap: () {}),
            const SizedBox(height: 8),
            _buildHistoryTable(),
            const SizedBox(height: 150),
          ],
        ),
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(AppConstants.paddingMd),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: AppConstants.buttonMd,
            child: ElevatedButton(
              onPressed: () {
                showZoneActions(context);
              },
              child: const Text('ACTIONS'),
            ),
          ),
        ),
      ),
    );
  }

  // --- Widget: Header Card ---
  Widget _buildMainHeaderCard() {
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Shrubs",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Position: 1",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Text("Front yard", style: TextStyle(color: Colors.black54)),
                Text(
                  "Skip watering: 2",
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget: Next Water Banner ---
  Widget _buildNextWaterBanner() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: Colors.green),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Next Water - Seedlings",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "Duration: 20m - Start: 19:00:00 1/1/2025",
                  style: TextStyle(color: Colors.black87),
                ),
                Text(
                  "Skip count 1 affected the time",
                  style: TextStyle(
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
  Widget _buildHistoryTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          const Divider(height: 1),
          _buildTableRow(
            source: "Scheduled",
            startAt: "19:00 22/12/2025",
            duration: "1h",
            status: "Start",
            statusColor: Colors.blue,
          ),
          const Divider(height: 1),
          _buildTableRow(
            source: "Command",
            startAt: "21:30 22/12/2025",
            duration: "15m",
            status: "Completed",
            statusColor: const Color(0xFF4CAF50),
          ),
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

  Widget _buildTableRow({
    required String source,
    required String startAt,
    required String duration,
    required String status,
    required Color statusColor,
  }) {
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
  Widget _buildSectionHeader(String title, {VoidCallback? onTap}) {
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
            child: const Text(
              'See all (2)',
              style: TextStyle(color: Colors.blue, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

// --- Widget: Schedule Item ---
Widget buildScheduleItem() {
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
        const Text(
          "Seedlings",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const Text(
          "Water seedlings a bit every day",
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildScheduleTag(Icons.timer_outlined, "30S"),
            const SizedBox(width: 8),
            _buildScheduleTag(Icons.access_time, "3:00 PM"),
            const SizedBox(width: 8),
            _buildScheduleTag(Icons.cached, "1 DAYS"),
          ],
        ),
      ],
    ),
  );
}

Widget _buildScheduleTag(IconData icon, String text) {
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
          text,
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
