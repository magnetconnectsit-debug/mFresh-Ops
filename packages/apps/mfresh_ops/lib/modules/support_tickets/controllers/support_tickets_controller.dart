import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:services/services.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/data/repositories/support_repository.dart';
import 'package:mfresh_ops/data/repositories/common_repository.dart';
import 'package:core/utils/app_export_utils.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import 'package:core/utils/app_common_toast_message.dart';

class SupportTicketsController extends GetxController {
  final SupportRepository _supportRepository = Get.find<SupportRepository>();

  final tickets = <SupportTicketListItem>[].obs;
  final projectCounts = <ProjectCount>[].obs;
  final unitCounts = <UnitCount>[].obs;
  final totalTickets = 0.obs;
  final isLoading = false.obs;

  final selectedTickets = <int>{}.obs;
  final expandedSubjectTickets = <int>{}.obs;
  final isSearching = false.obs;
  final searchController = TextEditingController();
  final searchFocusNode = FocusNode();
  final searchQuery = "".obs;

  List<SupportTicketListItem> get filteredTickets {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return tickets;
    }
    return tickets.where((ticket) {
      return (ticket.id.toString().contains(query)) ||
          (ticket.caseId?.toLowerCase().contains(query) ?? false) ||
          (ticket.subject?.toLowerCase().contains(query) ?? false) ||
          (ticket.description?.toLowerCase().contains(query) ?? false) ||
          (ticket.project?.toLowerCase().contains(query) ?? false) ||
          (ticket.mCategory?.toLowerCase().contains(query) ?? false) ||
          (ticket.subCat?.toLowerCase().contains(query) ?? false) ||
          (ticket.statusLabel?.toLowerCase().contains(query) ?? false) ||
          (ticket.priorityLabel?.toLowerCase().contains(query) ?? false) ||
          (ticket.assignedTo?.toLowerCase().contains(query) ?? false) ||
          (ticket.createdBy?.toLowerCase().contains(query) ?? false) ||
          (ticket.unitNo?.toLowerCase().contains(query) ?? false) ||
          (ticket.district?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

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

  // Quick Filters
  final quickFilters = <QuickFilter>[].obs;
  final selectedQuickFilter = Rxn<QuickFilter>();
  final isSavingFilter = false.obs;

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
    _initialLoad();
  }

  @override
  void onClose() {
    searchFocusNode.dispose();
    super.onClose();
  }

  Future<void> _initialLoad() async {
    try {
      isLoading.value = true;
      // Load all filters sequentially to ensure order and avoid parallel fetchTickets calls
      await fetchUnits();
      await fetchCategories();
      await fetchProjects();
      await fetchAssignees(shouldFetchTickets: false); // Don't fetch yet

      // Now fetch tickets with all filters applied (including default assignee)
      await fetchTickets();

      // Load quick filters in background
      fetchQuickFilters();
    } catch (e) {
      debugPrint('Error during initial load: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFilterData() async {
    try {
      await Future.wait([
        fetchUnits(),
        fetchCategories(),
        fetchProjects(),
        fetchAssignees(shouldFetchTickets: false),
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

  Future<void> fetchAssignees({bool shouldFetchTickets = true}) async {
    try {
      final storage = Get.find<StorageService>();
      final user = storage.getUser();
      if (user == null) return;
      
      final result = await Get.find<CommonRepository>().getAllAssignees(mainId: user.id.toString());
      assignees.assignAll(result);

      // Default select the current user
      if (selectedAssignees.isEmpty) {
        var currentUser = assignees.firstWhereOrNull((a) => a.id.toString() == user.id.toString());
        
        // If current user not in list, add them manually so they can be selected
        if (currentUser == null) {
          debugPrint('fetchAssignees: Current user ${user.id} not in list, adding manually');
          currentUser = AssigneeModel(id: user.id, name: user.name ?? 'Me');
          assignees.insert(0, currentUser);
        }

        selectedAssignees.assignAll([currentUser]);
        if (shouldFetchTickets) {
          fetchTickets();
        }
      }
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
    
    searchController.clear();
    searchQuery.value = '';
    isSearching.value = false;

    final storage = Get.find<StorageService>();
    final user = storage.getUser();
    if (user != null) {
      var currentUser = assignees.firstWhereOrNull((a) => a.id.toString() == user.id.toString());
      if (currentUser != null) {
        selectedAssignees.assignAll([currentUser]);
      }
    }

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

  Future<void> refreshAll() async {
    try {
      // Parallel fetch: all metadata + tickets + quick filters
      await Future.wait([
        fetchUnits(),
        fetchCategories(),
        fetchProjects(),
        fetchAssignees(shouldFetchTickets: false),
        fetchQuickFilters(),
      ]);
      // Fetch tickets after metadata is ready (to respect current filters)
      await fetchTickets();
    } catch (e) {
      debugPrint('Error during refresh: $e');
    }
  }

  Future<void> fetchQuickFilters() async {
    try {
      final result = await _supportRepository.getQuickFilters();
      quickFilters.assignAll(result);

      // Re-sync selected reference so the DropdownButton value matches an
      // item in the new list (required for == to work after list refresh).
      final currentId = selectedQuickFilter.value?.id;
      if (currentId != null) {
        selectedQuickFilter.value = quickFilters.firstWhereOrNull((f) => f.id == currentId);
      }
    } catch (e) {
      debugPrint('Error fetching quick filters: $e');
    }
  }

  Future<void> saveCurrentFilter(String name) async {
    try {
      isSavingFilter.value = true;

      // Build the filters payload matching the API format
      final filtersPayload = {
        'table_assignee': selectedAssignees.map((a) => a.name).toList(),
        'mcatid': selectedCategories.map((c) => c.categoryId.toString()).toList(),
        'submcatid': selectedSubCategory.value?.subCategoryId.toString() ?? '',
        'selectedUnits': selectedUnits.map((u) => u.unitId.toString()).toList(),
        'statusid': selectedStatuses,
        'selectedProject': selectedProjects.map((p) => p.projectId.toString()).toList(),
        'priorityId': selectedPriority.value ?? '',
        'globalsearch': searchController.text,
      };

      final success = await _supportRepository.saveFilter(
        name: name,
        filters: filtersPayload,
      );

      if (success) {
        AppCommonToastMessage.show(message: 'Filter "$name" saved!', type: ToastType.success);
        fetchQuickFilters(); // Refresh list
      } else {
        AppCommonToastMessage.show(message: 'Failed to save filter', type: ToastType.error);
      }
    } catch (e) {
      AppCommonToastMessage.show(message: 'Error saving filter: $e', type: ToastType.error);
    } finally {
      isSavingFilter.value = false;
    }
  }

  void applyQuickFilter(QuickFilter filter) {
    selectedQuickFilter.value = filter;
    final f = filter.filters;

    // Apply statuses
    selectedStatuses.assignAll(f.statusid);

    // Apply assignees by name
    if (f.tableAssignee.isNotEmpty) {
      final matched = assignees
          .where((a) => f.tableAssignee.contains(a.name))
          .toList();
      selectedAssignees.assignAll(matched);
    } else {
      selectedAssignees.clear();
    }

    // Apply categories
    if (f.mcatid.isNotEmpty) {
      final matched = categories
          .where((c) => f.mcatid.contains(c.categoryId.toString()))
          .toList();
      selectedCategories.assignAll(matched);
    } else {
      selectedCategories.clear();
    }

    // Apply projects
    if (f.selectedProject.isNotEmpty) {
      final matched = projects
          .where((p) => f.selectedProject.contains(p.projectId.toString()))
          .toList();
      selectedProjects.assignAll(matched);
    } else {
      selectedProjects.clear();
    }

    // Apply units
    if (f.selectedUnits.isNotEmpty) {
      final matched = units
          .where((u) => f.selectedUnits.contains(u.unitId.toString()))
          .toList();
      selectedUnits.assignAll(matched);
    } else {
      selectedUnits.clear();
    }

    fetchTickets();
  }

  Future<void> fetchTickets() async {
    try {
      isLoading.value = true;
      debugPrint('fetchTickets: Fetching with assigneeIds: ${selectedAssignees.map((e) => e.id).toList()}');
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
      AppCommonToastMessage.show(message: 'Failed to fetch tickets: $e', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    searchQuery.value = '';
    searchController.clear();
    
    if (isSearching.value) {
      Future.delayed(const Duration(milliseconds: 100), () {
        searchFocusNode.requestFocus();
      });
    }
  }

  void toggleTicketSelection(int id) {
    if (selectedTickets.contains(id)) {
      selectedTickets.remove(id);
    } else {
      selectedTickets.add(id);
    }
    selectedTickets.refresh();
  }

  void toggleSubjectExpansion(int id) {
    if (expandedSubjectTickets.contains(id)) {
      expandedSubjectTickets.remove(id);
    } else {
      expandedSubjectTickets.add(id);
    }
    expandedSubjectTickets.refresh();
  }

  void selectAllTickets(bool? select) {
    if (select == true) {
      // Select all visible tickets
      selectedTickets.assignAll(filteredTickets.map((t) => t.id).toList());
    } else {
      // Deselect all visible tickets
      final visibleIds = filteredTickets.map((t) => t.id).toSet();
      selectedTickets.removeWhere((id) => visibleIds.contains(id));
      selectedTickets.refresh();
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

      List<List<dynamic>> rows = filteredTickets.map((ticket) => [
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
      AppCommonToastMessage.show(message: 'Failed to export tickets: $e', type: ToastType.error);
    }
  }
  // Bulk Edit Dialog Variables
  final bulkSelectedUnit = Rxn<SupportUnit>();
  final bulkEnableUnit = false.obs;

  final bulkSelectedPriority = Rxn<String>();
  final bulkEnablePriority = false.obs;

  final bulkSelectedStatus = Rxn<String>();
  final bulkEnableStatus = false.obs;

  final bulkSelectedCategory = Rxn<SupportCategory>();
  final bulkEnableCategory = false.obs;

  final bulkSelectedSubCategory = Rxn<SupportSubCategory>();
  final bulkEnableSubCategory = false.obs;
  final bulkSubCategories = <SupportSubCategory>[].obs;

  final bulkSelectedAssignee = Rxn<AssigneeModel>();
  final bulkEnableAssignee = false.obs;

  Future<void> fetchBulkSubCategories(int categoryId) async {
    try {
      final result = await _supportRepository.getSupportSubCategories(categoryId);
      bulkSubCategories.assignAll(result);
      bulkSelectedSubCategory.value = null; // reset
    } catch (e) {
      debugPrint('Error fetching bulk subcategories: $e');
    }
  }

  void resetBulkEdit() {
    bulkSelectedUnit.value = null;
    bulkEnableUnit.value = false;
    bulkSelectedPriority.value = null;
    bulkEnablePriority.value = false;
    bulkSelectedStatus.value = null;
    bulkEnableStatus.value = false;
    bulkSelectedCategory.value = null;
    bulkEnableCategory.value = false;
    bulkSelectedSubCategory.value = null;
    bulkEnableSubCategory.value = false;
    bulkSubCategories.clear();
    bulkSelectedAssignee.value = null;
    bulkEnableAssignee.value = false;
  }

  Future<void> submitBulkEdit() async {
    if (selectedTickets.isEmpty) {
      AppCommonToastMessage.show(message: 'Please select at least one ticket', type: ToastType.error);
      return;
    }

    bool hasUpdates = (bulkEnableUnit.value && bulkSelectedUnit.value != null) ||
                      (bulkEnablePriority.value && bulkSelectedPriority.value != null) ||
                      (bulkEnableStatus.value && bulkSelectedStatus.value != null) ||
                      (bulkEnableCategory.value && bulkSelectedCategory.value != null) ||
                      (bulkEnableSubCategory.value && bulkSelectedSubCategory.value != null) ||
                      (bulkEnableAssignee.value && bulkSelectedAssignee.value != null);

    if (!hasUpdates) {
      AppCommonToastMessage.show(message: 'Please check at least one field and select a value to update.', type: ToastType.error);
      return;
    }

    try {
      isLoading.value = true;
      final storage = Get.find<StorageService>();
      final user = storage.getUser();
      if (user == null) {
        isLoading.value = false;
        return;
      }

      Map<String, dynamic> data = {
        "ticket_ids": selectedTickets.join(","),
        "userid": user.id.toString(),
      };

      if (bulkEnableUnit.value && bulkSelectedUnit.value != null) {
        data["munitId"] = bulkSelectedUnit.value!.unitId.toString();
      }
      if (bulkEnablePriority.value && bulkSelectedPriority.value != null) {
        data["priority"] = _getPriorityId(bulkSelectedPriority.value);
      }
      if (bulkEnableStatus.value && bulkSelectedStatus.value != null) {
        data["resolved_status"] = _getStatusId(bulkSelectedStatus.value);
      }
      if (bulkEnableCategory.value && bulkSelectedCategory.value != null) {
        data["mcatid"] = bulkSelectedCategory.value!.categoryId.toString();
      }
      if (bulkEnableSubCategory.value && bulkSelectedSubCategory.value != null) {
        data["bsubmcatid"] = bulkSelectedSubCategory.value!.subCategoryId.toString();
      }
      if (bulkEnableAssignee.value && bulkSelectedAssignee.value != null) {
        data["assignid"] = bulkSelectedAssignee.value!.id.toString();
      }

      final response = await _supportRepository.bulkUpdateTickets(data);
      if (response != null && response['status'] == true) {
        Get.back(); // close dialog
        selectedTickets.clear();
        AppCommonToastMessage.show(message: response['message'] ?? 'Tickets updated successfully', type: ToastType.success);
        fetchTickets();
      } else {
        AppCommonToastMessage.show(message: response?['message'] ?? 'Failed to update tickets', type: ToastType.error);
      }
    } catch (e) {
      AppCommonToastMessage.show(message: 'An error occurred: $e', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  String _getPriorityId(String? priority) {
    switch (priority) {
      case 'Low': return '1';
      case 'Medium': return '2';
      case 'High': return '3';
      case 'Top Priority': return '6';
      default: return '2';
    }
  }

  String _getStatusId(String? status) {
    switch (status) {
      case 'New': return '0';
      case 'WIP': return '1';
      case 'Resolved': return '2';
      case 'Closed': return '3';
      case 'Hold': return '4';
      case 'Awaited': return '5';
      default: return '0';
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
