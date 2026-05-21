import 'package:equatable/equatable.dart';

class QuestionOption extends Equatable {
  const QuestionOption({
    required this.id,
    required this.code,
    required this.label,
  });

  final int id;
  final String code;
  final String label;

  @override
  List<Object?> get props => [id, code, label];
}

/// Динамическая опция, подгружаемая с сервера (например, конкретная порода).
class DynamicOption extends Equatable {
  const DynamicOption({required this.code, required this.label, this.sourceType});

  final String code;
  final String label;
  final String? sourceType;

  @override
  List<Object?> get props => [code, label, sourceType];
}
