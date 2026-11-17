String formatNumber(double value) {
  final abs = value.abs();
  if (abs >= 1e12) return '${(value / 1e12).toStringAsFixed(2)}T';
  if (abs >= 1e9) return '${(value / 1e9).toStringAsFixed(2)}B';
  if (abs >= 1e6) return '${(value / 1e6).toStringAsFixed(2)}M';
  if (abs >= 1e3) return '${(value / 1e3).toStringAsFixed(2)}K';
  return value.toStringAsFixed(abs < 10 ? 1 : 0);
}

String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours > 0) return '${hours}h ${minutes}m';
  if (minutes > 0) return '${minutes}m';
  return '${duration.inSeconds}s';
}
