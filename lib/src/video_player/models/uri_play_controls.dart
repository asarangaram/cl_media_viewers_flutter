abstract class UriPlayControls {
  Future<void> play();
  Future<void> pause();
  Future<void> onPlayPause({
    required bool autoPlay,
    required bool forced,
  });
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
  Future<void> removeVideo();

  Uri? get uri;

  Future<void> onAdjustVolume(
    double value,
  );
  Future<void> onToggleAudioMute();
}
