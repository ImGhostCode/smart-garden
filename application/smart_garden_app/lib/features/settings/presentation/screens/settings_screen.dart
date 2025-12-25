import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMd),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: AppConstants.paddingMd),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 3),
                      blurRadius: 5,
                      spreadRadius: 2,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
                child: ListTile(
                  tileColor: AppColors.primary,
                  leading: Image.asset(Assets.farmer),
                  horizontalTitleGap: 15,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome!',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium!.copyWith(color: Colors.white),
                      ),
                      Text(
                        'John',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMd,
                    vertical: AppConstants.paddingSm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  trailing: IconButton(
                    onPressed: () async {
                      // Show confirmation dialog
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text(
                            'Are you sure you want to logout?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );

                      // Logout if user confirmed
                      if (shouldLogout == true) {
                        await ref.read(authProvider.notifier).logout();

                        if (!context.mounted) return;
                        if (ref.read(authProvider).errorMessage != null) {
                          if (context.mounted) {
                            AppUtils.showSnackBar(
                              context,
                              message: ref.read(authProvider).errorMessage!,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                            );
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.logout_rounded),
                    color: Colors.white,
                    iconSize: AppConstants.iconLg,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingMd),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                      spreadRadius: 2,
                      color: Colors.grey.shade200,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      onTap: () {},
                      minTileHeight: 45,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        'Account',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ListTile(
                      minTileHeight: 45,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        'Notifications',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ListTile(
                      minTileHeight: 45,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.settings_outlined,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        'Settings',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ListTile(
                      minTileHeight: 45,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.policy_outlined,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        'Privacy Policy',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ListTile(
                      minTileHeight: 45,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.help_outline,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        'Help',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
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
