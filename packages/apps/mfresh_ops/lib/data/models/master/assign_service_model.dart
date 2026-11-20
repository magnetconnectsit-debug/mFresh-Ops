// region Imports
import 'package:intl/intl.dart';
// endregion

// region Models

/// Unit item returned by assigns-index API
class AssignUnitItem {
  final int id;
  final String qrcodeId;
  final String? unitImgUrl;
  final String? unitcategory;
  final String? unitLocation;
  final String? ingDate;
  final String? fullAdd;
  final List<UnitAssignmentService> assignments;
  final UnitEditPayload? editPayload;

  AssignUnitItem({
    required this.id,
    required this.qrcodeId,
    this.unitImgUrl,
    this.unitcategory,
    this.unitLocation,
    this.ingDate,
    this.fullAdd,
    List<UnitAssignmentService>? assignments,
    this.editPayload,
  }) : assignments = assignments ?? [];

  bool get hasValidImage =>
      unitImgUrl != null &&
      unitImgUrl!.isNotEmpty &&
      !unitImgUrl!.endsWith('/NA') &&
      unitImgUrl != 'NA';

  String get formattedInaugurationDate {
    if (ingDate == null || ingDate!.isEmpty || ingDate == 'NA') return 'NA';
    try {
      final parsed = DateTime.tryParse(ingDate!);
      if (parsed != null) {
        return DateFormat('dd-MMM-yyyy').format(parsed.toLocal());
      }
    } catch (_) {}
    return ingDate!;
  }

  // region Factory & Serialization
  factory AssignUnitItem.fromJson(Map<String, dynamic> json) {
    return AssignUnitItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      qrcodeId: (json['qrcodeId'] ?? json['qrcode_id'] ?? '').toString(),
      unitImgUrl: json['unit_img_url']?.toString(),
      unitcategory: (json['unitcategory'] ?? json['unit_category'])?.toString(),
      unitLocation: (json['unit_location'] ?? json['city'])?.toString(),
      ingDate: (json['ing_date'] ?? json['inauguration_date'])?.toString(),
      fullAdd: (json['full_add'] ?? json['full_address'] ?? json['operating_hrs'])?.toString(),
      assignments: (json['assignments'] as List<dynamic>?)
              ?.map((e) =>
                  UnitAssignmentService.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      editPayload: json['edit_payload'] is Map<String, dynamic>
          ? UnitEditPayload.fromJson(
              json['edit_payload'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qrcodeId': qrcodeId,
      'unit_img_url': unitImgUrl,
      'unitcategory': unitcategory,
      'unit_location': unitLocation,
      'ing_date': ingDate,
      'full_add': fullAdd,
      'assignments': assignments.map((e) => e.toJson()).toList(),
      if (editPayload != null) 'edit_payload': editPayload!.toJson(),
    };
  }
  // endregion

  // region CopyWith
  AssignUnitItem copyWith({
    int? id,
    String? qrcodeId,
    String? unitImgUrl,
    String? unitcategory,
    String? unitLocation,
    String? ingDate,
    String? fullAdd,
    List<UnitAssignmentService>? assignments,
    UnitEditPayload? editPayload,
  }) {
    return AssignUnitItem(
      id: id ?? this.id,
      qrcodeId: qrcodeId ?? this.qrcodeId,
      unitImgUrl: unitImgUrl ?? this.unitImgUrl,
      unitcategory: unitcategory ?? this.unitcategory,
      unitLocation: unitLocation ?? this.unitLocation,
      ingDate: ingDate ?? this.ingDate,
      fullAdd: fullAdd ?? this.fullAdd,
      assignments: assignments ?? this.assignments,
      editPayload: editPayload ?? this.editPayload,
    );
  }
  // endregion
}

/// Service with its rows assigned to a unit (from assigns-index)
class UnitAssignmentService {
  final int serviceId;
  final String? serviceName;
  final List<UnitAssignmentRow> rows;

  UnitAssignmentService({
    required this.serviceId,
    this.serviceName,
    required this.rows,
  });

  factory UnitAssignmentService.fromJson(Map<String, dynamic> json) {
    return UnitAssignmentService(
      serviceId: json['service_id'] is int
          ? json['service_id']
          : int.tryParse(json['service_id']?.toString() ?? '') ?? 0,
      serviceName: json['service_name']?.toString(),
      rows: (json['rows'] as List<dynamic>?)
              ?.map((e) =>
                  UnitAssignmentRow.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'service_name': serviceName,
      'rows': rows.map((e) => e.toJson()).toList(),
    };
  }
}

/// Individual row inside UnitAssignmentService (from assigns-index)
class UnitAssignmentRow {
  final int rowId;
  final int servicesFor;
  final int payType;
  final String grossPrice;
  final num gst;
  final String netAmount;
  final String uses;
  final String order;
  final int status;

  UnitAssignmentRow({
    required this.rowId,
    required this.servicesFor,
    required this.payType,
    required this.grossPrice,
    required this.gst,
    required this.netAmount,
    required this.uses,
    required this.order,
    required this.status,
  });

  factory UnitAssignmentRow.fromJson(Map<String, dynamic> json) {
    return UnitAssignmentRow(
      rowId: json['row_id'] is int
          ? json['row_id']
          : int.tryParse(json['row_id']?.toString() ?? '') ?? 0,
      servicesFor: json['services_for'] is int
          ? json['services_for']
          : int.tryParse(json['services_for']?.toString() ?? '') ?? 0,
      payType: json['pay_type'] is int
          ? json['pay_type']
          : int.tryParse(json['pay_type']?.toString() ?? '') ?? 1,
      grossPrice: json['gross_price']?.toString() ?? '0',
      gst: json['gst'] is num
          ? (json['gst'] as num)
          : num.tryParse(json['gst']?.toString() ?? '') ?? 0,
      netAmount: json['net_amount']?.toString() ?? '0',
      uses: json['uses']?.toString() ?? 'Use',
      order: json['order']?.toString() ?? '1',
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'row_id': rowId,
      'services_for': servicesFor,
      'pay_type': payType,
      'gross_price': grossPrice,
      'gst': gst,
      'net_amount': netAmount,
      'uses': uses,
      'order': order,
      'status': status,
    };
  }
}

/// Edit payload representation included in assigns-index response
class UnitEditPayload {
  final String assignqrId;
  final List<int> serviceId;
  final List<int> rowsPerService;
  final List<int> rowId;
  final List<int> servicesFor;
  final List<int> payType;
  final List<String> grossPrice;
  final List<int> gst;
  final List<String> netAmount;
  final List<String> uses;
  final List<String> order;
  final List<int> status;

  UnitEditPayload({
    required this.assignqrId,
    required this.serviceId,
    required this.rowsPerService,
    required this.rowId,
    required this.servicesFor,
    required this.payType,
    required this.grossPrice,
    required this.gst,
    required this.netAmount,
    required this.uses,
    required this.order,
    required this.status,
  });

  factory UnitEditPayload.fromJson(Map<String, dynamic> json) {
    List<T> parseList<T>(dynamic list, T Function(dynamic) mapper) {
      if (list is List) {
        return list.map(mapper).toList();
      }
      return [];
    }

    return UnitEditPayload(
      assignqrId: json['assignqrId']?.toString() ?? '',
      serviceId: parseList<int>(
          json['service_id'], (e) => int.tryParse(e.toString()) ?? 0),
      rowsPerService: parseList<int>(
          json['rows_per_service'], (e) => int.tryParse(e.toString()) ?? 0),
      rowId: parseList<int>(
          json['row_id'], (e) => int.tryParse(e.toString()) ?? 0),
      servicesFor: parseList<int>(
          json['services_for'], (e) => int.tryParse(e.toString()) ?? 0),
      payType: parseList<int>(
          json['pay_type'], (e) => int.tryParse(e.toString()) ?? 1),
      grossPrice: parseList<String>(
          json['gross_price'], (e) => e.toString()),
      gst: parseList<int>(
          json['gst'], (e) => int.tryParse(e.toString()) ?? 0),
      netAmount: parseList<String>(
          json['net_amount'], (e) => e.toString()),
      uses: parseList<String>(
          json['uses'], (e) => e.toString()),
      order: parseList<String>(
          json['order'], (e) => e.toString()),
      status: parseList<int>(
          json['status'], (e) => int.tryParse(e.toString()) ?? 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignqrId': assignqrId,
      'service_id': serviceId,
      'rows_per_service': rowsPerService,
      'row_id': rowId,
      'services_for': servicesFor,
      'pay_type': payType,
      'gross_price': grossPrice,
      'gst': gst,
      'net_amount': netAmount,
      'uses': uses,
      'order': order,
      'status': status,
    };
  }
}

/// Response wrapper for assigns-index API
class AssignsIndexResponse {
  final bool status;
  final String? message;
  final List<AssignUnitItem> data;
  final int count;

  AssignsIndexResponse({
    required this.status,
    this.message,
    required this.data,
    required this.count,
  });

  // region Factory & Serialization
  factory AssignsIndexResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>?)
            ?.map((e) => AssignUnitItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final metaCount = json['meta'] is Map<String, dynamic>
        ? (json['meta']['count'] as int? ?? list.length)
        : list.length;
    return AssignsIndexResponse(
      status: json['status'] == true,
      message: json['message']?.toString(),
      data: list,
      count: metaCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
      'meta': {'count': count},
    };
  }
  // endregion
}

/// Represents an individual pricing/mode row within a service assignment matrix
class AssignedServiceRow {
  int? rowId;
  int serviceId;
  int servicesFor; // 0 = Customer, 1 = Members
  int payType; // 1 = Offline, 2 = Online
  double grossPrice;
  double gst;
  double netAmount;
  int uses;
  String? usesText;
  int order;
  int status; // 1 = Active, 0 = Inactive

  AssignedServiceRow({
    this.rowId,
    required this.serviceId,
    required this.servicesFor,
    required this.payType,
    this.grossPrice = 0.0,
    this.gst = 0.0,
    this.netAmount = 0.0,
    this.uses = 1,
    this.usesText,
    this.order = 1,
    this.status = 1,
  });

  String get serviceForLabel => servicesFor == 0 ? 'Customer' : 'Members';
  String get modeLabel => payType == 1 ? 'Offline' : 'Online';
  String get statusLabel => status == 1 ? 'Active' : 'Inactive';
  String get effectiveUsesText =>
      usesText ?? (uses == 1 ? 'Use' : uses.toString());

  // region Factory & Serialization
  factory AssignedServiceRow.fromJson(Map<String, dynamic> json) {
    final rawUses = json['uses']?.toString();
    final parsedUses = int.tryParse(rawUses ?? '') ??
        (rawUses?.toLowerCase() == 'use' ? 1 : 1);
    return AssignedServiceRow(
      rowId: json['row_id'] is int
          ? json['row_id']
          : int.tryParse(json['row_id']?.toString() ?? ''),
      serviceId: json['service_id'] is int
          ? json['service_id']
          : int.tryParse(json['service_id']?.toString() ?? '') ?? 0,
      servicesFor: json['services_for'] is int
          ? json['services_for']
          : int.tryParse(json['services_for']?.toString() ?? '') ?? 0,
      payType: json['pay_type'] is int
          ? json['pay_type']
          : int.tryParse(json['pay_type']?.toString() ?? '') ?? 1,
      grossPrice: json['gross_price'] is num
          ? (json['gross_price'] as num).toDouble()
          : double.tryParse(json['gross_price']?.toString() ?? '') ?? 0.0,
      gst: json['gst'] is num
          ? (json['gst'] as num).toDouble()
          : double.tryParse(json['gst']?.toString() ?? '') ?? 0.0,
      netAmount: json['net_amount'] is num
          ? (json['net_amount'] as num).toDouble()
          : double.tryParse(json['net_amount']?.toString() ?? '') ?? 0.0,
      uses: parsedUses,
      usesText: rawUses,
      order: json['order'] is int
          ? json['order']
          : int.tryParse(json['order']?.toString() ?? '') ?? 1,
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (rowId != null) 'row_id': rowId,
      'service_id': serviceId,
      'services_for': servicesFor,
      'pay_type': payType,
      'gross_price': grossPrice,
      'gst': gst,
      'net_amount': netAmount,
      'uses': usesText ?? uses,
      'order': order,
      'status': status,
    };
  }
  // endregion

  // region CopyWith
  AssignedServiceRow copyWith({
    int? rowId,
    int? serviceId,
    int? servicesFor,
    int? payType,
    double? grossPrice,
    double? gst,
    double? netAmount,
    int? uses,
    String? usesText,
    int? order,
    int? status,
  }) {
    return AssignedServiceRow(
      rowId: rowId ?? this.rowId,
      serviceId: serviceId ?? this.serviceId,
      servicesFor: servicesFor ?? this.servicesFor,
      payType: payType ?? this.payType,
      grossPrice: grossPrice ?? this.grossPrice,
      gst: gst ?? this.gst,
      netAmount: netAmount ?? this.netAmount,
      uses: uses ?? this.uses,
      usesText: usesText ?? this.usesText,
      order: order ?? this.order,
      status: status ?? this.status,
    );
  }
  // endregion
}

/// Represents a grouped block of assigned services with 4 default matrix rows
class AssignedServiceGroup {
  int? serviceId;
  String? serviceName;
  String? iconUrl;
  List<AssignedServiceRow> rows;

  AssignedServiceGroup({
    this.serviceId,
    this.serviceName,
    this.iconUrl,
    List<AssignedServiceRow>? rows,
  }) : rows = rows ?? [];

  /// Factory helper to create default 4 rows for a new service
  factory AssignedServiceGroup.createDefault({
    int? serviceId,
    String? serviceName,
    String? iconUrl,
    int defaultOrder = 0,
  }) {
    final sId = serviceId ?? 0;
    return AssignedServiceGroup(
      serviceId: serviceId,
      serviceName: serviceName,
      iconUrl: iconUrl,
      rows: [
        AssignedServiceRow(
          serviceId: sId,
          servicesFor: 0, // Customer
          payType: 1, // Offline
          order: defaultOrder,
        ),
        AssignedServiceRow(
          serviceId: sId,
          servicesFor: 0, // Customer
          payType: 2, // Online
          order: defaultOrder,
        ),
        AssignedServiceRow(
          serviceId: sId,
          servicesFor: 1, // Members
          payType: 1, // Offline
          order: defaultOrder,
        ),
        AssignedServiceRow(
          serviceId: sId,
          servicesFor: 1, // Members
          payType: 2, // Online
          order: defaultOrder,
        ),
      ],
    );
  }
}

/// Item returned by assign-services-index API representing an assigned service entry
class AllAssignServiceItem {
  final int id;
  final String assqrcodeId;
  final String serviceId;
  final String? servicesName;
  final int memStatus;
  final String? serviceFor;
  final int paytype;
  final String? payType;
  final String? price;
  final num? gstpercent;
  final String? netPrice;
  final String? uses;
  int status;
  String? statusLabel;

  AllAssignServiceItem({
    required this.id,
    required this.assqrcodeId,
    required this.serviceId,
    this.servicesName,
    this.memStatus = 0,
    this.serviceFor,
    this.paytype = 1,
    this.payType,
    this.price,
    this.gstpercent,
    this.netPrice,
    this.uses,
    this.status = 1,
    this.statusLabel,
  });

  bool get isActive => status == 1;

  // region Factory & Serialization
  factory AllAssignServiceItem.fromJson(Map<String, dynamic> json) {
    return AllAssignServiceItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      assqrcodeId: (json['assqrcodeId'] ?? json['qrcodeId'] ?? json['assqrcode_id'] ?? '').toString(),
      serviceId: (json['serviceId'] ?? json['service_id'] ?? '').toString(),
      servicesName: json['services_name']?.toString() ?? json['service_name']?.toString(),
      memStatus: json['mem_status'] is int
          ? json['mem_status']
          : int.tryParse(json['mem_status']?.toString() ?? '') ?? 0,
      serviceFor: json['service_for']?.toString() ?? (json['mem_status'] == 1 ? 'Membership' : 'Customer'),
      paytype: json['paytype'] is int
          ? json['paytype']
          : int.tryParse(json['paytype']?.toString() ?? '') ?? 1,
      payType: (json['pay_type'] ?? json['payType'])?.toString() ?? (json['paytype'] == 2 ? 'Online' : 'Offline'),
      price: json['price']?.toString(),
      gstpercent: json['gstpercent'] is num
          ? json['gstpercent'] as num
          : num.tryParse(json['gstpercent']?.toString() ?? ''),
      netPrice: (json['net_price'] ?? json['netPrice'])?.toString(),
      uses: json['uses']?.toString(),
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 1,
      statusLabel: json['status_label']?.toString() ?? (json['status'] == 1 ? 'Active' : 'Inactive'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assqrcodeId': assqrcodeId,
      'serviceId': serviceId,
      'services_name': servicesName,
      'mem_status': memStatus,
      'service_for': serviceFor,
      'paytype': paytype,
      'pay_type': payType,
      'price': price,
      'gstpercent': gstpercent,
      'net_price': netPrice,
      'uses': uses,
      'status': status,
      'status_label': statusLabel,
    };
  }
  // endregion

  // region CopyWith
  AllAssignServiceItem copyWith({
    int? id,
    String? assqrcodeId,
    String? serviceId,
    String? servicesName,
    int? memStatus,
    String? serviceFor,
    int? paytype,
    String? payType,
    String? price,
    num? gstpercent,
    String? netPrice,
    String? uses,
    int? status,
    String? statusLabel,
  }) {
    return AllAssignServiceItem(
      id: id ?? this.id,
      assqrcodeId: assqrcodeId ?? this.assqrcodeId,
      serviceId: serviceId ?? this.serviceId,
      servicesName: servicesName ?? this.servicesName,
      memStatus: memStatus ?? this.memStatus,
      serviceFor: serviceFor ?? this.serviceFor,
      paytype: paytype ?? this.paytype,
      payType: payType ?? this.payType,
      price: price ?? this.price,
      gstpercent: gstpercent ?? this.gstpercent,
      netPrice: netPrice ?? this.netPrice,
      uses: uses ?? this.uses,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
    );
  }
  // endregion
}

/// Response wrapper for assign-services-index API
class AllAssignServicesResponse {
  final bool status;
  final String? message;
  final List<AllAssignServiceItem> data;
  final int count;

  AllAssignServicesResponse({
    required this.status,
    this.message,
    required this.data,
    required this.count,
  });

  // region Factory & Serialization
  factory AllAssignServicesResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>?)
            ?.map((e) => AllAssignServiceItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final metaCount = json['meta'] is Map<String, dynamic>
        ? (json['meta']['count'] as int? ?? list.length)
        : list.length;
    return AllAssignServicesResponse(
      status: json['status'] == true,
      message: json['message']?.toString(),
      data: list,
      count: metaCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
      'meta': {'count': count},
    };
  }
  // endregion
}
// endregion

