import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../models/universal_video_controller.dart';
import '../models/uri_play_controls.dart';

class UniversalVideoControllerNotifier
    extends StateNotifier<UniversalVideoController>
    implements UniversalPlayControls {
  UniversalVideoControllerNotifier() : super(const UniversalVideoController());
  VideoPlayerController? controller;

  @override
  Future<void> resetVideo({
    bool autoPlay = true,
    bool forced = false,
  }) async {
    await setVideo(state.path!, forced: true);
  }

  @override
  Future<void> setVideo(
    Uri uri, {
    bool autoPlay = true,
    bool forced = false,
  }) async {
    if (!forced && state.path == uri) return;
    state = UniversalVideoController(path: uri);
    try {
      if (controller != null) {
        await controller!.pause();
        await controller!.dispose();
      }
      final VideoPlayerController newController;
      if (uri.scheme == 'file') {
        final path = uri.toFilePath();
        if (!File(path).existsSync()) {
          throw FileSystemException('missing file', path);
        }

        controller = VideoPlayerController.file(File(path));
        if (controller == null) {
          throw Exception('Failed to create controller');
        }
        newController = controller!;
        await newController.initialize();
        if (!newController.value.isInitialized) {
          throw Exception('Failed to load Video');
        }

        await newController.seekTo(Duration.zero);
        if (autoPlay) {
          await newController.play();
        }
      } else if (['http', 'https'].contains(uri.scheme)) {
        controller = VideoPlayerController.networkUrl(
          uri,
          formatHint: VideoFormat.hls,
          videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
        );
        if (controller == null) {
          throw Exception('Failed to create controller');
        }
        newController = controller!;
        await newController.initialize();
        if (!newController.value.isInitialized) {
          throw Exception('Failed to load Video');
        }

        await newController.seekTo(Duration.zero);
        if (autoPlay) {
          await newController.play();
        }
      } else {
        throw Exception('not supported');
      }

      state = state.copyWith(controllerAsync: AsyncValue.data(newController));
    } catch (error, stackTrace) {
      state = state.copyWith(controllerAsync: AsyncError(error, stackTrace));
    }
  }

  @override
  Future<void> stopVideo() async {
    if (controller != null) {
      await controller!.pause();
      state = const UniversalVideoController();
      await controller!.dispose();
      controller = null;
    }
  }

  @override
  void dispose() {
    if (mounted) {
      if (controller?.value.isPlaying ?? false) {
        controller?.pause();
      }
      controller?.dispose();
      super.dispose();
    }
  }
}

final universalVideoControllerProvider = StateNotifierProvider<
    UniversalVideoControllerNotifier, UniversalVideoController>((ref) {
  final notifier = UniversalVideoControllerNotifier();
  return notifier;
});
