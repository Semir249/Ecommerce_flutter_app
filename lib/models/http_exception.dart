class HttpException implements Exception {
  final String title;

  HttpException(this.title);

  @override
  String toString() {
    return title;
  }
}
