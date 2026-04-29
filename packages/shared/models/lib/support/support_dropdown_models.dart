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
}
