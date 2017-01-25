class DaemonException implements Exception {
  final String message;

  const DaemonException(this.message);

  @override
  String toString() => message;
}
