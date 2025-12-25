import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/inputs/app_labeled_input.dart';
import '../../../../core/utils/app_validators.dart';
import 'new_water_routine_screen.dart' show showZones;

class EditWaterRoutineScreen extends ConsumerStatefulWidget {
  final String routineId;
  const EditWaterRoutineScreen({super.key, required this.routineId});

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
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    print('edit water routine');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(title: const Text('New Water Routine'), centerTitle: true),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMd),
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
                  padding: const EdgeInsets.only(bottom: 8),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
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
                      title: Text('${index + 1}. Shrubs'),
                      titleTextStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'This zone controls watering to two trees that are watered deeply',
                          ),
                          Chip(
                            elevation: 0,
                            padding: const EdgeInsets.all(
                              AppConstants.paddingSm,
                            ),
                            backgroundColor: AppColors.primary,
                            labelPadding: EdgeInsets.zero,
                            labelStyle: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(color: Colors.white),
                            label: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.timer_outlined, color: Colors.white),
                                SizedBox(width: 5),
                                Text('15m'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red[400],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 8);
                  },
                  itemCount: 3,
                ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showZones(context);
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
