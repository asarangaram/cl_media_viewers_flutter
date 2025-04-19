import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

@immutable
class UniversalVideoController {
  const UniversalVideoController({
    this.path,
    this.controllerAsync = const AsyncValue.loading(),
  });
  final Uri? path;
  final AsyncValue<VideoPlayerController> controllerAsync;

  @override
  bool operator ==(covariant UniversalVideoController other) {
    if (identical(this, other)) return true;

    return other.path == path && other.controllerAsync == controllerAsync;
  }

  @override
  int get hashCode => path.hashCode ^ controllerAsync.hashCode;

  UniversalVideoController copyWith({
    ValueGetter<Uri?>? path,
    AsyncValue<VideoPlayerController>? controllerAsync,
  }) {
    return UniversalVideoController(
      path: path != null ? path.call() : this.path,
      controllerAsync: controllerAsync ?? this.controllerAsync,
    );
  }
}
