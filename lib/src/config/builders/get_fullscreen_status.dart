import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/show_controls.dart';

class GetFullScreenStatus extends ConsumerWidget {
  const GetFullScreenStatus({
    required this.builder,
    super.key,
  });

  final Widget Function({required bool isFullScreen, required bool showMenu})
      builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showControls = ref.watch(showControlsProvider);
    return builder(
      isFullScreen: showControls.isFullScreen,
      showMenu: showControls.showMenu,
    );
  }
}
