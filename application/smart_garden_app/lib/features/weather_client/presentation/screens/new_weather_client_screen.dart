import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/inputs/app_labeled_input.dart';
import '../../../../core/utils/app_validators.dart';

class NewWeatherClientScreen extends ConsumerStatefulWidget {
  const NewWeatherClientScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NewWeatherClientScreenState();
}

class _NewWeatherClientScreenState
    extends ConsumerState<NewWeatherClientScreen> {
  final _formKey = GlobalKey<FormState>();
  static const List<String> _clientTypes = ['Netatmo', 'Fake'];
  String? _type = _clientTypes.first;
  late final TextEditingController _name;
  late final TextEditingController _stationId;
  late final TextEditingController _stationName;
  late final TextEditingController _rainModuleId;
  late final TextEditingController _outdoorModuleId;
  late final TextEditingController _clientId;
  late final TextEditingController _clientSecret;
  late final TextEditingController _refreshToken;
  late final TextEditingController _ramMm;
  late final TextEditingController _rainInterval;
  late final TextEditingController _avgTemperature;

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
    _ramMm = TextEditingController();
    _rainInterval = TextEditingController();
    _avgTemperature = TextEditingController();
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
    _ramMm.dispose();
    _rainInterval.dispose();
    _avgTemperature.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    print('new weather client');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('New Weather Client'),
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
                _buildTextField('Client Name'),
                const SizedBox(height: 12),
                LabeledInput(
                  label: 'Type',
                  child: DropdownButtonFormField<String>(
                    value: _type,
                    menuMaxHeight: MediaQuery.sizeOf(context).height * 0.5,
                    items: _clientTypes
                        .map(
                          (tz) => DropdownMenuItem(value: tz, child: Text(tz)),
                        )
                        .toList(),
                    validator: AppValidators.required,
                    onChanged: (value) => setState(() => _type = value),
                    decoration: const InputDecoration(hintText: 'Select'),
                  ),
                ),
                const SizedBox(height: 12),
                if (_type == "Netatmo")
                  Column(
                    key: const ValueKey("Netatmo_Fields"), // Thêm Key ở đây
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
                      _buildTextField('Station ID'),
                      const SizedBox(height: 12),
                      _buildTextField('Station name'),
                      const SizedBox(height: 12),
                      _buildTextField('Rain module ID'),
                      const SizedBox(height: 12),
                      // _buildTextField('Rain module type'),
                      // const SizedBox(height: 12),
                      _buildTextField('Outdoor module ID'),
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
                      _buildTextField('Client ID'),
                      const SizedBox(height: 12),
                      _buildTextField('Client secret'),
                      const SizedBox(height: 12),
                      _buildTextField('Refresh token'),
                      const SizedBox(height: 12),
                    ],
                  ),
                if (_type == "Fake")
                  Column(
                    key: const ValueKey("Fake_Fields"), // Thêm Key ở đây
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
                      _buildTextField('Rain (mm)'),
                      const SizedBox(height: 12),
                      _buildTextField('Rain interval'),
                      const SizedBox(height: 12),
                      _buildTextField('Average high temperature (°C)'),
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

  // Widget tạo Label và TextField
  Widget _buildTextField(String label, {TextEditingController? controller}) {
    return LabeledInput(
      label: label,
      child: TextFormField(
        controller: controller,
        validator: AppValidators.required,
        textInputAction: TextInputAction.next,
      ),
    );
  }
}
