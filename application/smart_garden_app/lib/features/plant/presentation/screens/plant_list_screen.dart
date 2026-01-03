import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';
import '../../domain/entities/plant_entity.dart';
import '../../domain/usecases/get_all_plants.dart';
import '../providers/plant_provider.dart';

enum PlantAction { edit, remove }

class PlantListScreen extends ConsumerStatefulWidget {
  final String gardenId;
  const PlantListScreen({super.key, required this.gardenId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PlantListScreenState();
}

class _PlantListScreenState extends ConsumerState<PlantListScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(plantProvider).plants.isEmpty) {
        ref
            .read(plantProvider.notifier)
            .getAllPlant(GetAllPlantParams(gardenId: widget.gardenId));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final plantState = ref.watch(plantProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Plants"),
        actions: [
          TextButton(
            onPressed: () {
              context.goAddPlant('68de7e98ae6796d18a268a34');
            },
            child: const Text("Add plant"),
          ),
        ],
      ),
      body: plantState.isLoadingPlants
          ? const Center(child: CircularProgressIndicator())
          : plantState.errLoadingPlants != null
          ? Center(child: Text(plantState.errLoadingPlants!))
          : ListView.separated(
              padding: const EdgeInsets.all(AppConstants.paddingMd),
              itemCount: plantState.plants.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return PlantListItem(data: plantState.plants[index]);
              },
            ),
    );
  }
}

class PlantListItem extends StatelessWidget {
  final PlantEntity data;

  const PlantListItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.goPlantDetail(
          '68de7e98ae6796d18a268a34',
          '68de7e98ae6796d18a268a32',
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
              Container(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.only(top: AppConstants.paddingMd),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Image.asset(
                  Assets.plant,
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
                    const SizedBox(height: 4),

                    Text(
                      data.details?.description ?? '',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
              PopupMenuButton<PlantAction>(
                onSelected: (PlantAction item) {
                  switch (item) {
                    case PlantAction.edit:
                      context.goEditPlant(
                        '68de7e98ae6796d18a268a40',
                        '68de7e98ae6796d18a268a40',
                      );
                      break;
                    default:
                  }
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<PlantAction>>[
                      const PopupMenuItem<PlantAction>(
                        value: PlantAction.edit,
                        child: ListTile(
                          leading: Icon(Icons.edit_square),
                          title: Text('Edit'),
                          iconColor: Colors.blue,
                        ),
                      ),
                      const PopupMenuItem<PlantAction>(
                        value: PlantAction.remove,
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
