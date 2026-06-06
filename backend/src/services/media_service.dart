import 'dart:io';

class MediaService {
  MediaService({required String publicBaseUrl, required String mediaRootPath})
    : _publicBaseUri = Uri.parse(publicBaseUrl),
      _mediaRoot = Directory(mediaRootPath);

  final Uri _publicBaseUri;
  final Directory _mediaRoot;

  String? resolveStoryAvatarUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) {
      return rawUrl;
    }

    final uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      return rawUrl;
    }

    if (!uri.hasScheme) {
      return _publicBaseUri.resolveUri(uri).toString();
    }

    if (uri.path.startsWith('/media/story-avatars/')) {
      return _publicBaseUri
          .replace(
            path: uri.path,
            query: uri.hasQuery ? uri.query : null,
            fragment: uri.hasFragment ? uri.fragment : null,
          )
          .toString();
    }

    return rawUrl;
  }

  File? resolveStoryAvatarFile(String fileName) {
    if (fileName.isEmpty ||
        fileName.contains('..') ||
        fileName.contains('/') ||
        fileName.contains('\\')) {
      return null;
    }

    return File('${_mediaRoot.path}/story-avatars/$fileName');
  }
}
