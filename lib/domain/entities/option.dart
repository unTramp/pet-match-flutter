import 'package:equatable/equatable.dart';

class QuestionOption extends Equatable {
  const QuestionOption({
    required this.id,
    required this.code,
    required this.label,
    this.sortOrder = 0,
  });

  final int id;
  final String code;
  final String label;
  final int sortOrder;

  @override
  List<Object?> get props => [id, code, label, sortOrder];
}

/// Динамическая опция, подгружаемая с сервера (например, конкретная порода).
class DynamicOption extends Equatable {
  const DynamicOption({
    required this.code,
    required this.label,
    this.sourceType,
    this.sortOrder = 0,
  });

  final String code;
  final String label;
  final String? sourceType;
  final int sortOrder;

  @override
  List<Object?> get props => [code, label, sourceType, sortOrder];
}
