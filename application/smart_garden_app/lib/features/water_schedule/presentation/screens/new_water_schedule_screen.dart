import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/inputs/app_labeled_input.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';
import '../../domain/entities/water_schedule_entity.dart';
import '../providers/water_schedule_provider.dart';

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
  String? _startPeriod;
  String? _endPeriod;

  // Data Sources
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
    EasyLoading.dismiss();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(waterScheduleProvider.notifier)
        .createWaterSchedule(
          WaterScheduleEntity(
            name: _name.text,
            description: _description.text,
            durationMs: AppUtils.durationToMs(_duration.text),
            interval: int.parse(_interval.text),
            startTime:
                '${_hour.text.padLeft(2, '0')}:${_minute.text.padLeft(2, '0')}',
            activePeriod: _startPeriod != null && _endPeriod != null
                ? ActivePeriodEntity(
                    startMonth: _startPeriod!,
                    endMonth: _endPeriod!,
                  )
                : null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(waterScheduleProvider.select((state) => state.isCreatingWS), (
      previousLoading,
      nextLoading,
    ) {
      if (nextLoading == true) {
        EasyLoading.show(status: 'Loading...');
      } else if (nextLoading == false && previousLoading == true) {
        EasyLoading.dismiss();
      }
    });

    ref.listen(waterScheduleProvider, (previous, next) async {
      if (previous?.isCreatingWS == true && next.isCreatingWS == false) {
        if (next.errCreatingWS != null) {
          EasyLoading.showError(next.errCreatingWS ?? 'Error');
        } else {
          EasyLoading.showSuccess(next.responseMsg ?? 'Water Schedule created');
          context.goBack();
        }
      }
    });
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('New Water Schedule'),
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
                        decoration: const InputDecoration(
                          hintText: 'e.g., 1h30m',
                        ),
                        controller: _duration,
                        validator: AppValidators.combine([
                          AppValidators.required,
                          AppValidators.durationFormat,
                        ]),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LabeledInput(
                      label: 'Interval',
                      child: TextFormField(
                        decoration: const InputDecoration(hintText: 'Days'),
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
                        menuMaxHeight: MediaQuery.sizeOf(context).height * 0.5,
                        items: _months
                            .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m)),
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
                        menuMaxHeight: MediaQuery.sizeOf(context).height * 0.5,
                        items: _months
                            .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m)),
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
