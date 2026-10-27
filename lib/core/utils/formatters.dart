class Formatters {
  /// Format seconds into mm:ss or hh:mm:ss
  static String formatDuration(int? totalSeconds) {
    if (totalSeconds == null || totalSeconds <= 0) {
      return '--:--';
    }
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:$minutesStr:$secondsStr';
    } else {
      return '$minutesStr:$secondsStr';
    }
  }

  /// Format Duration object into mm:ss
  static String formatDurationObj(Duration? duration) {
    if (duration == null) return '00:00';
    return formatDuration(duration.inSeconds);
  }

  /// Format file size from bytes to MB / KB
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
