// WaterSchedule List Screen
// Screen that displays a list of waterSchedule items

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';

enum WaterRoutineAction { edit, remove }

class WaterRoutineScreen extends ConsumerStatefulWidget {
  const WaterRoutineScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _WaterRoutineScreenState();
}

class _WaterRoutineScreenState extends ConsumerState<WaterRoutineScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Water Routine'),
        centerTitle: false,
        titleTextStyle: Theme.of(
          context,
        ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
        actions: [
          IconButton.filled(
            onPressed: () {},
            icon: const Icon(Icons.notifications_rounded),
            color: AppColors.primary,
            style: IconButton.styleFrom(backgroundColor: AppColors.primary100),
          ),
          IconButton.filled(
            onPressed: () {
              context.goSettings();
            },
            icon: const Icon(Icons.settings_rounded),
            color: AppColors.primary,
            style: IconButton.styleFrom(backgroundColor: AppColors.primary100),
          ),
          const SizedBox(width: AppConstants.paddingSm),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMd),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: AppConstants.paddingLg),
              SearchBar(
                leading: const Icon(Icons.search_rounded, color: Colors.grey),
                hintText: 'Search',
                onChanged: (value) {},
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
              const SizedBox(height: 10),
              Container(
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
                      title: const Text(
                        'Morning Routine',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      titleTextStyle: Theme.of(context).textTheme.titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                      contentPadding: const EdgeInsets.only(
                        left: AppConstants.paddingMd,
                      ),
                      trailing: PopupMenuButton<WaterRoutineAction>(
                        onSelected: (WaterRoutineAction item) {
                          switch (item) {
                            case WaterRoutineAction.edit:
                              context.goEditWaterRoutine(
                                '68de7e98ae6796d18a268a40',
                              );
                              break;
                            default:
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
                                value: WaterRoutineAction.remove,
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
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingMd,
                            vertical: 0,
                          ),
                          title: Text(
                            '${index + 1}. Seedings',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          titleTextStyle: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(fontWeight: FontWeight.w600),
                          subtitle: const Text(
                            'This zone controls watering to two trees that are watered deeply',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: SizedBox(
                            width: 50,
                            child: Text(
                              '30m',
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        );
                      },
                      itemCount: 3,
                    ),
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingMd),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox.shrink(),
                          SizedBox(
                            height: AppConstants.buttonSm,
                            child: ElevatedButton(
                              onPressed: () {},
                              child: const Text('RUN ROUTINE'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
