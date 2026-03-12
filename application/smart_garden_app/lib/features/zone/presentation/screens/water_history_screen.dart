import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/usecases/get_water_history.dart';
import '../providers/zone_provider.dart';
import 'zone_detail_screen.dart';

class WaterHistoryScreen extends ConsumerStatefulWidget {
  final String gardenId;
  final String zoneId;
  const WaterHistoryScreen({
    super.key,
    required this.gardenId,
    required this.zoneId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _WaterHistoryScreenState();
}

class _WaterHistoryScreenState extends ConsumerState<WaterHistoryScreen> {
  DateTimeRange? _customDateRange;
  String _selectedRange = '24h';
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshHistory(_selectedRange);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _refreshHistory(String range) async {
    ref
        .read(zoneProvider.notifier)
        .getWaterHistory(
          GetWaterHistoryParams(
            gardenId: widget.gardenId,
            zoneId: widget.zoneId,
            range: range,
            limit: 0,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final zoneState = ref.watch(zoneProvider);
    ref.listen(zoneProvider.select((state) => state.isLoadingWHistory), (
      previousLoading,
      nextLoading,
    ) {
      if (nextLoading == true) {
        EasyLoading.show(status: 'Loading...');
      } else if (nextLoading == false && previousLoading == true) {
        EasyLoading.dismiss();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Water history'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 40,
              child: ListView(
                padding: const EdgeInsets.only(right: AppConstants.paddingMd),
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: [
                  FilterChip(
                    backgroundColor: Colors.white,
                    label: const Text('Last 24h'),
                    selected: _selectedRange == '24h',
                    onSelected: (selected) {
                      if (selected) {
                        _customDateRange = null;
                        _selectedRange = '24h';
                        _refreshHistory('24h');
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    backgroundColor: Colors.white,
                    label: const Text('Last 7d'),
                    selected: _selectedRange == '7d',
                    onSelected: (selected) {
                      if (selected) {
                        _customDateRange = null;
                        _selectedRange = '7d';
                        _refreshHistory('168h');
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    backgroundColor: Colors.white,
                    label: const Text('Last 30d'),
                    selected: _selectedRange == '30d',
                    onSelected: (selected) {
                      if (selected) {
                        _customDateRange = null;
                        _selectedRange = '30d';
                        _refreshHistory('720h');
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    backgroundColor: Colors.white,
                    label: Text(
                      _customDateRange != null
                          ? '${AppUtils.formatDate(_customDateRange!.start)} - ${AppUtils.formatDate(_customDateRange!.end)}'
                          : 'Custom',
                    ),
                    selected: _selectedRange == 'custom',
                    onSelected: (selected) {
                      showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        saveText: 'Apply',
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(scaffoldBackgroundColor: Colors.white),
                            child: child!,
                          );
                        },
                      ).then((pickedRange) {
                        if (pickedRange == null) return;
                        _selectedRange = 'custom';
                        _customDateRange = pickedRange;
                        final start = pickedRange.start;
                        final end = pickedRange.end;
                        if (end.difference(start).inDays > 30) {
                          AppUtils.showError(
                            'Please select a range of 30 days or less',
                          );
                          return;
                        }
                        final hoursRange = end.difference(start).inHours;
                        // check if hoursRange is 0, set to 24 to avoid invalid range
                        final validHoursRange = hoursRange > 0
                            ? hoursRange
                            : 24;
                        _refreshHistory('${validHoursRange}h');
                      });
                    },
                    // },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            zoneState.isLoadingWHistory
                ? const Center(child: CircularProgressIndicator())
                : zoneState.errLoadingWHistory.isNotEmpty
                ? Center(child: Text(zoneState.errLoadingWHistory))
                : zoneState.waterHistory.isNotEmpty
                ? buildHistoryTable(zoneState.waterHistory)
                : Center(
                    child: Text(
                      'No water history found',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
