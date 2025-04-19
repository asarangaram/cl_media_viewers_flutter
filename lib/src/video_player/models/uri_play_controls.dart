abstract class UriPlayControls {
  Future<void> play();
  Future<void> pause();
}

abstract class UniversalPlayControls {
  Future<void> setVideo(
    Uri uri, {
    bool autoPlay = true,
    bool forced = false,
  });
  Future<void> resetVideo({
    bool autoPlay = true,
    bool forced = false,
  });
  Future<void> stopVideo();
}
