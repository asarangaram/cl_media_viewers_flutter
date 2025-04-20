import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../config/providers/universal_config.dart';
import '../../config/providers/uri_config.dart';
import '../models/uri_play_controller.dart';
import '../models/uri_play_controls.dart';
import 'universal_video_controller.dart';

class UriPlayControllerNotifier extends StateNotifier<UriPlayController>
    implements UriPlayControls {
  UriPlayControllerNotifier(this.ref, super.state, {required this.uri});
  final Ref ref;
  final Uri uri;

  VideoPlayerController? get controller => state.controller;

  @override
  void play() => state.controller?.play();

  @override
  Future<void>? pause() => state.controller?.pause();

  @override
  void onPlayPause() {
    if (state.controller == null) {
      return;
    }
    final videoplayerStatus = state.controller!.value;
    if (videoplayerStatus.isCompleted) {
      final isLive = (videoplayerStatus.duration.inSeconds) > 10 * 60 * 60;
      if (isLive) {
        ref
            .read(universalVideoControllerProvider.notifier)
            .setVideo(uri, autoPlay: true, forced: true)
            .then((val) => play());
      } else {
        play();
      }
    }
    // If the video is playing, pause it.
    if (videoplayerStatus.isPlaying) {
      pause();
    } else {
      play();
    }
  }
}

final uriPlayControllerProvider = StateNotifierProvider.family<
    UriPlayControllerNotifier, UriPlayController, Uri>((ref, uri) {
  final universalVideoController = ref.watch(universalVideoControllerProvider);
  final universalConfig = ref.watch(universalConfigurationProvider);
  final uriConfig = ref.watch(uriConfigurationProvider(uri));

  final controller = universalVideoController.controllerAsync
      .whenOrNull(data: (controller) => controller);

  return UriPlayControllerNotifier(
    ref,
    UriPlayController(
      controller: controller,
      uriConfig: uriConfig,
      universalConfig: universalConfig,
    ),
    uri: uri,
  );
});
