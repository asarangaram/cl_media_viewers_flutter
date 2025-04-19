import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

import '../../config/models/universal_config.dart';
import '../../config/models/uri_config.dart';

@immutable
class UriPlayController {
  const UriPlayController({
    required this.universalConfig,
    required this.uriConfig,
    this.controller,
  });
  final UniversalConfiguration universalConfig;
  final UriConfig uriConfig;
  final VideoPlayerController? controller;

  UriPlayController copyWith({
    UniversalConfiguration? universalConfig,
    UriConfig? uriConfig,
  }) {
    return UriPlayController(
      universalConfig: universalConfig ?? this.universalConfig,
      uriConfig: uriConfig ?? this.uriConfig,
    );
  }

  @override
  bool operator ==(covariant UriPlayController other) {
    if (identical(this, other)) return true;

    return other.universalConfig == universalConfig &&
        other.uriConfig == uriConfig;
  }

  @override
  int get hashCode => universalConfig.hashCode ^ uriConfig.hashCode;

  @override
  String toString() =>
      'UriPlayController(configuration: $universalConfig, uriConfig: $uriConfig)';
}
