class SupportTicketListItem {
  final int id;
  final String? projectId;
  final String? caseId;
  final String? postedDate;
  final String? subject;
  final String? description;
  final String? statusLabel;
  final String? statusTextColor;
  final String? statusBgColor;
  final String? priorityLabel;
  final String? priorityTextColor;
  final String? priorityBgColor;
  final String? mCategory;
  final String? subCat;
  final String? createdBy;
  final String? project;
  final String? unitNo;
  final String? assignedTo;
  final String? assignedToName;
  final String? comment;
  final String? latestComment;
  final String? latestCommentUser;
  final String? followUp;
  final String? district;
  final String? tktAge;
  final String? resolvedOn;
  final String? resolvedStatus;
  final String? updatedAt;

  SupportTicketListItem({
    required this.id,
    this.projectId,
    this.caseId,
    this.postedDate,
    this.subject,
    this.description,
    this.statusLabel,
    this.statusTextColor,
    this.statusBgColor,
    this.priorityLabel,
    this.priorityTextColor,
    this.priorityBgColor,
    this.mCategory,
    this.subCat,
    this.createdBy,
    this.project,
    this.unitNo,
    this.assignedTo,
    this.assignedToName,
    this.comment,
    this.latestComment,
    this.latestCommentUser,
    this.followUp,
    this.district,
    this.tktAge,
    this.resolvedOn,
    this.resolvedStatus,
    this.updatedAt,
  });

  factory SupportTicketListItem.fromJson(Map<String, dynamic> json) {
    return SupportTicketListItem(
      id: json['id'],
      projectId: json['projectid']?.toString(),
      caseId: json['case_id']?.toString(),
      postedDate: json['posted_date'],
      subject: json['subject'],
      description: json['description'],
      statusLabel: json['status_label'],
      statusTextColor: json['status_text_color'],
      statusBgColor: json['status_bg_color'],
      priorityLabel: json['priority_label'],
      priorityTextColor: json['priority_text_color'],
      priorityBgColor: json['priority_bg_color'],
      mCategory: json['m_category'],
      subCat: json['sub_cat'],
      createdBy: json['created_by']?.toString(),
      project: json['project'],
      unitNo: json['qrcodeId']?.toString(),
      assignedTo: json['assigned_to']?.toString(),
      assignedToName: json['assigned_to_name']?.toString(),
      comment: json['comment'],
      latestComment: json['latest_comment'],
      latestCommentUser: json['latest_comment_user'],
      followUp: json['follow_up'],
      district: json['district'],
      tktAge: json['tkt_age'],
      resolvedOn: json['resolved_on'],
      resolvedStatus: json['resolved_status']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class SubtaskModel {
  final int id;
  final String? maintenanceId;
  final String? subtask;
  final String? subtaskStatus; // "0" = pending, "1" = completed
  final String? createdAt;
  final String? updatedAt;

  SubtaskModel({
    required this.id,
    this.maintenanceId,
    this.subtask,
    this.subtaskStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory SubtaskModel.fromJson(Map<String, dynamic> json) {
    return SubtaskModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      maintenanceId: json['maintenance_id']?.toString(),
      subtask: json['subtask']?.toString(),
      subtaskStatus: json['subtask_status']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class SupportTicketDetail {
  final int id;
  final String? caseId;
  final String? status;
  final String? priority;
  final String? category;
  final String? subcategory;
  final String? project;
  final String? unitNo;
  final int? createdBy;
  final String? userName;
  final String? subject;
  final String? description;
  final List<dynamic>? cashierImages;
  final List<String>? attachments;
  final String? followUp;
  final String? assignedTo;
  final String? assignedToName;
  final String? createdOn;
  final String? modifiedOn;
  final String? resolvedOn;
  final String? tktAge;
  final List<dynamic>? comments;
  final List<dynamic>? logs;
  final List<SubtaskModel>? subtasks;
  final int? projectId;
  final int? unitId;
  final int? categoryId;
  final int? subcategoryId;
  final String? priorityId;
  final int? assignedToId;
  final int? createdById;
  final dynamic reminderData;

  SupportTicketDetail({
    required this.id,
    this.caseId,
    this.status,
    this.priority,
    this.category,
    this.subcategory,
    this.project,
    this.unitNo,
    this.createdBy,
    this.userName,
    this.subject,
    this.description,
    this.cashierImages,
    this.attachments,
    this.followUp,
    this.assignedTo,
    this.assignedToName,
    this.createdOn,
    this.modifiedOn,
    this.resolvedOn,
    this.tktAge,
    this.comments,
    this.logs,
    this.subtasks,
    this.projectId,
    this.unitId,
    this.categoryId,
    this.subcategoryId,
    this.priorityId,
    this.assignedToId,
    this.createdById,
    this.reminderData,
  });

  // Convenience getters to match view
  int get ticketId => id;
  String? get categoryName => category;
  String? get subCategoryName => subcategory;
  String? get projectName => project;
  String? get createdAt => createdOn;
  String? get updatedAt => modifiedOn;
  String? get ticketAge => tktAge;
  SupportReminder? get reminder => reminderData as SupportReminder?;

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory SupportTicketDetail.fromJson(Map<String, dynamic> json) {
    return SupportTicketDetail(
      id: _parseInt(json['id']) ?? 0,
      caseId: json['case_id']?.toString(),
      status: json['status']?.toString(),
      priority: json['priority']?.toString(),
      category: json['category'],
      subcategory: json['subcategory'],
      project: json['project'],
      unitNo: json['unit_no'],
      createdBy: _parseInt(json['created_by']),
      userName: json['user_name'],
      subject: json['subject'],
      description: json['description'],
      cashierImages: json['cashier_images'],
      attachments: json['attachments'] is List
          ? (json['attachments'] as List).map((e) => e.toString()).toList()
          : [],
      followUp: json['follow_up'],
      assignedTo: json['assigned_to']?.toString(),
      assignedToName: json['assigned_to_name'],
      createdOn: json['created_on'],
      modifiedOn: json['modified_on'],
      resolvedOn: json['resolved_on'],
      tktAge: json['tkt_age'],
      comments: json['comments'],
      logs: json['logs'],
      subtasks: json['subtasks'] is List
          ? (json['subtasks'] as List)
                .map((e) => SubtaskModel.fromJson(e))
                .toList()
          : [],
      projectId: _parseInt(json['projectid']),
      unitId: _parseInt(json['unit_id']),
      categoryId: _parseInt(json['categoryid']),
      subcategoryId: _parseInt(json['subcategoryid']),
      priorityId: json['priorityid']?.toString(),
      assignedToId: _parseInt(json['assigned_to']),
      createdById: _parseInt(json['created_by']),
      reminderData: json['reminderdata'] != null
          ? SupportReminder.fromJson(json['reminderdata'])
          : null,
    );
  }
}

class SupportReminder {
  final int id;
  final String? ticketId;
  final String? userId;
  final String? assignee;
  final String? reminderDate;
  final String? reminderTime;
  final String? timeType;
  final String? whatsappNotification;
  final String? appNotification;

  SupportReminder({
    required this.id,
    this.ticketId,
    this.userId,
    this.assignee,
    this.reminderDate,
    this.reminderTime,
    this.timeType,
    this.whatsappNotification,
    this.appNotification,
  });

  factory SupportReminder.fromJson(Map<String, dynamic> json) {
    return SupportReminder(
      id: json['id'],
      ticketId: json['ticket_id']?.toString(),
      userId: json['user_id']?.toString(),
      assignee: json['assignee']?.toString(),
      reminderDate: json['reminder_date'],
      reminderTime: json['reminder_time'],
      timeType: json['time_type'],
      whatsappNotification: json['whatsapp_notification']?.toString(),
      appNotification: json['app_notification']?.toString(),
    );
  }
}

class EditSupportTicketData {
  final String? caseId;
  final String? stateId;
  final String? districtId;
  final String? unitId;
  final String? projectId;
  final String? mcatId;
  final String? subcatId;
  final String? priority;
  final String? status;
  final String? assignedTo;
  final String? linkedTicket;
  final String? followUp;
  final String? subject;
  final String? description;
  final String? comment;
  final String? resolution;
  final String? createdBy;
  final String? createdOn;
  final String? modifiedOn;
  final SupportReminder? reminder;

  EditSupportTicketData({
    this.caseId,
    this.stateId,
    this.districtId,
    this.unitId,
    this.projectId,
    this.mcatId,
    this.subcatId,
    this.priority,
    this.status,
    this.assignedTo,
    this.linkedTicket,
    this.followUp,
    this.subject,
    this.description,
    this.comment,
    this.resolution,
    this.createdBy,
    this.createdOn,
    this.modifiedOn,
    this.reminder,
  });

  factory EditSupportTicketData.fromJson(Map<String, dynamic> json) {
    return EditSupportTicketData(
      caseId: json['case_id']?.toString(),
      stateId: json['state_id']?.toString(),
      districtId: json['district_id']?.toString(),
      unitId: json['unit_id']?.toString(),
      projectId: json['projectid']?.toString(),
      mcatId: json['mcat_id']?.toString(),
      subcatId: json['subcat_id']?.toString(),
      priority: json['priority']?.toString(),
      status: json['status']?.toString(),
      assignedTo: json['assigned_to']?.toString(),
      linkedTicket: json['linked_ticket']?.toString(),
      followUp: json['follow_up']?.toString(),
      subject: json['subject'],
      description: json['description'],
      comment: json['comment'],
      resolution: json['resolution'],
      createdBy: json['created_by']?.toString(),
      createdOn: json['created_on'],
      modifiedOn: json['modified_on'],
      reminder: json['reminder'] != null
          ? SupportReminder.fromJson(json['reminder'])
          : null,
    );
  }
}

class SupportTicketListResponse {
  final bool status;
  final String message;
  final int totalTickets;
  final List<ProjectCount> projectCounts;
  final List<UnitCount> unitCounts;
  final List<SupportTicketListItem> data;

  SupportTicketListResponse({
    required this.status,
    required this.message,
    required this.totalTickets,
    required this.projectCounts,
    required this.unitCounts,
    required this.data,
  });

  factory SupportTicketListResponse.fromJson(Map<String, dynamic> json) {
    return SupportTicketListResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      totalTickets: json['totalTickets'] ?? 0,
      projectCounts:
          (json['projectCounts'] as List?)
              ?.map((e) => ProjectCount.fromJson(e))
              .toList() ??
          [],
      unitCounts:
          (json['unitCounts'] as List?)
              ?.map((e) => UnitCount.fromJson(e))
              .toList() ??
          [],
      data:
          (json['data'] as List?)
              ?.map((e) => SupportTicketListItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ProjectCount {
  final String? project;
  final int totalTickets;

  ProjectCount({this.project, required this.totalTickets});

  factory ProjectCount.fromJson(Map<String, dynamic> json) {
    return ProjectCount(
      project: json['project'],
      totalTickets: json['total_tickets'] ?? 0,
    );
  }
}

class UnitCount {
  final int id;
  final String? unit;
  final int totalTickets;

  UnitCount({required this.id, this.unit, required this.totalTickets});

  factory UnitCount.fromJson(Map<String, dynamic> json) {
    return UnitCount(
      id: json['id'],
      unit: json['unit'],
      totalTickets: json['total_tickets'] ?? 0,
    );
  }
}
