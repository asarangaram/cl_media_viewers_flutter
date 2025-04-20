import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../config/providers/uri_config.dart';
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
    final uriPlayController =
        ref.watch(uriPlayControllerProvider(uri).notifier);
    if (uriPlayController.controller == null) {
      return builder(null, null);
    }
    return GetUriPlayStatus0(
      uri: uri,
      uriPlayController: uriPlayController,
      builder: builder,
    );
  }
}

class GetUriPlayStatus0 extends ConsumerStatefulWidget {
  const GetUriPlayStatus0({
    required this.uri,
    required this.uriPlayController,
    required this.builder,
    super.key,
  });
  final Uri uri;
  final UriPlayControllerNotifier uriPlayController;
  final Widget Function(
    UriPlayControls? uriPlayController,
    VideoPlayerValue? videoplayerStatus,
  ) builder;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GetUriPlayStatus0State();
}

class _GetUriPlayStatus0State extends ConsumerState<GetUriPlayStatus0> {
  @override
  void initState() {
    widget.uriPlayController.controller?.addListener(_listener);
    super.initState();
  }

  @override
  void dispose() {
    //widget.uriPlayController.controller?.removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    final laskKnownPosition =
        ref.read(uriConfigurationProvider(widget.uri)).lastKnownPlayPosition;
    widget.uriPlayController.controller?.position.then((position) {
      final diff = position! - laskKnownPosition;
      if (diff > const Duration(seconds: 1)) {
        ref.read(uriConfigurationProvider(widget.uri).notifier).update(
              lastKnownPlayPosition: position,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.uriPlayController.controller!,
      builder: (context, value, child) {
        return widget.builder(widget.uriPlayController, value);
      },
    );
  }
}
