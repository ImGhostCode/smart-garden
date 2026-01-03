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

class EditWaterScheduleScreen extends ConsumerStatefulWidget {
  final String scheduleId;
  final WaterScheduleEntity ws;
  const EditWaterScheduleScreen({
    super.key,
    required this.scheduleId,
    required this.ws,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditWaterScheduleScreenState();
}

class _EditWaterScheduleScreenState
    extends ConsumerState<EditWaterScheduleScreen> {
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

  @override
  void initState() {
    _name = TextEditingController();
    _description = TextEditingController();
    _duration = TextEditingController();
    _interval = TextEditingController();
    _hour = TextEditingController();
    _minute = TextEditingController();

    final ws = widget.ws;
    _name.text = ws.name ?? '';
    _description.text = ws.description ?? '';
    _duration.text = ws.durationMs?.toString() ?? '';
    _interval.text = ws.interval?.toString() ?? '';
    final startTime = ws.startTime?.split(':');
    if (startTime != null && startTime.length == 2) {
      _hour.text = startTime[0];
      _minute.text = startTime[1];
    }
    _startPeriod = ws.activePeriod?.startMonth;
    _endPeriod = ws.activePeriod?.endMonth;
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
        .editWaterSchedule(
          WaterScheduleEntity(
            id: widget.ws.id,
            name: _name.text,
            description: _description.text,
            durationMs: AppUtils.durationToMs(_duration.text),
            interval: int.tryParse(_interval.text),
            startTime:
                '${_hour.text.padLeft(2, '0')}:${_minute.text.padLeft(2, '0')}:00',
            activePeriod: (_startPeriod != null && _endPeriod != null)
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
    ref.listen(waterScheduleProvider.select((state) => state.isEditingWS), (
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
      if (previous?.isEditingWS == true && next.isEditingWS == false) {
        if (next.errEditingWS != null) {
          EasyLoading.showError(next.errEditingWS ?? 'Error');
        } else {
          EasyLoading.showSuccess(next.responseMsg ?? 'Water Schedule edited');
          context.goBack();
        }
      }
    });
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Edit Water Schedule'),
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
                          value: _months
                              .where((m) => m.contains(_startPeriod ?? ''))
                              .firstOrNull,
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
                          value: _months
                              .where((m) => m.contains(_endPeriod ?? ''))
                              .firstOrNull,
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
