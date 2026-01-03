import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/inputs/app_labeled_input.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';
import '../../../garden/domain/usecases/get_all_gardens.dart';
import '../../../garden/presentation/providers/garden_provider.dart';
import '../../domain/entities/water_routine_entity.dart';
import '../providers/water_routine_provider.dart';
import '../providers/water_routine_ui_providers.dart';
import '../widgets/step_selection.dart';

class EditWaterRoutineScreen extends ConsumerStatefulWidget {
  final String waterRoutineId;
  final WaterRoutineEntity waterRoutine;
  const EditWaterRoutineScreen({
    super.key,
    required this.waterRoutineId,
    required this.waterRoutine,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditWaterRoutineScreenState();
}

class _EditWaterRoutineScreenState
    extends ConsumerState<EditWaterRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;

  @override
  void initState() {
    _name = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedWRStepsProvider.notifier).clear();
      ref.read(gardenProvider.notifier).getAllGarden(GetAllGardenParams());
      _name.text = widget.waterRoutine.name ?? '';
      for (var step in widget.waterRoutine.steps ?? []) {
        ref.read(selectedWRStepsProvider.notifier).addStep(step);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    EasyLoading.dismiss();
    super.dispose();
  }

  void _onEdit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(waterRoutineProvider.notifier)
        .editWaterRoutine(
          WaterRoutineEntity(
            name: _name.text,
            steps: ref.read(selectedWRStepsProvider),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final steps = ref.watch(selectedWRStepsProvider);

    ref.listen(waterRoutineProvider.select((state) => state.isEditingWR), (
      previousLoading,
      nextLoading,
    ) {
      if (nextLoading == true) {
        EasyLoading.show(status: 'Loading...');
      } else if (nextLoading == false && previousLoading == true) {
        EasyLoading.dismiss();
      }
    });

    ref.listen(waterRoutineProvider, (previous, next) async {
      if (previous?.isEditingWR == true && next.isEditingWR == false) {
        if (next.errEditingWR != null) {
          EasyLoading.showError(next.errEditingWR ?? 'Error');
        } else {
          EasyLoading.showSuccess(next.responseMsg ?? 'Water Routine edited');
          context.goBack();
        }
      }
    });
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Edit Water Routine'),
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
                label: 'Routine name',
                child: TextFormField(
                  controller: _name,
                  validator: AppValidators.required,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Steps',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: steps.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 8);
                },
                itemBuilder: (context, index) {
                  final step = steps[index];

                  return ListTile(
                    contentPadding: const EdgeInsets.only(
                      left: AppConstants.paddingMd,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMd,
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    title: Text('${index + 1}. ${step.zone?.name}'),
                    titleTextStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _DurationField(step: step),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        ref
                            .read(selectedWRStepsProvider.notifier)
                            .toggleZone(step.zone!);
                      },
                    ),
                  );
                },
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showStepSelection(context);
                  },
                  label: const Text('Add zone'),
                  icon: const Icon(Icons.add),
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
          child: ElevatedButton(
            onPressed: steps.isEmpty ? null : _onEdit,
            child: const Text('Save'),
          ),
        ),
      ),
    );
  }
}

class _DurationField extends ConsumerWidget {
  final StepEntity step;

  const _DurationField({required this.step});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      initialValue: AppUtils.msToDuration(step.durationMs ?? 0),
      decoration: const InputDecoration(hintText: 'e.g., 1h30m'),
      validator: AppValidators.combine([
        AppValidators.required,
        AppValidators.durationFormat,
      ]),
      onChanged: (value) {
        final durationMs = AppUtils.durationToMs(value);
        ref
            .read(selectedWRStepsProvider.notifier)
            .updateDuration(step.zone!.id!, durationMs);
      },
    );
  }
}
