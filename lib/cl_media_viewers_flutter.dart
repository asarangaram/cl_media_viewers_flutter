/// Media Viewers
library;

export 'src/config/models/persist_json.dart' show PersistJson;

export 'src/image_viewer/image_viewer.dart' show ImageViewer, OverlayWidgets;
export 'src/media_viewer.dart' show MediaViewer;
export 'src/video_player/builders/get_play_controls.dart'
    show GetVideoPlayerControls;
export 'src/video_player/builders/get_play_status.dart' show GetUriPlayStatus;
export 'src/video_player/models/video_player_controls.dart'
    show VideoPlayerControls;
export 'src/video_player/views/video_player.dart' show VideoPlayer;

//Utils

double durationToDouble(Duration duration) => duration.inSeconds.toDouble();

Duration doubleToDuration(double position) =>
    Duration(minutes: position ~/ 60, seconds: (position % 60).truncate());
