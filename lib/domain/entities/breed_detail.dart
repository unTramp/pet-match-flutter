import 'package:equatable/equatable.dart';

import 'breed_attributes.dart';
import 'breed_flags.dart';

class BreedSection extends Equatable {
  const BreedSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  List<Object?> get props => [title, body];
}

class BreedDetail extends Equatable {
  const BreedDetail({
    required this.breedId,
    required this.breedName,
    this.summary,
    this.imageUrl,
    this.storyAvatarUrl,
    this.galleryImages = const [],
    this.sections = const [],
    this.attributes,
    this.group,
    this.aliases = const [],
    this.flags,
  });

  final String breedId;
  final String breedName;
  final String? summary;
  final String? imageUrl;
  final String? storyAvatarUrl;
  final List<String> galleryImages;
  final List<BreedSection> sections;
  final BreedAttributes? attributes;
  final String? group;
  final List<String> aliases;
  final BreedFlags? flags;

  bool get hasGallery => galleryImages.isNotEmpty;

  @override
  List<Object?> get props => [
    breedId,
    breedName,
    summary,
    imageUrl,
    storyAvatarUrl,
    galleryImages,
    sections,
    attributes,
    group,
    aliases,
    flags,
  ];
}
