import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';

enum WeatherClientAction { edit, remove }

class WeatherClientScreen extends ConsumerStatefulWidget {
  const WeatherClientScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _WeatherClientScreenState();
}

class _WeatherClientScreenState extends ConsumerState<WeatherClientScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Weather Client'),
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
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: const Text('Ha Noi'),
                      titleTextStyle: Theme.of(context).textTheme.titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                      contentPadding: const EdgeInsets.only(
                        left: AppConstants.paddingMd,
                      ),
                      subtitle: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(top: 3),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.yellow.shade700,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.yellow.shade800),
                          ),
                          child: Text(
                            'Netatmo',
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      trailing: PopupMenuButton<WeatherClientAction>(
                        onSelected: (WeatherClientAction item) {
                          switch (item) {
                            case WeatherClientAction.edit:
                              context.goEditWeatherClient(
                                '68de7e98ae6796d18a268a40',
                              );
                              break;
                            default:
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<WeatherClientAction>>[
                              const PopupMenuItem<WeatherClientAction>(
                                value: WeatherClientAction.edit,
                                child: ListTile(
                                  leading: Icon(Icons.edit_square),
                                  title: Text('Edit'),
                                  iconColor: Colors.blue,
                                ),
                              ),
                              const PopupMenuItem<WeatherClientAction>(
                                value: WeatherClientAction.remove,
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
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.water_drop_outlined,
                                    color: Colors.blue,
                                    size: AppConstants.iconMd,
                                  ),
                                  SizedBox(width: 4),
                                  Text('200mm'),
                                ],
                              ),
                              SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(
                                    Icons.thermostat,
                                    color: Colors.orange,
                                    size: AppConstants.iconMd,
                                  ),
                                  SizedBox(width: 4),
                                  Text('34°C'),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: AppConstants.buttonSm,
                            child: ElevatedButton(
                              onPressed: () {},
                              child: const Text('GET WEATHER'),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                      title: const Text('Ho Chi Minh'),
                      titleTextStyle: Theme.of(context).textTheme.titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                      contentPadding: const EdgeInsets.only(
                        left: AppConstants.paddingMd,
                      ),
                      subtitle: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(top: 3),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade500,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.grey.shade600),
                          ),
                          child: Text(
                            'Fake',
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      trailing: PopupMenuButton<WeatherClientAction>(
                        onSelected: (WeatherClientAction item) {
                          switch (item) {
                            case WeatherClientAction.edit:
                              context.goEditWeatherClient(
                                '68de7e98ae6796d18a268a31',
                              );
                              break;
                            default:
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<WeatherClientAction>>[
                              const PopupMenuItem<WeatherClientAction>(
                                value: WeatherClientAction.edit,
                                child: ListTile(
                                  leading: Icon(Icons.edit_square),
                                  title: Text('Edit'),
                                  iconColor: Colors.blue,
                                ),
                              ),
                              const PopupMenuItem<WeatherClientAction>(
                                value: WeatherClientAction.remove,
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
                          const Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_rounded,
                                  color: Colors.red,
                                  size: AppConstants.iconMd,
                                ),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Can\'t get weather data',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 15),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: AppConstants.buttonSm,
                            child: ElevatedButton(
                              onPressed: () {},
                              child: const Text('GET WEATHER'),
                            ),
                          ),
                        ],
                      ),
                    ),
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
