import 'dart:async';
import 'dart:io';

import 'package:cl_media_viewers_flutter/src/image_viewer/overlay_widget.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/models/uri_config.dart';
import '../config/providers/uri_config.dart';

class ImageViewer extends ConsumerWidget {
  factory ImageViewer.basic({
    required Uri uri,
    required Widget Function(Object, StackTrace) errorBuilder,
    required Widget Function() loadingBuilder,
    required bool keepAspectRatio,
    void Function({required bool lock})? onLockPage,
    Key? key,
    BoxFit? fit,
    List<OverlayWidgets>? overlays,
  }) {
    return ImageViewer._(
      key: key,
      uri: uri,
      isLocked: false,
      onLockPage: onLockPage,
      fit: fit,
      overlays: overlays,
      hasGesture: false,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      keepAspectRatio: keepAspectRatio,
    );
  }
  factory ImageViewer.guesture({
    required Uri uri,
    required bool isLocked,
    required void Function({required bool lock}) onLockPage,
    required bool keepAspectRatio,
    required Widget Function(Object, StackTrace) errorBuilder,
    required Widget Function() loadingBuilder,
    Key? key,
    BoxFit? fit,
    List<OverlayWidgets>? overlays,
  }) {
    return ImageViewer._(
      key: key,
      uri: uri,
      isLocked: isLocked,
      onLockPage: onLockPage,
      fit: fit,
      overlays: overlays,
      hasGesture: true,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      keepAspectRatio: keepAspectRatio,
    );
  }
  const ImageViewer._({
    required this.uri,
    required this.isLocked,
    required this.onLockPage,
    required this.hasGesture,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.keepAspectRatio,
    required this.overlays,
    super.key,
    this.fit,
  });

  final Uri uri;

  final void Function({required bool lock})? onLockPage;
  final bool isLocked;

  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final bool keepAspectRatio;

  final BoxFit? fit;
  final List<OverlayWidgets>? overlays;
  final bool hasGesture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uriConfigAsync = ref.watch(uriConfigurationProvider(uri));

    final mode =
        hasGesture ? ExtendedImageMode.gesture : ExtendedImageMode.none;
    final image = uriConfigAsync.when(
      data: (uriConfig) {
        return switch (uri.scheme) {
          'file' => ExtendedImage.file(
              File(uri.toFilePath()),
              loadStateChanged: (ExtendedImageState state) =>
                  switch (state.extendedImageLoadState) {
                LoadState.loading => loadingBuilder(),
                LoadState.completed => ImageFromState(
                    state,
                    errorBuilder: errorBuilder,
                    loadingBuilder: loadingBuilder,
                    keepAspectRatio: keepAspectRatio,
                    uriConfig: uriConfig,
                    fit: fit,
                    mode: mode,
                    initGestureConfigHandler:
                        hasGesture ? initGestureConfigHandler : null,
                  ),
                LoadState.failed => runZonedGuarded(
                    () {
                      throw Exception('Error loading image $uri');
                    },
                    errorBuilder,
                  ),
              },
              fit: fit,
              mode: mode,
              initGestureConfigHandler:
                  hasGesture ? initGestureConfigHandler : null,
            ),
          _ => ExtendedImage.network(
              uri.toString(),
              loadStateChanged: (ExtendedImageState state) =>
                  switch (state.extendedImageLoadState) {
                LoadState.loading => loadingBuilder(),
                LoadState.completed => ImageFromState(
                    state,
                    errorBuilder: errorBuilder,
                    loadingBuilder: loadingBuilder,
                    keepAspectRatio: keepAspectRatio,
                    uriConfig: uriConfig,
                    fit: fit,
                    mode: mode,
                    initGestureConfigHandler:
                        hasGesture ? initGestureConfigHandler : null,
                  ),
                LoadState.failed => runZonedGuarded(
                    () {
                      throw Exception('Error loading image $uri');
                    },
                    errorBuilder,
                  ),
              },
              fit: fit,
              mode: mode,
              initGestureConfigHandler:
                  hasGesture ? initGestureConfigHandler : null,
              cache: false,
            )
        };
      },
      error: errorBuilder,
      loading: loadingBuilder,
    );

    if (overlays?.isNotEmpty ?? false) {
      return Stack(
        children: [
          Positioned.fill(child: image),
          ...overlays!,
        ],
      );
    } else {
      return image;
    }
  }

  GestureConfig initGestureConfigHandler(ExtendedImageState state) {
    return GestureConfig(
      inPageView: true,
      animationMaxScale: 10,
      minScale: 1,
      maxScale: 10,
      gestureDetailsIsChanged: (details) {
        if (details?.totalScale == null) return;
        onLockPage?.call(lock: details!.totalScale! > 1.0);
      },
    );
  }
}

class ImageFromState extends ConsumerWidget {
  const ImageFromState(
    this.state, {
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.keepAspectRatio,
    required this.uriConfig,
    required this.mode,
    super.key,
    this.initGestureConfigHandler,
    this.fit,
  });
  final ExtendedImageState state;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final bool keepAspectRatio;
  final UriConfig uriConfig;
  final ExtendedImageMode mode;
  final BoxFit? fit;
  final GestureConfig Function(ExtendedImageState)? initGestureConfigHandler;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!keepAspectRatio) {
      return RotatedBox(
        quarterTurns: uriConfig.quarterTurns,
        child: ExtendedImage(
          image: state.imageProvider,
          fit: fit,
          mode: mode,
          initGestureConfigHandler: initGestureConfigHandler,
        ),
      );
    }
    final imageInfo = state.extendedImageInfo;
    final width = imageInfo?.image.width.toDouble() ?? 1;
    final height = imageInfo?.image.height.toDouble() ?? 1;
    final aspectRatio = width / height;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: RotatedBox(
        quarterTurns: uriConfig.quarterTurns,
        child: ExtendedImage(
          image: state.imageProvider,
          fit: fit,
          mode: mode,
          initGestureConfigHandler: initGestureConfigHandler,
        ),
      ),
    );
  }
}
