import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../basics/widgets/cl_button.dart';
import '../../config/providers/show_controls.dart';
import '../../media_viewer.dart';
import '../builders/get_video_player_controls.dart';
import 'controls/cl_icons.dart';
import 'controls/on_toggle_audio_mute.dart';
import 'controls/on_toggle_play.dart';
import 'controls/toggle_fullscreen.dart';
import 'controls/video_progress.dart';
import 'media_background.dart';

class MediaPlayerControls extends ConsumerWidget {
  const MediaPlayerControls({
    required this.uri,
    required this.child,
    required this.mime,
    required this.onClose,
    super.key,
  });
  final Uri uri;
  final MediaViewer child;
  final String mime;
  final void Function()? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showControls =
        ref.watch(showControlsProvider.select((e) => e.showControls));
    final themeData = ShadTheme.of(context).copyWith(
      textTheme: ShadTheme.of(context).textTheme.copyWith(
            small: ShadTheme.of(context).textTheme.small.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                ),
          ),
      ghostButtonTheme: const ShadButtonTheme(
        foregroundColor: Colors.white,
        size: ShadButtonSize.sm,
      ),
    );
    return ShadTheme(
      data: themeData,
      child: GetVideoPlayerControls(
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
                                      //if (onClose != null)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: OnExitMediaView(
                                          onClose: onClose!,
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Column(
                                          spacing: 12,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            OnToggleAudioMute(uri: uri),
                                            const OnToggleFullScreen(),
                                          ],
                                        ),
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
      ),
    );
  }
}

class OnExitMediaView extends ConsumerWidget {
  const OnExitMediaView({
    required this.onClose,
    super.key,
  });
  final void Function() onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: CLButtonIcon.small(
          videoPlayerIcons.playerClose,
          onTap: onClose,
          color: ShadTheme.of(context).colorScheme.background,
        ),
      ),
    );
  }
}
