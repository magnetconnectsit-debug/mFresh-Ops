import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mfresh_ops/data/repositories/tracking_repository.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/core/utils/map_marker_utils.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';

import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';

class StaffTrackingController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final TrackingRepository _repository = Get.find<TrackingRepository>();

  late TabController tabController;
  final RxBool isSearching = false.obs;

  final RxList<Map<String, dynamic>> allEmployees =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredEmployees =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final TextEditingController searchController = TextEditingController();
  final RxString selectedFilter = 'Total'.obs;
  final RxSet<dynamic> selectedEmployeeIds = <dynamic>{}.obs;

  final RxSet<Marker> employeeMarkers = <Marker>{}.obs;
  GoogleMapController? mapController;

  final RxDouble currentZoom = 14.0.obs;
  Timer? _debounceTimer;
  Timer? _pollingTimer;

  // Cache for marker icons to avoid recreating bitmaps continuously
  final Map<String, BitmapDescriptor> _markerCache = {};

  final RxMap<String, dynamic> selectedEmployeeLiveStats =
      <String, dynamic>{}.obs;
  final RxBool isLoadingLiveStats = false.obs;

  final Rx<MapType> currentMapType = MapType.normal.obs;

  void toggleMapType() {
    currentMapType.value =
    currentMapType.value == MapType.normal ? MapType.satellite : MapType.normal;
  }

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    searchController.addListener(filterEmployees);
    fetchEmployees();
    _startPolling();
  }

  @override
  void onClose() {
    tabController.dispose();
    searchController.dispose();
    _debounceTimer?.cancel();
    _pollingTimer?.cancel();
    super.onClose();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchEmployees(isSilent: true);
    });
  }

  void locateEmployeeOnMap(Map<String, dynamic> emp) {
    isSearching.value = false;
    searchController.clear();

    tabController.animateTo(1);

    final lat = emp['latitude'] ?? emp['live_status']?['latitude'];
    final lng = emp['longitude'] ?? emp['live_status']?['longitude'];

    if (lat != null && lng != null) {
      final double latitude = double.tryParse(lat.toString()) ?? 0.0;
      final double longitude = double.tryParse(lng.toString()) ?? 0.0;

      if (latitude != 0.0 && longitude != 0.0) {
        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(latitude, longitude), 16.0),
        );
      }
    }

    _showEmployeeStatusBottomSheet(emp);
  }

  Future<void> fetchEmployees({bool isSilent = false}) async {
    if (!isSilent) {
      isLoading.value = true;
      selectedEmployeeIds.clear();
      selectedFilter.value = 'Total';
      searchController.clear();
      isSearching.value = false;
    }
    try {
      final response = await _repository.getCurrentStatus();
      if (response != null && response['status'] == true) {
        final List emps = response['employees'] ?? [];
        allEmployees.value = emps
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        await filterEmployees();
      } else {
        if (!isSilent) {
          AppCommonToastMessage.show(
            message: response['message'] ?? 'Failed to load staff',
            type: ToastType.error,
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching employees: $e');
      if (!isSilent) {
        AppCommonToastMessage.show(
          message: 'Failed to load staff list',
          type: ToastType.error,
        );
      }
    } finally {
      if (!isSilent) {
        isLoading.value = false;
      }
    }
  }

  void onCameraMove(CameraPosition position) {
    if ((currentZoom.value - position.zoom).abs() > 0.5) {
      currentZoom.value = position.zoom;

      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        _updateMarkers(shouldFitBounds: false);
      });
    }
  }

  Future<void> filterEmployees() async {
    final query = searchController.text.toLowerCase();
    final filter = selectedFilter.value;

    List<Map<String, dynamic>> temp = allEmployees;

    // Apply multiple staff selection filter
    if (selectedEmployeeIds.isNotEmpty) {
      temp = temp.where((emp) {
        final id = emp['id'] ?? emp['user_id'];
        return id != null && selectedEmployeeIds.contains(id);
      }).toList();
    }

    // Apply status filter
    if (filter != 'Total') {
      temp = temp.where((emp) {
        final status = emp['current_status']?.toString().toLowerCase() ?? '';
        final bool isOnDuty = emp['is_on_duty'] == 1 ||
            emp['is_on_duty'] == true || emp['is_on_duty'] == '1';
        final lastSeen = emp['last_seen'];

        bool isNotInstalled = lastSeen == null && emp['live_status'] == null;

        if (filter == 'Not Installed') return isNotInstalled;

        // If not installed, they shouldn't appear in other filters
        if (isNotInstalled) return false;

        if (filter == 'Off Duty') return !isOnDuty;

        // If off duty, they shouldn't appear in Live/NotLive/Moving/Stopped
        if (!isOnDuty) return false;

        if (filter == 'On Duty') return true;

        if (filter == 'Moving') return status == 'moving';
        if (filter == 'Stopped') return status == 'stopped';

        if (filter == 'Live') {
          return !AppDateUtils.isOlderThanMinutes(lastSeen?.toString(), 10);
        }
        if (filter == 'Not Live') {
          return AppDateUtils.isOlderThanMinutes(lastSeen?.toString(), 10);
        }

        return false;
      }).toList();
    }

    // Apply search query
    if (query.isNotEmpty) {
      temp = temp.where((emp) {
        final name = (emp['name'] ?? '').toString().toLowerCase();
        final mobile = (emp['mobile'] ?? '').toString().toLowerCase();
        return name.contains(query) || mobile.contains(query);
      }).toList();
    }

    filteredEmployees.value = temp;
    await _updateMarkers(shouldFitBounds: false);
  }

  List<Map<String, dynamic>> _clusterEmployees(
      List<Map<String, dynamic>> employees,
      double zoom,) {
    if (zoom >= 11.5) {
      // High zoom: detect overlapping markers and spiderify
      double minDistance = 0.0001; // roughly 11 meters

      Map<String, List<Map<String, dynamic>>> preciseGrid = {};
      for (var emp in employees) {
        final latStr = emp['latitude']?.toString();
        final lngStr = emp['longitude']?.toString();
        if (latStr != null &&
            lngStr != null &&
            latStr != 'null' &&
            lngStr != 'null') {
          double? lat = double.tryParse(latStr);
          double? lng = double.tryParse(lngStr);
          if (lat != null && lng != null) {
            int gridX = (lng / minDistance).floor();
            int gridY = (lat / minDistance).floor();
            String key = '${gridX}_$gridY';
            preciseGrid.putIfAbsent(key, () => []).add(emp);
          }
        }
      }

      List<Map<String, dynamic>> result = [];
      for (var group in preciseGrid.values) {
        if (group.length == 1) {
          result.add({
            'isCluster': false,
            'employees': group,
            'latitude': group[0]['latitude'],
            'longitude': group[0]['longitude'],
          });
        } else {
          // Spiderify!
          double centerLat = 0;
          double centerLng = 0;
          for (var emp in group) {
            centerLat +=
                double.tryParse(emp['latitude']?.toString() ?? '0') ?? 0.0;
            centerLng +=
                double.tryParse(emp['longitude']?.toString() ?? '0') ?? 0.0;
          }
          centerLat /= group.length;
          centerLng /= group.length;

          // Expand radius slightly if there are many users
          double radius = 0.0002 + (group.length * 0.00002);
          for (int i = 0; i < group.length; i++) {
            double angle = (i * 2 * pi) / group.length;
            double offsetX = radius * cos(angle);
            // Adjust latitude offset to account for aspect ratio, roughly
            double offsetY = radius * sin(angle) * 0.8;

            result.add({
              'isCluster': false,
              'employees': [group[i]],
              'latitude': centerLat + offsetY,
              'longitude': centerLng + offsetX,
            });
          }
        }
      }
      return result;
    }

    // Grid clustering for low zoom
    double cellSize = 360.0 / (1 << zoom.floor()) * 0.4;

    Map<String, List<Map<String, dynamic>>> grid = {};
    for (var emp in employees) {
      final latStr = emp['latitude']?.toString();
      final lngStr = emp['longitude']?.toString();
      if (latStr != null &&
          lngStr != null &&
          latStr.isNotEmpty &&
          lngStr.isNotEmpty &&
          latStr != 'null' &&
          lngStr != 'null') {
        double? lat = double.tryParse(latStr);
        double? lng = double.tryParse(lngStr);

        if (lat != null && lng != null) {
          int gridX = (lng / cellSize).floor();
          int gridY = (lat / cellSize).floor();
          String key = '${gridX}_$gridY';

          grid.putIfAbsent(key, () => []).add(emp);
        }
      }
    }

    List<Map<String, dynamic>> clusters = [];
    for (var group in grid.values) {
      if (group.length == 1) {
        clusters.add({
          'isCluster': false,
          'employees': group,
          'latitude': group[0]['latitude'],
          'longitude': group[0]['longitude'],
        });
      } else {
        double sumLat = 0;
        double sumLng = 0;
        for (var emp in group) {
          sumLat += double.tryParse(emp['latitude']?.toString() ?? '0') ?? 0.0;
          sumLng += double.tryParse(emp['longitude']?.toString() ?? '0') ?? 0.0;
        }
        clusters.add({
          'isCluster': true,
          'employees': group,
          'count': group.length,
          'latitude': sumLat / group.length,
          'longitude': sumLng / group.length,
        });
      }
    }
    return clusters;
  }

  Future<void> _updateMarkers({bool shouldFitBounds = false}) async {
    final Set<Marker> newMarkers = {};
    final clusters = _clusterEmployees(filteredEmployees, currentZoom.value);

    for (var cluster in clusters) {
      try {
        final double lat =
            double.tryParse(cluster['latitude']?.toString() ?? '0') ?? 0.0;
        final double lng =
            double.tryParse(cluster['longitude']?.toString() ?? '0') ?? 0.0;

        if (lat == 0.0 && lng == 0.0) continue;

        if (cluster['isCluster']) {
          // It's a cluster of multiple employees
          final int count = cluster['count'];
          final String cacheKey = 'cluster_$count';

          if (!_markerCache.containsKey(cacheKey)) {
            _markerCache[cacheKey] = await MapMarkerUtils.createClusterMarker(
              count: count,
              color: AppColors.blue500,
            );
          }

          newMarkers.add(
            Marker(
              markerId: MarkerId('cluster_${lat}_$lng'),
              position: LatLng(lat, lng),
              icon: _markerCache[cacheKey]!,
              onTap: () {
                // Zoom in to see the cluster spread out
                mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(lat, lng),
                    currentZoom.value + 2.5,
                  ),
                );
              },
            ),
          );
        } else {
          // Individual employee
          final emp = cluster['employees'][0];
          final status = emp['current_status']?.toString().toLowerCase();
          Color markerColor = Colors.red;
          if (status == 'moving') {
            markerColor = Colors.green;
          } else if (status == 'stopped') {
            markerColor = Colors.orange;
          }

          final name = emp['name']?.toString() ?? 'U';
          String initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';
          if (name.contains(' ')) {
            final parts = name.split(' ');
            if (parts.length > 1 && parts[1].isNotEmpty) {
              initials += parts[1][0].toUpperCase();
            }
          }

          final bool isOnDuty = emp['is_on_duty'] == 1 ||
              emp['is_on_duty'] == true;
          final Color borderColor = isOnDuty ? AppColors.green : AppColors.red;

          final String imageUrl = emp['image_url']?.toString() ?? '';
          final bool hasImage = imageUrl.isNotEmpty &&
              !imageUrl.endsWith('/NA');

          final String cacheKey = hasImage
              ? 'emp_img_${emp['id']}_${markerColor.hashCode}_${borderColor
              .hashCode}'
              : 'emp_${initials}_${markerColor.hashCode}_${borderColor
              .hashCode}';

          if (!_markerCache.containsKey(cacheKey)) {
            if (hasImage) {
              _markerCache[cacheKey] =
              await MapMarkerUtils.createNetworkImageMarker(
                imageUrl: imageUrl,
                color: markerColor,
                fallbackText: initials,
                borderColor: borderColor,
              );
            } else {
              _markerCache[cacheKey] = await MapMarkerUtils.createCustomMarker(
                color: markerColor,
                text: initials,
                borderColor: borderColor,
              );
            }
          }

          newMarkers.add(
            Marker(
              markerId: MarkerId('emp_${emp['id']}'),
              position: LatLng(lat, lng),
              icon: _markerCache[cacheKey]!,
              onTap: () {
                _showEmployeeStatusBottomSheet(emp);
              },
            ),
          );
        }
      } catch (e) {
        debugPrint('Error generating marker for cluster/employee: $e');
        AppCommonToastMessage.show(
          message: 'Error generating marker: $e',
          type: ToastType.error,
        );
      }
    }
    employeeMarkers.assignAll(newMarkers);

    if (shouldFitBounds) {
      // Slight delay to allow map to update before fitting bounds
      Future.delayed(const Duration(milliseconds: 300), () {
        fitBounds();
      });
    }
  }

  void fitBounds() {
    if (mapController == null || employeeMarkers.isEmpty) return;

    double? minLat, maxLat, minLng, maxLng;
    for (final marker in employeeMarkers) {
      final p = marker.position;
      if (minLat == null || p.latitude < minLat) minLat = p.latitude;
      if (maxLat == null || p.latitude > maxLat) maxLat = p.latitude;
      if (minLng == null || p.longitude < minLng) minLng = p.longitude;
      if (maxLng == null || p.longitude > maxLng) maxLng = p.longitude;
    }

    if (minLat != null && maxLat != null && minLng != null && maxLng != null) {
      if (minLat == maxLat && minLng == maxLng) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(minLat, minLng), 14),
        );
      } else {
        mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: LatLng(minLat, minLng),
              northeast: LatLng(maxLat, maxLng),
            ),
            50.0,
          ),
        );
      }
    }
  }

  void _showEmployeeStatusBottomSheet(Map<String, dynamic> emp) {
    selectedEmployeeLiveStats.clear();
    isLoadingLiveStats.value = true;

    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _repository
        .getEmployeeSummary(
      employeeId: emp['id'] ?? emp['user_id'],
      date: dateStr,
    )
        .then((res) {
      if (res != null && res['status'] == true) {
        selectedEmployeeLiveStats.value = Map<String, dynamic>.from(
          res['live_status'] ?? {},
        );
      }
    })
        .whenComplete(() {
      isLoadingLiveStats.value = false;
    });

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Obx(() {
          final liveStats = selectedEmployeeLiveStats.isEmpty
              ? emp
              : selectedEmployeeLiveStats;

          final status =
              liveStats['current_status']?.toString().toLowerCase() ??
                  emp['current_status']?.toString().toLowerCase();
          Color statusColor = Colors.red;
          if (status == 'moving') {
            statusColor = Colors.green;
          } else if (status == 'stopped') {
            statusColor = Colors.orange;
          }

          final lastSeen =
              liveStats['last_seen'] ?? emp['last_seen'] ?? 'Never';
          final battery = liveStats['battery'] ?? emp['battery'];
          final speed = liveStats['speed'] ?? emp['speed'];

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: statusColor.withValues(alpha: 0.1),
                    child: Icon(Icons.person, color: statusColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          emp['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          emp['mobile'] ?? 'No Mobile',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  if (isLoadingLiveStats.value)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow(
                Icons.info_outline,
                'Status',
                status?.toUpperCase() ?? 'OFFLINE',
                statusColor,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.access_time,
                'Last Seen',
                AppDateUtils.formatToDateTimeAmPm(lastSeen?.toString()),
                Colors.black87,
              ),
              if (battery != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.battery_std,
                  'Battery',
                  '$battery%',
                  Colors.black87,
                ),
              ],
              if (speed != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.speed,
                  'Speed',
                  '${((double.tryParse(speed.toString()) ?? 0.0) * 3.6).toStringAsFixed(2)} km/h',
                  Colors.black87,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // close bottom sheet
                    openEmployeeHistory(emp);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'View History',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(IconData icon,
      String label,
      String value,
      Color valueColor,) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  void openEmployeeHistory(Map<String, dynamic> employee) {
    Get.toNamed(
      AppRoutes.routeHistory,
      arguments: {
        'employee_id': employee['id'],
        'employee_name': employee['name'],
        'current_lat': employee['latitude'],
        'current_lng': employee['longitude'],
        'last_seen': employee['last_seen'],
      },
    );
  }

  void showMultiSelectStaffBottomSheet() {
    final RxSet<dynamic> tempSelectedIds = RxSet<dynamic>({...selectedEmployeeIds});
    final RxString searchSelectionQuery = ''.obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Staff',
                  style: AppTextStyle.style_18_600(color: AppColors.black),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        if (tempSelectedIds.length == allEmployees.length) {
                          tempSelectedIds.clear();
                        } else {
                          tempSelectedIds.assignAll(
                            allEmployees.map((e) => e['id'] ?? e['user_id']).toList(),
                          );
                        }
                      },
                      child: Obx(() {
                        final isAll = tempSelectedIds.length == allEmployees.length;
                        return Text(
                          isAll ? 'Clear All' : 'Select All',
                          style: AppTextStyle.style_14_600(color: AppColors.blue500),
                        );
                      }),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search staff name...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.blue500),
                ),
              ),
              onChanged: (val) {
                searchSelectionQuery.value = val.toLowerCase();
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final query = searchSelectionQuery.value;
                final list = allEmployees.where((emp) {
                  final name = (emp['name'] ?? '').toString().toLowerCase();
                  return name.contains(query);
                }).toList();

                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'No matching staff found',
                      style: AppTextStyle.style_14_500(color: AppColors.grey500),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.grey100),
                  itemBuilder: (context, index) {
                    final emp = list[index];
                    final id = emp['id'] ?? emp['user_id'];
                    return Obx(() {
                      final isChecked = tempSelectedIds.contains(id);
                      return CheckboxListTile(
                        value: isChecked,
                        title: Text(
                          emp['name'] ?? 'Unknown',
                          style: AppTextStyle.style_14_600(color: AppColors.black),
                        ),
                        subtitle: Text(
                          emp['mobile'] ?? 'No Mobile',
                          style: AppTextStyle.style_12_500(color: AppColors.grey500),
                        ),
                        activeColor: AppColors.blue500,
                        checkboxShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (val) {
                          if (val == true) {
                            tempSelectedIds.add(id);
                          } else {
                            tempSelectedIds.remove(id);
                          }
                        },
                      );
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      selectedEmployeeIds.clear();
                      filterEmployees();
                      Get.back();
                      _updateMarkers(shouldFitBounds: true);
                    },
                    child: Text(
                      'Reset Filter',
                      style: AppTextStyle.style_14_600(color: AppColors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.blue500,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      selectedEmployeeIds.assignAll(tempSelectedIds);
                      filterEmployees();
                      Get.back();
                      if (selectedEmployeeIds.isNotEmpty) {
                        _updateMarkers(shouldFitBounds: true);
                      }
                    },
                    child: Text(
                      'Apply',
                      style: AppTextStyle.style_14_600(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
