class HttpMethod {
  final String value;

  const HttpMethod._(this.value);

  static const HttpMethod get = const HttpMethod._('get');
  static const HttpMethod put = const HttpMethod._('put');
  static const HttpMethod post = const HttpMethod._('post');
  static const HttpMethod delete = const HttpMethod._('delete');
}
