import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart' as vplayer;

import '../providers/uri_play_controller.dart';

class VideoPlayer extends ConsumerWidget {
  const VideoPlayer({
    required this.uri,
    required this.autoStart,
    required this.autoPlay,
    required this.isLocked,
    required this.placeHolder,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.keepAspectRatio,
    super.key,
    this.onLockPage,
  });
  final Uri uri;
  final bool autoStart;
  final bool autoPlay;
  final void Function({required bool lock})? onLockPage;
  final bool isLocked;
  final bool keepAspectRatio;

  final Widget? placeHolder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uriPlayControllerAsync = ref.watch(uriPlayControllerProvider(uri));
    print('Rebuild VideoPlayer');
    return uriPlayControllerAsync.when(
      data: (uriPlayController) {
        if (uriPlayController.controller == null) {
          return placeHolder ?? Container();
        }
        if (keepAspectRatio) {
          return AspectRatio(
            aspectRatio: uriPlayController.controller!.value.aspectRatio,
            child: vplayer.VideoPlayer(uriPlayController.controller!),
          );
        }
        return vplayer.VideoPlayer(uriPlayController.controller!);
      },
      error: errorBuilder,
      loading: loadingBuilder,
    );
  }
}
