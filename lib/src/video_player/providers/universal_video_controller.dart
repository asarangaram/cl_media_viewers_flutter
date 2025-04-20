import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../config/providers/universal_config.dart';
import '../../config/providers/uri_config.dart';
import '../models/universal_video_controller.dart';
import '../models/uri_play_controls.dart';

class UniversalVideoControllerNotifier
    extends StateNotifier<UniversalVideoController>
    implements UniversalPlayControls {
  UniversalVideoControllerNotifier(this.ref)
      : super(const UniversalVideoController());
  Ref ref;
  VideoPlayerController? controller;

  @override
  Future<void> resetVideo({
    required bool autoPlay,
  }) async {
    await setVideo(state.path!, autoPlay: autoPlay, forced: true);
  }

  @override
  Future<void> setVideo(
    Uri uri, {
    required bool autoPlay,
    required bool forced,
  }) async {
    if (!forced && state.path == uri) return;
    state = state.copyWith(path: () => uri);
    try {
      if (controller != null) {
        await controller!.pause();
        controller!.removeListener(timestampUpdater);
        await controller!.dispose();
      }

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
      if (controller != null) {
        await controller!.initialize();
        if (!controller!.value.isInitialized) {
          throw Exception('Failed to load Video');
        }
        await controller!.setVolume(
          ref.read(universalConfigurationProvider).audioVolume,
        );
        await controller!.seekTo(
          ref.read(uriConfigurationProvider(uri)).lastKnownPlayPosition,
        );
        if (autoPlay) {
          await controller!.play();
        }
        controller!.addListener(timestampUpdater);
        state = state.copyWith(controllerAsync: AsyncValue.data(controller!));
      }
    } catch (error, stackTrace) {
      state = state.copyWith(controllerAsync: AsyncError(error, stackTrace));
    }
  }

  void timestampUpdater() {
    if (state.path != null) {
      final uri = state.path!;
      controller?.position.then((position) {
        final laskKnownPosition =
            ref.read(uriConfigurationProvider(uri)).lastKnownPlayPosition;
        final diff = position! - laskKnownPosition;
        if (diff > const Duration(seconds: 1)) {
          ref.read(uriConfigurationProvider(uri).notifier).update(
                lastKnownPlayPosition: position,
              );
        }
      });
    }
  }

  @override
  Future<void> removeVideo() async {
    if (controller != null) {
      await controller!.pause();
      state = state.copyWith(
        controllerAsync: const AsyncValue.loading(),
        path: () => null,
      );
      await controller!.dispose();
    }
  }

  @override
  void dispose() {
    if (mounted) {
      if (controller?.value.isPlaying ?? false) {
        controller?.pause();
      }
      controller!.removeListener(timestampUpdater);
      controller?.dispose();
      controller = null;
      super.dispose();
    }
  }

  @override
  Uri? get uri => state.path;

  @override
  Future<void> onAdjustVolume(
    double value,
  ) async {
    final curr = ref.read(universalConfigurationProvider);
    if (curr.lastKnownVolume != value) {
      await ref
          .read(universalConfigurationProvider.notifier)
          .update(lastKnownVolume: value);
    }
    if (controller != null) {
      await controller!.setVolume(value);
    }
  }

  @override
  Future<void> onToggleAudioMute() async {
    final curr = ref.read(universalConfigurationProvider);
    final mute = !curr.isAudioMuted;

    await ref
        .read(universalConfigurationProvider.notifier)
        .update(isAudioMuted: mute);

    await controller?.setVolume(mute ? 0 : curr.lastKnownVolume);
  }
}

final universalVideoControllerProvider = StateNotifierProvider<
    UniversalVideoControllerNotifier, UniversalVideoController>((ref) {
  final notifier = UniversalVideoControllerNotifier(ref);
  return notifier;
});
