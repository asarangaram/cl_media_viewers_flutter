import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../providers/universal_video_controller.dart';

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
    final uriPlayControlAsync = ref.watch(universalVideoControllerProvider);

    return uriPlayControlAsync.when(
      data: (uriPlayControl) {
        if (uriPlayControl.controller == null) {
          return builder(null);
        }
        return ValueListenableBuilder(
          valueListenable: uriPlayControl.controller!,
          builder: (context, value, child) {
            return builder(value);
          },
        );
      },
      error: (_, __) => builder(null),
      loading: () => builder(null),
    );
  }
}
