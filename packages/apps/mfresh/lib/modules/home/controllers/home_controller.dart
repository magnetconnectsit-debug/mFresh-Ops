import 'package:get/get.dart';

class HomeController extends GetxController {
  final cityController = ''.obs;
  final unitNumberController = ''.obs;

  // Placeholder data for units
  final List<Map<String, String>> units = [
    {
      'unitNo': 'MM20250001',
      'location': 'Near Bagala Dharmsala, Puri',
      'timing': '7 A.M. to 8 P.M.',
    },
    {
      'unitNo': 'MM25002',
      'location': 'Near Bagala Dharmsala, Puri',
      'timing': '7 A.M. to 8 P.M.',
    },
    {
      'unitNo': 'MM25003',
      'location': 'Near Bagala Dharmsala, Puri',
      'timing': '7 A.M. to 8 P.M.',
    },
    {
      'unitNo': 'MM25004',
      'location': 'Near Bagala Dharmsala, Puri',
      'timing': '7 A.M. to 8 P.M.',
    },
  ];
}
