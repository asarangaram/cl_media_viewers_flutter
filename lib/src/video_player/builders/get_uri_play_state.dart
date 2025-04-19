import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../providers/uri_play_controller.dart';

class GetUriPlayStatus extends ConsumerWidget {
  const GetUriPlayStatus({
    required this.uri,
    required this.builder,
    super.key,
  });
  final Uri uri;
  final Widget Function(
    VideoPlayerValue? videoplayerStatus,
  ) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uriPlayController = ref.watch(uriPlayControllerProvider(uri));
    if (uriPlayController.controller == null) {
      return builder(null);
    }
    return ValueListenableBuilder(
      valueListenable: uriPlayController.controller!,
      builder: (context, value, child) {
        return builder(value);
      },
    );
  }
}
