class UserSummaryDto {
  const UserSummaryDto({required this.id, this.externalId, this.displayName});

  factory UserSummaryDto.fromJson(Map<String, dynamic> json) => UserSummaryDto(
    id: (json['id'] as num).toInt(),
    externalId: json['external_id'] as String?,
    displayName: json['display_name'] as String?,
  );

  final int id;
  final String? externalId;
  final String? displayName;

  Map<String, dynamic> toJson() => {
    'id': id,
    if (externalId != null) 'external_id': externalId,
    if (displayName != null) 'display_name': displayName,
  };
}
