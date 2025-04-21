import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../models/uri_play_controls.dart';
import '../providers/uri_play_controller.dart';

class GetUriPlayStatus extends ConsumerWidget {
  const GetUriPlayStatus({
    required this.uri,
    required this.builder,
    super.key,
  });
  final Uri uri;
  final Widget Function(
    UriPlayControls? uriPlayController,
    VideoPlayerValue? videoplayerStatus,
  ) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uriPlayControlAsync = ref.watch(uriPlayControllerProvider(uri));
    final notifier = ref.watch(uriPlayControllerProvider(uri).notifier);
    return uriPlayControlAsync.when(
      data: (uriPlayControl) {
        if (uriPlayControl.controller == null) {
          return builder(null, null);
        }
        return ValueListenableBuilder(
          valueListenable: uriPlayControl.controller!,
          builder: (context, value, child) {
            return builder(notifier, value);
          },
        );
      },
      error: (_, __) => builder(null, null),
      loading: () => builder(null, null),
    );
  }
}
