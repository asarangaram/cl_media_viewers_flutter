import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../config/providers/universal_config.dart';
import '../../config/providers/uri_config.dart';
import '../models/uri_play_controller.dart';
import '../models/uri_play_controls.dart';
import 'universal_video_controller.dart';

class UriPlayControllerNotifier extends StateNotifier<UriPlayController>
    implements UriPlayControls {
  UriPlayControllerNotifier(this.ref, super.state, {required this.uri});
  final Ref ref;
  final Uri uri;

  VideoPlayerController? get controller => state.controller;

  @override
  Future<void> play() async => state.controller?.play();
  @override
  Future<void> pause() async => state.controller?.pause();
}

final uriPlayControllerProvider = StateNotifierProvider.family<
    UriPlayControllerNotifier, UriPlayController, Uri>((ref, uri) {
  final universalVideoController = ref.watch(universalVideoControllerProvider);
  final universalConfig = ref.watch(universalConfigurationProvider);
  final uriConfig = ref.watch(uriConfigurationProvider(uri));

  final controller = universalVideoController.controllerAsync
      .whenOrNull(data: (controller) => controller);

  return UriPlayControllerNotifier(
    ref,
    UriPlayController(
      controller: controller,
      uriConfig: uriConfig,
      universalConfig: universalConfig,
    ),
    uri: uri,
  );
});
