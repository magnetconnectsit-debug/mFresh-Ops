import 'dart:convert';

class QuickFilter {
  final int id;
  final String name;
  final QuickFilterData filters;
  final String userid;
  final String createdAt;
  final String updatedAt;

  QuickFilter({
    required this.id,
    required this.name,
    required this.filters,
    required this.userid,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuickFilter.fromJson(Map<String, dynamic> json) {
    final rawFilters = json['filters'];
    late QuickFilterData filtersData;
    if (rawFilters is String) {
      filtersData = QuickFilterData.fromJson(jsonDecode(rawFilters));
    } else if (rawFilters is Map<String, dynamic>) {
      filtersData = QuickFilterData.fromJson(rawFilters);
    } else {
      filtersData = QuickFilterData.empty();
    }
    return QuickFilter(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      filters: filtersData,
      userid: json['userid']?.toString() ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuickFilter && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class QuickFilterData {
  final List<String> tableAssignee;
  final List<String> mcatid;
  final String? submcatid;
  final List<String> selectedUnits;
  final List<String> statusid;
  final List<String> selectedProject;
  final String? priorityId;
  final String? globalsearch;

  QuickFilterData({
    required this.tableAssignee,
    required this.mcatid,
    this.submcatid,
    required this.selectedUnits,
    required this.statusid,
    required this.selectedProject,
    this.priorityId,
    this.globalsearch,
  });

  factory QuickFilterData.fromJson(Map<String, dynamic> json) {
    List<String> _toStringList(dynamic v) {
      if (v == null) return [];
      if (v is List) return v.map((e) => e.toString()).toList();
      return [];
    }

    return QuickFilterData(
      tableAssignee: _toStringList(json['table_assignee']),
      mcatid: _toStringList(json['mcatid']),
      submcatid: json['submcatid']?.toString(),
      selectedUnits: _toStringList(json['selectedUnits']),
      statusid: _toStringList(json['statusid']),
      selectedProject: _toStringList(json['selectedProject']),
      priorityId: json['priorityId']?.toString(),
      globalsearch: json['globalsearch']?.toString(),
    );
  }

  factory QuickFilterData.empty() {
    return QuickFilterData(
      tableAssignee: [],
      mcatid: [],
      selectedUnits: [],
      statusid: [],
      selectedProject: [],
    );
  }

  Map<String, dynamic> toJson() => {
    'table_assignee': tableAssignee,
    'mcatid': mcatid,
    'submcatid': submcatid,
    'selectedUnits': selectedUnits,
    'statusid': statusid,
    'selectedProject': selectedProject,
    'priorityId': priorityId,
    'globalsearch': globalsearch,
  };
}
