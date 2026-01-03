import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';
import '../../../garden/domain/entities/garden_entity.dart';
import '../../../garden/presentation/providers/garden_provider.dart';

enum GardenAction { edit, remove }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    // if (ref.read(gardenProvider).gardens.isEmpty) {
    //   ref
    //       .read(gardenProvider.notifier)
    //       .getAllGarden(GetAllGardenParams(endDated: false));
    // }
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final gardenState = ref.watch(gardenProvider);

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              scrolledUnderElevation: 0,
              floating: true,
              pinned: false,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leadingWidth: 120,
              leading: Padding(
                padding: const EdgeInsets.only(left: AppConstants.paddingSm),
                child: Image.asset(Assets.logo),
              ),
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
                  onPressed: () => context.goSettings(),
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
                  leading: const Icon(Icons.search_rounded, color: Colors.grey),
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
              sliver: _buildSliverContent(gardenState),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 150)),
          ],
        ),
      ),
    );
  }

  // Tách hàm để quản lý logic Sliver dễ hơn
  Widget _buildSliverContent(GardenState gardenState) {
    if (gardenState.isLoadingGardens) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (gardenState.errLoadingGardens != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text(gardenState.errLoadingGardens!)),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final garden = gardenState.gardens[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppConstants.paddingMd),
          child: InkWell(
            onTap: () => context.goGardenDetail(garden.id!),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.neutral50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context, garden),
                  _buildGridContent(context, garden),
                  _buildFooter(context, garden),
                ],
              ),
            ),
          ),
        );
      }, childCount: gardenState.gardens.length),
    );
  }

  // Tiêu đề: Front yard
  Widget _buildHeader(BuildContext context, GardenEntity garden) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const SizedBox(width: 48),
      title: Center(
        child: Text(
          garden.name ?? "",
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: PopupMenuButton<GardenAction>(
        onSelected: (GardenAction item) {
          switch (item) {
            case GardenAction.edit:
              context.goEditGarden(garden.id!);
              break;
            default:
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<GardenAction>>[
          const PopupMenuItem<GardenAction>(
            value: GardenAction.edit,
            child: ListTile(
              leading: Icon(Icons.edit_square),
              title: Text('Edit'),
              iconColor: Colors.blue,
            ),
          ),
          const PopupMenuItem<GardenAction>(
            value: GardenAction.remove,
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
    );
  }

  // Nội dung chính: Các thẻ thông số
  Widget _buildGridContent(BuildContext context, GardenEntity garden) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMd),
      child: Column(
        children: [
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Humidity',
                  '${garden.tempHumData?.humidityPercentage ?? '- '}%',
                  Icons.air,
                  Colors.teal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Temperature',
                  '${garden.tempHumData?.temperatureCelsius ?? '- '}°C',
                  Icons.thermostat,
                  Colors.teal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Connectivity',
                  garden.health?.status == 'UP' ? 'Online' : 'Offline',
                  Icons.wifi,
                  Colors.teal,
                  isOnline: garden.health?.status == 'UP',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildStatusCard(context, garden)),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: _buildStatCard(
                  context,
                  'Light Status',
                  garden.nextLightAction?.action == "OFF" ? "ON" : "OFF",
                  Icons.lightbulb_outline,
                  Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  // Widget cho các thẻ nhỏ (Humidity, Temperature, Connectivity, Light)
  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isOnline = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withOpacity(0.6), size: 30),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey[800],
                ),
              ),
              if (isOnline) ...[
                const SizedBox(width: 4),
                const Icon(Icons.circle, color: Colors.green, size: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Widget cho thẻ Status (6 plants growing, 2 Zones)
  Widget _buildStatusCard(BuildContext context, GardenEntity garden) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          _buildStatusItem(
            context,
            Icons.local_florist_outlined,
            '${garden.numPlants} plants growing',
          ),
          const SizedBox(height: 8),
          _buildStatusItem(
            context,
            Icons.explore_outlined,
            '${garden.numZones} Zones',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal[300], size: 24),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green[900],
          ),
        ),
      ],
    );
  }

  // Phần chân trang với nút Actions
  Widget _buildFooter(BuildContext context, GardenEntity garden) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Tooltip(
            triggerMode: TooltipTriggerMode.tap,
            message: 'Topic prefix: ${garden.topicPrefix ?? ''}',
            child: const Icon(Icons.info_rounded, color: Colors.blue),
          ),
          SizedBox(
            height: AppConstants.buttonSm,
            child: ElevatedButton(
              onPressed: () {
                showGardenActions(context, garden);
              },
              child: const Text('ACTIONS'),
            ),
          ),
        ],
      ),
    );
  }

  // Định dạng chung cho các Card
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

void showGardenActions(BuildContext context, GardenEntity garden) {
  showModalBottomSheet(
    useRootNavigator: true,
    context: context,
    showDragHandle: true,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Garden Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMd,
            ),
            title: const Text(
              'Lights',
              style: TextStyle(
                color: AppColors.primary700,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "Status: ${garden.nextLightAction?.action == 'OFF' ? 'ON' : 'OFF'}",
            ),
            trailing: Switch(
              value: garden.nextLightAction?.action == 'OFF' ? true : false,
              onChanged: (val) {},
              activeColor: Colors.white,
              activeTrackColor: AppColors.primary,
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMd,
            ),
            title: const Text(
              'Watering',
              style: TextStyle(
                color: AppColors.primary700,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.block,
                size: AppConstants.iconMd,
                color: Colors.white,
              ),
              label: const Text(
                'Stop all',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error, // Màu đỏ/cam nhạt
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    },
  );
}
