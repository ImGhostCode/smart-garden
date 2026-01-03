import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/assets.dart';
import '../../../garden/presentation/providers/garden_provider.dart';
import '../../../water_routine/presentation/providers/water_routine_ui_providers.dart';
import '../../../zone/domain/usecases/get_all_zones.dart';
import '../../../zone/presentation/providers/zone_provider.dart';

class StepSelection extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  const StepSelection({super.key, required this.scrollController});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StepSelectionState();
}

class _StepSelectionState extends ConsumerState<StepSelection> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(zoneProvider.notifier).clearZones();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final gardensState = ref.watch(gardenProvider);
    final zoneState = ref.watch(zoneProvider);

    if (gardensState.isLoadingGardens) {
      return const Center(child: CircularProgressIndicator());
    }

    return Material(
      color: Colors.white,
      child: Column(
        children: [
          _HeaderSection(
            gardensState: gardensState,
            onGardenSelected: (value) {
              ref
                  .read(zoneProvider.notifier)
                  .getAllZone(GetAllZoneParams(gardenId: value));
            },
          ),

          const SizedBox(height: 8),

          Expanded(
            child: _ZoneContent(
              zoneState: zoneState,
              scrollController: widget.scrollController,
            ),
          ),

          _FooterSection(),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final GardenState gardensState;
  final ValueChanged<String?> onGardenSelected;

  const _HeaderSection({
    required this.gardensState,
    required this.onGardenSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMd),
        child: Column(
          children: [
            const Text(
              'Zones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            DropdownMenu<String>(
              width: double.infinity,
              menuHeight: MediaQuery.of(context).size.height * 0.5,
              leadingIcon: Image.asset(
                Assets.outdoorGarden,
                color: Colors.black,
              ),
              enabled: !gardensState.isLoadingGardens,
              dropdownMenuEntries: gardensState.gardens
                  .map(
                    (g) => DropdownMenuEntry(
                      value: g.id ?? '',
                      label: g.name ?? '',
                    ),
                  )
                  .toList(),
              onSelected: onGardenSelected,
            ),
            const SizedBox(height: 8),
            const SearchBar(
              leading: Icon(Icons.search),
              hintText: 'Search a zone',
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoneContent extends ConsumerWidget {
  final ZoneState zoneState;
  final ScrollController scrollController;

  const _ZoneContent({required this.zoneState, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (zoneState.isLoadingZones) {
      return const Center(child: CircularProgressIndicator());
    }

    if (zoneState.errLoadingZones != null) {
      return Center(child: Text(zoneState.errLoadingZones!));
    }

    final selectedSteps = ref.watch(selectedWRStepsProvider);

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMd,
        0,
        AppConstants.paddingMd,
        24,
      ),
      itemCount: zoneState.zones.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final zone = zoneState.zones[index];
        final isSelected = selectedSteps.any((s) => s.zone?.id == zone.id);

        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            side: const BorderSide(color: Colors.black12),
          ),
          leading: Image.asset(Assets.zone),
          title: Text(
            zone.name ?? '',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(zone.details?.description ?? ''),
          onTap: () {
            ref.read(selectedWRStepsProvider.notifier).toggleZone(zone);
          },
          trailing: Checkbox.adaptive(
            value: isSelected,
            onChanged: (_) {
              ref.read(selectedWRStepsProvider.notifier).toggleZone(zone);
            },
          ),
        );
      },
    );
  }
}

class _FooterSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSteps = ref.watch(selectedWRStepsProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMd,
        4,
        AppConstants.paddingMd,
        AppConstants.paddingMd,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (selectedSteps.isNotEmpty)
            Wrap(
              spacing: 8,
              children: selectedSteps
                  .map(
                    (s) => Chip(
                      label: Text(s.zone?.name ?? ''),
                      onDeleted: () {
                        ref
                            .read(selectedWRStepsProvider.notifier)
                            .toggleZone(s.zone!);
                      },
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 8),
          SizedBox(
            height: AppConstants.buttonMd,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

Future<dynamic> showStepSelection(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    clipBehavior: Clip.antiAlias,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return StepSelection(scrollController: scrollController);
        },
      );
    },
  );
}
