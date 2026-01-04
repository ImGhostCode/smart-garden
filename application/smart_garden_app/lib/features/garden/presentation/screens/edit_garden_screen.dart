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
import '../providers/garden_provider.dart';

class EditGardenScreen extends ConsumerStatefulWidget {
  final String gardenId;
  const EditGardenScreen({super.key, required this.gardenId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditGardenScreenState();
}

class _EditGardenScreenState extends ConsumerState<EditGardenScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _topicPrefixController;
  late final TextEditingController _maxZonesController;
  late final TextEditingController _hourController;
  late final TextEditingController _minuteController;
  late final TextEditingController _lightPinController;
  late final TextEditingController _sensorPinController;
  late final TextEditingController _intervalController;
  // We use lists of TextEditingControllers to manage the state of each input field.
  final List<TextEditingController> _valveControllers = [];
  final List<TextEditingController> _pumpControllers = [];

  // Local State
  String? _lsDuration;
  bool isSensorEnabled = true;

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
    _lightPinController = TextEditingController();
    _sensorPinController = TextEditingController();
    _intervalController = TextEditingController();

    // Generate hours 1-24 once
    _durationHours = List.generate(24, (index) => index + 1);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(gardenProvider.notifier)
          .getGardenById(id: widget.gardenId);
      final gardenState = ref.read(gardenProvider);
      final garden = gardenState.garden;
      if (garden != null) {
        _nameController.text = garden.name ?? '';
        _topicPrefixController.text = garden.topicPrefix ?? '';
        _maxZonesController.text = garden.maxZones?.toString() ?? '';
        // Light Schedule
        if (garden.lightSchedule != null) {
          final ls = garden.lightSchedule!;
          _lsDuration = Duration(
            milliseconds: garden.lightSchedule?.durationMs ?? 0,
          ).inHours.toString();
          final timeParts = ls.startTime?.split(':') ?? [];
          if (timeParts.length >= 2) {
            _hourController.text = timeParts[0];
            _minuteController.text = timeParts[1];
          }
          _lightPinController.text =
              garden.controllerConfig?.lightPin?.toString() ?? '';
        }
        // Sensor
        if (garden.controllerConfig?.tempHumidityPin != null) {
          isSensorEnabled = true;
          _sensorPinController.text =
              garden.controllerConfig!.tempHumidityPin?.toString() ?? '';
          _intervalController.text = AppUtils.msToDurationString(
            garden.controllerConfig!.tempHumIntervalMs,
          );
        } else {
          isSensorEnabled = false;
        }

        // Valves and Pumps
        final valvePins = garden.controllerConfig?.valvePins ?? [];
        final pumpPins = garden.controllerConfig?.pumpPins ?? [];
        for (var pin in valvePins) {
          final controller = TextEditingController(text: pin.toString());
          _valveControllers.add(controller);
        }
        for (var pin in pumpPins) {
          final controller = TextEditingController(text: pin.toString());
          _pumpControllers.add(controller);
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _topicPrefixController.dispose();
    _maxZonesController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    // Always dispose controllers to free memory
    for (var controller in _valveControllers) {
      controller.dispose();
    }
    for (var controller in _pumpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addZone() {
    setState(() {
      _valveControllers.add(TextEditingController());
      _pumpControllers.add(TextEditingController());
    });
  }

  void _removeZone(int index) {
    setState(() {
      _valveControllers[index].dispose();
      _valveControllers.removeAt(index);
      _pumpControllers[index].dispose();
      _pumpControllers.removeAt(index);
    });
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(gardenProvider.notifier)
        .editGarden(
          GardenEntity(
            id: widget.gardenId,
            name: _nameController.text,
            topicPrefix: _topicPrefixController.text,
            maxZones: int.parse(_maxZonesController.text),
            // Add other fields as necessary
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final gardenState = ref.watch(gardenProvider);
    ref.listen(gardenProvider.select((state) => state.isEditingGarden), (
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
      if (previous?.isEditingGarden == true && next.isEditingGarden == false) {
        if (next.errEditingGarden.isNotEmpty) {
          EasyLoading.showError(next.errEditingGarden);
        } else {
          EasyLoading.showSuccess(next.responseMsg ?? 'Garden edited');
          context.goBack();
        }
      }
    });
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(title: const Text('Edit Garden'), centerTitle: true),
      body: gardenState.isLoadingGarden
          ? const Center(child: CircularProgressIndicator())
          : gardenState.errLoadingGarden.isNotEmpty
          ? Center(child: Text(gardenState.errLoadingGarden))
          : gardenState.garden != null
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingMd),
              child: Form(
                key: _formKey,
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
                        validator: AppValidators.required,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LabeledInput(
                      label: 'Max zones',
                      child: TextFormField(
                        controller: _maxZonesController,
                        keyboardType: TextInputType.number,
                        validator: AppValidators.required,
                        textInputAction: TextInputAction.next,
                      ),
                    ),

                    // --- Light Schedule ---
                    const SizedBox(height: 12),
                    const Text(
                      'Light schedule',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: LabeledInput(
                            label: 'Light Pin',
                            child: TextFormField(
                              controller: _lightPinController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: LabeledInput(
                            label: 'Duration',
                            child: DropdownButtonFormField<String>(
                              menuMaxHeight:
                                  MediaQuery.sizeOf(context).height * 0.5,
                              value: _lsDuration,
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
                                setState(() {
                                  _lsDuration = value;
                                });
                              },
                              validator:
                                  _lightPinController.text.trim().isNotEmpty
                                  ? AppValidators.required
                                  : null,
                              decoration: const InputDecoration(
                                hintText: 'Select',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                                  ? AppValidators.required
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
                                  ? AppValidators.required
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Sensor',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Temperature/Humidity sensor'),
                      value: isSensorEnabled,
                      onChanged: (val) =>
                          setState(() => isSensorEnabled = val!),
                      controlAffinity: ListTileControlAffinity.leading,
                      // activeColor: Colors.deepSubtitlePurple, // Màu tím giống trong ảnh
                    ),
                    const SizedBox(height: 8),
                    if (isSensorEnabled)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: LabeledInput(
                              label: 'Sensor Pin',
                              child: TextFormField(
                                controller: _sensorPinController,
                                keyboardType: TextInputType.number,
                                validator: AppValidators.required,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: LabeledInput(
                              label: 'Interval',
                              child: TextFormField(
                                controller: _intervalController,
                                keyboardType: TextInputType.number,
                                validator: AppValidators.combine([
                                  AppValidators.required,
                                  AppValidators.durationFormat,
                                ]),
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (isSensorEnabled) const SizedBox(height: 12),

                    const Text(
                      'Valve pins',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // === Valve Section ===
                    PinSectionCard(
                      controllers: _valveControllers,
                      onAddPressed: _addZone,
                      onRemovePressed: _removeZone,
                    ),
                    const SizedBox(height: 12),
                    // === Pump Section ===
                    const Text(
                      'Valve pins',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    PinSectionCard(
                      controllers: _pumpControllers,
                      onAddPressed: _addZone,
                      onRemovePressed: _removeZone,
                      accentColor: Colors.blue[700]!,
                    ),
                    const SizedBox(height: 150),
                  ],
                ),
              ),
            )
          : const Center(child: Text('No garden data found.')),
      bottomSheet:
          gardenState.isLoadingGarden == true ||
              gardenState.errLoadingGarden.isNotEmpty
          ? null
          : Container(
              color: Colors.white,
              padding: const EdgeInsets.all(AppConstants.paddingMd),
              child: SizedBox(
                width: double.infinity,
                height: AppConstants.buttonMd,
                child: ElevatedButton(
                  onPressed: _onSave,
                  child: const Text('Save'),
                ),
              ),
            ),
    );
  }
}

class PinSectionCard extends StatelessWidget {
  final List<TextEditingController> controllers;
  final VoidCallback onAddPressed;
  final Function(int index) onRemovePressed;
  final Color accentColor;

  const PinSectionCard({
    super.key,
    required this.controllers,
    required this.onAddPressed,
    required this.onRemovePressed,
    this.accentColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controllers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return PinEntryRow(
              index: index,
              controller: controllers[index],
              onDelete: () => onRemovePressed(index),
            );
          },
        ),

        const SizedBox(height: 12),

        // The Add Button Footer
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onAddPressed,
            icon: const Icon(Icons.add),
            label: const Text("Add Zone"),
          ),
        ),
      ],
    );
  }
}

class PinEntryRow extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final VoidCallback onDelete;

  const PinEntryRow({
    super.key,
    required this.index,
    required this.controller,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Zone Label
        SizedBox(width: 70, child: Text("Zone ${index + 1}")),
        const SizedBox(width: 8),
        // Input Field
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            validator: AppValidators.required,
          ),
        ),
        const SizedBox(width: 6),
        // Delete Button
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          color: Colors.red[400],
        ),
      ],
    );
  }
}
