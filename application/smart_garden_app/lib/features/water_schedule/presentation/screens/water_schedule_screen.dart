import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';

enum WaterScheduleAction { edit, remove }

class WaterScheduleScreen extends ConsumerStatefulWidget {
  const WaterScheduleScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _WaterScheduleScreenState();
}

class _WaterScheduleScreenState extends ConsumerState<WaterScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Water Schedule'),
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
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: const Text(
                        'Seedlings',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      titleTextStyle: Theme.of(context).textTheme.titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                      contentPadding: const EdgeInsets.only(
                        left: AppConstants.paddingMd,
                      ),
                      trailing: PopupMenuButton<WaterScheduleAction>(
                        onSelected: (WaterScheduleAction item) {
                          switch (item) {
                            case WaterScheduleAction.edit:
                              context.goEditWaterSchedule(
                                '68de7e98ae6796d18a268a39',
                              );
                              break;
                            default:
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<WaterScheduleAction>>[
                              const PopupMenuItem<WaterScheduleAction>(
                                value: WaterScheduleAction.edit,
                                child: ListTile(
                                  leading: Icon(Icons.edit_square),
                                  title: Text('Edit'),
                                  iconColor: Colors.blue,
                                ),
                              ),
                              const PopupMenuItem<WaterScheduleAction>(
                                value: WaterScheduleAction.remove,
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
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMd,
                      ),
                      child: Text(
                        'Water seedlings a bit every day',
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMd,
                      ),
                      height: 50,
                      child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: const [
                          ScheduleConfig(
                            icon: Icons.timer_outlined,
                            value: '15m',
                          ),
                          SizedBox(width: 5),
                          ScheduleConfig(
                            icon: Icons.access_time,
                            value: '3:00 PM',
                          ),
                          SizedBox(width: 5),
                          ScheduleConfig(icon: Icons.cached, value: '1 DAYS'),
                          SizedBox(width: 5),
                          ScheduleConfig(
                            icon: Icons.calendar_month_rounded,
                            value: 'APR - OCT',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSm),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: const Text('Seedlings'),
                      titleTextStyle: Theme.of(context).textTheme.titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                      contentPadding: const EdgeInsets.only(
                        left: AppConstants.paddingMd,
                      ),
                      trailing: PopupMenuButton<WaterScheduleAction>(
                        onSelected: (WaterScheduleAction item) {
                          switch (item) {
                            case WaterScheduleAction.edit:
                              context.goEditWaterRoutine(
                                '68de7e98ae6796d18a268a41',
                              );
                              break;
                            default:
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<WaterScheduleAction>>[
                              const PopupMenuItem<WaterScheduleAction>(
                                value: WaterScheduleAction.edit,
                                child: ListTile(
                                  leading: Icon(Icons.edit_square),
                                  title: Text('Edit'),
                                  iconColor: Colors.blue,
                                ),
                              ),
                              const PopupMenuItem<WaterScheduleAction>(
                                value: WaterScheduleAction.remove,
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
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMd,
                      ),
                      child: Text('Water seedlings a bit every day'),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMd,
                      ),
                      height: 50,
                      child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: const [
                          ScheduleConfig(
                            icon: Icons.timer_outlined,
                            value: '15m',
                          ),
                          SizedBox(width: 5),
                          ScheduleConfig(
                            icon: Icons.access_time,
                            value: '3:00 PM',
                          ),
                          SizedBox(width: 5),
                          ScheduleConfig(icon: Icons.cached, value: '1 DAYS'),
                          SizedBox(width: 5),
                          ScheduleConfig(
                            icon: Icons.calendar_month_rounded,
                            value: 'APR - OCT',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSm),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScheduleConfig extends StatelessWidget {
  const ScheduleConfig({super.key, required this.value, required this.icon});
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      elevation: 0,
      padding: const EdgeInsets.all(AppConstants.paddingSm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      backgroundColor: AppColors.primary,
      labelPadding: EdgeInsets.zero,
      labelStyle: Theme.of(
        context,
      ).textTheme.bodyMedium!.copyWith(color: Colors.white),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            value,
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
}
