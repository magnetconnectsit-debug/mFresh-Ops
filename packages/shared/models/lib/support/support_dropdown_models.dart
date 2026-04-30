class SupportUnit {
  final int unitId;
  final String unitName;

  SupportUnit({required this.unitId, required this.unitName});

  factory SupportUnit.fromJson(Map<String, dynamic> json) {
    return SupportUnit(
      unitId: json['unitid'],
      unitName: json['unitname'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportUnit && runtimeType == other.runtimeType && unitId == other.unitId;

  @override
  int get hashCode => unitId.hashCode;
}

class SupportCategory {
  final int categoryId;
  final String categoryName;

  SupportCategory({required this.categoryId, required this.categoryName});

  factory SupportCategory.fromJson(Map<String, dynamic> json) {
    return SupportCategory(
      categoryId: json['categoryid'],
      categoryName: json['categoryname'],
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
      projectId: json['projectid'],
      projectName: json['projectname'],
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

  SupportSubCategory({required this.subCategoryId, required this.subCategoryName});

  factory SupportSubCategory.fromJson(Map<String, dynamic> json) {
    return SupportSubCategory(
      subCategoryId: json['subcategoryid'],
      subCategoryName: json['subcategoryname'],
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
