import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/inputs/app_labeled_input.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';
import '../../../zone/domain/entities/zone_entity.dart';
import '../../domain/entities/plant_entity.dart';
import '../providers/plant_provider.dart';

class AddPlantScreen extends ConsumerStatefulWidget {
  const AddPlantScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends ConsumerState<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _timeToHarvest;
  late final TextEditingController _description;
  late final TextEditingController _notes;
  late final TextEditingController _quantity;

  @override
  void initState() {
    _name = TextEditingController();
    _timeToHarvest = TextEditingController();
    _description = TextEditingController();
    _notes = TextEditingController();
    _quantity = TextEditingController();
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

  void _onAdd() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(plantProvider.notifier)
        .addPlant(
          PlantEntity(
            name: _name.text,
            zone: const ZoneEntity(id: 'zone-id-placeholder'),
            details: PlantDetailEntity(
              timeToHarvest: _timeToHarvest.text,
              description: _description.text,
              notes: _notes.text,
              count: int.tryParse(_quantity.text),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(plantProvider.select((state) => state.isCreatingPlant), (
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
      if (previous?.isCreatingPlant == true && next.isCreatingPlant == false) {
        if (next.errCreatingPlant.isNotEmpty) {
          EasyLoading.showError(next.errCreatingPlant);
        } else {
          EasyLoading.showSuccess(next.responseMsg ?? 'Plant added');
          context.goBack();
        }
      }
    });
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(title: const Text('Add Plant'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Plant name', controller: _name),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Garden',
                      controller: TextEditingController(text: 'Front Yard'),
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      'Zone',
                      controller: TextEditingController(text: 'Shrubs'),
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                'Description',
                controller: _description,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              _buildTextField('Time to harvest', controller: _timeToHarvest),
              const SizedBox(height: 12),
              _buildTextField('Quantity', controller: _quantity),
              const SizedBox(height: 12),
              _buildTextField(
                'Notes',
                controller: _notes,
                maxLines: 3,
                required: false,
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
          child: ElevatedButton(onPressed: _onAdd, child: const Text('Save')),
        ),
      ),
    );
  }

  // Widget tạo Label và TextField
  Widget _buildTextField(
    String label, {
    bool? required = true,
    TextEditingController? controller,
    int? maxLines,
    bool? readOnly = false,
  }) {
    return LabeledInput(
      label: label,
      child: TextFormField(
        controller: controller,
        validator: required! ? AppValidators.required : null,
        textInputAction: TextInputAction.next,
        maxLines: maxLines,
        readOnly: readOnly!,
      ),
    );
  }
}
