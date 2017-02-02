class HttpMethod {
  final String value;

  const HttpMethod._(this.value);

  static const HttpMethod GET = const HttpMethod._('get');
  static const HttpMethod PUT = const HttpMethod._('put');
  static const HttpMethod POST = const HttpMethod._('post');
  static const HttpMethod DELETE = const HttpMethod._('delete');
}
