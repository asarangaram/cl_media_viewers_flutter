//Utils

double durationToDouble(Duration duration) => duration.inSeconds.toDouble();

Duration doubleToDuration(double position) =>
    Duration(minutes: position ~/ 60, seconds: (position % 60).truncate());
