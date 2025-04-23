import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../basics/widgets/cl_button.dart';
import '../../builders/get_uri_play_status.dart';
import 'cl_icons.dart';

class OnToggleAudioMute extends StatelessWidget {
  const OnToggleAudioMute({
    required this.uri,
    super.key,
  });

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return GetUriPlayStatus(
      uri: uri,
      builder: ([playerControls, playStatus]) {
        if (playerControls == null || playStatus == null) {
          return const SizedBox.shrink();
        }
        {
          return CLButtonIcon.small(
            playStatus.volume == 0
                ? videoPlayerIcons.audioMuted
                : videoPlayerIcons.audioUnmuted,
            onTap: playerControls.onToggleAudioMute,
            color: playStatus.volume == 0
                ? ShadTheme.of(context).colorScheme.destructive
                : ShadTheme.of(context).colorScheme.background,
          );
        }
      },
    );
  }
}
/* 
class OnToggleAudioMute2 extends StatelessWidget {
  const OnToggleAudioMute2({
    required this.uri,
    super.key,
  });

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return GetUriPlayStatus(
      uri: uri,
      builder: ([playerControls, playStatus]) {
        if (playerControls == null || playStatus == null) {
          return const SizedBox.shrink();
        }
        {
          return CircledIcon(
            playStatus.volume == 0
                ? videoPlayerIcons.audioMuted
                : videoPlayerIcons.audioUnmuted,
            onTap: playerControls.onToggleAudioMute,
            color: playStatus.volume == 0
                ? ShadTheme.of(context).colorScheme.destructive
                : ShadTheme.of(context).colorScheme.background,
          );
        }
      },
    );
  }
}
 */
