import 'package:flutter/material.dart';

import 'image_viewer/image_viewer.dart';
import 'video_player/views/video_player.dart';

class MediaViewer extends StatelessWidget {
  const MediaViewer({
    required this.uri,
    required this.onLockPage,
    required this.isLocked,
    required this.autoStart,
    required this.autoPlay,
    required this.heroTag,
    required this.mime,
    required this.previewUri,
    required this.brokenImage,
    required this.decoration,
    required this.keepAspectRatio,
    this.loadWidget,
    super.key,
  });

  final void Function({required bool lock})? onLockPage;
  final bool isLocked;
  final bool autoStart;
  final bool autoPlay;
  final Uri uri;
  final Uri? previewUri;
  final String heroTag;
  final String mime;
  final Widget brokenImage;
  final Widget? loadWidget;
  final Decoration? Function()? decoration;
  final bool keepAspectRatio;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Container(
        decoration: decoration != null
            ? decoration!()
            : BoxDecoration(
                border: Border.all(color: Colors.red),
              ),
        child: switch (mime) {
          (_) when mime.startsWith('image') => ImageViewer.guesture(
              uri: uri,
              onLockPage: onLockPage,
              isLocked: isLocked,
              brokenImage: brokenImage,
              loadingWidget: loadWidget,
              keepAspectRatio: keepAspectRatio,
            ),
          (_) when mime.startsWith('video') => VideoPlayer(
              uri: uri,
              autoStart: autoStart,
              autoPlay: autoPlay,
              onLockPage: onLockPage,
              isLocked: isLocked,
              placeHolder: previewUri == null
                  ? null
                  : ImageViewer.basic(
                      uri: previewUri!,
                      brokenImage: brokenImage,
                      loadingWidget: loadWidget,
                      keepAspectRatio: keepAspectRatio,
                    ),
              errorBuilder: (_, __) => brokenImage,
              loadingBuilder: () =>
                  loadWidget ??
                  LoadWidgetDefault(
                    previewUri: previewUri,
                    brokenImage: brokenImage,
                    loadWidget: loadWidget,
                    keepAspectRatio: keepAspectRatio,
                  ),
              keepAspectRatio: keepAspectRatio,
            ),
          _ => brokenImage,
        },
      ),
    );
  }
}

class LoadWidgetDefault extends StatelessWidget {
  const LoadWidgetDefault({
    required this.previewUri,
    required this.brokenImage,
    required this.loadWidget,
    required this.keepAspectRatio,
    super.key,
  });

  final Uri? previewUri;
  final Widget brokenImage;
  final Widget? loadWidget;
  final bool keepAspectRatio;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (previewUri != null)
          ImageViewer.basic(
            uri: previewUri!,
            brokenImage: brokenImage,
            loadingWidget: null,
            keepAspectRatio: keepAspectRatio,
          ),
        const CircularProgressIndicator(
          color: Colors.white,
        ),
      ],
    );
  }
}
