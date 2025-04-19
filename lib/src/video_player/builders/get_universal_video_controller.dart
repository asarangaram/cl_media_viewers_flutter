import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../models/universal_video_controller.dart';

import '../providers/universal_video_controller.dart';

class GetUniversalVideoController extends ConsumerWidget {
  const GetUniversalVideoController({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final Widget Function(
    UniversalVideoController state,
    VideoPlayerController controller,
  ) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(universalVideoControllerProvider);
    return state.controllerAsync.when(
      data: (controller) => builder(state, controller),
      error: errorBuilder,
      loading: loadingBuilder,
    );
  }
}
