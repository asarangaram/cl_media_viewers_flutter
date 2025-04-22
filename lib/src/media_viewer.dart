import 'dart:async';

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
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.decoration,
    required this.keepAspectRatio,
    super.key,
    this.previewUri,
  });

  final void Function({required bool lock}) onLockPage;
  final bool isLocked;
  final bool autoStart;
  final bool autoPlay;
  final Uri uri;
  final Uri? previewUri;

  final String heroTag;
  final String mime;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

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
              isLocked: isLocked,
              onLockPage: onLockPage,
              keepAspectRatio: keepAspectRatio,
              errorBuilder: errorBuilder,
              loadingBuilder: loadingBuilder,
            ),
          (_) when mime.startsWith('video') => VideoPlayer(
              uri: uri,
              isLocked: isLocked,
              onLockPage: onLockPage,
              keepAspectRatio: keepAspectRatio,
              autoStart: autoStart,
              autoPlay: autoPlay,
              errorBuilder: errorBuilder,
              loadingBuilder: () {
                {
                  if (previewUri != null) {
                    return ImageViewer.basic(
                      uri: previewUri!,
                      errorBuilder: errorBuilder,
                      loadingBuilder: loadingBuilder,
                      keepAspectRatio: keepAspectRatio,
                    );
                  }
                  return const CircularProgressIndicator(
                    color: Colors.white,
                  );
                }
              },
            ),
          _ => runZonedGuarded(
              () {
                throw Exception('unsupported MIME');
              },
              errorBuilder,
            ),
        },
      ),
    );
  }
}
