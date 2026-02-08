import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/build_context_extentions.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';
import '../../domain/entities/weather_client_entity.dart';
import '../../domain/usecases/get_all_weather_clients.dart';
import '../providers/weather_client_provider.dart';

enum WeatherClientAction { edit, delete }

enum WeatherClientType { netatmo, fake }

class WeatherClientScreen extends ConsumerStatefulWidget {
  const WeatherClientScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _WeatherClientScreenState();
}

class _WeatherClientScreenState extends ConsumerState<WeatherClientScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(weatherClientProvider).weatherClients.isEmpty) {
        ref
            .read(weatherClientProvider.notifier)
            .getAllWeatherClients(GetAllWeatherClientsParams());
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
    final weatherClientState = ref.watch(weatherClientProvider);

    ref.listen(
      weatherClientProvider.select((state) => state.isLoadingWeather),
      (previousLoading, nextLoading) {
        if (nextLoading == true) {
          EasyLoading.show(status: 'Loading...');
        } else if (nextLoading == false && previousLoading == true) {
          EasyLoading.dismiss();
        }
      },
    );

    ref.listen(weatherClientProvider.select((state) => state.isDeletingWC), (
      previousLoading,
      nextLoading,
    ) {
      if (nextLoading == true) {
        EasyLoading.show(status: 'Loading...');
      } else if (nextLoading == false && previousLoading == true) {
        EasyLoading.dismiss();
      }
    });

    ref.listen(weatherClientProvider, (previous, next) async {
      if (previous?.isDeletingWC == true && next.isDeletingWC == false) {
        if (next.errDeletingWC.isNotEmpty) {
          EasyLoading.showError(next.errDeletingWC);
        } else {
          EasyLoading.showSuccess(next.responseMsg ?? 'Weather client deleted');
          // refresh list
        }
      }
    });
    return RefreshIndicator(
      onRefresh: () async {
        ref
            .read(weatherClientProvider.notifier)
            .getAllWeatherClients(GetAllWeatherClientsParams());
      },
      child: SafeArea(
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                scrolledUnderElevation: 0,
                floating: true,
                pinned: false,
                centerTitle: false,
                title: const Text('Weather Client'),
                titleTextStyle: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                // backgroundColor: Colors.white,
                leadingWidth: 120,
                actions: [
                  IconButton.filled(
                    onPressed: () {
                      context.goNotificationClients();
                    },
                    icon: const Icon(Icons.notification_add_rounded),
                    color: AppColors.primary,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary100,
                    ),
                  ),
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
                sliver: _buildSliverContent(weatherClientState),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 150)),
            ],
          ),
        ),
      ),
    );
  }

  // Tách hàm để quản lý logic Sliver dễ hơn
  Widget _buildSliverContent(WeatherClientState weatherClientState) {
    if (weatherClientState.isLoadingWCs) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (weatherClientState.errLoadingWCs.isNotEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text(weatherClientState.errLoadingWCs)),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final wc = weatherClientState.weatherClients[index];
        return WeatherClientItem(
          wc: wc,
          fetchWeatherData: () {
            ref.read(weatherClientProvider.notifier).getWeatherData(wc.id!);
          },
          onDelete: () {
            ref
                .read(weatherClientProvider.notifier)
                .deleteWeatherClient(wc.id!);
          },
        );
      }, childCount: weatherClientState.weatherClients.length),
    );
  }
}

class WeatherClientItem extends StatelessWidget {
  final WeatherClientEntity wc;
  final VoidCallback fetchWeatherData;
  final VoidCallback? onDelete;
  const WeatherClientItem({
    super.key,
    required this.wc,
    required this.fetchWeatherData,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMd),
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
            title: Text(wc.name ?? ""),
            titleTextStyle: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            contentPadding: const EdgeInsets.only(left: AppConstants.paddingMd),
            subtitle: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(top: 3),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: wc.type == WeatherClientType.netatmo.name
                      ? Colors.yellow.shade700
                      : Colors.grey.shade500,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: wc.type == WeatherClientType.netatmo.name
                        ? Colors.yellow.shade800
                        : Colors.grey.shade600,
                  ),
                ),
                child: Text(
                  wc.type ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(color: Colors.white),
                ),
              ),
            ),
            trailing: PopupMenuButton<WeatherClientAction>(
              onSelected: (WeatherClientAction item) {
                switch (item) {
                  case WeatherClientAction.edit:
                    context.goEditWeatherClient(wc.id!, wc);
                    break;
                  case WeatherClientAction.delete:
                    context.showConfirmDialog(
                      title: 'Delete Weather Client',
                      content:
                          'Are you sure you want to delete the weather client "${wc.name}"?',
                      confirmText: 'Delete',
                      confirmColor: AppColors.error,
                      onConfirm: onDelete,
                    );
                    break;
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
                      value: WeatherClientAction.delete,
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
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (wc.error == null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.thermostat,
                            color: Colors.orange,
                            size: AppConstants.iconMd,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${wc.latestWeatherData?.temperature?.celsius?.toStringAsFixed(1) ?? '-'}°C',
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.water_drop_outlined,
                            color: Colors.blue,
                            size: AppConstants.iconMd,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${wc.latestWeatherData?.rain?.mm?.toStringAsFixed(1) ?? '-'} mm',
                          ),
                        ],
                      ),
                    ],
                  ),
                if (wc.latestWeatherData == null && wc.error != null)
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_rounded,
                          color: Colors.red,
                          size: AppConstants.iconMd,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            wc.error ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 15),
                      ],
                    ),
                  ),
                SizedBox(
                  height: AppConstants.buttonSm,
                  child: ElevatedButton(
                    onPressed: fetchWeatherData,
                    child: const Text('GET WEATHER'),
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
