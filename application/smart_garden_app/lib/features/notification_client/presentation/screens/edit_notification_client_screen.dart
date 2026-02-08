import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/inputs/app_labeled_input.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';
import '../../domain/entities/notification_client_entity.dart';
import '../../domain/usecases/get_all_notification_clients.dart';
import '../providers/notification_client_provider.dart';
import 'new_notification_client_screen.dart' show clientTypes;

class EditNotificationClientScreen extends ConsumerStatefulWidget {
  final String clientId;
  final NotificationClientEntity nc;
  const EditNotificationClientScreen({
    super.key,
    required this.clientId,
    required this.nc,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditNotificationClientScreenState();
}

class _EditNotificationClientScreenState
    extends ConsumerState<EditNotificationClientScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _type = clientTypes.first.value;
  late final TextEditingController _name;
  late final TextEditingController _user;
  late final TextEditingController _token;
  late final TextEditingController _deviceName;
  late final TextEditingController _createError;
  late final TextEditingController _sendMessageError;

  @override
  void initState() {
    _name = TextEditingController();
    _user = TextEditingController();
    _token = TextEditingController();
    _deviceName = TextEditingController();
    _createError = TextEditingController();
    _sendMessageError = TextEditingController();

    final nc = widget.nc;
    _name.text = nc.name ?? '';
    _type = clientTypes
        .firstWhere(
          (ct) => ct.value.toLowerCase() == nc.type?.toLowerCase(),
          orElse: () => clientTypes.first,
        )
        .value;
    if (nc.options != null) {
      final options = nc.options!;
      // Netatmo fields
      if (nc.type == "pushover") {
        _user.text = options.user ?? '';
        _token.text = options.token ?? '';
        _deviceName.text = options.deviceName ?? '';
      } else if (nc.type == "fake") {
        // Fake fields
        _createError.text = options.createError ?? '';
        _sendMessageError.text = options.sendMessageError ?? '';
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _user.dispose();
    _token.dispose();
    _deviceName.dispose();
    _createError.dispose();
    _sendMessageError.dispose();
    EasyLoading.dismiss();
    super.dispose();
  }

  void _onEdit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(notiClientProvider.notifier)
        .editNotificationClient(
          NotificationClientEntity(
            id: widget.clientId,
            name: _name.text,
            type: _type!,
            // Netatmo fields
            options: _type! == "pushover"
                ? OptionEntity(
                    user: _user.text,
                    token: _token.text,
                    deviceName: _deviceName.text,
                  )
                // Fake fields
                : _type! == "fake"
                ? OptionEntity(
                    createError: _createError.text,
                    sendMessageError: _sendMessageError.text,
                  )
                : null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(notiClientProvider.select((state) => state.isEditingNC), (
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
      if (previous?.isEditingNC == true && next.isEditingNC == false) {
        if (next.errEditingNC.isNotEmpty) {
          EasyLoading.showError(next.errEditingNC);
        } else {
          EasyLoading.showSuccess(
            next.responseMsg ?? 'Notification Client edited',
          );
          ref
              .read(notiClientProvider.notifier)
              .getAllNotificationClients(GetAllNotificationClientsParams());
          context.goBack();
        }
      }
    });
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Edit Notification Client'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMd),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabeledInput(
                label: 'Client Name',
                child: TextFormField(
                  controller: _name,
                  validator: AppValidators.required,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 12),
              LabeledInput(
                label: 'Type',
                child: DropdownButtonFormField<String>(
                  value: _type,
                  menuMaxHeight: MediaQuery.sizeOf(context).height * 0.5,
                  items: clientTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type.value,
                      child: Text(type.label),
                    );
                  }).toList(),
                  validator: AppValidators.required,
                  // onChanged: (value) => setState(() => _type = value),
                  onChanged: null,
                  decoration: const InputDecoration(hintText: 'Select'),
                ),
              ),
              const SizedBox(height: 12),
              if (_type == "pushover")
                Column(
                  key: const ValueKey("Netatmo_Fields"),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabeledInput(
                      label: 'User key',
                      child: TextFormField(
                        controller: _user,
                        validator: AppValidators.required,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LabeledInput(
                      label: 'App token',
                      child: TextFormField(
                        controller: _token,
                        validator: AppValidators.required,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LabeledInput(
                      label: 'Device name',
                      child: TextFormField(
                        controller: _deviceName,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              if (_type == "fake")
                Column(
                  key: const ValueKey("Fake_Fields"),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabeledInput(
                      label: 'Create error',
                      child: TextFormField(
                        controller: _createError,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LabeledInput(
                      label: 'Send message error',
                      child: TextFormField(
                        controller: _sendMessageError,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 150),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(AppConstants.paddingMd),
        child: SizedBox(
          width: double.infinity,
          height: AppConstants.buttonMd,
          child: ElevatedButton(onPressed: _onEdit, child: const Text('Save')),
        ),
      ),
    );
  }
}
