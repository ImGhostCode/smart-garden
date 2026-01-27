import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/inputs/app_labeled_input.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';
import '../../../zone/domain/entities/zone_entity.dart';
import '../../../zone/domain/usecases/get_all_zones.dart';
import '../../../zone/presentation/providers/zone_provider.dart';
import '../../domain/entities/plant_entity.dart';
import '../../domain/usecases/edit_plant.dart';
import '../../domain/usecases/get_all_plants.dart';
import '../providers/plant_provider.dart';

class EditPlantScreen extends ConsumerStatefulWidget {
  final String plantId;
  final PlantEntity plant;
  const EditPlantScreen({
    super.key,
    required this.plantId,
    required this.plant,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditPlantScreenState();
}

class _EditPlantScreenState extends ConsumerState<EditPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _timeToHarvest;
  late final TextEditingController _description;
  late final TextEditingController _notes;
  late final TextEditingController _quantity;
  ZoneEntity? _selectedZone;

  @override
  void initState() {
    _name = TextEditingController();
    _timeToHarvest = TextEditingController();
    _description = TextEditingController();
    _notes = TextEditingController();
    _quantity = TextEditingController();

    _name.text = widget.plant.name ?? '';
    _timeToHarvest.text = widget.plant.details?.timeToHarvest ?? '';
    _description.text = widget.plant.details?.description ?? '';
    _notes.text = widget.plant.details?.notes ?? '';
    _quantity.text = widget.plant.details?.count?.toString() ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(zoneProvider.notifier)
          .getAllZone(GetAllZoneParams(gardenId: widget.plant.garden?.id));
      setState(() {
        _selectedZone = ref
            .read(zoneProvider)
            .zones
            .where((zone) => zone.id == widget.plant.zone?.id)
            .firstOrNull;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _timeToHarvest.dispose();
    _description.dispose();
    _notes.dispose();
    _quantity.dispose();
    EasyLoading.dismiss();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(plantProvider.notifier)
        .editPlant(
          EditPlantParams(
            gardenId: widget.plant.garden?.id,
            plantId: widget.plantId,
            plant: PlantEntity(
              name: _name.text,
              zone: ZoneEntity(id: _selectedZone?.id),
              details: PlantDetailEntity(
                timeToHarvest: _timeToHarvest.text,
                description: _description.text,
                notes: _notes.text.isEmpty ? null : _notes.text,
                count: int.tryParse(_quantity.text),
              ),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(plantProvider.select((state) => state.isEditingPlant), (
      previousLoading,
      nextLoading,
    ) {
      if (nextLoading == true) {
        EasyLoading.show(status: 'Loading...');
      } else if (nextLoading == false && previousLoading == true) {
        EasyLoading.dismiss();
      }
    });

    ref.listen(plantProvider, (previous, next) async {
      if (previous?.isEditingPlant == true && next.isEditingPlant == false) {
        if (next.errEditingPlant.isNotEmpty) {
          EasyLoading.showError(next.errEditingPlant);
        } else {
          EasyLoading.showSuccess(next.responseMsg ?? 'Plant edited');
          ref
              .read(plantProvider.notifier)
              .getAllPlant(
                GetAllPlantParams(gardenId: widget.plant.garden?.id),
              );
          context.goBack();
        }
      }
    });
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(title: const Text('Edit Plant'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabeledInput(
                label: 'Plant name',
                child: TextFormField(
                  controller: _name,
                  validator: AppValidators.required,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: LabeledInput(
                      label: 'Garden',
                      child: TextFormField(
                        controller: TextEditingController(
                          text: widget.plant.garden?.name ?? 'Unknown Garden',
                        ),
                        readOnly: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LabeledInput(
                      label: 'Zone',
                      child: DropdownButtonFormField<ZoneEntity>(
                        validator: AppValidators.required,
                        value: _selectedZone,
                        items: ref.read(zoneProvider).zones.map((zone) {
                          return DropdownMenuItem<ZoneEntity>(
                            value: zone,
                            child: Text(zone.name ?? ''),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedZone = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LabeledInput(
                label: 'Description',
                child: TextFormField(
                  controller: _description,
                  validator: AppValidators.required,
                  textInputAction: TextInputAction.next,
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 12),
              LabeledInput(
                label: 'Time to harvest',
                child: TextFormField(
                  controller: _timeToHarvest,
                  validator: AppValidators.required,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 12),
              LabeledInput(
                label: 'Quantity',
                child: TextFormField(
                  controller: _quantity,
                  validator: AppValidators.combine([
                    AppValidators.required,
                    AppValidators.positiveInt,
                  ]),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 12),
              LabeledInput(
                label: 'Notes',
                child: TextFormField(
                  controller: _notes,
                  textInputAction: TextInputAction.done,
                  maxLines: 3,
                ),
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
          child: ElevatedButton(onPressed: _onSave, child: const Text('Save')),
        ),
      ),
    );
  }
}
