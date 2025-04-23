/// Media Viewers
library;

import 'package:cl_media_viewers_flutter/src/image_viewer/image_viewer.dart';
import 'package:cl_media_viewers_flutter/src/image_viewer/overlay_widget.dart';
import 'package:cl_media_viewers_flutter/src/media_viewer.dart';
import 'package:cl_media_viewers_flutter/src/video_player/builders/get_uri_play_status.dart';
import 'package:cl_media_viewers_flutter/src/video_player/builders/get_video_player_controls.dart';
import 'package:cl_media_viewers_flutter/src/video_player/views/media_player_controller.dart';
import 'package:cl_media_viewers_flutter/src/video_player/views/video_player.dart';

/// Implements Widgets required to play Media.
///   Currently supports Image and Video
///   [VideoPlayer], [ImageViewer] and [MediaViewer] for raw viewing.
///
/// To show preview with overlay icons, or some minimal controls,
///   use [ImageViewer] and [OverlayWidgets]
///
/// A default control [MediaPlayerControls] is implemented with the following features
///   For Image, rotateview
///   For Video, play/pause Audio Mute, FullScreen toggle, rotateview,
///       Play Slider and time display
///   Note, [MediaPlayerControls] don't create [MediaViewer] itself and
///     you need to create and pass it as a widget. This is to avoid
///     rebuild of the core player that will create artifacts  / flicker
///
///   If you prefer to create your control, you can use
///     [GetVideoPlayerControls] to get access to all the available controls
///     exposed via [MediaPlayerControls] and
///     [GetUriPlayStatus] to get the status of the player
///
///

export 'src/config/builders/get_fullscreen_status.dart'
    show GetFullScreenStatus;
export 'src/config/models/media_view_modifier.dart' show MediaViewModifier;
export 'src/image_viewer/image_viewer.dart'
    show ImageViewer; // can we pass this over MediaViewer?
export 'src/image_viewer/overlay_widget.dart' show OverlayWidgets;
export 'src/media_viewer.dart' show MediaViewer;
export 'src/video_player/builders/get_uri_play_status.dart'
    show GetUriPlayStatus;
export 'src/video_player/builders/get_video_player_controls.dart'
    show GetVideoPlayerControls;
export 'src/video_player/models/video_player_controls.dart'
    show VideoPlayerControls;
export 'src/video_player/views/media_player_controller.dart'
    show MediaPlayerControls;
export 'src/video_player/views/video_player.dart' show VideoPlayer;
