import 'package:equatable/equatable.dart';

class Progress extends Equatable {
  const Progress({required this.answered, required this.total});

  final int answered;
  final int total;

  double get percent {
    if (total <= 0) return 0;
    return (answered / total).clamp(0.0, 1.0);
  }

  int get percentInt => (percent * 100).round();

  @override
  List<Object?> get props => [answered, total];
}
