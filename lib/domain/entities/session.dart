import 'package:equatable/equatable.dart';

import 'compatibility.dart';
import 'progress.dart';
import 'question.dart';

class Session extends Equatable {
  const Session({
    required this.userId,
    required this.progress,
    this.nextQuestion,
    this.compatibility,
  });

  final int userId;
  final Progress progress;
  final Question? nextQuestion;
  final Compatibility? compatibility;

  bool get isCompleted => nextQuestion == null;

  @override
  List<Object?> get props => [userId, progress, nextQuestion, compatibility];
}
