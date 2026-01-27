// WaterSchedule List Screen
// Screen that displays a list of waterSchedule items

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/extensions/build_context_extentions.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';
import '../../domain/entities/water_routine_entity.dart';
import '../../domain/usecases/get_all_water_routines.dart';
import '../providers/water_routine_provider.dart';

enum WaterRoutineAction { edit, delete }

class WaterRoutineScreen extends ConsumerStatefulWidget {
  const WaterRoutineScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _WaterRoutineScreenState();
}

class _WaterRoutineScreenState extends ConsumerState<WaterRoutineScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(waterRoutineProvider).waterRoutines.isEmpty) {
        ref
            .read(waterRoutineProvider.notifier)
            .getAllWaterRoutine(GetAllWRParams());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    EasyLoading.dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waterRoutineState = ref.watch(waterRoutineProvider);

    ref.listen(waterRoutineProvider.select((state) => state.isRunningWR), (
      previousLoading,
      nextLoading,
    ) {
      if (nextLoading == true) {
        EasyLoading.show(status: 'Loading...');
      } else if (nextLoading == false && previousLoading == true) {
        EasyLoading.dismiss();
      }
    });

    ref.listen(waterRoutineProvider, (previous, next) async {
      if (previous?.isRunningWR == true && next.isRunningWR == false) {
        if (next.errRunningWR.isNotEmpty) {
          EasyLoading.showError(next.errRunningWR);
        } else {
          EasyLoading.showSuccess(
            next.responseMsg ?? 'Water Routine run successfully',
          );
          // context.goBack();
        }
      }
    });

    ref.listen(waterRoutineProvider.select((state) => state.isDeletingWR), (
      previousLoading,
      nextLoading,
    ) {
      if (nextLoading == true) {
        EasyLoading.show(status: 'Loading...');
      } else if (nextLoading == false && previousLoading == true) {
        EasyLoading.dismiss();
      }
    });

    ref.listen(waterRoutineProvider, (previous, next) async {
      if (previous?.isDeletingWR == true && next.isDeletingWR == false) {
        if (next.errDeletingWR.isNotEmpty) {
          EasyLoading.showError(next.errDeletingWR);
        } else {
          EasyLoading.showSuccess(
            next.responseMsg ?? 'Water Routine deleted successfully',
          );
          ref
              .read(waterRoutineProvider.notifier)
              .getAllWaterRoutine(GetAllWRParams());
          // refresh list
        }
      }
    });

    return SafeArea(
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            ref
                .read(waterRoutineProvider.notifier)
                .getAllWaterRoutine(GetAllWRParams());
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                scrolledUnderElevation: 0,
                floating: true,
                pinned: false,
                centerTitle: false,
                title: const Text('Water Routine'),
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
                sliver: _buildSliverContent(waterRoutineState),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 150)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverContent(WaterRoutineState waterRoutineState) {
    if (waterRoutineState.isLoadingWRs) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (waterRoutineState.errLoadingWRs.isNotEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text(waterRoutineState.errLoadingWRs)),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final wr = waterRoutineState.waterRoutines[index];
        return WaterRoutineItem(
          wr: wr,
          onRun: () {
            ref.read(waterRoutineProvider.notifier).runWaterRoutine(wr.id!);
          },
          onDelete: () {
            ref.read(waterRoutineProvider.notifier).deleteWaterRoutine(wr.id!);
          },
        );
      }, childCount: waterRoutineState.waterRoutines.length),
    );
  }
}

class WaterRoutineItem extends StatelessWidget {
  final WaterRoutineEntity wr;
  final VoidCallback? onRun;
  final VoidCallback? onDelete;
  const WaterRoutineItem({
    super.key,
    required this.wr,
    this.onRun,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        // color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const SizedBox(width: 48),
            title: Text(
              wr.name ?? '',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            titleTextStyle: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            contentPadding: const EdgeInsets.only(left: AppConstants.paddingMd),
            trailing: PopupMenuButton<WaterRoutineAction>(
              onSelected: (WaterRoutineAction item) {
                switch (item) {
                  case WaterRoutineAction.edit:
                    context.goEditWaterRoutine(wr.id!, wr);
                    break;
                  case WaterRoutineAction.delete:
                    context.showConfirmDialog(
                      title: 'Delete Water Routine',
                      content:
                          'Are you sure you want to delete the water routine "${wr.name}"?',
                      confirmText: 'Delete',
                      confirmColor: AppColors.error,
                      onConfirm: onDelete,
                    );
                    break;
                }
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<WaterRoutineAction>>[
                    const PopupMenuItem<WaterRoutineAction>(
                      value: WaterRoutineAction.edit,
                      child: ListTile(
                        leading: Icon(Icons.edit_square),
                        title: Text('Edit'),
                        iconColor: Colors.blue,
                      ),
                    ),
                    const PopupMenuItem<WaterRoutineAction>(
                      value: WaterRoutineAction.delete,
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
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final step = wr.steps![index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMd,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${index + 1}. ${step.zone?.name ?? ''}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      AppUtils.msToDurationString(step.durationMs),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              );
            },
            itemCount: wr.steps!.length,
          ),
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMd),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox.shrink(),
                SizedBox(
                  height: AppConstants.buttonSm,
                  child: ElevatedButton(
                    onPressed: onRun,
                    child: const Text('RUN ROUTINE'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
