import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pet_match/core/failures.dart';
import 'package:pet_match/domain/entities/breed_detail.dart';
import 'package:pet_match/domain/usecases/get_breed_detail.dart';
import 'package:pet_match/presentation/details/cubit/breed_detail_cubit.dart';
import 'package:pet_match/presentation/details/cubit/breed_detail_state.dart';

class _MockGetBreedDetail extends Mock implements GetBreedDetail {}

void main() {
  late _MockGetBreedDetail useCase;

  setUp(() {
    useCase = _MockGetBreedDetail();
  });

  const detail = BreedDetail(breedId: 1, breedName: 'Лабрадор');

  blocTest<BreedDetailCubit, BreedDetailState>(
    'success: load → [Loading, Loaded]',
    setUp: () {
      when(() => useCase(any())).thenAnswer((_) async => detail);
    },
    build: () => BreedDetailCubit(useCase),
    act: (cubit) => cubit.load(1),
    expect: () => [
      isA<BreedDetailLoading>(),
      isA<BreedDetailLoaded>().having(
        (s) => s.detail.breedName,
        'breedName',
        'Лабрадор',
      ),
    ],
  );

  blocTest<BreedDetailCubit, BreedDetailState>(
    'AppFailure → [Loading, Error]',
    setUp: () {
      when(() => useCase(any())).thenThrow(const NetworkFailure());
    },
    build: () => BreedDetailCubit(useCase),
    act: (cubit) => cubit.load(1),
    expect: () => [
      isA<BreedDetailLoading>(),
      isA<BreedDetailError>().having(
        (s) => s.failure,
        'failure',
        isA<NetworkFailure>(),
      ),
    ],
  );

  blocTest<BreedDetailCubit, BreedDetailState>(
    'retry после ошибки восстанавливается',
    setUp: () {
      var first = true;
      when(() => useCase(any())).thenAnswer((_) async {
        if (first) {
          first = false;
          throw const NetworkFailure();
        }
        return detail;
      });
    },
    build: () => BreedDetailCubit(useCase),
    act: (cubit) async {
      await cubit.load(1);
      await cubit.load(1);
    },
    expect: () => [
      isA<BreedDetailLoading>(),
      isA<BreedDetailError>(),
      isA<BreedDetailLoading>(),
      isA<BreedDetailLoaded>(),
    ],
  );
}
