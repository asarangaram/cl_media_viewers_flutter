import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../models/video_controls.dart';
import 'video_player_state.dart';

final videoControlProvider = StateNotifierProvider.family<VideoControlsNotifier,
    VideoPlayerController?, Uri>((ref, uri) {
  final playerState = ref.watch(videoPlayerStateProvider);
  return playerState.controllerAsync.when(
    data: (controller) {
      if (uri == playerState.path) {
        return VideoControlsNotifier(controller);
      }
      return VideoControlsNotifier(null);
    },
    error: (_, __) => VideoControlsNotifier(null),
    loading: () => VideoControlsNotifier(null),
  );
});

class VideoControlsNotifier extends StateNotifier<VideoPlayerController?>
    implements VideoControls {
  VideoControlsNotifier(super.state);

  @override
  Future<void> pause() async {
    await state?.pause();
  }

  @override
  Future<void> play() async {
    await state?.play();
  }
}
