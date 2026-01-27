import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/inputs/app_labeled_input.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';
import '../../domain/entities/garden_entity.dart';
import '../../domain/usecases/get_all_gardens.dart';
import '../providers/garden_provider.dart';

class CreateGardenScreen extends ConsumerStatefulWidget {
  const CreateGardenScreen({super.key});

  @override
  ConsumerState<CreateGardenScreen> createState() => _CreateGardenScreenState();
}

class _CreateGardenScreenState extends ConsumerState<CreateGardenScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _topicPrefixController;
  late final TextEditingController _maxZonesController;
  late final TextEditingController _hourController;
  late final TextEditingController _minuteController;

  // Local State
  String? _lsDuration;

  // Data Sources
  late final List<int> _durationHours;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _topicPrefixController = TextEditingController();
    _maxZonesController = TextEditingController();
    _hourController = TextEditingController();
    _minuteController = TextEditingController();

    // Generate hours 1-24 once
    _durationHours = List.generate(24, (index) => index + 1);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _topicPrefixController.dispose();
    _maxZonesController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    EasyLoading.dismiss();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    String? startTime = _lsDuration == null
        ? null
        : '${_hourController.text.padLeft(2, '0')}:${_minuteController.text.padLeft(2, '0')}:00';
    startTime = AppUtils.toUtcTime(startTime);
    ref
        .read(gardenProvider.notifier)
        .createGarden(
          GardenEntity(
            name: _nameController.text,
            topicPrefix: _topicPrefixController.text,
            maxZones: int.parse(_maxZonesController.text),
            lightSchedule: _lsDuration != null
                ? LightScheduleEntity(
                    durationMs: AppUtils.durationToMs(_lsDuration!),
                    startTime: startTime,
                  )
                : null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(gardenProvider.select((state) => state.isCreatingGarden), (
      previousLoading,
      nextLoading,
    ) {
      if (nextLoading == true) {
        EasyLoading.show(status: 'Loading...');
      } else if (nextLoading == false && previousLoading == true) {
        EasyLoading.dismiss();
      }
    });

    ref.listen(gardenProvider, (previous, next) async {
      if (previous?.isCreatingGarden == true &&
          next.isCreatingGarden == false) {
        if (next.errCreatingGarden.isNotEmpty) {
          EasyLoading.showError(next.errCreatingGarden);
        } else {
          EasyLoading.showSuccess(next.responseMsg ?? 'Garden created');
          ref.read(gardenProvider.notifier).getAllGarden(GetAllGardenParams());
          context.goBack();
        }
      }
    });
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(title: const Text('Create Garden'), centerTitle: true),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Basic Info ---
                LabeledInput(
                  label: 'Garden name',
                  child: TextFormField(
                    controller: _nameController,
                    validator: AppValidators.required,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(height: 12),
                LabeledInput(
                  label: 'Topic prefix',
                  child: TextFormField(
                    controller: _topicPrefixController,
                    validator: AppValidators.combine([
                      AppValidators.required,
                      AppValidators.validTopic,
                    ]),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(height: 12),
                LabeledInput(
                  label: 'Max zones',
                  child: TextFormField(
                    controller: _maxZonesController,
                    keyboardType: TextInputType.number,
                    validator: AppValidators.combine([
                      AppValidators.required,
                      AppValidators.positiveInt,
                    ]),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(height: 12),

                // --- Light Schedule ---
                const Text(
                  'Light schedule',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  menuMaxHeight: MediaQuery.sizeOf(context).height * 0.5,
                  items: _durationHours
                      .map(
                        (i) => DropdownMenuItem(
                          value: '$i',
                          child: Text('$i hours'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _lsDuration = '${value}h');
                  },
                  decoration: const InputDecoration(
                    hintText: 'Select duration',
                  ),
                ),
                const SizedBox(height: 12),

                // --- Light Start Time & Timezone ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: LabeledInput(
                        label: 'Hour',
                        child: TextFormField(
                          controller: _hourController,
                          keyboardType: TextInputType.number,
                          validator: _lsDuration != null
                              ? AppValidators.combine([
                                  AppValidators.required,
                                  AppValidators.validHour,
                                ])
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LabeledInput(
                        label: 'Minute',
                        child: TextFormField(
                          controller: _minuteController,
                          keyboardType: TextInputType.number,
                          validator: _lsDuration != null
                              ? AppValidators.combine([
                                  AppValidators.required,
                                  AppValidators.validMinute,
                                ])
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 150),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(AppConstants.paddingMd),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: AppConstants.buttonMd,
            child: ElevatedButton(
              onPressed: _onSave,
              child: const Text('Save'),
            ),
          ),
        ),
      ),
    );
  }
}
