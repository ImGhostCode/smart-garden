import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';
import '../../../garden/presentation/screens/garden_detail_screen.dart'
    show showZoneActions;

enum ZoneAction { edit, remove }

class ZoneData {
  final String title;
  final String description;
  final String imageUrl;

  ZoneData({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}

class ZoneListScreen extends StatelessWidget {
  const ZoneListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ZoneData> zones = [
      ZoneData(
        title: "Shrubs",
        description:
            "This zone has a few shrubs that need water more frequently",
        imageUrl:
            "https://img.freepik.com/free-vector/scene-park-with-many-trees_1308-56272.jpg?w=740", // Ảnh demo
      ),
      ZoneData(
        title: "Trees",
        description:
            "This zone has a few shrubs that need water more frequently",
        imageUrl:
            "https://img.freepik.com/free-vector/park-scene-with-nature-landscape_1308-46672.jpg?w=740", // Ảnh demo
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Zones"),
        actions: [
          TextButton(
            onPressed: () {
              context.goAddZone('gardenId');
            },
            child: const Text("Add zone"),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.paddingMd),
        itemCount: zones.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return ZoneListItem(data: zones[index]);
        },
      ),
    );
  }
}

class ZoneListItem extends StatelessWidget {
  final ZoneData data;

  const ZoneListItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.goZoneDetail(
          '68de7e98ae6796d18a268a34',
          '68de7e98ae6796d18a268a34',
        );
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
                      data.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Description
                    Text(
                      data.description,
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
              PopupMenuButton<ZoneAction>(
                onSelected: (ZoneAction item) {
                  switch (item) {
                    case ZoneAction.edit:
                      context.goEditZone(
                        '68de7e98ae6796d18a268a40',
                        '68de7e98ae6796d18a268a40',
                      );
                      break;
                    default:
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
                        value: ZoneAction.remove,
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
