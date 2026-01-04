import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/extensions/build_context_extentions.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';
import '../providers/plant_provider.dart';

class PlantDetailScreen extends ConsumerStatefulWidget {
  final String plantId;
  const PlantDetailScreen({super.key, required this.plantId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PlantDetailScreenState();
}

class _PlantDetailScreenState extends ConsumerState<PlantDetailScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(plantProvider.notifier).getPlantById(id: widget.plantId);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final plantState = ref.watch(plantProvider);

    ref.listen(plantProvider.select((state) => state.isDeletingPlant), (
      previousLoading,
      nextLoading,
    ) {
      if (nextLoading == true) {
        EasyLoading.show(status: 'Loading...');
      } else if (nextLoading == false && previousLoading == true) {
        EasyLoading.dismiss();
      }
    });

    ref.listen(plantProvider, (previous, next) async {
      if (previous?.isDeletingPlant == true && next.isDeletingPlant == false) {
        if (next.errDeletingPlant.isNotEmpty) {
          EasyLoading.showError(next.errDeletingPlant);
        } else {
          EasyLoading.showSuccess(next.responseMsg ?? 'Plant deleted');
          context.goBack();
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Plant Detail"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 28),
            onPressed: () {
              context.goEditPlant(
                '68de7e98ae6796d18a268a40',
                '68de7e98ae6796d18a268a40',
                plantState.plant!,
              );
            },
          ),
        ],
      ),
      body: plantState.isLoadingPlant
          ? const Center(child: CircularProgressIndicator())
          : plantState.errLoadingPlant.isNotEmpty
          ? Center(child: Text(plantState.errLoadingPlant))
          : plantState.plant != null
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header  ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMd,
                      vertical: AppConstants.paddingSm,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMd,
                      ),
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
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusMd,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(Assets.plant),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plantState.plant?.name ?? '',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              plantState.plant?.zone?.name ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const Text(""),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    "Details",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  GridView.count(
                    padding: EdgeInsets.zero,
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _buildInfoCard(
                        Icons.timer_outlined,
                        "Harvest in",
                        plantState.plant?.details?.timeToHarvest ?? '',
                        Colors.orange,
                      ),
                      _buildInfoCard(
                        Icons.grass,
                        "Plants",
                        plantState.plant?.details?.count?.toString() ?? '',
                        Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildListInfoCard(
                    icon: Icons.water_drop_outlined,
                    title: "Next water time",
                    value: AppUtils.utcToLocalString(
                      plantState.plant?.nextWaterTime,
                    ),
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildListInfoCard(
                    icon: Icons.description_outlined,
                    title: "Description",
                    value: plantState.plant?.details?.description ?? '',
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppConstants.paddingMd),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMd,
                      ),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.sticky_note_2_outlined,
                              size: 20,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "NOTES",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          plantState.plant!.details?.notes ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            // height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Center(
                    child: TextButton(
                      onPressed: () {
                        context.showConfirmDialog(
                          title: "Delete Plant",
                          content:
                              "Are you sure you want to delete this plant?",
                          confirmColor: AppColors.error,
                          onConfirm: () {
                            ref
                                .read(plantProvider.notifier)
                                .deletePlant(plantState.plant?.id ?? '');
                          },
                        );
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text("Delete this plant"),
                    ),
                  ),
                  const SizedBox(height: 150),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildListInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMd,
      ),
      leading: Icon(icon, color: color, size: 28),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    );
  }
}
