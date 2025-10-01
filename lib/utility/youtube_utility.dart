class YouTubeUtility {
  static String? getYouTubeThumbnail(String videoUrl) {
    try {
      final uri = Uri.parse(videoUrl);
      if (uri.host.contains('youtube.com') || uri.host.contains('youtu.be')) {
        String? videoId;
        if (uri.host.contains('youtube.com')) {
          videoId = uri.queryParameters['v'];
        } else if (uri.host.contains('youtu.be')) {
          videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
        }
        if (videoId != null && videoId.isNotEmpty) {
          return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
