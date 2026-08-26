import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StaffTrackingView extends StatelessWidget {
  const StaffTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      body: const GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(20.296058, 85.824539), // Default center
          zoom: 12,
        ),
        myLocationEnabled: true,
      ),
    );
  }
}
