import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/uri_play_controls.dart';
import '../providers/universal_video_controller.dart';

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
