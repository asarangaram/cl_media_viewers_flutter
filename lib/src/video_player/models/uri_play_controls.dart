abstract class UriPlayControls {
  Future<void> play();
  Future<void> pause();
  Future<void> onPlayPause();
}

abstract class UniversalPlayControls {
  Future<void> setVideo(
    Uri uri, {
    required bool autoPlay,
    required bool forced,
  });
  Future<void> resetVideo({
    required bool autoPlay,
  });
  Future<void> stopVideo();

  Uri? get uri;
}
