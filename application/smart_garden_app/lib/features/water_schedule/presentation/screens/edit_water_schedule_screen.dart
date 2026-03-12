import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/inputs/app_labeled_input.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';
import '../../../notification_client/domain/entities/notification_client_entity.dart';
import '../../../notification_client/domain/usecases/get_all_notification_clients.dart';
import '../../../notification_client/presentation/providers/notification_client_provider.dart';
import '../../../weather_client/domain/usecases/get_all_weather_clients.dart';
import '../../../weather_client/presentation/providers/weather_client_provider.dart';
import '../../domain/entities/water_schedule_entity.dart';
import '../../domain/usecases/get_all_water_schedules.dart';
import '../providers/water_schedule_provider.dart';
import '../providers/water_schedule_ui_providers.dart';

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

  String? _selectedNCId;
  // Weather control
  String? _temperatureClientId;
  String? _rainClientId;

  late final TextEditingController _tempBaseline;
  late final TextEditingController _tempFactor;
  late final TextEditingController _tempRange;

  late final TextEditingController _rainBaseline;
  late final TextEditingController _rainFactor;
  late final TextEditingController _rainRange;

  @override
  void initState() {
    _name = TextEditingController();
    _description = TextEditingController();
    _duration = TextEditingController();
    _interval = TextEditingController();
    _hour = TextEditingController();
    _minute = TextEditingController();
    _tempBaseline = TextEditingController();
    _tempFactor = TextEditingController();
    _tempRange = TextEditingController();
    _rainBaseline = TextEditingController();
    _rainFactor = TextEditingController();
    _rainRange = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(weatherClientProvider.notifier)
          .getAllWeatherClients(GetAllWeatherClientsParams());
      await ref
          .read(notiClientProvider.notifier)
          .getAllNotificationClients(GetAllNotificationClientsParams());

      final ws = widget.ws;
      _name.text = ws.name ?? '';
      _description.text = ws.description ?? '';
      _duration.text = AppUtils.msToDurationString(ws.durationMs ?? 0);
      _interval.text = ws.interval?.toString() ?? '';
      final utcStartTime = AppUtils.toLocalTime(ws.startTime);
      if (utcStartTime != null && utcStartTime.isNotEmpty) {
        final timeParts = utcStartTime.split(':');
        if (timeParts.length >= 2) {
          _hour.text = timeParts[0];
          _minute.text = timeParts[1];
        }
      }
      _startPeriod = ws.activePeriod?.startMonth;
      _endPeriod = ws.activePeriod?.endMonth;

      _selectedNCId = ws.notificationClient?.id;

      _temperatureClientId = ws.weatherControl?.temperatureControl?.clientId;
      _rainClientId = ws.weatherControl?.rainControl?.clientId;
      if (ws.weatherControl?.temperatureControl != null) {
        _tempBaseline.text = ws
            .weatherControl!
            .temperatureControl!
            .baselineValue
            .toString();
        _tempFactor.text = ws.weatherControl!.temperatureControl!.factor
            .toString();
        _tempRange.text = ws.weatherControl!.temperatureControl!.range
            .toString();
      }
      if (ws.weatherControl?.rainControl != null) {
        _rainBaseline.text = ws.weatherControl!.rainControl!.baselineValue
            .toString();
        _rainFactor.text = ws.weatherControl!.rainControl!.factor.toString();
        _rainRange.text = ws.weatherControl!.rainControl!.range.toString();
      }
    });
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
    _tempBaseline.dispose();
    _tempFactor.dispose();
    _tempRange.dispose();
    _rainBaseline.dispose();
    _rainFactor.dispose();
    _rainRange.dispose();
    EasyLoading.dismiss();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    String? startTime =
        '${_hour.text.padLeft(2, '0')}:${_minute.text.padLeft(2, '0')}:00';
    startTime = AppUtils.toUtcTime(startTime);
    ref
        .read(waterScheduleProvider.notifier)
        .editWaterSchedule(
          WaterScheduleEntity(
            id: widget.scheduleId,
            name: _name.text,
            description: _description.text,
            durationMs: AppUtils.durationToMs(_duration.text),
            interval: int.tryParse(_interval.text),
            startTime: startTime,
            activePeriod: (_startPeriod != null && _endPeriod != null)
                ? ActivePeriodEntity(
                    startMonth: _startPeriod!,
                    endMonth: _endPeriod!,
                  )
                : null,
            notificationClient: _selectedNCId != null
                ? NotificationClientEntity(id: _selectedNCId)
                : null,
            weatherControl:
                (_temperatureClientId != null || _rainClientId != null)
                ? WeatherControlEntity(
                    temperatureControl: _temperatureClientId != null
                        ? ControlEntity(
                            clientId: _temperatureClientId!,
                            baselineValue: double.parse(_tempBaseline.text),
                            factor: double.parse(_tempFactor.text),
                            range: double.parse(_tempRange.text),
                          )
                        : null,
                    rainControl: _rainClientId != null
                        ? ControlEntity(
                            clientId: _rainClientId!,
                            baselineValue: double.parse(_rainBaseline.text),
                            factor: double.parse(_rainFactor.text),
                            range: double.parse(_rainRange.text),
                          )
                        : null,
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
        if (next.errEditingWS.isNotEmpty) {
          AppUtils.showError(next.errEditingWS);
        } else {
          AppUtils.showSuccess(next.responseMsg ?? 'Water Schedule edited');
          ref
              .read(waterScheduleProvider.notifier)
              .getAllWaterSchedule(
                GetAllWSParams(
                  excludeWeatherData: ref.read(excludeWeatherProvider),
                ),
              );
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
                          controller: _interval,
                          validator: AppValidators.combine([
                            AppValidators.required,
                            AppValidators.positiveInt,
                          ]),
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
                          validator: AppValidators.combine([
                            AppValidators.required,
                            AppValidators.validHour,
                          ]),
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
                          validator: AppValidators.combine([
                            AppValidators.required,
                            AppValidators.validMinute,
                          ]),
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
                          value: _startPeriod != null
                              ? _months
                                    .where((m) => m.contains(_startPeriod!))
                                    .firstOrNull
                              : null,
                          items: _months
                              .map(
                                (m) =>
                                    DropdownMenuItem(value: m, child: Text(m)),
                              )
                              .toList(),
                          validator: _endPeriod != null
                              ? AppValidators.combine([
                                  AppValidators.required,
                                  (value) {
                                    if (value != null &&
                                        _months.indexOf(value) ==
                                            _months.indexOf(_endPeriod!)) {
                                      return 'Start month is invalid';
                                    }
                                    return null;
                                  },
                                ])
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
                          value: _endPeriod != null
                              ? _months
                                    .where((m) => m.contains(_endPeriod!))
                                    .firstOrNull
                              : null,
                          items: _months
                              .map(
                                (m) =>
                                    DropdownMenuItem(value: m, child: Text(m)),
                              )
                              .toList(),
                          validator: _startPeriod != null
                              ? AppValidators.combine([
                                  AppValidators.required,
                                  (value) {
                                    if (value != null &&
                                        _months.indexOf(value) ==
                                            _months.indexOf(_startPeriod!)) {
                                      return 'End month is invalid';
                                    }
                                    return null;
                                  },
                                ])
                              : null,
                          onChanged: (value) =>
                              setState(() => _endPeriod = value),
                          decoration: const InputDecoration(hintText: 'Select'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Weather control',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Temperature',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 6),
                LabeledInput(
                  label: 'Client',
                  child: DropdownButtonFormField<String>(
                    menuMaxHeight: MediaQuery.sizeOf(context).height * 0.5,
                    value: _temperatureClientId,
                    items: ref
                        .watch(weatherClientProvider)
                        .weatherClients
                        .map(
                          (i) => DropdownMenuItem(
                            value: i.id,
                            child: Text(i.name ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _temperatureClientId = value);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Select client',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: LabeledInput(
                        label: 'Baseline',
                        child: TextFormField(
                          decoration: const InputDecoration(
                            // hintText: 'e.g., 1h30m',
                            helperText: 'Đơn vị: °C',
                          ),
                          controller: _tempBaseline,
                          validator: _temperatureClientId != null
                              ? AppValidators.combine([
                                  AppValidators.required,
                                  AppValidators.numberOnly,
                                ])
                              : null,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LabeledInput(
                        label: 'Factor',
                        child: TextFormField(
                          // decoration: const InputDecoration(helperText: '0 -> 1'),
                          controller: _tempFactor,
                          validator: _temperatureClientId != null
                              ? AppValidators.combine([
                                  AppValidators.required,
                                  AppValidators.factor,
                                ])
                              : null,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LabeledInput(
                        label: 'Range',
                        child: TextFormField(
                          decoration: const InputDecoration(
                            helperText: 'Đơn vị: °C',
                          ),
                          controller: _tempRange,
                          validator: _temperatureClientId != null
                              ? AppValidators.combine([
                                  AppValidators.required,
                                  AppValidators.nonNegativeNum,
                                ])
                              : null,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Rain',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 6),
                LabeledInput(
                  label: 'Client',
                  child: DropdownButtonFormField<String>(
                    menuMaxHeight: MediaQuery.sizeOf(context).height * 0.5,
                    value: _rainClientId,
                    items: ref
                        .watch(weatherClientProvider)
                        .weatherClients
                        .map(
                          (i) => DropdownMenuItem(
                            value: i.id,
                            child: Text(i.name ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _rainClientId = value);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Select client',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: LabeledInput(
                        label: 'Baseline',
                        child: TextFormField(
                          decoration: const InputDecoration(
                            // hintText: 'e.g., 1h30m',
                            helperText: 'Đơn vị: mm',
                          ),
                          controller: _rainBaseline,
                          validator: _rainClientId != null
                              ? AppValidators.combine([
                                  AppValidators.required,
                                  AppValidators.numberOnly,
                                ])
                              : null,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LabeledInput(
                        label: 'Factor',
                        child: TextFormField(
                          // decoration: const InputDecoration(helperText: '0 -> 1'),
                          controller: _rainFactor,
                          validator: _rainClientId != null
                              ? AppValidators.combine([
                                  AppValidators.required,
                                  AppValidators.factor,
                                ])
                              : null,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LabeledInput(
                        label: 'Range',
                        child: TextFormField(
                          decoration: const InputDecoration(
                            helperText: 'Đơn vị: mm',
                          ),
                          controller: _rainRange,
                          validator: _rainClientId != null
                              ? AppValidators.combine([
                                  AppValidators.required,
                                  AppValidators.nonNegativeNum,
                                ])
                              : null,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LabeledInput(
                  label: 'Notification Client',
                  child: DropdownButtonFormField<String>(
                    value: _selectedNCId,
                    menuMaxHeight: MediaQuery.sizeOf(context).height * 0.5,
                    items: ref
                        .watch(notiClientProvider)
                        .notiClients
                        .map(
                          (i) => DropdownMenuItem(
                            value: i.id,
                            child: Text(i.name ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedNCId = value);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Select client',
                    ),
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
