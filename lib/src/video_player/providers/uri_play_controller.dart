import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/providers/universal_config.dart';
import '../../config/providers/uri_config.dart';
import '../models/uri_play_controller.dart';
import '../models/uri_play_controls.dart';
import 'universal_video_controller.dart';

class UriPlayControllerNotifier
    extends AutoDisposeFamilyAsyncNotifier<UriPlayController, Uri>
    implements UriPlayControls {
  UriPlayControllerNotifier();

  @override
  FutureOr<UriPlayController> build(Uri arg) async {
    final universalVideoController =
        (await ref.watch(universalVideoControllerProvider.future)).controller;

    final universalConfig = await ref.watch(universalConfigProvider.future);
    final uriConfig = await ref.watch(uriConfigurationProvider(arg).future);

    return UriPlayController(
      controller: universalVideoController,
      uriConfig: uriConfig,
      universalConfig: universalConfig,
    );
  }

  @override
  Future<void> play() async => state.value?.controller?.play();

  @override
  Future<void> pause() async => state.value?.controller?.pause();
  @override
  Future<void> onPlayPause({
    required bool autoPlay,
    required bool forced,
  }) async {
    final uri = arg;
    if (state.value?.controller != null) {
      final controller = state.value!.controller!;
      final videoplayerStatus = controller.value;
      if (videoplayerStatus.isCompleted) {
        final isLive = (videoplayerStatus.duration.inSeconds) > 10 * 60 * 60;
        if (isLive) {
          await ref
              .read(universalVideoControllerProvider.notifier)
              .setVideo(uri, autoPlay: autoPlay, forced: forced);
        }
        await play();
      }

      if (videoplayerStatus.isPlaying) {
        await pause();
      } else {
        await play();
      }
    }
  }
}

final uriPlayControllerProvider = AsyncNotifierProvider.family
    .autoDispose<UriPlayControllerNotifier, UriPlayController, Uri>(
  UriPlayControllerNotifier.new,
);
