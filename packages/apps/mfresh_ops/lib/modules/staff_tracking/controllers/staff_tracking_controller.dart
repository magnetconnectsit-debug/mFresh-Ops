import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mfresh_ops/data/repositories/tracking_repository.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
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
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

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
  final RxBool hasFetchedOnce = false.obs;
  final TextEditingController searchController = TextEditingController();
  final RxString selectedFilter = 'Total'.obs;
  final RxSet<dynamic> selectedEmployeeIds = <dynamic>{}.obs;

  final RxSet<Marker> employeeMarkers = <Marker>{}.obs;
  final RxSet<Circle> employeeCircles = <Circle>{}.obs;
  final RxSet<Polyline> employeePolylines = <Polyline>{}.obs;
  GoogleMapController? mapController;

  final RxDouble currentZoom = 14.0.obs;
  Timer? _debounceTimer;
  Timer? _pollingTimer;
  Timer? _rippleTimer;
  double _rippleFactor = 0.0;

  // Cache for marker icons to avoid recreating bitmaps continuously
  final Map<String, BitmapDescriptor> _markerCache = {};
  int _updateMarkerGeneration = 0;
  bool _pendingFitBounds = false;
  int _lastZoomFloor = -1;
  bool _lastSpiderifyState = false;

  final RxMap<String, dynamic> selectedEmployeeLiveStats =
      <String, dynamic>{}.obs;
  final RxBool isLoadingLiveStats = false.obs;

  final Rx<MapType> currentMapType = MapType.normal.obs;
  bool _hasInitialFit = false;

  void toggleMapType() {
    currentMapType.value = currentMapType.value == MapType.normal
        ? MapType.satellite
        : MapType.normal;
  }

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (tabController.index == 1 && _pendingFitBounds) {
        _pendingFitBounds = false;
        Future.delayed(const Duration(milliseconds: 300), () {
          fitBounds();
        });
      }
    });
    searchController.addListener(filterEmployees);
    _checkLocationPermissions();
    fetchEmployees();
    _startPolling();
    _startRippleAnimation();
  }

  Future<void> _checkLocationPermissions() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Location Disabled',
          'Please turn on your location.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        await Geolocator.openLocationSettings();
      }

      var permission = await Permission.locationWhenInUse.status;
      if (permission.isDenied) {
        await Permission.locationWhenInUse.request();
      }
    } catch (e) {
      debugPrint('Error checking location permissions: $e');
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    searchController.dispose();
    _debounceTimer?.cancel();
    _pollingTimer?.cancel();
    _rippleTimer?.cancel();
    super.onClose();
  }

  void _startRippleAnimation() {
    _rippleTimer?.cancel();
    _rippleTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      _rippleFactor += 0.03;
      if (_rippleFactor > 1.0) {
        _rippleFactor = 0.0;
      }
      _animateCircles();
    });
  }

  void _animateCircles() {
    if (employeeCircles.isEmpty) return;

    final List<Circle> updated = [];
    for (var circle in employeeCircles) {
      if (circle.circleId.value.startsWith('ripple_')) {
        final isInner = circle.circleId.value.startsWith('ripple_inner_');
        final double scaleFactor = pow(
          2.0,
          max(0.0, currentZoom.value - 12.0),
        ).toDouble();
        final double radius = isInner
            ? (120.0 + (180.0 * _rippleFactor)) / scaleFactor
            : (250.0 + (350.0 * _rippleFactor)) / scaleFactor;
        final double opacity = isInner
            ? 0.25 * (1.0 - _rippleFactor)
            : 0.12 * (1.0 - _rippleFactor);

        updated.add(
          circle.copyWith(
            radiusParam: radius,
            fillColorParam: AppColors.green.withValues(alpha: opacity),
            strokeColorParam: AppColors.green.withValues(alpha: opacity * 1.5),
          ),
        );
      } else {
        updated.add(circle);
      }
    }
    employeeCircles.assignAll(updated);
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
      if (!isSilent) {
        // Fetch profile to keep user permissions and settings up-to-date on manual refresh
        Get.find<AuthRepository>().fetchProfile();
      }
      
      final response = await _repository.getCurrentStatus();
      if (response != null && response['status'] == true) {
        final List emps = response['employees'] ?? [];
        allEmployees.value = emps
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        await filterEmployees(shouldFitBounds: !isSilent);
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
      hasFetchedOnce.value = true;
    }
  }

  void onCameraMove(CameraPosition position) {
    currentZoom.value = position.zoom;

    final int newZoomFloor = position.zoom.floor();
    final bool newSpiderifyState = position.zoom >= 15.5;

    // Only rebuild markers if the zoom change actually affects cluster groupings or spiderification
    if (_lastZoomFloor != newZoomFloor || _lastSpiderifyState != newSpiderifyState) {
      _lastZoomFloor = newZoomFloor;
      _lastSpiderifyState = newSpiderifyState;

      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 100), () {
        _updateMarkers(shouldFitBounds: false);
      });
    }
  }

  Future<void> filterEmployees({bool shouldFitBounds = true}) async {
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
        final bool isOnDuty =
            emp['is_on_duty'] == 1 ||
            emp['is_on_duty'] == true ||
            emp['is_on_duty'] == '1';
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
    _updateMarkers(shouldFitBounds: shouldFitBounds);
  }

  List<Map<String, dynamic>> _clusterEmployees(
    List<Map<String, dynamic>> employees,
    double zoom,
  ) {
    // Group markers into a visual grid based on zoom level
    double cellSize = 360.0 / (1 << zoom.floor()) * 0.4;

    Map<String, List<Map<String, dynamic>>> grid = {};
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
          int gridX = (lng / cellSize).floor();
          int gridY = (lat / cellSize).floor();
          grid.putIfAbsent('${gridX}_$gridY', () => []).add(emp);
        }
      }
    }

    List<Map<String, dynamic>> result = [];
    for (var group in grid.values) {
      if (group.length == 1) {
        result.add({
          'isCluster': false,
          'employees': group,
          'latitude': group[0]['latitude'],
          'longitude': group[0]['longitude'],
        });
      } else {
        if (zoom >= 15.5) {
          // High zoom: Spiderify overlapping markers in a circle
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

          // Scale spiderify radius based on zoom cell size so they don't overlap visually
          // Adjusted for a moderate spread so they are distinguishable but not across blocks
          double radius = cellSize * 0.35 + (group.length * cellSize * 0.04);
          for (int i = 0; i < group.length; i++) {
            double angle = (i * 2 * pi) / group.length;
            double offsetX = radius * cos(angle);
            // Adjust latitude offset to account for aspect ratio roughly
            double offsetY = radius * sin(angle) * 0.8;

            result.add({
              'isCluster': false,
              'employees': [group[i]],
              'latitude': centerLat + offsetY,
              'longitude': centerLng + offsetX,
              'originalLat': centerLat,
              'originalLng': centerLng,
            });
          }
        } else {
          // Low zoom: Show a normal cluster marker
          double sumLat = 0;
          double sumLng = 0;
          for (var emp in group) {
            sumLat +=
                double.tryParse(emp['latitude']?.toString() ?? '0') ?? 0.0;
            sumLng +=
                double.tryParse(emp['longitude']?.toString() ?? '0') ?? 0.0;
          }
          result.add({
            'isCluster': true,
            'employees': group,
            'count': group.length,
            'latitude': sumLat / group.length,
            'longitude': sumLng / group.length,
          });
        }
      }
    }
    return result;
  }

  Future<void> _updateMarkers({bool shouldFitBounds = false}) async {
    if (shouldFitBounds) {
      _pendingFitBounds = true;
    }

    _updateMarkerGeneration++;
    final int currentGeneration = _updateMarkerGeneration;

    final Set<Marker> newMarkers = {};
    final Set<Circle> newCircles = {};
    final Set<Polyline> newPolylines = {};
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
                final List employeesInCluster = cluster['employees'];
                double? minLat, maxLat, minLng, maxLng;
                for (var emp in employeesInCluster) {
                  double empLat = double.tryParse(emp['latitude']?.toString() ?? '0') ?? 0.0;
                  double empLng = double.tryParse(emp['longitude']?.toString() ?? '0') ?? 0.0;
                  if (empLat != 0.0 && empLng != 0.0) {
                    if (minLat == null || empLat < minLat) minLat = empLat;
                    if (maxLat == null || empLat > maxLat) maxLat = empLat;
                    if (minLng == null || empLng < minLng) minLng = empLng;
                    if (maxLng == null || empLng > maxLng) maxLng = empLng;
                  }
                }

                if (minLat != null && maxLat != null && minLng != null && maxLng != null) {
                  double latDiff = maxLat - minLat;
                  double lngDiff = maxLng - minLng;
                  
                  if (latDiff < 0.0005 && lngDiff < 0.0005) {
                    // Points are identical or extremely close, force zoom past spiderify threshold
                    mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2),
                        16.5,
                      ),
                    );
                  } else {
                    // Zoom exactly to fit all points in this cluster
                    mapController?.animateCamera(
                      CameraUpdate.newLatLngBounds(
                        LatLngBounds(
                          southwest: LatLng(minLat, minLng),
                          northeast: LatLng(maxLat, maxLng),
                        ),
                        80.0, // padding
                      ),
                    );
                  }
                }
              },
            ),
          );
        } else {
          // Individual employee
          final emp = cluster['employees'][0];
          final status = emp['current_status']?.toString().toLowerCase();

          final double? originalLat = cluster['originalLat'] != null
              ? double.tryParse(cluster['originalLat'].toString())
              : null;
          final double? originalLng = cluster['originalLng'] != null
              ? double.tryParse(cluster['originalLng'].toString())
              : null;

          if (originalLat != null && originalLng != null) {
            newPolylines.add(
              Polyline(
                polylineId: PolylineId('spider_${emp['id'] ?? emp['user_id']}'),
                points: [LatLng(originalLat, originalLng), LatLng(lat, lng)],
                color: Colors.grey.withValues(alpha: 0.6),
                width: 2,
                patterns: [PatternItem.dash(15), PatternItem.gap(10)],
              ),
            );
          }

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

          final bool isOnDuty =
              emp['is_on_duty'] == 1 || emp['is_on_duty'] == true;

          if (isOnDuty && lat != 0.0 && lng != 0.0) {
            final String empId = (emp['id'] ?? emp['user_id'] ?? '').toString();
            final double scaleFactor = pow(
              2.0,
              max(0.0, currentZoom.value - 12.0),
            ).toDouble();
            final double innerRadius =
                (120.0 + (180.0 * _rippleFactor)) / scaleFactor;
            final double outerRadius =
                (250.0 + (350.0 * _rippleFactor)) / scaleFactor;
            final double innerOpacity = 0.25 * (1.0 - _rippleFactor);
            final double outerOpacity = 0.12 * (1.0 - _rippleFactor);

            newCircles.add(
              Circle(
                circleId: CircleId('ripple_inner_$empId'),
                center: LatLng(lat, lng),
                radius: innerRadius,
                fillColor: AppColors.green.withValues(alpha: innerOpacity),
                strokeColor: AppColors.green.withValues(
                  alpha: innerOpacity * 1.5,
                ),
                strokeWidth: 2,
              ),
            );
            newCircles.add(
              Circle(
                circleId: CircleId('ripple_outer_$empId'),
                center: LatLng(lat, lng),
                radius: outerRadius,
                fillColor: AppColors.green.withValues(alpha: outerOpacity),
                strokeColor: AppColors.green.withValues(
                  alpha: outerOpacity * 1.5,
                ),
                strokeWidth: 1,
              ),
            );
          }

          final Color borderColor = isOnDuty ? AppColors.green : AppColors.red;

          final lastSeen = emp['last_seen'];
          final bool isStale = AppDateUtils.isOlderThanMinutes(
            lastSeen?.toString(),
            60,
          );
          final bool showLiveWifi = isOnDuty && !isStale;
          final bool showStaleWifi = isOnDuty && isStale;

          final String imageUrl = emp['image_url']?.toString() ?? '';
          final bool hasImage =
              imageUrl.isNotEmpty && !imageUrl.endsWith('/NA');

          final String cacheKey = hasImage
              ? 'emp_img_${emp['id']}_${markerColor.hashCode}_${borderColor.hashCode}_${showLiveWifi}_$showStaleWifi'
              : 'emp_${emp['id']}_${markerColor.hashCode}_${borderColor.hashCode}_${showLiveWifi}_$showStaleWifi';

          if (!_markerCache.containsKey(cacheKey)) {
            // Instantly create a text-based marker
            _markerCache[cacheKey] = await MapMarkerUtils.createCustomMarker(
              color: markerColor,
              text: initials,
              fullName: initials,
              borderColor: borderColor,
              showLiveWifi: showLiveWifi,
              showStaleWifi: showStaleWifi,
            );

            // Fetch network image asynchronously in the background
            if (hasImage) {
              _fetchImageMarkerInBackground(
                cacheKey: cacheKey,
                imageUrl: imageUrl,
                markerColor: markerColor,
                initials: initials,
                borderColor: borderColor,
                showLiveWifi: showLiveWifi,
                showStaleWifi: showStaleWifi,
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

    if (currentGeneration != _updateMarkerGeneration) return;

    employeeMarkers.assignAll(newMarkers);
    employeeCircles.assignAll(newCircles);
    employeePolylines.assignAll(newPolylines);

    bool shouldDoFit =
        _pendingFitBounds ||
        (!_hasInitialFit && newMarkers.isNotEmpty && mapController != null);

    if (shouldDoFit) {
      _hasInitialFit = true;
      _pendingFitBounds = false;
      // Slight delay to allow map to update before fitting bounds
      Future.delayed(const Duration(milliseconds: 600), () {
        fitBounds();
      });
    }
  }

  void fitBounds([int retries = 3]) {
    if (mapController == null || filteredEmployees.isEmpty) return;

    if (tabController.index != 1) {
      _pendingFitBounds = true;
      return;
    }

    List<double> lats = [];
    List<double> lngs = [];
    for (final emp in filteredEmployees) {
      final latStr = emp['latitude']?.toString();
      final lngStr = emp['longitude']?.toString();
      if (latStr != null &&
          lngStr != null &&
          latStr != 'null' &&
          lngStr != 'null') {
        double? lat = double.tryParse(latStr);
        double? lng = double.tryParse(lngStr);
        if (lat != null && lng != null && lat != 0.0 && lng != 0.0) {
          lats.add(lat);
          lngs.add(lng);
        }
      }
    }

    if (lats.isEmpty) return;

    lats.sort();
    lngs.sort();
    double medianLat = lats[lats.length ~/ 2];
    double medianLng = lngs[lngs.length ~/ 2];

    double? minLat, maxLat, minLng, maxLng;
    int validCount = 0;

    for (int i = 0; i < lats.length; i++) {
      double lat = lats[i];
      double lng = lngs[i];

      // Ignore severe outliers (e.g. wrong GPS across the country)
      // 10 degrees is roughly 1100km. Anything further from the median group is ignored.
      if ((lat - medianLat).abs() > 10.0 || (lng - medianLng).abs() > 10.0) {
        continue;
      }

      validCount++;
      if (minLat == null || lat < minLat) minLat = lat;
      if (maxLat == null || lat > maxLat) maxLat = lat;
      if (minLng == null || lng < minLng) minLng = lng;
      if (maxLng == null || lng > maxLng) maxLng = lng;
    }

    if (minLat != null && maxLat != null && minLng != null && maxLng != null) {
      if (validCount == 1) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(minLat, minLng), 14),
        );
      } else {
        // Enforce a minimum bounding box size to prevent excessive zooming
        // 0.02 degrees is roughly 2km
        double latDiff = maxLat - minLat;
        if (latDiff < 0.02) {
          double centerLat = (minLat + maxLat) / 2;
          minLat = centerLat - 0.01;
          maxLat = centerLat + 0.01;
        }
        double lngDiff = maxLng - minLng;
        if (lngDiff < 0.02) {
          double centerLng = (minLng + maxLng) / 2;
          minLng = centerLng - 0.01;
          maxLng = centerLng + 0.01;
        }

        mapController!
            .animateCamera(
              CameraUpdate.newLatLngBounds(
                LatLngBounds(
                  southwest: LatLng(minLat!, minLng!),
                  northeast: LatLng(maxLat!, maxLng!),
                ),
                50.0,
              ),
            )
            .catchError((e) {
              debugPrint('fitBounds error: $e');
              if (retries > 0) {
                // Map layout might not be ready yet. Retry after a delay.
                Future.delayed(const Duration(milliseconds: 500), () {
                  fitBounds(retries - 1);
                });
              } else {
                // Ultimate fallback to center zoom if bounds repeatedly fail
                double centerLat = (minLat! + maxLat!) / 2;
                double centerLng = (minLng! + maxLng!) / 2;
                mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(LatLng(centerLat, centerLng), 10),
                );
              }
            });
      }
    }
  }

  void _fetchImageMarkerInBackground({
    required String cacheKey,
    required String imageUrl,
    required Color markerColor,
    required String initials,
    required Color borderColor,
    required bool showLiveWifi,
    required bool showStaleWifi,
  }) async {
    try {
      final marker = await MapMarkerUtils.createNetworkImageMarker(
        imageUrl: imageUrl,
        color: markerColor,
        fallbackText: initials,
        borderColor: borderColor,
        showLiveWifi: showLiveWifi,
        showStaleWifi: showStaleWifi,
      );

      _markerCache[cacheKey] = marker;

      if (_debounceTimer?.isActive ?? false) return;
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _updateMarkers(shouldFitBounds: false);
      });
    } catch (e) {
      debugPrint('Failed background image fetch: $e');
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
                  '${double.tryParse(speed.toString())?.toStringAsFixed(2) ?? 0} km/h',
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

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color valueColor,
  ) {
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
    final RxSet<dynamic> tempSelectedIds = RxSet<dynamic>({
      ...selectedEmployeeIds,
    });
    final RxString searchSelectionQuery = ''.obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(maxHeight: Get.height * 0.75),
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
                            allEmployees
                                .map((e) => e['id'] ?? e['user_id'])
                                .toList(),
                          );
                        }
                      },
                      child: Obx(() {
                        final isAll =
                            tempSelectedIds.length == allEmployees.length;
                        return Text(
                          isAll ? 'Clear All' : 'Select All',
                          style: AppTextStyle.style_14_600(
                            color: AppColors.blue500,
                          ),
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
                      style: AppTextStyle.style_14_500(
                        color: AppColors.grey500,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.grey100),
                  itemBuilder: (context, index) {
                    final emp = list[index];
                    final id = emp['id'] ?? emp['user_id'];
                    return Obx(() {
                      final isChecked = tempSelectedIds.contains(id);
                      return CheckboxListTile(
                        value: isChecked,
                        title: Text(
                          emp['name'] ?? 'Unknown',
                          style: AppTextStyle.style_14_600(
                            color: AppColors.black,
                          ),
                        ),
                        subtitle: Text(
                          emp['mobile'] ?? 'No Mobile',
                          style: AppTextStyle.style_12_500(
                            color: AppColors.grey500,
                          ),
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
