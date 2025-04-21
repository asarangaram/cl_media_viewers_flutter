import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart' as vplayer;

import '../../config/providers/uri_config.dart';
import '../providers/video_manager.dart';

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
    final controllerAsync = ref.watch(videoPlayerProvider);
    final uriConfigAsync = ref.watch(uriConfigurationProvider(uri));

    return uriConfigAsync.when(
      data: (uriConfig) => controllerAsync.when(
        data: (playControl) {
          if (playControl.path != uri || playControl.controller == null) {
            return placeHolder ?? Container();
          }
          print('uriConfig.quarterTurns: ${uriConfig.quarterTurns}');
          final controller = playControl.controller!;
          if (keepAspectRatio) {
            return AspectRatio(
              aspectRatio: uriConfig.quarterTurns.isEven
                  ? controller.value.aspectRatio
                  : 1 / controller.value.aspectRatio,
              child: RotatedBox(
                quarterTurns: uriConfig.quarterTurns,
                child: vplayer.VideoPlayer(controller),
              ),
            );
          }
          return vplayer.VideoPlayer(controller);
        },
        error: errorBuilder,
        loading: loadingBuilder,
      ),
      error: errorBuilder,
      loading: loadingBuilder,
    );
  }
}
