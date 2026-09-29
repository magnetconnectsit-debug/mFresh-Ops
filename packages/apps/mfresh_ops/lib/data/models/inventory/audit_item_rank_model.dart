class AuditItemRankModel {
  final int id;
  final String rankName;
  final String? createdAt;
  final String? updatedAt;

  AuditItemRankModel({
    required this.id,
    required this.rankName,
    this.createdAt,
    this.updatedAt,
  });

  factory AuditItemRankModel.fromJson(Map<String, dynamic> json) {
    return AuditItemRankModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      rankName: json['rank_name']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rank_name': rankName,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
