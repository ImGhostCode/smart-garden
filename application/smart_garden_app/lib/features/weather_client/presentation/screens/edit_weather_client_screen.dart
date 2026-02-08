import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/inputs/app_labeled_input.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';
import '../../domain/entities/weather_client_entity.dart';
import '../../domain/usecases/get_all_weather_clients.dart';
import '../providers/weather_client_provider.dart';
import 'new_weather_client_screen.dart' show clientTypes;

class EditWeatherClientScreen extends ConsumerStatefulWidget {
  final String clientId;
  final WeatherClientEntity wc;
  const EditWeatherClientScreen({
    super.key,
    required this.clientId,
    required this.wc,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditWeatherClientScreenState();
}

class _EditWeatherClientScreenState
    extends ConsumerState<EditWeatherClientScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _type = clientTypes.first.value;
  late final TextEditingController _name;
  late final TextEditingController _stationId;
  late final TextEditingController _stationName;
  late final TextEditingController _rainModuleId;
  late final TextEditingController _outdoorModuleId;
  late final TextEditingController _clientId;
  late final TextEditingController _clientSecret;
  late final TextEditingController _refreshToken;
  late final TextEditingController _rainMm;
  late final TextEditingController _rainInterval;
  late final TextEditingController _avgHighTemperature;
  late final TextEditingController _error;

  @override
  void initState() {
    _name = TextEditingController();
    _stationId = TextEditingController();
    _stationName = TextEditingController();
    _rainModuleId = TextEditingController();
    _outdoorModuleId = TextEditingController();
    _clientId = TextEditingController();
    _clientSecret = TextEditingController();
    _refreshToken = TextEditingController();
    _rainMm = TextEditingController();
    _rainInterval = TextEditingController();
    _avgHighTemperature = TextEditingController();
    _error = TextEditingController();

    final wc = widget.wc;
    _name.text = wc.name ?? '';
    _type = clientTypes
        .firstWhere(
          (ct) => ct.value.toLowerCase() == wc.type?.toLowerCase(),
          orElse: () => clientTypes.first,
        )
        .value;
    if (wc.options != null) {
      final options = wc.options!;
      // Netatmo fields
      if (wc.type == "netatmo") {
        _stationId.text = options.stationId ?? '';
        _stationName.text = options.stationName ?? '';
        _rainModuleId.text = options.rainModuleId ?? '';
        _outdoorModuleId.text = options.outdoorModuleId ?? '';
        _clientId.text = options.clientId ?? '';
        _clientSecret.text = options.clientSecret ?? '';
        if (options.authentication != null) {
          _refreshToken.text = options.authentication!.refreshToken ?? '';
        }
      } else if (wc.type == "fake") {
        // Fake fields
        _rainMm.text = options.rainMm?.toString() ?? '';
        _rainInterval.text = AppUtils.msToDurationString(
          options.rainIntervalMs,
        );
        _avgHighTemperature.text = options.avgHighTemperature?.toString() ?? '';
        _error.text = options.error ?? '';
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _stationId.dispose();
    _stationName.dispose();
    _rainModuleId.dispose();
    _outdoorModuleId.dispose();
    _clientId.dispose();
    _clientSecret.dispose();
    _refreshToken.dispose();
    _rainMm.dispose();
    _rainInterval.dispose();
    _avgHighTemperature.dispose();
    _error.dispose();
    EasyLoading.dismiss();
    super.dispose();
  }

  void _onEdit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(weatherClientProvider.notifier)
        .editWeatherClient(
          WeatherClientEntity(
            id: widget.clientId,
            name: _name.text,
            type: _type!,
            // Netatmo fields
            options: _type! == "netatmo"
                ? OptionEntity(
                    stationId: _stationId.text,
                    stationName: _stationName.text,
                    rainModuleId: _rainModuleId.text,
                    rainModuleType: 'NAModule3',
                    outdoorModuleId: _outdoorModuleId.text,
                    outdoorModuleType: 'NAModule1',
                    clientId: _clientId.text,
                    clientSecret: _clientSecret.text,
                    authentication: _refreshToken.text.isNotEmpty
                        ? AuthenticationEntity(refreshToken: _refreshToken.text)
                        : null,
                  )
                // Fake fields
                : _type! == "fake"
                ? OptionEntity(
                    rainMm: double.tryParse(_rainMm.text),
                    rainIntervalMs: AppUtils.durationToMs(_rainInterval.text),
                    avgHighTemperature: double.tryParse(
                      _avgHighTemperature.text,
                    ),
                    error: _error.text,
                  )
                : null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(weatherClientProvider.select((state) => state.isEditingWC), (
      previousLoading,
      nextLoading,
    ) {
      if (nextLoading == true) {
        EasyLoading.show(status: 'Loading...');
      } else if (nextLoading == false && previousLoading == true) {
        EasyLoading.dismiss();
      }
    });

    ref.listen(weatherClientProvider, (previous, next) async {
      if (previous?.isEditingWC == true && next.isEditingWC == false) {
        if (next.errEditingWC.isNotEmpty) {
          EasyLoading.showError(next.errEditingWC);
        } else {
          EasyLoading.showSuccess(next.responseMsg ?? 'Weather Client edited');
          ref
              .read(weatherClientProvider.notifier)
              .getAllWeatherClients(GetAllWeatherClientsParams());
          context.goBack();
        }
      }
    });
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Edit Weather Client'),
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
                label: 'Client Name',
                child: TextFormField(
                  controller: _name,
                  validator: AppValidators.required,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 12),
              LabeledInput(
                label: 'Type',
                child: DropdownButtonFormField<String>(
                  value: _type,
                  menuMaxHeight: MediaQuery.sizeOf(context).height * 0.5,
                  items: clientTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type.value,
                      child: Text(type.label),
                    );
                  }).toList(),
                  validator: AppValidators.required,
                  // onChanged: (value) => setState(() => _type = value),
                  onChanged: null,
                  decoration: const InputDecoration(hintText: 'Select'),
                ),
              ),
              const SizedBox(height: 12),
              if (_type == "netatmo")
                Column(
                  key: const ValueKey("Netatmo_Fields"),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Netatmo Station',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LabeledInput(
                      label: 'Station ID',
                      child: TextFormField(
                        controller: _stationId,
                        validator: AppValidators.required,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LabeledInput(
                      label: 'Station name',
                      child: TextFormField(
                        controller: _stationName,
                        validator: AppValidators.required,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LabeledInput(
                      label: 'Rain module ID',
                      child: TextFormField(
                        controller: _rainModuleId,
                        validator: AppValidators.required,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // _buildTextField('Rain module type'),
                    // const SizedBox(height: 12),
                    LabeledInput(
                      label: 'Outdoor module ID',
                      child: TextFormField(
                        controller: _outdoorModuleId,
                        validator: AppValidators.required,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // _buildTextField('Outdoor module type'),
                    // const SizedBox(height: 12),
                    const Text(
                      'Authentication',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LabeledInput(
                      label: 'Client ID',
                      child: TextFormField(
                        controller: _clientId,
                        validator: AppValidators.required,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LabeledInput(
                      label: 'Client secret',
                      child: TextFormField(
                        controller: _clientSecret,
                        validator: AppValidators.required,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LabeledInput(
                      label: 'Refresh token',
                      child: TextFormField(
                        controller: _refreshToken,
                        validator: AppValidators.required,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              if (_type == "fake")
                Column(
                  key: const ValueKey("Fake_Fields"),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weather Data',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LabeledInput(
                      label: 'Rain (mm)',
                      child: TextFormField(
                        controller: _rainMm,
                        validator: AppValidators.combine([
                          AppValidators.required,
                          AppValidators.nonNegativeNum,
                        ]),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LabeledInput(
                      label: 'Rain interval',
                      child: TextFormField(
                        controller: _rainInterval,
                        validator: AppValidators.combine([
                          AppValidators.required,
                          AppValidators.durationFormat,
                        ]),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LabeledInput(
                      label: 'Average high temperature (°C)',
                      child: TextFormField(
                        controller: _avgHighTemperature,
                        validator: AppValidators.combine([
                          AppValidators.required,
                          AppValidators.numberOnly,
                        ]),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LabeledInput(
                      label: 'Error',
                      child: TextFormField(
                        controller: _error,
                        textInputAction: TextInputAction.next,
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
          child: ElevatedButton(onPressed: _onEdit, child: const Text('Save')),
        ),
      ),
    );
  }
}
