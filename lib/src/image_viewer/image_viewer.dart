import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/providers/uri_config.dart';

class OverlayWidgets extends StatelessWidget {
  factory OverlayWidgets({
    required Widget child,
    required Alignment alignment,
    double? widthFactor = 0.3,
    double? heightFactor = 0.3,
    BoxFit? fit,
    Key? key,
  }) {
    return OverlayWidgets._(
      alignment: alignment,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      key: key,
      fit: fit,
      child: child,
    );
  }
  factory OverlayWidgets.dimension({
    required Widget child,
    required Alignment alignment,
    double? sizeFactor = 0.3,
    Key? key,
    BoxFit? fit,
  }) {
    return OverlayWidgets._(
      alignment: alignment,
      widthFactor: sizeFactor,
      heightFactor: sizeFactor,
      key: key,
      fit: fit,
      child: child,
    );
  }
  const OverlayWidgets._({
    required this.alignment,
    required this.child,
    super.key,
    this.widthFactor,
    this.heightFactor,
    this.fit,
  });
  final Alignment alignment;
  final Widget child;
  final double? widthFactor;
  final double? heightFactor;
  final BoxFit? fit;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        heightFactor: heightFactor,
        child: FittedBox(
          fit: fit ?? BoxFit.contain,
          child: child,
        ),
      ),
    );
  }
}

class ImageViewer extends StatelessWidget {
  factory ImageViewer.basic({
    required Uri uri,
    required Widget? brokenImage,
    required Widget? loadingWidget,
    required bool keepAspectRatio,
    Widget? placeHolder,
    void Function({required bool lock})? onLockPage,
    Key? key,
    BoxFit? fit,
    List<OverlayWidgets>? overlays,
  }) {
    return ImageViewer._(
      key: key,
      uri: uri,
      autoStart: false,
      autoPlay: false,
      isLocked: false,
      onLockPage: onLockPage,
      placeHolder: placeHolder,
      fit: fit,
      overlays: overlays,
      hasGesture: false,
      brokenImage: brokenImage,
      loadingWidget: loadingWidget,
      keepAspectRatio: keepAspectRatio,
    );
  }
  factory ImageViewer.guesture({
    required Uri uri,
    required bool isLocked,
    required Widget? brokenImage,
    required Widget? loadingWidget,
    required bool keepAspectRatio,
    Widget? placeHolder,
    void Function({required bool lock})? onLockPage,
    Key? key,
    BoxFit? fit,
    List<OverlayWidgets>? overlays,
  }) {
    return ImageViewer._(
      key: key,
      uri: uri,
      autoStart: false,
      autoPlay: false,
      isLocked: isLocked,
      onLockPage: onLockPage,
      placeHolder: placeHolder,
      fit: fit,
      overlays: overlays,
      hasGesture: true,
      brokenImage: brokenImage,
      loadingWidget: loadingWidget,
      keepAspectRatio: keepAspectRatio,
    );
  }
  const ImageViewer._({
    required this.uri,
    required this.autoStart,
    required this.autoPlay,
    required this.isLocked,
    required this.hasGesture,
    required this.brokenImage,
    required this.loadingWidget,
    required this.keepAspectRatio,
    required this.overlays,
    required this.onLockPage,
    required this.placeHolder,
    super.key,
    this.fit,
  });

  final Uri uri;
  final bool autoStart;
  final bool autoPlay;
  final void Function({required bool lock})? onLockPage;
  final bool isLocked;
  final Widget? placeHolder;
  final Widget? brokenImage;
  final Widget? loadingWidget;
  final bool keepAspectRatio;

  final BoxFit? fit;
  //final GestureConfig Function(ExtendedImageState)? gestureControl;
  final List<OverlayWidgets>? overlays;
  final bool hasGesture;

  @override
  Widget build(BuildContext context) {
    final mode =
        hasGesture ? ExtendedImageMode.gesture : ExtendedImageMode.none;
    final image = switch (uri.scheme) {
      'file' => ExtendedImage.file(
          File(uri.toFilePath()),
          loadStateChanged: (ExtendedImageState state) {
            if (state.extendedImageLoadState == LoadState.completed) {
              return AspectRatioAware(
                state: state,
                image: state.imageProvider,
                uri: uri,
                fit: fit,
                mode: mode,
                initGestureConfigHandler: initGestureConfigHandler,
                brokenImage:
                    brokenImage ?? const Center(child: Icon(Icons.error)),
                loadingWidget: loadingWidget ??
                    const Center(child: CircularProgressIndicator()),
                keepAspectRatio: keepAspectRatio,
              );
            } else if (state.extendedImageLoadState == LoadState.failed) {
              return brokenImage ?? const Center(child: Icon(Icons.error));
            }
            return loadingWidget ??
                const Center(child: CircularProgressIndicator());
          },
          fit: fit,
          mode: mode,
          initGestureConfigHandler:
              hasGesture ? initGestureConfigHandler : null,
        ),
      _ => ExtendedImage.network(
          uri.toString(),
          loadStateChanged: (ExtendedImageState state) {
            if (state.extendedImageLoadState == LoadState.completed) {
              return AspectRatioAware(
                state: state,
                image: state.imageProvider,
                uri: uri,
                fit: fit,
                mode: mode,
                initGestureConfigHandler: initGestureConfigHandler,
                brokenImage:
                    brokenImage ?? const Center(child: Icon(Icons.error)),
                loadingWidget: loadingWidget ??
                    const Center(child: CircularProgressIndicator()),
                keepAspectRatio: keepAspectRatio,
              );
            } else if (state.extendedImageLoadState == LoadState.failed) {
              return brokenImage ?? const Center(child: Icon(Icons.error));
            }
            return loadingWidget ??
                const Center(child: CircularProgressIndicator());
          },
          fit: fit,
          mode: mode,
          initGestureConfigHandler:
              hasGesture ? initGestureConfigHandler : null,
          cache: false,
        )
    };
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

class ViewModifiedImage extends ConsumerWidget {
  const ViewModifiedImage({
    required this.image,
    required this.uri,
    required this.brokenImage,
    required this.loadingWidget,
    super.key,
    this.fit,
    this.mode,
    this.initGestureConfigHandler,
  });
  final Uri uri;
  final ImageProvider<Object> image;
  final BoxFit? fit;
  final ExtendedImageMode? mode;
  final GestureConfig Function(ExtendedImageState)? initGestureConfigHandler;
  final Widget brokenImage;
  final Widget loadingWidget;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uriConfigAsync = ref.watch(uriConfigurationProvider(uri));

    return uriConfigAsync.when(
      data: (uriConfig) {
        return RotatedBox(
          quarterTurns: uriConfig.quarterTurns,
          child: ExtendedImage(
            image: image,
            fit: fit,
            mode: mode ?? ExtendedImageMode.none,
            initGestureConfigHandler: initGestureConfigHandler,
          ),
        );
      },
      error: (_, __) => brokenImage,
      loading: () => loadingWidget,
    );

    /* return uriConfigAsync.when(
      data: (uriConfig) => controllerAsync.when(
        data: (playControl) {
          if (playControl.path != uri || playControl.controller == null) {
            return placeHolder ?? Container();
          }
          print('uriConfig.quarterTurns: ${uriConfig.quarterTurns}');
          final controller = playControl.controller;
          if (keepAspectRatio) {
            return AspectRatio(
              aspectRatio: uriConfig.quarterTurns.isEven
                  ? controller.value.aspectRatio
                  : 1 / controller.value.aspectRatio,
              child: RotatedBox(
                quarterTurns: uriConfig.quarterTurns,
                child: vplayer.VideoPlayer(controller),
              ),
            );
          }
          return vplayer.VideoPlayer(controller);
        },
        error: errorBuilder,
        loading: loadingBuilder,
      ),
      error: errorBuilder,
      loading: loadingBuilder,
    ); */
  }
}

class AspectRatioAware extends ConsumerWidget {
  const AspectRatioAware({
    required this.image,
    required this.uri,
    required this.brokenImage,
    required this.loadingWidget,
    required this.state,
    required this.keepAspectRatio,
    super.key,
    this.fit,
    this.mode,
    this.initGestureConfigHandler,
  });
  final Uri uri;
  final ImageProvider<Object> image;
  final BoxFit? fit;
  final ExtendedImageMode? mode;
  final GestureConfig Function(ExtendedImageState)? initGestureConfigHandler;
  final Widget brokenImage;
  final Widget loadingWidget;
  final bool keepAspectRatio;
  final ExtendedImageState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!keepAspectRatio) {
      return ViewModifiedImage(
        image: image,
        uri: uri,
        fit: fit,
        mode: mode,
        initGestureConfigHandler: initGestureConfigHandler,
        brokenImage: brokenImage,
        loadingWidget: loadingWidget,
      );
    }
    final imageInfo = state.extendedImageInfo;
    final width = imageInfo?.image.width.toDouble() ?? 1;
    final height = imageInfo?.image.height.toDouble() ?? 1;
    final aspectRatio = width / height;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ViewModifiedImage(
        image: image,
        uri: uri,
        fit: fit,
        mode: mode,
        initGestureConfigHandler: initGestureConfigHandler,
        brokenImage: brokenImage,
        loadingWidget: loadingWidget,
      ),
    );
  }
}
