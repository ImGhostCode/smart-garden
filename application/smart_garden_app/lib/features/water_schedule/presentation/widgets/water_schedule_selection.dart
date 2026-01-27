import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/usecases/get_all_water_schedules.dart';
import '../providers/water_schedule_provider.dart';
import '../providers/water_schedule_ui_providers.dart';
import '../screens/water_schedule_screen.dart' show WaterScheduleItem;

class WaterScheduleSelection extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  const WaterScheduleSelection({super.key, required this.scrollController});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _WaterScheduleSelectionState();
}

class _WaterScheduleSelectionState
    extends ConsumerState<WaterScheduleSelection> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(waterScheduleProvider.notifier)
          .getAllWaterSchedule(GetAllWSParams());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final gardensState = ref.watch(gardenProvider);
    // final zoneState = ref.watch(zoneProvider);
    // if (wsState.isLoadingWSs) {
    //   return const Center(child: CircularProgressIndicator());
    // }

    return Material(
      color: Colors.white,
      child: Column(
        children: [
          const _HeaderSection(),

          const SizedBox(height: 8),

          Expanded(child: _Content(scrollController: widget.scrollController)),

          _FooterSection(),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMd),
        child: Column(
          children: [
            Text(
              'Water Schedules',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            SearchBar(
              leading: Icon(Icons.search),
              hintText: 'Search a water schedule',
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  final ScrollController scrollController;

  const _Content({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wsState = ref.watch(waterScheduleProvider);

    if (wsState.isLoadingWSs) {
      return const Center(child: CircularProgressIndicator());
    }

    if (wsState.errLoadingWSs.isNotEmpty) {
      return Center(child: Text(wsState.errLoadingWSs));
    }

    final selectedWS = ref.watch(selectedWSProvider);

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMd,
        0,
        AppConstants.paddingMd,
        24,
      ),
      itemCount: wsState.waterSchedules.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final ws = wsState.waterSchedules[index];
        final isSelected = selectedWS.any((s) => s.id == ws.id);
        return WaterScheduleItem(
          trailing: Checkbox.adaptive(
            value: isSelected,
            onChanged: (value) {
              ref.read(selectedWSProvider.notifier).toggle(ws);
            },
          ),
          ws: ws,
        );
      },
    );
  }
}

class _FooterSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: SizedBox(
        height: AppConstants.buttonMd,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ),
    );
  }
}

Future<dynamic> showWSSelection(BuildContext context) {
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
          return WaterScheduleSelection(scrollController: scrollController);
        },
      );
    },
  );
}
