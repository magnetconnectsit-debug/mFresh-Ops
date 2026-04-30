import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:services/services.dart';
import 'package:models/models.dart';
import 'package:core/utils/app_export_utils.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';

class SupportTicketsController extends GetxController {
  final SupportRepository _supportRepository = Get.find<SupportRepository>();

  final tickets = <SupportTicketListItem>[].obs;
  final projectCounts = <ProjectCount>[].obs;
  final unitCounts = <UnitCount>[].obs;
  final totalTickets = 0.obs;
  final isLoading = false.obs;

  final selectedTickets = <int>{}.obs;
  final isSearching = false.obs;
  final searchController = TextEditingController();

  // Filters
  final categories = <SupportCategory>[].obs;
  final subCategories = <SupportSubCategory>[].obs;
  final projects = <SupportProject>[].obs;
  final units = <SupportUnit>[].obs;
  final assignees = <AssigneeModel>[].obs;
  final priorities = ['Low', 'Medium', 'High', 'Top Priority'].obs;
  final statuses = ['New', 'WIP', 'Hold', 'Awaited', 'Resolved', 'Closed'].obs;

  // Selected Filters
  final selectedCategories = <SupportCategory>[].obs;
  final selectedSubCategory = Rxn<SupportSubCategory>();
  final selectedProjects = <SupportProject>[].obs;
  final selectedUnits = <SupportUnit>[].obs;
  final selectedAssignees = <AssigneeModel>[].obs;
  final selectedPriority = Rxn<String>();
  final selectedStatuses = <String>[].obs;

  // Dropdown Options
  List<DropdownOption<SupportCategory>> get categoryOptions => 
    categories.map((e) => DropdownOption(value: e, label: e.categoryName)).toList();
  
  List<DropdownOption<SupportSubCategory>> get subCategoryOptions => 
    subCategories.map((e) => DropdownOption(value: e, label: e.subCategoryName)).toList();
  
  List<DropdownOption<SupportProject>> get projectOptions => 
    projects.map((e) => DropdownOption(value: e, label: e.projectName)).toList();
  
  List<DropdownOption<SupportUnit>> get unitOptions => 
    units.map((e) => DropdownOption(value: e, label: e.unitName)).toList();
  
  List<DropdownOption<AssigneeModel>> get assigneeOptions => 
    assignees.map((e) => DropdownOption(value: e, label: e.name)).toList();
  
  List<DropdownOption<String>> get priorityOptions => 
    priorities.map((e) => DropdownOption(value: e, label: e)).toList();
  
  List<DropdownOption<String>> get statusOptions => 
    statuses.map((e) => DropdownOption(value: e, label: e)).toList();

  @override
  void onInit() {
    super.onInit();
    fetchTickets();
    fetchFilterData();
  }

  Future<void> fetchFilterData() async {
    try {
      await Future.wait([
        fetchUnits(),
        fetchCategories(),
        fetchProjects(),
        fetchAssignees(),
      ]);
    } catch (e) {
      debugPrint('Error fetching filters: $e');
    }
  }

  Future<void> fetchUnits() async {
    try {
      final result = await _supportRepository.getSupportUnits();
      units.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching units: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      final result = await _supportRepository.getSupportCategories();
      categories.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> fetchProjects() async {
    try {
      final result = await _supportRepository.getSupportProjects();
      projects.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching projects: $e');
    }
  }

  Future<void> fetchSubCategories(int categoryId) async {
    try {
      final result = await _supportRepository.getSupportSubCategories(categoryId);
      subCategories.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching subcategories: $e');
    }
  }

  Future<void> fetchAssignees() async {
    try {
      final storage = Get.find<StorageService>();
      final user = storage.getUser();
      if (user == null) return;
      final result = await Get.find<CommonRepository>().getAllAssignees(mainId: user.id.toString());
      assignees.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching assignees: $e');
    }
  }

  void resetFilters() {
    selectedCategories.clear();
    selectedSubCategory.value = null;
    selectedProjects.clear();
    selectedUnits.clear();
    selectedAssignees.clear();
    selectedPriority.value = null;
    selectedStatuses.clear();
    subCategories.clear();
    fetchTickets();
  }

  void removeFilter(dynamic item) {
    if (item is SupportCategory) {
      selectedCategories.remove(item);
      if (selectedCategories.isEmpty) {
        subCategories.clear();
        selectedSubCategory.value = null;
      }
    } else if (item is SupportSubCategory) {
      selectedSubCategory.value = null;
    } else if (item is SupportProject) {
      selectedProjects.remove(item);
    } else if (item is SupportUnit) {
      selectedUnits.remove(item);
    } else if (item is AssigneeModel) {
      selectedAssignees.remove(item);
    } else if (item is String) {
      if (selectedPriority.value == item) selectedPriority.value = null;
      selectedStatuses.remove(item);
    }
  }

  void applyFilters() {
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    try {
      isLoading.value = true;
      final response = await _supportRepository.getAllSupportTickets(
        globalSearch: searchController.text,
        mcatIds: selectedCategories.map((e) => e.categoryId).toList(),
        subMcatIds: selectedSubCategory.value != null ? [selectedSubCategory.value!.subCategoryId] : [],
        projectIds: selectedProjects.map((e) => e.projectId).toList(),
        unitIds: selectedUnits.map((e) => e.unitId).toList(),
        statusIds: [], // Need mapping if numeric
        assigneeIds: selectedAssignees.map((e) => e.id).toList(),
      );
      if (response != null) {
        tickets.assignAll(response.data);
        projectCounts.assignAll(response.projectCounts);
        unitCounts.assignAll(response.unitCounts);
        totalTickets.value = response.totalTickets;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch tickets: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      fetchTickets();
    }
  }

  void toggleTicketSelection(int id) {
    if (selectedTickets.contains(id)) {
      selectedTickets.remove(id);
    } else {
      selectedTickets.add(id);
    }
  }

  Future<void> exportTickets({bool isPdf = false}) async {
    try {
      // Prepare Data
      List<String> columns = [
        "Ticket ID",
        "Unit No.",
        "Subject",
        "Project",
        "Category",
        "Sub-Category",
        "Status",
        "Priority",
        "Assignee",
        "Posted Date",
      ];

      List<List<dynamic>> rows = tickets.map((ticket) => [
        ticket.id,
        ticket.unitNo ?? '',
        ticket.subject ?? '',
        ticket.project ?? '',
        ticket.mCategory ?? '',
        ticket.subCat ?? '',
        ticket.statusLabel ?? '',
        ticket.priorityLabel ?? '',
        ticket.assignedTo ?? '',
        ticket.postedDate ?? '',
      ]).toList();

      if (isPdf) {
        await AppExportUtils.exportToPdf(
          title: "Support Tickets",
          columns: columns,
          rows: rows,
        );
      } else {
        await AppExportUtils.exportToExcel(
          title: "Support Tickets",
          columns: columns,
          rows: rows,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to export tickets: $e');
    }
  }
}

class TicketModel {
  final String id;
  final String unitNo;
  final String subject;
  final String project;
  final String category;
  final String subCategory;
  final String status;
  final String priority;
  final String assignee;
  final String comment;
  final String followUpOn;
  final String tktAge;

  TicketModel({
    required this.id,
    required this.unitNo,
    required this.subject,
    required this.project,
    required this.category,
    required this.subCategory,
    required this.status,
    required this.priority,
    required this.assignee,
    this.comment = '',
    required this.followUpOn,
    required this.tktAge,
  });
}
