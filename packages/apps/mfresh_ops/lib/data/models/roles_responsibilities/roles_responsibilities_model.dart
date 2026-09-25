class RoleItem {
  final int id;
  final String roleName;
  final String? createdAt;
  final String? updatedAt;

  RoleItem({
    required this.id,
    required this.roleName,
    this.createdAt,
    this.updatedAt,
  });

  factory RoleItem.fromJson(Map<String, dynamic> json) {
    return RoleItem(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      roleName: json['role_name']?.toString() ?? json['name']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoleItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class RolesResponse {
  final bool status;
  final String? message;
  final int count;
  final int currentPage;
  final int perPage;
  final int lastPage;
  final List<RoleItem> roles;

  RolesResponse({
    required this.status,
    this.message,
    required this.count,
    required this.currentPage,
    required this.perPage,
    required this.lastPage,
    required this.roles,
  });

  factory RolesResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['result'] ?? json['data'];
    return RolesResponse(
      status: json['status'] ?? true,
      message: json['message']?.toString(),
      count: json['count'] is int ? json['count'] : (int.tryParse(json['count']?.toString() ?? '0') ?? 0),
      currentPage: json['current_page'] is int ? json['current_page'] : 1,
      perPage: json['per_page'] is int ? json['per_page'] : 15,
      lastPage: json['last_page'] is int ? json['last_page'] : 1,
      roles: rawList is List
          ? rawList.map((e) => RoleItem.fromJson(e as Map<String, dynamic>)).toList()
          : [],
    );
  }
}

class ResponsibilityItem {
  final int id;
  final int roleId;
  final String? roleName;
  final String? guidelinesEnglish;
  final String? guidelinesOdia;

  ResponsibilityItem({
    required this.id,
    required this.roleId,
    this.roleName,
    this.guidelinesEnglish,
    this.guidelinesOdia,
  });

  factory ResponsibilityItem.fromJson(Map<String, dynamic> json) {
    return ResponsibilityItem(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      roleId: json['role_id'] is int
          ? json['role_id']
          : (int.tryParse(json['role_id']?.toString() ?? '0') ?? 0),
      roleName: json['role_name']?.toString(),
      guidelinesEnglish: json['guidelines_english']?.toString(),
      guidelinesOdia: json['guidelines_odia']?.toString(),
    );
  }
}

class ResponsibilitiesResponse {
  final bool status;
  final String? message;
  final int count;
  final int currentPage;
  final int perPage;
  final int lastPage;
  final List<ResponsibilityItem> responsibilities;

  ResponsibilitiesResponse({
    required this.status,
    this.message,
    required this.count,
    required this.currentPage,
    required this.perPage,
    required this.lastPage,
    required this.responsibilities,
  });

  factory ResponsibilitiesResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['result'] ?? json['data'];
    return ResponsibilitiesResponse(
      status: json['status'] ?? true,
      message: json['message']?.toString(),
      count: json['count'] is int ? json['count'] : (int.tryParse(json['count']?.toString() ?? '0') ?? 0),
      currentPage: json['current_page'] is int ? json['current_page'] : 1,
      perPage: json['per_page'] is int ? json['per_page'] : 15,
      lastPage: json['last_page'] is int ? json['last_page'] : 1,
      responsibilities: rawList is List
          ? rawList.map((e) => ResponsibilityItem.fromJson(e as Map<String, dynamic>)).toList()
          : [],
    );
  }
}

class ResponsibilityViewResponse {
  final bool status;
  final String? message;
  final int roleId;
  final String? roleName;
  final String? language;
  final String? guidelines;

  ResponsibilityViewResponse({
    required this.status,
    this.message,
    required this.roleId,
    this.roleName,
    this.language,
    this.guidelines,
  });

  factory ResponsibilityViewResponse.fromJson(Map<String, dynamic> json) {
    return ResponsibilityViewResponse(
      status: json['status'] ?? true,
      message: json['message']?.toString(),
      roleId: json['role_id'] is int
          ? json['role_id']
          : (int.tryParse(json['role_id']?.toString() ?? '0') ?? 0),
      roleName: json['role_name']?.toString(),
      language: json['language']?.toString(),
      guidelines: json['guidelines']?.toString() ?? json['result']?.toString(),
    );
  }
}
