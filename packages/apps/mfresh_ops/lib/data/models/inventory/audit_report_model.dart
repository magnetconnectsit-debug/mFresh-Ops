// region Imports
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
// endregion

// region Models

// region AuditorOption
class AuditorOption {
  // region Properties
  final int id;
  final String name;
  // endregion

  // region Constructor
  AuditorOption({
    required this.id,
    required this.name,
  });
  // endregion

  // region Factory & Serialization
  factory AuditorOption.fromJson(Map<String, dynamic> json) {
    return AuditorOption(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
  // endregion
}
// endregion

// region UnitOption
class UnitOption {
  // region Properties
  final int id;
  final String name;
  final String districtName;
  // endregion

  // region Constructor
  UnitOption({
    required this.id,
    required this.name,
    required this.districtName,
  });
  // endregion

  // region Factory & Serialization
  factory UnitOption.fromJson(Map<String, dynamic> json) {
    return UnitOption(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      districtName: json['district_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'district_name': districtName,
  };
  // endregion
}
// endregion

// region AuditReportUnitItem
class AuditReportUnitItem {
  // region Properties
  final int auditId;
  final String auditNumber;
  final int unitId;
  final String unitName;
  final String auditDate;
  // endregion

  // region Constructor
  AuditReportUnitItem({
    required this.auditId,
    required this.auditNumber,
    required this.unitId,
    required this.unitName,
    required this.auditDate,
  });
  // endregion

  // region Factory & Serialization
  factory AuditReportUnitItem.fromJson(Map<String, dynamic> json) {
    return AuditReportUnitItem(
      auditId: json['audit_id'] is int
          ? json['audit_id']
          : int.tryParse(json['audit_id']?.toString() ?? '') ?? 0,
      auditNumber: json['audit_number']?.toString() ?? '',
      unitId: json['unit_id'] is int
          ? json['unit_id']
          : int.tryParse(json['unit_id']?.toString() ?? '') ?? 0,
      unitName: json['unit_name']?.toString() ?? '',
      auditDate: json['audit_date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'audit_id': auditId,
    'audit_number': auditNumber,
    'unit_id': unitId,
    'unit_name': unitName,
    'audit_date': auditDate,
  };
  // endregion
}
// endregion

// region AuditReportEntry
class AuditReportEntry {
  // region Properties
  final int id;
  final int representativeId;
  final String auditNumber;
  final String auditDay;
  final String auditDateDisplay;
  final String dayName;
  final int auditCount;
  final int unitCount;
  final String unitNames;
  final List<AuditReportUnitItem> units;

  // Fallback / legacy fields for backward compatibility
  final int unitId;
  final String unitName;
  final String districtName;
  final String imageUrl;
  final int auditorId;
  final String auditorName;
  final String auditDate;
  final String createdAt;
  // endregion

  // region Constructor
  AuditReportEntry({
    required this.id,
    required this.representativeId,
    required this.auditNumber,
    required this.auditDay,
    required this.auditDateDisplay,
    required this.dayName,
    required this.auditCount,
    required this.unitCount,
    required this.unitNames,
    required this.units,
    required this.unitId,
    required this.unitName,
    required this.districtName,
    required this.imageUrl,
    required this.auditorId,
    required this.auditorName,
    required this.auditDate,
    required this.createdAt,
  });
  // endregion

  // region Factory & Serialization
  factory AuditReportEntry.fromJson(Map<String, dynamic> json) {
    final unit = json['unit'] is Map ? json['unit'] : {};
    final auditor = json['auditor'] is Map ? json['auditor'] : {};

    final rawUnits = json['units'] as List? ?? [];
    final parsedUnits = rawUnits
        .map((u) => AuditReportUnitItem.fromJson(u as Map<String, dynamic>))
        .toList();

    final rawDate = json['audit_date']?.toString() ??
        json['audited_at']?.toString() ??
        json['audit_day']?.toString() ??
        json['created_at']?.toString() ??
        '';

    final formattedDate = AppDateUtils.formatToShortOrdinalDate(rawDate);

    final repId = json['representative_id'] is int
        ? json['representative_id']
        : int.tryParse(json['representative_id']?.toString() ?? '') ??
            (json['id'] is int
                ? json['id']
                : int.tryParse(json['id']?.toString() ?? '') ?? 0);

    return AuditReportEntry(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      representativeId: repId,
      auditNumber: json['audit_number']?.toString() ??
          json['audit_no']?.toString() ??
          '-',
      auditDay: json['audit_day']?.toString() ?? '',
      auditDateDisplay: json['audit_date_display']?.toString() ??
          (formattedDate.isNotEmpty ? formattedDate : rawDate),
      dayName: json['day_name']?.toString() ?? '',
      auditCount: json['audit_count'] is int
          ? json['audit_count']
          : int.tryParse(json['audit_count']?.toString() ?? '') ??
              parsedUnits.length,
      unitCount: json['unit_count'] is int
          ? json['unit_count']
          : int.tryParse(json['unit_count']?.toString() ?? '') ??
              parsedUnits.length,
      unitNames: json['unit_names']?.toString() ??
          parsedUnits.map((u) => u.unitName).join(', '),
      units: parsedUnits,
      unitId: unit['id'] is int
          ? unit['id']
          : int.tryParse(unit['id']?.toString() ?? '') ?? 0,
      unitName: unit['name']?.toString() ??
          json['unit_name']?.toString() ??
          (parsedUnits.isNotEmpty ? parsedUnits.first.unitName : '-'),
      districtName: unit['district_name']?.toString() ?? '',
      imageUrl: unit['image_url']?.toString() ?? '',
      auditorId: auditor['id'] is int
          ? auditor['id']
          : int.tryParse(auditor['id']?.toString() ?? '') ?? 0,
      auditorName: auditor['name']?.toString() ??
          json['audited_by_name']?.toString() ??
          '-',
      auditDate: rawDate,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'representative_id': representativeId,
    'audit_number': auditNumber,
    'audit_day': auditDay,
    'audit_date_display': auditDateDisplay,
    'day_name': dayName,
    'audit_count': auditCount,
    'unit_count': unitCount,
    'unit_names': unitNames,
    'units': units.map((u) => u.toJson()).toList(),
    'unit_id': unitId,
    'unit_name': unitName,
    'district_name': districtName,
    'image_url': imageUrl,
    'auditor_id': auditorId,
    'auditor_name': auditorName,
    'audit_date': auditDate,
    'created_at': createdAt,
  };
  // endregion
}
// endregion

// region AuditUnitSummary
class AuditUnitSummary {
  // region Properties
  final int id;
  final int auditId;
  final String auditNumber;
  final int unitId;
  final String unitName;
  final String auditDate;
  final String auditDateDisplay;
  final String auditorName;
  // endregion

  // region Constructor
  AuditUnitSummary({
    required this.id,
    required this.auditId,
    required this.auditNumber,
    required this.unitId,
    required this.unitName,
    required this.auditDate,
    required this.auditDateDisplay,
    required this.auditorName,
  });
  // endregion

  // region Factory & Serialization
  factory AuditUnitSummary.fromJson(Map<String, dynamic> json) {
    return AuditUnitSummary(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      auditId: json['audit_id'] is int
          ? json['audit_id']
          : int.tryParse(json['audit_id']?.toString() ?? '') ?? 0,
      auditNumber: json['audit_number']?.toString() ?? '-',
      unitId: json['unit_id'] is int
          ? json['unit_id']
          : int.tryParse(json['unit_id']?.toString() ?? '') ?? 0,
      unitName: json['unit_name']?.toString() ?? '-',
      auditDate: json['audit_date']?.toString() ?? '',
      auditDateDisplay: json['audit_date_display']?.toString() ??
          json['audit_date']?.toString() ??
          '-',
      auditorName: json['auditor_name']?.toString() ?? '-',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'audit_id': auditId,
    'audit_number': auditNumber,
    'unit_id': unitId,
    'unit_name': unitName,
    'audit_date': auditDate,
    'audit_date_display': auditDateDisplay,
    'auditor_name': auditorName,
  };
  // endregion
}
// endregion

// region AuditCellData
class AuditCellData {
  // region Properties
  final int auditItemId;
  final int auditId;
  final num system;
  final num actual;
  final num diff;
  final String systemDisplay;
  final String actualDisplay;
  final String diffDisplay;
  final String result;
  final String? image;
  final List<String> images;
  final List<String> auditItemImg;
  // endregion

  // region Constructor
  AuditCellData({
    required this.auditItemId,
    required this.auditId,
    required this.system,
    required this.actual,
    required this.diff,
    required this.systemDisplay,
    required this.actualDisplay,
    required this.diffDisplay,
    required this.result,
    this.image,
    this.images = const [],
    this.auditItemImg = const [],
  });
  // endregion

  // region Factory & Serialization
  factory AuditCellData.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'] as List? ?? [];
    final imgList = rawImages.map((e) => e.toString()).toList();

    final rawItemImg = json['audit_item_img'] as List? ?? [];
    final itemImgList = rawItemImg.map((e) => e.toString()).toList();

    final singleImg = json['image']?.toString();

    // Ensure all resolved image URLs are accessible
    final allUrls = <String>{};
    if (singleImg != null && singleImg.isNotEmpty) allUrls.add(singleImg);
    allUrls.addAll(imgList.where((u) => u.isNotEmpty));
    allUrls.addAll(itemImgList.where((u) => u.isNotEmpty));

    final rawSys = json['system']?.toString() ??
        json['system_qty']?.toString() ??
        '0';
    final rawAct = json['actual']?.toString() ??
        json['actual_qty']?.toString() ??
        '0';
    final rawDiff = json['diff']?.toString() ??
        json['diff_qty']?.toString() ??
        '0';

    return AuditCellData(
      auditItemId: json['audit_item_id'] is int
          ? json['audit_item_id']
          : int.tryParse(json['audit_item_id']?.toString() ?? '') ?? 0,
      auditId: json['audit_id'] is int
          ? json['audit_id']
          : int.tryParse(json['audit_id']?.toString() ?? '') ?? 0,
      system: num.tryParse(rawSys) ?? 0,
      actual: num.tryParse(rawAct) ?? 0,
      diff: num.tryParse(rawDiff) ?? 0,
      systemDisplay: rawSys,
      actualDisplay: rawAct,
      diffDisplay: rawDiff,
      result: json['result']?.toString() ?? 'Matched',
      image: singleImg?.isNotEmpty == true
          ? singleImg
          : (allUrls.isNotEmpty ? allUrls.first : null),
      images: allUrls.toList(),
      auditItemImg: itemImgList,
    );
  }

  Map<String, dynamic> toJson() => {
    'audit_item_id': auditItemId,
    'audit_id': auditId,
    'system': system,
    'actual': actual,
    'diff': diff,
    'system_display': systemDisplay,
    'actual_display': actualDisplay,
    'diff_display': diffDisplay,
    'result': result,
    'image': image,
    'images': images,
    'audit_item_img': auditItemImg,
  };
  // endregion
}
// endregion

// region AuditOverallTotal
class AuditOverallTotal {
  // region Properties
  final num system;
  final num actual;
  final num diff;
  final String systemDisplay;
  final String actualDisplay;
  final String diffDisplay;
  final String result;
  // endregion

  // region Constructor
  AuditOverallTotal({
    required this.system,
    required this.actual,
    required this.diff,
    required this.systemDisplay,
    required this.actualDisplay,
    required this.diffDisplay,
    required this.result,
  });
  // endregion

  // region Factory & Serialization
  factory AuditOverallTotal.fromJson(Map<String, dynamic> json) {
    final rawSys = json['system']?.toString() ??
        json['system_qty']?.toString() ??
        '0';
    final rawAct = json['actual']?.toString() ??
        json['actual_qty']?.toString() ??
        '0';
    final rawDiff = json['diff']?.toString() ??
        json['diff_qty']?.toString() ??
        '0';

    return AuditOverallTotal(
      system: num.tryParse(rawSys) ?? 0,
      actual: num.tryParse(rawAct) ?? 0,
      diff: num.tryParse(rawDiff) ?? 0,
      systemDisplay: rawSys,
      actualDisplay: rawAct,
      diffDisplay: rawDiff,
      result: json['result']?.toString() ?? 'Matched',
    );
  }

  Map<String, dynamic> toJson() => {
    'system': system,
    'actual': actual,
    'diff': diff,
    'system_display': systemDisplay,
    'actual_display': actualDisplay,
    'diff_display': diffDisplay,
    'result': result,
  };
  // endregion
}
// endregion

// region AuditMatrixItem
class AuditMatrixItem {
  // region Properties
  final int itemId;
  final String name;
  final String category;
  final String unit;
  final Map<String, AuditCellData> cells;
  final AuditOverallTotal overallTotal;
  // endregion

  // region Constructor
  AuditMatrixItem({
    required this.itemId,
    required this.name,
    required this.category,
    required this.unit,
    required this.cells,
    required this.overallTotal,
  });
  // endregion

  // region Factory & Serialization
  factory AuditMatrixItem.fromJson(Map<String, dynamic> json) {
    final rawCells = json['cells'] is Map ? json['cells'] as Map : {};
    final cellsMap = <String, AuditCellData>{};

    rawCells.forEach((key, val) {
      if (val is Map<String, dynamic>) {
        cellsMap[key.toString()] = AuditCellData.fromJson(val);
      } else if (val is Map) {
        cellsMap[key.toString()] =
            AuditCellData.fromJson(Map<String, dynamic>.from(val));
      }
    });

    final rawOverall = json['overall_total'] is Map
        ? Map<String, dynamic>.from(json['overall_total'])
        : <String, dynamic>{};

    return AuditMatrixItem(
      itemId: json['item_id'] is int
          ? json['item_id']
          : int.tryParse(json['item_id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '-',
      category: json['category']?.toString() ?? '-',
      unit: json['unit']?.toString() ?? '-',
      cells: cellsMap,
      overallTotal: AuditOverallTotal.fromJson(rawOverall),
    );
  }

  Map<String, dynamic> toJson() => {
    'item_id': itemId,
    'name': name,
    'category': category,
    'unit': unit,
    'cells': cells.map((k, v) => MapEntry(k, v.toJson())),
    'overall_total': overallTotal.toJson(),
  };
  // endregion
}
// endregion

// region AuditExtraItem
class AuditExtraItem {
  // region Properties
  final int itemId;
  final String name;
  final String category;
  final String unit;
  final Map<String, num> actualPerUnit;
  final Map<String, String> actualPerUnitDisplay;
  final num totalActual;
  final String totalActualDisplay;
  final List<String> imageUrls;
  // endregion

  // region Constructor
  AuditExtraItem({
    required this.itemId,
    required this.name,
    required this.category,
    required this.unit,
    required this.actualPerUnit,
    this.actualPerUnitDisplay = const {},
    required this.totalActual,
    this.totalActualDisplay = '0',
    this.imageUrls = const [],
  });
  // endregion

  // region Factory & Serialization
  factory AuditExtraItem.fromJson(Map<String, dynamic> json) {
    final rawCells = json['cells'] is Map ? json['cells'] as Map : {};
    final perUnit = <String, num>{};
    final perUnitDisplay = <String, String>{};

    rawCells.forEach((key, val) {
      if (val is Map) {
        final act = val['actual'] ?? val['actual_qty'];
        final strVal = act?.toString() ?? '0';
        perUnit[key.toString()] = num.tryParse(strVal) ?? 0;
        perUnitDisplay[key.toString()] = strVal;
      } else if (val is num) {
        perUnit[key.toString()] = val;
        perUnitDisplay[key.toString()] = val.toString();
      }
    });

    final rawOverall = json['overall_total'] is Map ? json['overall_total'] : {};
    final rawTotal = rawOverall['actual']?.toString() ??
        json['total_actual']?.toString() ??
        '0';
    final total = num.tryParse(rawTotal) ?? 0;

    final rawUrls = json['images'] ?? json['audit_item_img'] ?? json['image'];
    final urls = <String>[];
    if (rawUrls is List) {
      for (var u in rawUrls) {
        if (u is String && u.isNotEmpty) urls.add(u);
      }
    } else if (rawUrls is String && rawUrls.isNotEmpty) {
      urls.add(rawUrls);
    }

    return AuditExtraItem(
      itemId: json['item_id'] is int
          ? json['item_id']
          : int.tryParse(json['item_id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? json['item_name']?.toString() ?? '-',
      category: json['category']?.toString() ?? '-',
      unit: json['unit']?.toString() ?? json['measurement_unit']?.toString() ?? '-',
      actualPerUnit: perUnit,
      actualPerUnitDisplay: perUnitDisplay,
      totalActual: total,
      totalActualDisplay: rawTotal,
      imageUrls: urls,
    );
  }

  Map<String, dynamic> toJson() => {
    'item_id': itemId,
    'name': name,
    'category': category,
    'unit': unit,
    'actual_per_unit': actualPerUnit,
    'actual_per_unit_display': actualPerUnitDisplay,
    'total_actual': totalActual,
    'total_actual_display': totalActualDisplay,
    'images': imageUrls,
  };
  // endregion
}
// endregion

// region AuditDetailData
class AuditDetailData {
  // region Properties
  final int id;
  final String auditNumber;
  final String day;
  final String dateDisplay;
  final int totalUnits;
  final String unitNames;
  final List<AuditUnitSummary> unitList;
  final Map<String, dynamic> columns;
  final List<AuditMatrixItem> matrix;
  final List<AuditExtraItem> extra;
  final int existingItemsCount;
  final int additionalItemsCount;

  // Legacy fields for backward compatibility
  final String unitName;
  final String districtName;
  final String imageUrl;
  final String auditorName;
  final String auditDateDisplay;
  final int totalItemsCount;
  // endregion

  // region Constructor
  AuditDetailData({
    required this.id,
    required this.auditNumber,
    required this.day,
    required this.dateDisplay,
    required this.totalUnits,
    required this.unitNames,
    required this.unitList,
    required this.columns,
    required this.matrix,
    required this.extra,
    required this.existingItemsCount,
    required this.additionalItemsCount,
    required this.unitName,
    required this.districtName,
    required this.imageUrl,
    required this.auditorName,
    required this.auditDateDisplay,
    required this.totalItemsCount,
  });
  // endregion

  // region Factory & Serialization
  factory AuditDetailData.fromJson(Map<String, dynamic> json) {
    final rawUnitList = json['unitList'] as List? ?? [];
    final unitList = rawUnitList
        .map((u) => AuditUnitSummary.fromJson(u as Map<String, dynamic>))
        .toList();

    final rawMatrix = json['matrix'] as List? ?? [];
    final matrix = rawMatrix
        .map((m) => AuditMatrixItem.fromJson(m as Map<String, dynamic>))
        .toList();

    final rawExtra = json['extra'] as List? ?? [];
    final extra = rawExtra
        .map((e) => AuditExtraItem.fromJson(e as Map<String, dynamic>))
        .toList();

    final id = json['audit_id'] is int
        ? json['audit_id']
        : int.tryParse(json['audit_id']?.toString() ?? '') ??
            (json['id'] is int
                ? json['id']
                : int.tryParse(json['id']?.toString() ?? '') ?? 0);

    final auditNumber = json['audit_number']?.toString() ?? '-';
    final day = json['day']?.toString() ?? json['audit_day']?.toString() ?? '';
    final dateDisplay = json['date_display']?.toString() ??
        json['audit_date_display']?.toString() ??
        '-';

    final totalUnits = json['total_units'] is int
        ? json['total_units']
        : int.tryParse(json['total_units']?.toString() ?? '') ??
            unitList.length;

    final unitNames = json['unit_names']?.toString() ??
        unitList.map((u) => u.unitName).join(', ');

    final existCount = json['existing_items_count'] is int
        ? json['existing_items_count']
        : int.tryParse(json['existing_items_count']?.toString() ?? '') ??
            matrix.length;

    final addCount = json['additional_items_count'] is int
        ? json['additional_items_count']
        : int.tryParse(json['additional_items_count']?.toString() ?? '') ??
            extra.length;

    // Resolve legacy fallbacks
    final firstUnit = unitList.isNotEmpty ? unitList.first : null;
    final unitName = firstUnit?.unitName ?? '-';
    final auditorName = firstUnit?.auditorName ?? '-';

    return AuditDetailData(
      id: id,
      auditNumber: auditNumber,
      day: day,
      dateDisplay: dateDisplay,
      totalUnits: totalUnits,
      unitNames: unitNames,
      unitList: unitList,
      columns: json['columns'] is Map
          ? Map<String, dynamic>.from(json['columns'])
          : {},
      matrix: matrix,
      extra: extra,
      existingItemsCount: existCount,
      additionalItemsCount: addCount,
      unitName: unitName,
      districtName: '',
      imageUrl: '',
      auditorName: auditorName,
      auditDateDisplay: dateDisplay,
      totalItemsCount: existCount + addCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'audit_id': id,
    'audit_number': auditNumber,
    'day': day,
    'date_display': dateDisplay,
    'total_units': totalUnits,
    'unit_names': unitNames,
    'unitList': unitList.map((u) => u.toJson()).toList(),
    'columns': columns,
    'matrix': matrix.map((m) => m.toJson()).toList(),
    'extra': extra.map((e) => e.toJson()).toList(),
    'existing_items_count': existingItemsCount,
    'additional_items_count': additionalItemsCount,
  };
  // endregion
}
// endregion

// endregion
