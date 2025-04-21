import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../config/providers/universal_config.dart';
import '../../config/providers/uri_config.dart';
import '../models/video_player_controls.dart';
import '../models/video_player_state.dart';

class VideoPlayerNotifier extends AutoDisposeAsyncNotifier<VideoPlayerState>
    implements VideoPlayerControls {
  VideoPlayerNotifier();

  @override
  Future<VideoPlayerState> build() async {
    ref.onDispose(dispose);
    return const VideoPlayerState();
  }

  Future<void> dispose() async {
    final controller = state.value?.controller;
    if (controller == null) return;
    await controller.pause();
    controller.removeListener(timestampUpdater);
    await controller.dispose();
  }

  @override
  Future<void> resetVideo({
    required bool autoPlay,
  }) async {
    if (state.value?.path != null) {
      await setVideo(state.value!.path!, autoPlay: autoPlay, forced: true);
    }
  }

  @override
  Future<void> setVideo(
    Uri uri, {
    required bool autoPlay,
    required bool forced,
  }) async {
    if (!forced && state.value?.path == uri) return;
    await removeVideo();

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
        VideoPlayerState(controller: controller, path: uri),
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
          print('Updating timestamp $position');
          ref.read(uriConfigurationProvider(uri).notifier).onChange(
                lastKnownPlayPosition: position,
              );
        }
      });
    }
  }

  @override
  Future<void> removeVideo() async {
    final controller = state.value?.controller;
    state = const AsyncData(VideoPlayerState());
    state = const AsyncValue.loading();

    if (controller != null) {
      await controller.pause();
      controller.removeListener(timestampUpdater);
      await controller.dispose();
    }
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
    if (state.value?.controller != null) {
      final controller = state.value!.controller!;
      final videoplayerStatus = controller.value;
      if (videoplayerStatus.isCompleted) {
        final isLive = (videoplayerStatus.duration.inSeconds) > 10 * 60 * 60;
        if (isLive) {
          await ref
              .read(videoPlayerProvider.notifier)
              .resetVideo(autoPlay: autoPlay);
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

  @override
  Uri? get uri => state.value?.path;

  @override
  Future<void> onAdjustVolume(double value) async {
    final curr = await ref.read(universalConfigProvider.future);

    if (curr.lastKnownVolume != value) {
      await ref
          .read(universalConfigProvider.notifier)
          .onChange(lastKnownVolume: value, isAudioMuted: value != 0);
    }
    if (state.value?.controller != null) {
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
    if (state.value?.controller != null) {
      final controller = state.value!.controller!;
      await controller.setVolume(mute ? 0 : curr.lastKnownVolume);
    }
  }
}

final videoPlayerProvider =
    AsyncNotifierProvider.autoDispose<VideoPlayerNotifier, VideoPlayerState>(
  VideoPlayerNotifier.new,
);
