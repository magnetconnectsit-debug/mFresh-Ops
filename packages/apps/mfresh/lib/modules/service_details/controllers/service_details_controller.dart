import 'package:get/get.dart';

class ServiceItem {
  final String name;
  final int price;
  final RxInt quantity;

  ServiceItem({
    required this.name,
    required this.price,
    int initialQty = 0,
  }) : quantity = initialQty.obs;
}

class ServiceDetailsController extends GetxController {
  // Unit info
  final unitNo = ''.obs;
  final location = ''.obs;

  // Toggle states
  final isCustomer = true.obs; // true = Customer, false = Membership
  final isOnline = true.obs;

  // Contact details
  final mobileController = ''.obs;
  final nameController = ''.obs;
  final createAccount = false.obs;

  // Services list
  final services = <ServiceItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Get arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      unitNo.value = args['unitNo']?.toString() ?? 'MM25004';
      location.value = args['location']?.toString() ?? 'Ballapanda, Puri';
    }
    _initServices();
  }

  void _initServices() {
    services.value = [
      ServiceItem(name: 'Toilet - Male', price: 50),
      ServiceItem(name: 'Toilet - Female', price: 50),
      ServiceItem(name: 'Urinal - Male', price: 50),
      ServiceItem(name: 'Urinal - Female', price: 50),
      ServiceItem(name: 'Shower - Male', price: 50),
      ServiceItem(name: 'Shower - Female', price: 50),
      ServiceItem(name: 'Shower - Kiddo', price: 50),
      ServiceItem(name: 'Shower + Locker', price: 50),
      ServiceItem(name: 'Dress Change', price: 50),
      ServiceItem(name: 'Locker', price: 50),
      ServiceItem(name: 'Mobile Charging', price: 50),
      ServiceItem(name: 'Dental Kit', price: 50),
      ServiceItem(name: 'D&S Fee 1', price: 50),
      ServiceItem(name: 'D&S Fee 2', price: 50),
    ];
  }

  void increment(int index) {
    services[index].quantity.value++;
  }

  void decrement(int index) {
    if (services[index].quantity.value > 0) {
      services[index].quantity.value--;
    }
  }

  int get total {
    int sum = 0;
    for (var s in services) {
      sum += s.price * s.quantity.value;
    }
    return sum;
  }

  void toggleCustomerType(bool isCustomerSelected) {
    isCustomer.value = isCustomerSelected;
  }

  void toggleOnline() {
    isOnline.value = !isOnline.value;
  }
}
