# Media Viewer

    This pacakge implements Widgets to display various Media Content.

    Supported:
        Image (using extended_image package)
        Video (using video_player package)

    Planned:
        Audio
        PDF
        Markdown

## Why do I build this pacakge?

At first glance, this package may seem like a simple wrapper around extended_image and video_player. However, it introduces a few unique features that are either missing or difficult to implement with video_player alone.

### One-at-a-Time Playback

Consider a scenario where you have a grid or a PageView displaying multiple media items. If users start playing several videos simultaneously, the app is likely to run into memory issues, as each video controller begins buffering content.

Playing multiple videos at once is not practical in most use cases. This package solves that by ensuring that only one video plays at any given time. When a new video is played, any previously playing video is automatically stopped, thereby optimizing memory usage and improving performance.

### Rotate Video

Somevideos are wrongly recorded in wrong orientation. In that case, the video can be rotated. This rotation won't change the video file

### Playback Persistence

The following information is preserved across session. The information is stored internally in a SQLite database.

* Playback  volume, or mute state
* Retaining current playback position (timestamp) for individual files
* Media Rotation  for individual files

## Usage

### To display a media

    ``` dart
    MediaViewer(
        heroTag: 'heroTag',
        uri: mediaUri,
        previewUri: previewUri,
        mime: media.data.mimeType!,
        onLockPage: onLockPage,
        isLocked: isLocked,
        autoStart: autoStart,
        autoPlay: autoPlay,
        errorBuilder: (_, __) => const BrokenImage(),
        loadingBuilder: () => const GreyShimmer(),
        decoration: () => null,
        keepAspectRatio: true,
      )

    ```
    When the mime starts with 'image':
        extendedImage viewer widget is called with GestureConfig. When the user interact with it, isLocked() is signalled to the application to handle it. The application can use this signal to modify the views
    When the mime starts with 'video':
        If the controller is configured to play this specific URI, it calls the video_player with the given controller. If not, it shows the previewUri which is expected to be a image in basic mode without allowing any geustures.
        Note this widget don't start the video by itself or provide any control interface. The control interface is implemented outside this widget to give more flexibiltiy.

## Pending tasks

    [ ] Similar to VideoPlayerControls, explose ImagePlayerControls.
        - As of now, Image rotation is the only control available for image. Once we add more controls, we can expose this.
    [ ] Play at different speed.
    [ ] Create a example application to demonstrate.
        - with two use cases
          - A brower to get a video and play it.
          - A browser to get upto 4 videos and show it in a grid structure and demonstrate how the **One-at-a-Time Playback** works 
    [ ] Play from begining control.
    [ ] reset the internal cache that stores the persist          

=== TODO ====

## MediaViewer Widget

    This widget shows the media without any control. 

    MediaViewer(
        heroTag: '$parentIdentifier /item/${media.id}',
        uri: media.mediaUri!,
        previewUri: media.previewUri,
        mime: media.data.mimeType!,
        onLockPage: onLockPage,
        isLocked: isLocked,
        autoStart: autoStart,
        autoPlay: autoPlay,
        errorBuilder: (_, __) => const BrokenImage(),
        loadingBuilder: () => const GreyShimmer(),
        decoration: () => null,
        keepAspectRatio: true,
      )

 Implements Widgets required to play Media.
   Currently supports Image and Video
   [VideoPlayer], [ImageViewer] and [MediaViewer] for raw viewing.

 To show preview with overlay icons, or some minimal controls,
   use [ImageViewer] and [OverlayWidgets]

 A default control [MediaPlayerControls] is implemented with the following features
   For Image, rotateview
   For Video, play/pause Audio Mute, FullScreen toggle, rotateview,
       Play Slider and time display
   Note, [MediaPlayerControls] don't create [MediaViewer] itself and
     you need to create and pass it as a widget. This is to avoid
     rebuild of the core player that will create artifacts  / flicker

   If you prefer to create your control, you can use
     [GetVideoPlayerControls] to get access to all the available controls
     exposed via [VideoPlayerControls] and
     [GetUriPlayStatus] to get the status of the player
