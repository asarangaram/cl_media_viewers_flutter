import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../config/providers/universal_config.dart';
import '../../config/providers/uri_config.dart';
import '../models/universal_video_controller.dart';
import '../models/uri_play_controls.dart';

class UniversalVideoControllerNotifier
    extends AutoDisposeAsyncNotifier<UniversalVideoController>
    implements UniversalPlayControls {
  UniversalVideoControllerNotifier();

  @override
  Future<UniversalVideoController> build() async {
    ref.onDispose(dispose);
    return const UniversalVideoController();
  }

  Future<void> dispose() async {
    final controller = state.value!.controller;
    await controller!.pause();
    controller.removeListener(timestampUpdater);
    await controller.dispose();
  }

  @override
  Future<void> resetVideo({
    required bool autoPlay,
  }) async {
    await setVideo(state.value!.path!, autoPlay: autoPlay, forced: true);
  }

  @override
  Future<void> setVideo(
    Uri uri, {
    required bool autoPlay,
    required bool forced,
  }) async {
    if (!forced && state.value!.path == uri) return;
    if (state.value!.controller != null) {
      final controller = state.value!.controller;
      await controller!.pause();
      controller.removeListener(timestampUpdater);
      await controller.dispose();
    }
    state = const AsyncValue.loading();
    try {
      VideoPlayerController? controller;

      if (uri.scheme == 'file') {
        final path = uri.toFilePath();
        if (!File(path).existsSync()) {
          throw FileSystemException('missing file', path);
        }

        controller = VideoPlayerController.file(File(path));
      } else if (['http', 'https'].contains(uri.scheme)) {
        controller = VideoPlayerController.networkUrl(
          uri,
          formatHint: VideoFormat.hls,
          videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
        );
      } else {
        throw Exception('not supported');
      }
      final universalConfig = await ref.read(universalConfigProvider.future);
      final uriConfig = await ref.read(uriConfigurationProvider(uri).future);
      await controller.initialize();
      if (!controller.value.isInitialized) {
        throw Exception('Failed to load Video');
      }
      await controller.setVolume(universalConfig.audioVolume);
      await controller.seekTo(uriConfig.lastKnownPlayPosition);

      if (autoPlay) {
        await controller.play();
      }
      controller.addListener(timestampUpdater);
      state = AsyncValue.data(
        state.value!.copyWith(controller: controller, path: () => uri),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> timestampUpdater() async {
    if (state.value?.path != null && state.value?.controller != null) {
      final controller = state.value!.controller!;

      final uri = state.value!.path!;
      final uriConfig = await ref.read(uriConfigurationProvider(uri).future);
      await controller.position.then((position) {
        final laskKnownPosition = uriConfig.lastKnownPlayPosition;
        final diff = (position! - laskKnownPosition).abs();
        if (diff > const Duration(seconds: 1)) {
          ref.read(uriConfigurationProvider(uri).notifier).onChange(
                lastKnownPlayPosition: position,
              );
        }
      });
    }
  }

  @override
  Future<void> removeVideo() async {
    if (state.value?.controller != null) {
      final controller = state.value!.controller!;
      await controller.pause();
      state = const AsyncValue.loading();
      await controller.dispose();
    }
  }

  @override
  Uri? get uri => state.value!.path;

  @override
  Future<void> onAdjustVolume(double value) async {
    final curr = await ref.read(universalConfigProvider.future);

    if (curr.lastKnownVolume != value) {
      await ref
          .read(universalConfigProvider.notifier)
          .onChange(lastKnownVolume: value, isAudioMuted: value != 0);
    }
    if (state.value!.controller != null) {
      final controller = state.value!.controller!;
      await controller.setVolume(curr.lastKnownVolume);
    }
  }

  @override
  Future<void> onToggleAudioMute() async {
    final curr = await ref.read(universalConfigProvider.future);
    final mute = !curr.isAudioMuted;

    await ref
        .read(universalConfigProvider.notifier)
        .onChange(isAudioMuted: mute);
    if (state.value!.controller != null) {
      final controller = state.value!.controller!;
      await controller.setVolume(mute ? 0 : curr.lastKnownVolume);
    }
  }
}

final universalVideoControllerProvider = AsyncNotifierProvider.autoDispose<
    UniversalVideoControllerNotifier,
    UniversalVideoController>(UniversalVideoControllerNotifier.new);
