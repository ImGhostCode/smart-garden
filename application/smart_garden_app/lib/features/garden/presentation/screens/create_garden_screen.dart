import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/inputs/app_labeled_input.dart';
import '../../../../core/utils/app_validators.dart';

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
  String? _timezone;

  // Data Sources
  static const List<String> _timezones = ['UTC', 'UTC+7'];
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
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    // Xử lý logic save ở đây
    print('Creating garden: ${_nameController.text}');
    print(_timezone);
  }

  @override
  Widget build(BuildContext context) {
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: LabeledInput(
                        label: 'Timezone',
                        child: DropdownButtonFormField<String>(
                          menuMaxHeight:
                              MediaQuery.sizeOf(context).height * 0.5,
                          items: _timezones
                              .map(
                                (tz) => DropdownMenuItem(
                                  value: tz,
                                  child: Text(tz),
                                ),
                              )
                              .toList(),
                          validator: _lsDuration != null
                              ? AppValidators.required
                              : null,
                          onChanged: (value) =>
                              setState(() => _timezone = value),
                          decoration: const InputDecoration(hintText: 'Select'),
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
