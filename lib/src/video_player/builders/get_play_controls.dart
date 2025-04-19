import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/uri_play_controls.dart';
import '../providers/universal_video_controller.dart';
import '../providers/uri_play_controller.dart';

class GetUriVideoControls extends ConsumerWidget {
  const GetUriVideoControls({
    required this.uri,
    required this.builder,
    super.key,
  });
  final Uri uri;
  final Widget Function(
    UriPlayControls controller,
  ) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoControl = ref.watch(uriPlayControllerProvider(uri).notifier);
    return builder(videoControl);
  }
}

class GetUniversalVideoControls extends ConsumerWidget {
  const GetUniversalVideoControls({required this.builder, super.key});
  final Widget Function(
    UniversalPlayControls controller,
  ) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final control = ref.watch(universalVideoControllerProvider.notifier);
    return builder(control);
  }
}
