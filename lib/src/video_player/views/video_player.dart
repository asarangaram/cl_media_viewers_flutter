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
    super.key,
    this.onLockPage,
  });
  final Uri uri;
  final bool autoStart;
  final bool autoPlay;
  final void Function({required bool lock})? onLockPage;
  final bool isLocked;

  final Widget? placeHolder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uriPlayController = ref.watch(uriPlayControllerProvider(uri));
    if (uriPlayController.controller == null) {
      return placeHolder ?? Container();
    }
    return AspectRatio(
      aspectRatio: uriPlayController.controller!.value.aspectRatio,
      child: vplayer.VideoPlayer(
        uriPlayController.controller!,
      ),
    );
  }
}
