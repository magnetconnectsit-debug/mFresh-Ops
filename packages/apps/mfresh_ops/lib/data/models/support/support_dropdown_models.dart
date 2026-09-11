class SupportUnit {
  final int unitId;
  final String unitName;

  SupportUnit({required this.unitId, required this.unitName});

  factory SupportUnit.fromJson(Map<String, dynamic> json) {
    return SupportUnit(
      unitId: json['unitid'] is int
          ? json['unitid']
          : int.tryParse(json['unitid']?.toString() ?? '') ?? 0,
      unitName: json['unitname']?.toString() ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportUnit &&
          runtimeType == other.runtimeType &&
          unitId == other.unitId;

  @override
  int get hashCode => unitId.hashCode;
}

class SupportCategory {
  final int categoryId;
  final String categoryName;

  SupportCategory({required this.categoryId, required this.categoryName});

  factory SupportCategory.fromJson(Map<String, dynamic> json) {
    return SupportCategory(
      categoryId: json['categoryid'] is int
          ? json['categoryid']
          : int.tryParse(json['categoryid']?.toString() ?? '') ?? 0,
      categoryName: json['categoryname']?.toString() ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportCategory &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId;

  @override
  int get hashCode => categoryId.hashCode;
}

class SupportProject {
  final int projectId;
  final String projectName;

  SupportProject({required this.projectId, required this.projectName});

  factory SupportProject.fromJson(Map<String, dynamic> json) {
    return SupportProject(
      projectId: json['projectid'] is int
          ? json['projectid']
          : int.tryParse(json['projectid']?.toString() ?? '') ?? 0,
      projectName: json['projectname']?.toString() ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportProject &&
          runtimeType == other.runtimeType &&
          projectId == other.projectId;

  @override
  int get hashCode => projectId.hashCode;
}

class SupportSubCategory {
  final int subCategoryId;
  final String subCategoryName;

  SupportSubCategory({
    required this.subCategoryId,
    required this.subCategoryName,
  });

  factory SupportSubCategory.fromJson(Map<String, dynamic> json) {
    return SupportSubCategory(
      subCategoryId: json['subcategoryid'] is int
          ? json['subcategoryid']
          : int.tryParse(json['subcategoryid']?.toString() ?? '') ?? 0,
      subCategoryName: json['subcategoryname']?.toString() ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportSubCategory &&
          runtimeType == other.runtimeType &&
          subCategoryId == other.subCategoryId;

  @override
  int get hashCode => subCategoryId.hashCode;
}
