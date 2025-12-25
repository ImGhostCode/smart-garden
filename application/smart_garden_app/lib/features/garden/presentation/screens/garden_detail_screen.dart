// Garden Detail Screen
// Screen that displays details of a specific garden

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';
import '../../../home/presentation/screens/home_screen.dart'
    show showGardenActions;

class GardenDetailScreen extends ConsumerWidget {
  final String gardenId;
  const GardenDetailScreen({super.key, required this.gardenId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print(gardenId);
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
              context.goEditGarden('68de7e98ae6796d18a268a40');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Card
            _buildHeaderCard(),
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
              value: "20°C",
              progressColor: Colors.amber,
              progressValue: 0.6,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.water_drop,
              iconColor: Colors.blue,
              title: "Humidity",
              value: "90%",
              progressColor: Colors.blue,
              progressValue: 0.9,
            ),
            const SizedBox(height: 12),
            _buildLightScheduleCard(),

            const SizedBox(height: 12),

            // 3. Zones Section (Horizontal List)
            _buildSectionHeader(
              "Zones",
              onTap: () {
                context.goZones('68de7e98ae6796d18a268a35');
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildZoneCard(
                    context: context,
                    title: "Trees",
                    desc: "This zone controls watering to two trees...",
                    imageUrl:
                        "https://images.unsplash.com/photo-1598512114194-257a07941708?q=80&w=200",
                  ),
                  const SizedBox(width: 12),
                  _buildZoneCard(
                    context: context,
                    title: "Vegetables",
                    desc: "This zone controls watering to vegetables...",
                    imageUrl:
                        "https://images.unsplash.com/photo-1592419044706-39796d40f98c?q=80&w=200",
                  ),
                  const SizedBox(width: 12),
                  _buildZoneCard(
                    context: context,
                    title: "Grass",
                    desc: "This zone controls watering to the lawn...",
                    imageUrl:
                        "https://images.unsplash.com/photo-1558904541-efa843a96f01?q=80&w=200",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Plants Section
            _buildSectionHeader(
              "Plants",
              onTap: () {
                context.goPlants('68de7e98ae6796d18a268a36');
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildPlantCard(
                    context: context,
                    name: "Mint",
                    desc: "Mint will be ready for harvest in 3 days",
                    imageUrl:
                        "https://images.unsplash.com/photo-1628519586326-e17ee91d8d32?q=80&w=200",
                  ),
                  const SizedBox(width: 12),
                  _buildPlantCard(
                    context: context,
                    name: "Basil",
                    desc: "Basil will be ready for harvest in 5 days",
                    imageUrl:
                        "https://images.unsplash.com/photo-1618331835717-801e976710b2?q=80&w=200",
                  ),
                  const SizedBox(width: 12),
                  _buildPlantCard(
                    context: context,
                    name: "Rosemary",
                    desc: "Ready for harvest",
                    imageUrl:
                        "https://images.unsplash.com/photo-1597055819777-1c6dc32560d7?q=80&w=200",
                  ),
                ],
              ),
            ),
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
                showGardenActions(context);
              },
              child: const Text('ACTIONS'),
            ),
          ),
        ),
      ),
    );
  }

  // --- Widget Con: Header Card ---
  Widget _buildHeaderCard() {
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
              const Text(
                "Front Yard",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                "Topic prefix: front-yard",
                style: TextStyle(color: Colors.grey.shade700),
              ),

              Row(
                children: [
                  const Text(
                    "Status: Online",
                    style: TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const Text(
                "Max zone: 5",
                style: TextStyle(color: Colors.black87),
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

  Widget _buildLightScheduleCard() {
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Light Schedule",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "Duration: 15h - Start: 7:00 PM",
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
                SizedBox(height: 4),
                Text(
                  "Next action: OFF - 07:00 1/1/2025",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            "ON",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

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

  Widget _buildZoneCard({
    required BuildContext context,
    required String title,
    required String desc,
    required String imageUrl,
  }) {
    return InkWell(
      onTap: () {
        context.goZoneDetail(
          '68de7e98ae6796d18a268a34',
          '68de7e98ae6796d18a268a38',
        );
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
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: AppConstants.buttonSm,
              child: ElevatedButton(
                onPressed: () {
                  showZoneActions(context);
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
    required String name,
    required String desc,
    required String imageUrl,
  }) {
    return InkWell(
      onTap: () {
        context.goPlantDetail(
          '68de7e98ae6796d18a268a34',
          '68de7e98ae6796d18a268a37',
        );
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
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
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

void showZoneActions(BuildContext context) {
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
                      print("Watering in $durationMinutes minutes");
                      Navigator.pop(context);
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
