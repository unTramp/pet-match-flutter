import 'dart:io';

import '../repositories/breed_repository.dart';
import 'media_service.dart';

class BreedService {
  BreedService(this._repository, this._mediaService);

  final BreedRepository _repository;
  final MediaService _mediaService;

  Map<String, dynamic>? getBreed(String breedId) {
    final breed = _repository.getBreedById(breedId);
    if (breed == null) {
      return null;
    }

    return <String, dynamic>{
      ...breed,
      'storyAvatarUrl': _mediaService.resolveStoryAvatarUrl(
        breed['storyAvatarUrl'] as String?,
      ),
    };
  }

  File? getStoryAvatarFile(String fileName) =>
      _mediaService.resolveStoryAvatarFile(fileName);
}
