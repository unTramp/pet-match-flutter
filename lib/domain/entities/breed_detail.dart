import 'package:equatable/equatable.dart';

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
    this.galleryImages = const [],
    this.sections = const [],
  });

  final String breedId;
  final String breedName;
  final String? summary;
  final String? imageUrl;
  final List<String> galleryImages;
  final List<BreedSection> sections;

  bool get hasGallery => galleryImages.isNotEmpty;

  @override
  List<Object?> get props => [
    breedId,
    breedName,
    summary,
    imageUrl,
    galleryImages,
    sections,
  ];
}
