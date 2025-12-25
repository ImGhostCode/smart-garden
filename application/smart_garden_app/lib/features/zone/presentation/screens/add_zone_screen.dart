import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/inputs/app_labeled_input.dart';
import '../../../../core/utils/app_validators.dart';

class AddZoneScreen extends ConsumerStatefulWidget {
  const AddZoneScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddZoneScreenState();
}

class _AddZoneScreenState extends ConsumerState<AddZoneScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _position = 1;
  late final TextEditingController _name;
  late final TextEditingController _skipCount;
  late final TextEditingController _description;
  late final TextEditingController _note;

  @override
  void initState() {
    _name = TextEditingController();
    _skipCount = TextEditingController();
    _description = TextEditingController();
    _note = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _skipCount.dispose();
    _description.dispose();
    _note.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    print('add zone');
  }

  @override
  Widget build(BuildContext context) {
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
                  Expanded(child: _buildTextField('Zone name')),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 100,
                    child: LabeledInput(
                      label: 'Position',
                      child: DropdownButtonFormField<int>(
                        value: _position,
                        menuMaxHeight: MediaQuery.sizeOf(context).height * 0.5,
                        items: [1, 2, 3, 4, 5]
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(p.toString()),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => _position = value),
                        decoration: const InputDecoration(hintText: 'Select'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField('Skip count', controller: _skipCount),
              const SizedBox(height: 12),
              _buildTextField(
                'Description',
                controller: _description,
                maxLines: 3,
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
                  return _buildScheduleItem(
                    trailing: SizedBox(
                      height: 35,
                      width: 35,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 8);
                },
                itemCount: 3,
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
              _buildTextField(
                'Note',
                controller: _note,
                maxLines: 3,
                required: false,
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
          child: ElevatedButton(onPressed: _onSave, child: const Text('Save')),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label, {
    bool? required = true,
    TextEditingController? controller,
    int? maxLines,
  }) {
    return LabeledInput(
      label: label,
      child: TextFormField(
        controller: controller,
        validator: required! ? AppValidators.required : null,
        textInputAction: TextInputAction.next,
        maxLines: maxLines,
      ),
    );
  }
}

// --- Widget: Schedule Item ---
Widget _buildScheduleItem({Widget? trailing, VoidCallback? onTap}) {
  return ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.only(
      left: AppConstants.paddingMd,
      right: AppConstants.paddingSm,
    ),
    tileColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      side: const BorderSide(color: Colors.black12),
    ),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Seedlings",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing ?? const SizedBox.shrink(),
      ],
    ),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Water seedlings a bit every day",
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: [
              _buildScheduleTag(Icons.timer_outlined, "30S"),
              const SizedBox(width: 8),
              _buildScheduleTag(Icons.access_time, "3:00 PM"),
              const SizedBox(width: 8),
              _buildScheduleTag(Icons.cached, "1 DAYS"),
              const SizedBox(width: 8),
              _buildScheduleTag(Icons.calendar_month_rounded, 'APR - OCT'),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildScheduleTag(IconData icon, String text) {
  return Chip(
    elevation: 0,
    padding: const EdgeInsets.all(AppConstants.paddingSm),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
    ),
    backgroundColor: AppColors.primary,
    labelPadding: EdgeInsets.zero,
    labelStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    ),
    label: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 5),
        Text(text),
      ],
    ),
  );
}

void showWSSelection(BuildContext context) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    clipBehavior: Clip.antiAlias,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Material(
                color: Colors.white,
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Material(
                            color: Colors.white,
                            child: ListView(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(
                                left: AppConstants.paddingMd,
                                right: AppConstants.paddingMd,
                                bottom: AppConstants.paddingMd,
                              ),
                              children: const [
                                Text(
                                  'Water Schedules',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 12),
                                SearchBar(
                                  leading: Icon(Icons.search),
                                  hintText: 'Search a schedule',
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.only(
                                left: AppConstants.paddingMd,
                                right: AppConstants.paddingMd,
                                bottom: 24,
                              ),
                              clipBehavior: Clip.antiAlias,
                              controller: scrollController,
                              itemBuilder: (context, index) {
                                return _buildScheduleItem(
                                  onTap: () {},
                                  trailing: Checkbox.adaptive(
                                    value: false,
                                    onChanged: (value) {},
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return const SizedBox(height: 8);
                              },
                              itemCount: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: AppConstants.buttonMd,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Add'),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}
