/// Минимальный shape пользователя из `SessionRead.user`. Из DTO в domain
/// проходит только `id` (см. `SessionMapper.fromDto`); поля
/// `external_id`/`display_name` нам сейчас не нужны на клиенте.
class UserSummaryDto {
  const UserSummaryDto({required this.id});

  factory UserSummaryDto.fromJson(Map<String, dynamic> json) =>
      UserSummaryDto(id: (json['id'] as num).toInt());

  final int id;
}
