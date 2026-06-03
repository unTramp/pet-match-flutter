import 'dart:io';

import 'reference_matcher.dart';

const List<String> _requiredFlags = <String>[
  'isVocal',
  'isHighPreyDrive',
  'isSensitive',
  'isEscapeProne',
  'isSuitableForFirstTimeOwners',
];

const List<String> _requiredContentLists = <String>[
  'strengths',
  'watchouts',
  'adaptationTips',
];

class CatalogValidationReport {
  const CatalogValidationReport({
    required this.catalogVersion,
    required this.breedCount,
    required this.errors,
    required this.warnings,
  });

  final int catalogVersion;
  final int breedCount;
  final List<String> errors;
  final List<String> warnings;

  bool get isValid => errors.isEmpty;
}

class CatalogValidator {
  CatalogValidator({
    required this.catalogPath,
    required this.scoringConfigPath,
  });

  final String catalogPath;
  final String scoringConfigPath;

  CatalogValidationReport validate() {
    final errors = <String>[];
    final warnings = <String>[];

    final catalog = loadJson(catalogPath);
    final config = ScoringConfig.fromJson(loadJson(scoringConfigPath));
    final catalogVersion = (catalog['catalogVersion'] as num?)?.toInt() ?? -1;
    final petType = catalog['petType'] as String?;
    final breeds = List<Map<String, dynamic>>.from(
      catalog['breeds'] as List<dynamic>? ?? const [],
    );

    final requiredAttributes = _requiredAttributes(config);
    final seenBreedIds = <String>{};

    for (final entry in breeds) {
      final breedId = entry['breedId'] as String?;
      final fileName = entry['file'] as String?;

      if (breedId == null || breedId.isEmpty) {
        errors.add('Catalog entry is missing breedId.');
        continue;
      }
      if (!seenBreedIds.add(breedId)) {
        errors.add('Duplicate breedId in catalog: $breedId');
      }
      if (fileName == null || fileName.isEmpty) {
        errors.add('Catalog entry $breedId is missing file.');
        continue;
      }

      final file = File(_resolveExamplePath(fileName));
      if (!file.existsSync()) {
        errors.add('Breed file not found for $breedId: ${file.path}');
        continue;
      }

      final breedJson = loadJson(file.path);
      _validateBreed(
        breedId: breedId,
        catalogPetType: petType,
        catalogVersion: catalogVersion,
        requiredAttributes: requiredAttributes,
        breedJson: breedJson,
        errors: errors,
        warnings: warnings,
      );
    }

    return CatalogValidationReport(
      catalogVersion: catalogVersion,
      breedCount: breeds.length,
      errors: errors,
      warnings: warnings,
    );
  }

  void _validateBreed({
    required String breedId,
    required String? catalogPetType,
    required int catalogVersion,
    required Set<String> requiredAttributes,
    required Map<String, dynamic> breedJson,
    required List<String> errors,
    required List<String> warnings,
  }) {
    if (breedJson['breedId'] != breedId) {
      errors.add(
        'Breed file mismatch for $breedId: file contains ${breedJson['breedId']}',
      );
    }

    if (catalogPetType != null && breedJson['petType'] != catalogPetType) {
      errors.add(
        'Breed $breedId has petType=${breedJson['petType']}, expected $catalogPetType',
      );
    }

    final attributes = Map<String, dynamic>.from(
      breedJson['attributes'] as Map<String, dynamic>? ?? const {},
    );
    for (final field in requiredAttributes) {
      final value = attributes[field];
      if (value == null) {
        errors.add('Breed $breedId is missing required attribute $field');
        continue;
      }
      if (value is! num || value < 1 || value > 5) {
        errors.add('Breed $breedId has out-of-range attribute $field=$value');
      }
    }

    final flags = Map<String, dynamic>.from(
      breedJson['flags'] as Map<String, dynamic>? ?? const {},
    );
    for (final field in _requiredFlags) {
      final value = flags[field];
      if (value is! bool) {
        errors.add('Breed $breedId has invalid flag $field=$value');
      }
    }

    final content = Map<String, dynamic>.from(
      breedJson['content'] as Map<String, dynamic>? ?? const {},
    );
    final summaryShort = content['summaryShort'];
    if (summaryShort is! String || summaryShort.trim().isEmpty) {
      errors.add('Breed $breedId is missing content.summaryShort');
    }
    for (final field in _requiredContentLists) {
      final value = content[field];
      if (value is! List ||
          value.isEmpty ||
          value.any((item) => item is! String)) {
        errors.add('Breed $breedId has invalid content.$field');
      }
    }

    final quality = Map<String, dynamic>.from(
      breedJson['quality'] as Map<String, dynamic>? ?? const {},
    );
    final confidenceScore = quality['confidenceScore'];
    if (confidenceScore is! num || confidenceScore < 0 || confidenceScore > 1) {
      errors.add(
        'Breed $breedId has invalid quality.confidenceScore=$confidenceScore',
      );
    }
    final sourceCount = quality['sourceCount'];
    if (sourceCount is! num || sourceCount < 1) {
      errors.add('Breed $breedId has invalid quality.sourceCount=$sourceCount');
    }
    final sourceNotes = quality['sourceNotes'];
    if (sourceNotes is! List || sourceNotes.isEmpty) {
      errors.add('Breed $breedId has invalid quality.sourceNotes');
    } else if (sourceCount is num &&
        sourceNotes.length != sourceCount.toInt()) {
      warnings.add(
        'Breed $breedId has sourceCount=${sourceCount.toInt()} but ${sourceNotes.length} sourceNotes',
      );
    }
    final needsReview = quality['needsReview'];
    if (needsReview is! bool) {
      errors.add('Breed $breedId has invalid quality.needsReview=$needsReview');
    }
    final version = quality['version'];
    if (version is! num || version.toInt() != catalogVersion) {
      warnings.add(
        'Breed $breedId has quality.version=$version while catalogVersion=$catalogVersion',
      );
    }
  }

  Set<String> _requiredAttributes(ScoringConfig config) {
    final fields = <String>{...config.baseWeights.keys};
    for (final rule in config.priorityBonusRules) {
      fields.add(rule.breedField);
    }
    for (final rule in config.criticalCaps) {
      fields.add(rule.breedField);
    }
    return fields;
  }

  String _resolveExamplePath(String fileName) {
    final baseDir = File(catalogPath).parent.path;
    return '$baseDir/$fileName';
  }
}
