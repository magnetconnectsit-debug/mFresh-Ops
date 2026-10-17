// region Models
class TaskProject {
  final int projectId;
  final String projectName;

  TaskProject({required this.projectId, required this.projectName});

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
      other is TaskGroup && runtimeType == other.runtimeType && id == other.id;

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
  final String? instStartTime;
  final String? instEndTime;
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
  final String? projectName;
  final String? unitName;
  final dynamic selectedGroups;

  // Additional fields from daily-tasks
  final String? groupNames;
  final bool? canStatusBtnClicked;
  final dynamic picture;
  final String? ucomment;
  final String? approverComment;
  final String? taskDayStatus;
  final String? badgeText;
  final String? masterStartDate;
  final String? masterEndDate;
  final String? seriesStartDate;
  final String? seriesEndDate;
  final String? recurringTask;
  final String? recurrenceStartDate;
  final String? recurrenceEndDate;
  final String? seriesEndChoice;
  final String? monthlyPattern;
  final String? monthlyWeek;
  final String? monthlyDayName;
  final String? yearlyPattern;
  final String? yearlyMonth;
  final String? yearlyDay;
  final String? yearlyWeek;
  final String? yearlyDayName;
  final String? yearlyMonth2;

  bool get isRecurring =>
      recurringTask == '1' ||
      (recurringTask == null &&
          frequency.isNotEmpty &&
          frequency.toLowerCase() != 'none');

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
    this.instStartTime,
    this.instEndTime,
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
    this.projectName,
    this.unitName,
    this.selectedGroups,
    this.groupNames,
    this.canStatusBtnClicked,
    this.picture,
    this.ucomment,
    this.approverComment,
    this.taskDayStatus,
    this.badgeText,
    this.masterStartDate,
    this.masterEndDate,
    this.seriesStartDate,
    this.seriesEndDate,
    this.recurringTask,
    this.recurrenceStartDate,
    this.recurrenceEndDate,
    this.seriesEndChoice,
    this.monthlyPattern,
    this.monthlyWeek,
    this.monthlyDayName,
    this.yearlyPattern,
    this.yearlyMonth,
    this.yearlyDay,
    this.yearlyWeek,
    this.yearlyDayName,
    this.yearlyMonth2,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    final rawTaskId = json['task_id']?.toString();
    final rawId = json['id'];

    int parsedTaskId = 0;
    int parsedInstanceId = json['task_instance_id'] is int
        ? json['task_instance_id']
        : (int.tryParse(json['task_instance_id']?.toString() ?? '') ??
              (json['instance_id'] is int
                  ? json['instance_id']
                  : (int.tryParse(json['instance_id']?.toString() ?? '') ??
                        0)));

    if (rawTaskId != null && rawTaskId.isNotEmpty && rawTaskId != '0') {
      parsedTaskId = int.tryParse(rawTaskId) ?? 0;
      if (parsedInstanceId == 0 && rawId != null) {
        final parsedRawId = rawId is int
            ? rawId
            : (int.tryParse(rawId.toString()) ?? 0);
        if (parsedRawId != parsedTaskId) {
          parsedInstanceId = parsedRawId;
        }
      }
    }

    if (parsedTaskId == 0 && rawId != null) {
      parsedTaskId = rawId is int
          ? rawId
          : (int.tryParse(rawId.toString()) ?? 0);
    }

    String parsedGroupId = '';
    if (json['selected_groups'] is List) {
      parsedGroupId = (json['selected_groups'] as List).isNotEmpty
          ? (json['selected_groups'] as List).first.toString()
          : '';
    } else if (json['selected_groups'] != null &&
        json['selected_groups'] != 'null') {
      parsedGroupId = json['selected_groups'].toString();
    } else {
      parsedGroupId =
          json['s_groupId']?.toString() ?? json['s_groupid']?.toString() ?? '';
    }

    String? parsedGroupNames;
    if (json['group_names'] is List) {
      parsedGroupNames = (json['group_names'] as List).join(', ');
    } else {
      parsedGroupNames =
          json['group_names']?.toString() ?? json['group_name']?.toString();
    }

    String parsedAssignTo = '';
    if (json['selected_assignee'] != null &&
        json['selected_assignee'] != 'null' &&
        json['selected_assignee'] != 'NA') {
      parsedAssignTo = json['selected_assignee'].toString();
    } else if (json['assign_to'] != null &&
        json['assign_to'] != 'null' &&
        json['assign_to'] != 'NA') {
      parsedAssignTo = json['assign_to'].toString();
    }

    String parsedUnitId = '';
    if (json['selected_unit'] != null &&
        json['selected_unit'] != 'null' &&
        json['selected_unit'] != 'NA') {
      parsedUnitId = json['selected_unit'].toString();
    } else {
      parsedUnitId =
          json['unitID']?.toString() ?? json['unit_id']?.toString() ?? '';
    }

    final unitName =
        json['unit_name']?.toString() ?? json['unitname']?.toString();

    String parsedProjectId = '';
    if (json['prj_id'] != null &&
        json['prj_id'] != 'null' &&
        json['prj_id'] != 'NA') {
      parsedProjectId = json['prj_id'].toString();
    } else {
      parsedProjectId = json['project_id']?.toString() ?? '';
    }

    final projectName =
        json['project_name']?.toString() ?? json['project']?.toString();

    final rawIsRecurring = json['is_recurring'];
    final bool isRec =
        rawIsRecurring == true ||
        rawIsRecurring == 1 ||
        rawIsRecurring == 'true' ||
        rawIsRecurring == '1' ||
        json['recurring_task'] == '1' ||
        json['recurring_task'] == 1 ||
        (json['frequency'] != null &&
            json['frequency'].toString().isNotEmpty &&
            json['frequency'].toString().toLowerCase() != 'none');

    return TaskItem(
      id: parsedTaskId,
      taskCode: json['task_code'] ?? '',
      projectId: parsedProjectId,
      groupId: parsedGroupId,
      taskType: json['task_type'] ?? '',
      unitId: parsedUnitId,
      assignTo: parsedAssignTo,
      assigneeRole: json['assignee_role']?.toString() ?? '',
      title: json['title'] ?? json['task_title'] ?? '',
      description: json['description'] ?? json['desp'] ?? '',
      frequency: json['frequency'] ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      startDate: json['start_date'] ?? json['schedule_date'] ?? '',
      endDate: json['end_date'] ?? json['completed_at'] ?? '',
      repeatInterval: json['repeat_interval']?.toString() ?? '1',
      photoRequired: json['photo_required']?.toString() ?? '0',
      approvalRequired: json['approval_required']?.toString() ?? '0',
      approverId: json['approver_id']?.toString() ?? '',
      selectedDays: json['selected_days'] ?? '',
      monthDays: json['month_days'] ?? '',
      yearDays: json['year_days'] ?? '',
      occurrences: json['occurrences']?.toString() ?? '',
      startTime: json['start_time'] ?? json['inst_start_time'] ?? '',
      endTime: json['end_time'] ?? json['inst_end_time'] ?? '',
      instStartTime: json['inst_start_time'] ?? json['start_time'],
      instEndTime: json['inst_end_time'] ?? json['end_time'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      taskInstanceId: parsedInstanceId,
      instanceCode: json['instance_code'],
      scheduleDateTime:
          json['shedule_date_time'] ??
          json['schedule_date_time'] ??
          json['start_date_time'] ??
          '',
      status:
          json['display_status'] ??
          json['status'] ??
          json['raw_status'] ??
          'pending',
      assigneeName: json['assignee_name'],
      approverName: json['approver_name'],
      createdByName: json['createdby_name'],
      completedByName: json['competed_by_name'] ?? json['completed_by_name'],
      project: projectName ?? unitName,
      projectName: projectName,
      unitName: unitName,
      selectedGroups: json['selected_groups'],
      groupNames: parsedGroupNames,
      canStatusBtnClicked:
          json['canStatusbtnClicked'] ?? json['can_status_button_clicked'],
      picture: json['picture'],
      ucomment: json['ucomment'] ?? json['user_comment'],
      approverComment: json['approver_comment'],
      taskDayStatus:
          json['backend_day_status'] ??
          json['ui_state'] ??
          json['task_day_status'],
      badgeText:
          json['badge_text']?.toString() ?? json['badgeText']?.toString(),
      masterStartDate:
          json['master_start_date']?.toString() ??
          json['series_start_date']?.toString() ??
          json['seriesStartDate']?.toString(),
      masterEndDate:
          json['master_end_date']?.toString() ??
          json['series_end_date']?.toString() ??
          json['seriesEndDate']?.toString(),
      seriesStartDate:
          json['series_start_date']?.toString() ??
          json['seriesStartDate']?.toString() ??
          json['master_start_date']?.toString(),
      seriesEndDate:
          json['series_end_date']?.toString() ??
          json['seriesEndDate']?.toString() ??
          json['master_end_date']?.toString(),
      recurringTask: isRec ? '1' : '0',
      recurrenceStartDate:
          json['recurrence_start_date']?.toString() ??
          json['recurrenceStartDate']?.toString(),
      recurrenceEndDate:
          json['recurrence_end_date']?.toString() ??
          json['recurrenceEndDate']?.toString(),
      seriesEndChoice:
          json['series_end_choice']?.toString() ??
          json['seriesEndChoice']?.toString(),
      monthlyPattern:
          json['monthlyPattern']?.toString() ??
          json['monthly_pattern']?.toString(),
      monthlyWeek:
          json['monthly_week']?.toString() ?? json['monthlyWeek']?.toString(),
      monthlyDayName:
          json['monthly_day_name']?.toString() ??
          json['monthlyDayName']?.toString(),
      yearlyPattern:
          json['yearlyPattern']?.toString() ??
          json['yearly_pattern']?.toString(),
      yearlyMonth:
          json['yearly_month']?.toString() ?? json['yearlyMonth']?.toString(),
      yearlyDay:
          json['yearly_day']?.toString() ?? json['yearlyDay']?.toString(),
      yearlyWeek:
          json['yearly_week']?.toString() ?? json['yearlyWeek']?.toString(),
      yearlyDayName:
          json['yearly_dayName']?.toString() ??
          json['yearly_day_name']?.toString() ??
          json['yearlyDayName']?.toString(),
      yearlyMonth2:
          json['yearly_month2']?.toString() ?? json['yearlyMonth2']?.toString(),
    );
  }

  TaskItem copyWith({
    int? id,
    String? taskCode,
    String? projectId,
    String? groupId,
    String? taskType,
    String? unitId,
    String? assignTo,
    String? assigneeRole,
    String? title,
    String? description,
    String? frequency,
    String? createdBy,
    String? startDate,
    String? endDate,
    String? repeatInterval,
    String? photoRequired,
    String? approvalRequired,
    String? approverId,
    String? selectedDays,
    String? monthDays,
    String? yearDays,
    String? occurrences,
    String? startTime,
    String? endTime,
    String? instStartTime,
    String? instEndTime,
    String? createdAt,
    String? updatedAt,
    int? taskInstanceId,
    String? instanceCode,
    String? scheduleDateTime,
    String? status,
    String? assigneeName,
    String? approverName,
    String? createdByName,
    String? completedByName,
    String? project,
    String? projectName,
    String? unitName,
    dynamic selectedGroups,
    String? groupNames,
    bool? canStatusBtnClicked,
    dynamic picture,
    String? ucomment,
    String? approverComment,
    String? taskDayStatus,
    String? badgeText,
    String? masterStartDate,
    String? masterEndDate,
    String? seriesStartDate,
    String? seriesEndDate,
    String? recurringTask,
    String? recurrenceStartDate,
    String? recurrenceEndDate,
    String? seriesEndChoice,
    String? monthlyPattern,
    String? monthlyWeek,
    String? monthlyDayName,
    String? yearlyPattern,
    String? yearlyMonth,
    String? yearlyDay,
    String? yearlyWeek,
    String? yearlyDayName,
    String? yearlyMonth2,
  }) {
    return TaskItem(
      id: id ?? this.id,
      taskCode: taskCode ?? this.taskCode,
      projectId: projectId ?? this.projectId,
      groupId: groupId ?? this.groupId,
      taskType: taskType ?? this.taskType,
      unitId: unitId ?? this.unitId,
      assignTo: assignTo ?? this.assignTo,
      assigneeRole: assigneeRole ?? this.assigneeRole,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      createdBy: createdBy ?? this.createdBy,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      photoRequired: photoRequired ?? this.photoRequired,
      approvalRequired: approvalRequired ?? this.approvalRequired,
      approverId: approverId ?? this.approverId,
      selectedDays: selectedDays ?? this.selectedDays,
      monthDays: monthDays ?? this.monthDays,
      yearDays: yearDays ?? this.yearDays,
      occurrences: occurrences ?? this.occurrences,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      instStartTime: instStartTime ?? this.instStartTime,
      instEndTime: instEndTime ?? this.instEndTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      taskInstanceId: taskInstanceId ?? this.taskInstanceId,
      instanceCode: instanceCode ?? this.instanceCode,
      scheduleDateTime: scheduleDateTime ?? this.scheduleDateTime,
      status: status ?? this.status,
      assigneeName: assigneeName ?? this.assigneeName,
      approverName: approverName ?? this.approverName,
      createdByName: createdByName ?? this.createdByName,
      completedByName: completedByName ?? this.completedByName,
      project: project ?? this.project,
      projectName: projectName ?? this.projectName,
      unitName: unitName ?? this.unitName,
      selectedGroups: selectedGroups ?? this.selectedGroups,
      groupNames: groupNames ?? this.groupNames,
      canStatusBtnClicked: canStatusBtnClicked ?? this.canStatusBtnClicked,
      picture: picture ?? this.picture,
      ucomment: ucomment ?? this.ucomment,
      approverComment: approverComment ?? this.approverComment,
      taskDayStatus: taskDayStatus ?? this.taskDayStatus,
      badgeText: badgeText ?? this.badgeText,
      masterStartDate: masterStartDate ?? this.masterStartDate,
      masterEndDate: masterEndDate ?? this.masterEndDate,
      seriesStartDate: seriesStartDate ?? this.seriesStartDate,
      seriesEndDate: seriesEndDate ?? this.seriesEndDate,
      recurringTask: recurringTask ?? this.recurringTask,
      recurrenceStartDate: recurrenceStartDate ?? this.recurrenceStartDate,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      seriesEndChoice: seriesEndChoice ?? this.seriesEndChoice,
      monthlyPattern: monthlyPattern ?? this.monthlyPattern,
      monthlyWeek: monthlyWeek ?? this.monthlyWeek,
      monthlyDayName: monthlyDayName ?? this.monthlyDayName,
      yearlyPattern: yearlyPattern ?? this.yearlyPattern,
      yearlyMonth: yearlyMonth ?? this.yearlyMonth,
      yearlyDay: yearlyDay ?? this.yearlyDay,
      yearlyWeek: yearlyWeek ?? this.yearlyWeek,
      yearlyDayName: yearlyDayName ?? this.yearlyDayName,
      yearlyMonth2: yearlyMonth2 ?? this.yearlyMonth2,
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
      data:
          (json['data'] as List?)?.map((e) => TaskItem.fromJson(e)).toList() ??
          [],
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
      tasks:
          (json['tasks'] as List?)?.map((e) => TaskItem.fromJson(e)).toList() ??
          [],
    );
  }
}

class TaskDetailResponse {
  final bool status;
  final String message;
  final TaskItem? data;

  TaskDetailResponse({required this.status, required this.message, this.data});

  factory TaskDetailResponse.fromJson(Map<String, dynamic> json) {
    return TaskDetailResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? TaskItem.fromJson(json['data']) : null,
    );
  }
}

// endregion
