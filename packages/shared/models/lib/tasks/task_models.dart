// region Models
class TaskProject {
  final int projectId;
  final String projectName;

  TaskProject({
    required this.projectId,
    required this.projectName,
  });

  factory TaskProject.fromJson(Map<String, dynamic> json) {
    return TaskProject(
      projectId: json['projectid'] ?? 0,
      projectName: json['projectname'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskProject &&
          runtimeType == other.runtimeType &&
          projectId == other.projectId;

  @override
  int get hashCode => projectId.hashCode;
}

class TaskGroup {
  final int id;
  final String type;
  final String roleName;
  final String roleVal;
  final String roleFor;
  final String createdAt;
  final String updatedAt;

  TaskGroup({
    required this.id,
    required this.type,
    required this.roleName,
    required this.roleVal,
    required this.roleFor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskGroup.fromJson(Map<String, dynamic> json) {
    return TaskGroup(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      roleName: json['RoleNm'] ?? '',
      roleVal: json['Role_val'] ?? '0',
      roleFor: json['rolefor'] ?? '0',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskGroup &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class TaskItem {
  final int id;
  final String taskCode;
  final String projectId;
  final String groupId;
  final String taskType;
  final String unitId;
  final String assignTo;
  final String assigneeRole;
  final String title;
  final String description;
  final String frequency;
  final String createdBy;
  final String startDate;
  final String endDate;
  final String repeatInterval;
  final String photoRequired;
  final String approvalRequired;
  final String approverId;
  final String selectedDays;
  final String monthDays;
  final String yearDays;
  final String occurrences;
  final String startTime;
  final String endTime;
  final String createdAt;
  final String updatedAt;
  final int taskInstanceId;
  final String? instanceCode;
  final String scheduleDateTime;
  final String status;
  final String? assigneeName;
  final String? approverName;
  final String? createdByName;
  final String? completedByName;
  final String? project;

  // Additional fields from daily-tasks
  final String? groupNames;
  final bool? canStatusBtnClicked;

  TaskItem({
    required this.id,
    required this.taskCode,
    required this.projectId,
    required this.groupId,
    required this.taskType,
    required this.unitId,
    required this.assignTo,
    required this.assigneeRole,
    required this.title,
    required this.description,
    required this.frequency,
    required this.createdBy,
    required this.startDate,
    required this.endDate,
    required this.repeatInterval,
    required this.photoRequired,
    required this.approvalRequired,
    required this.approverId,
    required this.selectedDays,
    required this.monthDays,
    required this.yearDays,
    required this.occurrences,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.updatedAt,
    required this.taskInstanceId,
    this.instanceCode,
    required this.scheduleDateTime,
    required this.status,
    this.assigneeName,
    this.approverName,
    this.createdByName,
    this.completedByName,
    this.project,
    this.groupNames,
    this.canStatusBtnClicked,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] ?? 0,
      taskCode: json['task_code'] ?? '',
      projectId: json['prj_id']?.toString() ?? '',
      groupId: json['s_groupId']?.toString() ?? json['s_groupid']?.toString() ?? '',
      taskType: json['task_type'] ?? '',
      unitId: json['unitID']?.toString() ?? '',
      assignTo: json['assign_to']?.toString() ?? '',
      assigneeRole: json['assignee_role']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['desp'] ?? '',
      frequency: json['frequency'] ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      repeatInterval: json['repeat_interval']?.toString() ?? '1',
      photoRequired: json['photo_required']?.toString() ?? '0',
      approvalRequired: json['approval_required']?.toString() ?? '0',
      approverId: json['approver_id']?.toString() ?? '',
      selectedDays: json['selected_days'] ?? '',
      monthDays: json['month_days'] ?? '',
      yearDays: json['year_days'] ?? '',
      occurrences: json['occurrences']?.toString() ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      taskInstanceId: json['task_instance_id'] ?? 0,
      instanceCode: json['instance_code'],
      scheduleDateTime: json['shedule_date_time'] ?? '',
      status: json['status'] ?? 'pending',
      assigneeName: json['assignee_name'],
      approverName: json['approver_name'],
      createdByName: json['createdby_name'],
      completedByName: json['competed_by_name'],
      project: json['project'] ?? json['project_name'],
      groupNames: json['group_names'] ?? json['group_name'],
      canStatusBtnClicked: json['canStatusbtnClicked'],
    );
  }
}

class TaskListResponse {
  final bool status;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int totalRecords;
  final List<TaskItem> data;

  TaskListResponse({
    required this.status,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.totalRecords,
    required this.data,
  });

  factory TaskListResponse.fromJson(Map<String, dynamic> json) {
    return TaskListResponse(
      status: json['status'] ?? false,
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      totalRecords: json['total_records'] ?? 0,
      data: (json['data'] as List?)?.map((e) => TaskItem.fromJson(e)).toList() ?? [],
    );
  }
}

class DailyTaskResponse {
  final bool status;
  final Map<String, int> counts;
  final List<TaskItem> tasks;

  DailyTaskResponse({
    required this.status,
    required this.counts,
    required this.tasks,
  });

  factory DailyTaskResponse.fromJson(Map<String, dynamic> json) {
    return DailyTaskResponse(
      status: json['status'] ?? false,
      counts: Map<String, int>.from(json['counts'] ?? {}),
      tasks: (json['tasks'] as List?)?.map((e) => TaskItem.fromJson(e)).toList() ?? [],
    );
  }
}

class TaskDetailResponse {
  final bool status;
  final String message;
  final TaskItem? data;

  TaskDetailResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory TaskDetailResponse.fromJson(Map<String, dynamic> json) {
    return TaskDetailResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? TaskItem.fromJson(json['data']) : null,
    );
  }
}
// endregion
