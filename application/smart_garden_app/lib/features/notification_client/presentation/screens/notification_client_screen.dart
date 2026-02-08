import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/inputs/app_labeled_input.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/extensions/build_context_extentions.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';
import '../../domain/entities/notification_client_entity.dart';
import '../../domain/usecases/get_all_notification_clients.dart';
import '../../domain/usecases/send_notification.dart';
import '../providers/notification_client_provider.dart';

enum NotificationClientAction { edit, delete }

enum NotificationClientType { pushover, fake }

class NotificationClientScreen extends ConsumerStatefulWidget {
  const NotificationClientScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotificationClientScreenState();
}

class _NotificationClientScreenState
    extends ConsumerState<NotificationClientScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(notiClientProvider).notiClients.isEmpty) {
        ref
            .read(notiClientProvider.notifier)
            .getAllNotificationClients(GetAllNotificationClientsParams());
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
    final notiClientState = ref.watch(notiClientProvider);

    ref.listen(notiClientProvider.select((state) => state.isSendingNoti), (
      previousLoading,
      nextLoading,
    ) {
      if (nextLoading == true) {
        EasyLoading.show(status: 'Loading...');
      } else if (nextLoading == false && previousLoading == true) {
        EasyLoading.dismiss();
      }
    });

    ref.listen(notiClientProvider.select((state) => state.isDeletingNC), (
      previousLoading,
      nextLoading,
    ) {
      if (nextLoading == true) {
        EasyLoading.show(status: 'Loading...');
      } else if (nextLoading == false && previousLoading == true) {
        EasyLoading.dismiss();
      }
    });

    ref.listen(notiClientProvider, (previous, next) async {
      if (previous?.isSendingNoti == true && next.isSendingNoti == false) {
        if (next.errSendingNoti.isNotEmpty) {
          EasyLoading.showError(next.errSendingNoti);
        } else {
          EasyLoading.showSuccess(next.responseMsg ?? 'Notification sent');
          // refresh list
        }
      }
    });
    ref.listen(notiClientProvider, (previous, next) async {
      if (previous?.isDeletingNC == true && next.isDeletingNC == false) {
        if (next.errDeletingNC.isNotEmpty) {
          EasyLoading.showError(next.errDeletingNC);
        } else {
          EasyLoading.showSuccess(
            next.responseMsg ?? 'Notification client deleted',
          );
          ref
              .read(notiClientProvider.notifier)
              .getAllNotificationClients(GetAllNotificationClientsParams());
        }
      }
    });
    return RefreshIndicator(
      onRefresh: () async {
        ref
            .read(notiClientProvider.notifier)
            .getAllNotificationClients(GetAllNotificationClientsParams());
      },
      child: SafeArea(
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                scrolledUnderElevation: 0,
                floating: true,
                pinned: false,
                centerTitle: true,
                title: const Text('Notification Client'),
                titleTextStyle: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                // backgroundColor: Colors.white,
                // leadingWidth: 120,
                actions: [
                  TextButton.icon(
                    onPressed: () {
                      context.goNewNotificationClient();
                    },
                    // icon: const Icon(Icons.add_circle_rounded),
                    label: const Text('New'),
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
                sliver: _buildSliverContent(notiClientState),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 150)),
            ],
          ),
        ),
      ),
    );
  }

  // Tách hàm để quản lý logic Sliver dễ hơn
  Widget _buildSliverContent(NotificationClientState notiClientState) {
    if (notiClientState.isLoadingNCs) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (notiClientState.errLoadingNCs.isNotEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text(notiClientState.errLoadingNCs)),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final nc = notiClientState.notiClients[index];
        return NotificationClientItem(
          nc: nc,
          onSend: (title, message) {
            ref
                .read(notiClientProvider.notifier)
                .sendNotification(
                  SendNotificationParams(
                    id: nc.id!,
                    title: title,
                    message: message,
                  ),
                );
          },
          onDelete: () {
            ref
                .read(notiClientProvider.notifier)
                .deleteNotificationClient(nc.id!);
          },
        );
      }, childCount: notiClientState.notiClients.length),
    );
  }
}

class NotificationClientItem extends StatelessWidget {
  final NotificationClientEntity nc;
  final Function(String, String) onSend;
  final VoidCallback? onDelete;
  const NotificationClientItem({
    super.key,
    required this.nc,
    required this.onSend,
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
            title: Text(nc.name ?? ""),
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
                  color: nc.type == NotificationClientType.pushover.name
                      ? Colors.blue.shade600
                      : Colors.grey.shade500,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: nc.type == NotificationClientType.pushover.name
                        ? Colors.blue.shade700
                        : Colors.grey.shade600,
                  ),
                ),
                child: Text(
                  nc.type ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(color: Colors.white),
                ),
              ),
            ),
            trailing: PopupMenuButton<NotificationClientAction>(
              onSelected: (NotificationClientAction item) {
                switch (item) {
                  case NotificationClientAction.edit:
                    context.goEditNotificationClient(nc.id!, nc);
                    break;
                  case NotificationClientAction.delete:
                    context.showConfirmDialog(
                      title: 'Delete Notification Client',
                      content:
                          'Are you sure you want to delete the notification client "${nc.name}"?',
                      confirmText: 'Delete',
                      confirmColor: AppColors.error,
                      onConfirm: onDelete,
                    );
                    break;
                }
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<NotificationClientAction>>[
                    const PopupMenuItem<NotificationClientAction>(
                      value: NotificationClientAction.edit,
                      child: ListTile(
                        leading: Icon(Icons.edit_square),
                        title: Text('Edit'),
                        iconColor: Colors.blue,
                      ),
                    ),
                    const PopupMenuItem<NotificationClientAction>(
                      value: NotificationClientAction.delete,
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
                const SizedBox.shrink(),
                SizedBox(
                  height: AppConstants.buttonSm,
                  child: ElevatedButton(
                    onPressed: () {
                      showSendingNotiDialog(context: context, onSend: onSend);
                    },
                    child: const Text('Send notification'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showSendingNotiDialog({
    required BuildContext context,
    required Function(String, String) onSend,
  }) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Send notification',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMd,
                    ),
                    child: LabeledInput(
                      label: 'Title',
                      child: TextFormField(
                        controller: titleController,
                        validator: AppValidators.required,
                        textInputAction: TextInputAction.done,
                        maxLines: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMd,
                    ),
                    child: LabeledInput(
                      label: 'Message',
                      child: TextFormField(
                        controller: messageController,
                        validator: AppValidators.required,
                        textInputAction: TextInputAction.newline,
                        maxLines: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMd),
                    child: SizedBox(
                      height: AppConstants.buttonMd,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            onSend(
                              titleController.text,
                              messageController.text,
                            );
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
