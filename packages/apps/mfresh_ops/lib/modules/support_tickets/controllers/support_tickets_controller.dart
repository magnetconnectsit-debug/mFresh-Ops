import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:core/constants/app_colors.dart';
import 'package:services/services.dart';
import 'package:services/repositories/support_repository.dart';
import 'package:models/models.dart';
import 'package:core/utils/app_export_utils.dart';

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
  final selectedCategory = Rxn<SupportCategory>();
  final selectedSubCategory = Rxn<SupportSubCategory>();
  final selectedProject = Rxn<SupportProject>();
  final selectedUnit = Rxn<SupportUnit>();
  final selectedAssignee = Rxn<AssigneeModel>();
  final selectedPriority = Rxn<String>();
  final selectedStatus = Rxn<String>();

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
    selectedCategory.value = null;
    selectedSubCategory.value = null;
    selectedProject.value = null;
    selectedUnit.value = null;
    selectedAssignee.value = null;
    selectedPriority.value = null;
    selectedStatus.value = null;
    subCategories.clear();
    fetchTickets();
  }

  void applyFilters() {
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    try {
      isLoading.value = true;
      final response = await _supportRepository.getAllSupportTickets(
        globalSearch: searchController.text,
        mcatIds: selectedCategory.value != null ? [selectedCategory.value!.categoryId] : [],
        subMcatIds: selectedSubCategory.value != null ? [selectedSubCategory.value!.subCategoryId] : [],
        projectIds: selectedProject.value != null ? [selectedProject.value!.projectId] : [],
        unitIds: selectedUnit.value != null ? [selectedUnit.value!.unitId] : [],
        statusIds: [], // Need mapping if numeric
        assigneeIds: selectedAssignee.value != null ? [selectedAssignee.value!.id] : [],
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
      if (isPdf) {
        await AppExportUtils.exportToPdf(
          title: "Support Tickets",
        );
        return;
      }

      // Prepare Data for Excel
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

      await AppExportUtils.exportToExcel(
        title: "Support Tickets",
        columns: columns,
        rows: rows,
      );
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
