import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/inputs/app_labeled_input.dart';
import '../../../../core/utils/app_validators.dart';

class NewWaterScheduleScreen extends ConsumerStatefulWidget {
  const NewWaterScheduleScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NewWaterScheduleScreenState();
}

class _NewWaterScheduleScreenState
    extends ConsumerState<NewWaterScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _duration;
  late final TextEditingController _interval;
  late final TextEditingController _hour;
  late final TextEditingController _minute;

  // Local State
  String? _wsDuration;
  String? _timezone;
  String? _startPeriod;
  String? _endPeriod;

  // Data Sources
  static const List<String> _timezones = ['UTC', 'UTC+7'];
  static const List<String> _months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];
  // late final List<int> _durationHours;

  @override
  void initState() {
    _name = TextEditingController();
    _description = TextEditingController();
    _duration = TextEditingController();
    _interval = TextEditingController();
    _hour = TextEditingController();
    _minute = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _duration.dispose();
    _interval.dispose();
    _hour.dispose();
    _minute.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    print(_wsDuration);
    print(_timezone);
    print('new water schedule');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('New Water Schedule'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabeledInput(
                  label: 'Schedule name',
                  child: TextFormField(
                    controller: _name,
                    validator: AppValidators.required,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(height: 12),
                LabeledInput(
                  label: 'Desciption',
                  child: TextFormField(
                    controller: _description,
                    validator: AppValidators.required,
                    textInputAction: TextInputAction.next,
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: LabeledInput(
                        label: 'Duration',
                        child: TextFormField(
                          controller: _duration,
                          validator: AppValidators.required,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LabeledInput(
                        label: 'Interval',
                        child: TextFormField(
                          controller: _interval,
                          validator: AppValidators.required,
                          textInputAction: TextInputAction.next,
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
                          controller: _hour,
                          validator: AppValidators.required,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LabeledInput(
                        label: 'Minute',
                        child: TextFormField(
                          controller: _minute,
                          validator: AppValidators.required,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
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
                          validator: AppValidators.required,
                          onChanged: (value) =>
                              setState(() => _timezone = value),
                          decoration: const InputDecoration(hintText: 'Select'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Active Period',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: LabeledInput(
                        label: 'Start',
                        child: DropdownButtonFormField<String>(
                          menuMaxHeight:
                              MediaQuery.sizeOf(context).height * 0.5,
                          items: _months
                              .map(
                                (m) =>
                                    DropdownMenuItem(value: m, child: Text(m)),
                              )
                              .toList(),
                          validator: _endPeriod != null
                              ? AppValidators.required
                              : null,
                          onChanged: (value) =>
                              setState(() => _startPeriod = value),
                          decoration: const InputDecoration(hintText: 'Select'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LabeledInput(
                        label: 'End',
                        child: DropdownButtonFormField<String>(
                          menuMaxHeight:
                              MediaQuery.sizeOf(context).height * 0.5,
                          items: _months
                              .map(
                                (m) =>
                                    DropdownMenuItem(value: m, child: Text(m)),
                              )
                              .toList(),
                          validator: _startPeriod != null
                              ? AppValidators.required
                              : null,
                          onChanged: (value) =>
                              setState(() => _endPeriod = value),
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
        child: SizedBox(
          width: double.infinity,
          height: AppConstants.buttonMd,
          child: ElevatedButton(onPressed: _onSave, child: const Text('Save')),
        ),
      ),
    );
  }
}
