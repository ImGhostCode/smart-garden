import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/theme/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state to get current user
    // final authState = ref.watch(authProvider);
    // final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
            style: IconButton.styleFrom(backgroundColor: AppColors.primary100),
          ),
          IconButton.filled(
            onPressed: () {
              context.push(AppConstants.settingsRoute);
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
                  children: [
                    _buildHeader(context),
                    _buildGridContent(context),
                    _buildFooter(),
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
                  children: [
                    _buildHeader(context),
                    _buildGridContent(context),
                    _buildFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tiêu đề: Front yard
  Widget _buildHeader(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const SizedBox(width: 48),
      title: Center(
        child: Text(
          'Front yard',
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
    );
  }

  // Nội dung chính: Các thẻ thông số
  Widget _buildGridContent(BuildContext context) {
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
                  '74%',
                  Icons.air,
                  Colors.teal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Temperature',
                  '23°C',
                  Icons.thermostat,
                  Colors.teal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Connectivity',
                  'Online',
                  Icons.wifi,
                  Colors.teal,
                  isOnline: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildStatusCard(context)),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: _buildStatCard(
                  context,
                  'Light Status',
                  'On',
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
                  fontWeight: FontWeight.bold,
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
  Widget _buildStatusCard(BuildContext context) {
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
            '6 plants growing',
          ),
          const SizedBox(height: 8),
          _buildStatusItem(context, Icons.explore_outlined, '2 Zones'),
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
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Tooltip(
            triggerMode: TooltipTriggerMode.tap,
            message: 'Topic prefix: front-yard',
            child: Icon(Icons.info_rounded, color: Colors.blue),
          ),
          SizedBox(
            height: AppConstants.buttonSm,
            child: ElevatedButton(
              onPressed: () {},
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
