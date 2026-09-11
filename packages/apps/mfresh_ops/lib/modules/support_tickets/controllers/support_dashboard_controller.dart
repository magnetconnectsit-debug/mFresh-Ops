import 'package:get/get.dart';

class SupportDashboardController extends GetxController {
  final isLoading = false.obs;

  // Filter state
  final selectedUnits = <String>[].obs;
  final dateFilter = 'Custom'.obs;
  final fromDate = Rxn<DateTime>();
  final toDate = Rxn<DateTime>();
  final selectedStatuses = <String>[].obs;
  final selectedCategories = <String>[].obs;
  final selectedAssignees = <String>[].obs;

  // Summary Cards
  final openTickets = 100.obs;
  final holdTickets = 12.obs;
  final resolvedTickets = 691.obs;
  final totalTickets = 821.obs;

  // Dummy Chart Data
  final statusData = [
    {'label': 'New', 'value': 61},
    {'label': 'WIP', 'value': 39},
    {'label': 'Hold', 'value': 12},
    {'label': 'Awaited', 'value': 18},
    {'label': 'Resolved', 'value': 573},
    {'label': 'Closed', 'value': 118},
  ].obs;

  final unitsData = [
    {'label': 'MM25001', 'value': 12},
    {'label': 'MM25002', 'value': 110},
    {'label': 'MM25003', 'value': 104},
    {'label': 'MM25004', 'value': 74},
    {'label': 'MM25005', 'value': 30},
    {'label': 'Other', 'value': 491},
  ].obs;

  final categoryData = [
    // This is for stacked bar chart, simplified for now
    {'label': 'Advertisement', 'value': 4},
    {'label': 'Cleaning', 'value': 5},
    {'label': 'Construction', 'value': 12},
    {'label': 'Design', 'value': 56},
    {'label': 'Documentation', 'value': 11},
    {'label': 'Implementation', 'value': 3},
    {'label': 'Info Doc', 'value': 6},
    {'label': 'IT', 'value': 293},
    {'label': 'Maintenance', 'value': 250},
    {'label': 'Manufacturing', 'value': 5},
    {'label': 'Marketing', 'value': 15},
    {'label': 'Others', 'value': 161},
  ].obs;

  // Dummy Assignee Report
  final assigneeReport = [
    {'name': 'Abhiram', 'total': 1, 'open': 0, 'hold': 0, 'awaited': 0, 'resolved': 1},
    {'name': 'Ajay Sir', 'total': 1, 'open': 0, 'hold': 0, 'awaited': 0, 'resolved': 1},
    {'name': 'Ajay Sharma', 'total': 3, 'open': 1, 'hold': 0, 'awaited': 0, 'resolved': 2},
    {'name': 'Sweta Jindal', 'total': 155, 'open': 1, 'hold': 0, 'awaited': 3, 'resolved': 151},
  ].obs;

  // Trend Chart Data (dummy)
  final trendDates = ['17 May', '18 May', '19 May', '20 May', '21 May', '22 May', '23 May'];
  final trendSeries = [
    {
      'name': 'Sweta Jindal',
      'color': '#2196F3',
      'data': [0, 1, 2, 1, 3, 1, 0]
    },
    {
      'name': 'Kanhaiya Agrawal',
      'color': '#FF9800',
      'data': [0, 3, 1, 1, 0, 0, 0]
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  void fetchDashboard() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    isLoading.value = false;
  }

  void resetFilters() {
    selectedUnits.clear();
    dateFilter.value = 'Custom';
    fromDate.value = null;
    toDate.value = null;
    selectedStatuses.clear();
    selectedCategories.clear();
    selectedAssignees.clear();
  }

  void applyFilters() {
    fetchDashboard();
  }
}
