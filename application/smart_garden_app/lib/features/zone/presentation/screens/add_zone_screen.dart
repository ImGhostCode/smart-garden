import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/inputs/app_labeled_input.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/extensions/navigation_extensions.dart';
import '../../../garden/domain/entities/garden_entity.dart';
import '../../../garden/presentation/providers/garden_provider.dart';
import '../../../water_schedule/presentation/providers/water_schedule_ui_providers.dart';
import '../../../water_schedule/presentation/screens/water_schedule_screen.dart';
import '../../../water_schedule/presentation/widgets/water_schedule_selection.dart';
import '../../domain/entities/zone_entity.dart';
import '../../domain/usecases/get_all_zones.dart';
import '../../domain/usecases/new_zone.dart';
import '../providers/zone_provider.dart';

class AddZoneScreen extends ConsumerStatefulWidget {
  final String gardenId;
  const AddZoneScreen({super.key, required this.gardenId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddZoneScreenState();
}

class _AddZoneScreenState extends ConsumerState<AddZoneScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _position = 0;
  late final TextEditingController _name;
  late final TextEditingController _skipCount;
  late final TextEditingController _description;
  late final TextEditingController _notes;
  late List<int> existedPositions;
  late int maxZones;
  List<int> availablePositions = [];
  @override
  void initState() {
    _name = TextEditingController();
    _skipCount = TextEditingController();
    _description = TextEditingController();
    _notes = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(selectedWSProvider.notifier).clear();

      existedPositions = ref
          .read(zoneProvider.notifier)
          .existedPositions(widget.gardenId);
      await ref
          .read(gardenProvider.notifier)
          .getGardenById(id: widget.gardenId);
      final garden = ref.read(gardenProvider).garden;
      maxZones = garden?.maxZones ?? 1;
      availablePositions = List<int>.generate(
        maxZones,
        (i) => i,
      ).where((pos) => !existedPositions.contains(pos)).toList();
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _skipCount.dispose();
    _description.dispose();
    _notes.dispose();
    EasyLoading.dismiss();
    super.dispose();
  }

  void _onAdd() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(zoneProvider.notifier)
        .addZone(
          NewZoneParams(
            gardenId: widget.gardenId,
            zone: ZoneEntity(
              name: _name.text,
              position: _position!,
              garden: GardenEntity(id: widget.gardenId),
              waterSchedules: ref.read(selectedWSProvider),
              skipCount: _skipCount.text.isNotEmpty
                  ? int.parse(_skipCount.text)
                  : null,
              details: ZoneDetailEntity(
                description: _description.text,
                notes: _notes.text.isNotEmpty ? _notes.text : null,
              ),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(zoneProvider.select((state) => state.isCreatingZone), (
      previousLoading,
      nextLoading,
    ) {
      if (nextLoading == true) {
        EasyLoading.show(status: 'Loading...');
      } else if (nextLoading == false && previousLoading == true) {
        EasyLoading.dismiss();
      }
    });

    ref.listen(zoneProvider, (previous, next) async {
      if (previous?.isCreatingZone == true && next.isCreatingZone == false) {
        if (next.errCreatingZone.isNotEmpty) {
          EasyLoading.showError(next.errCreatingZone);
        } else {
          EasyLoading.showSuccess(next.responseMsg ?? 'Zone created');
          ref
              .read(zoneProvider.notifier)
              .getAllZone(GetAllZoneParams(gardenId: widget.gardenId));
          context.goBack();
        }
      }
    });
    final selectedWS = ref.watch(selectedWSProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(title: const Text('Add Zone'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LabeledInput(
                      label: 'Zone name',
                      child: TextFormField(
                        controller: _name,
                        validator: AppValidators.required,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 100,
                    child: LabeledInput(
                      label: 'Position',
                      child: DropdownButtonFormField<int>(
                        menuMaxHeight: MediaQuery.sizeOf(context).height * 0.5,
                        items: availablePositions
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text('${p + 1}'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => _position = value),
                        decoration: const InputDecoration(hintText: 'Select'),
                        validator: AppValidators.required,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LabeledInput(
                label: 'Skip watering',
                child: TextFormField(
                  controller: _skipCount,
                  validator: _skipCount.text.isNotEmpty
                      ? AppValidators.nonNegativeInt
                      : null,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 12),
              LabeledInput(
                label: 'Description',
                child: TextFormField(
                  controller: _description,
                  validator: AppValidators.required,
                  textInputAction: TextInputAction.next,
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Water schedule',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              ListView.separated(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return WaterScheduleItem(
                    ws: selectedWS[index],
                    trailing: SizedBox(
                      height: 35,
                      width: 35,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          ref
                              .read(selectedWSProvider.notifier)
                              .toggle(selectedWS[index]);
                        },
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 8);
                },
                itemCount: selectedWS.length,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showWSSelection(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add schedule'),
                ),
              ),
              const SizedBox(height: 12),
              LabeledInput(
                label: 'Notes',
                child: TextFormField(controller: _notes, maxLines: 3),
              ),
              const SizedBox(height: 12),
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
          child: ElevatedButton(onPressed: _onAdd, child: const Text('Add')),
        ),
      ),
    );
  }
}
