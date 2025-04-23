import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/providers/show_controls.dart';
import '../../media_viewer.dart';
import '../builders/get_video_player_controls.dart';
import 'controls/on_toggle_audio_mute.dart';
import 'controls/on_toggle_play.dart';
import 'controls/toggle_fullscreen.dart';
import 'controls/video_progress.dart';
import 'media_background.dart';

class EntityFullScreenView extends ConsumerWidget {
  const EntityFullScreenView({
    required this.uri,
    required this.child,
    required this.mime,
    super.key,
  });
  final Uri uri;
  final MediaViewer child;
  final String mime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showControls =
        ref.watch(showControlsProvider.select((e) => e.showControls));
    return GetVideoPlayerControls(
      builder: (playerControls) {
        return MouseRegion(
          onHover: (onHover) =>
              ref.read(showControlsProvider.notifier).briefHover(),
          child: Center(
            child: Column(
              children: [
                Flexible(
                  child: Stack(
                    children: [
                      const MediaBackground(),
                      Center(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                final cb = switch (mime) {
                                  (_) when mime.startsWith('video') => () {
                                      ref
                                          .read(showControlsProvider.notifier)
                                          .briefHover();
                                      playerControls.onPlayPause(
                                        autoPlay: false,
                                        forced: true,
                                      );
                                    },
                                  (_) when mime.startsWith('image') => () {
                                      ref
                                          .read(showControlsProvider.notifier)
                                          .briefHover();
                                      ref
                                          .read(showControlsProvider.notifier)
                                          .fullScreenToggle();
                                    },
                                  _ => null
                                };
                                cb?.call();
                              },
                              child: child,
                            ),
                            if (showControls)
                              ...switch (mime) {
                                (_) when mime.startsWith('video') => [
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: VideoProgress(uri: uri),
                                    ),
                                    const Positioned(
                                      top: 8,
                                      right: 8,
                                      child: OnToggleFullScreen(),
                                    ),
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: OnToggleAudioMute(uri: uri),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      left: 4,
                                      bottom: 4,
                                      child: Center(
                                        child: DecoratedBox(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color.fromARGB(
                                              192,
                                              70,
                                              70,
                                              70,
                                            ), // make this configurable
                                          ),
                                          child: OnTogglePlay(uri: uri),
                                        ),
                                      ),
                                    ),
                                  ],
                                (_) when mime.startsWith('image') => [
                                    const SizedBox.shrink(),
                                  ],
                                _ => [const SizedBox.shrink()],
                              },
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
