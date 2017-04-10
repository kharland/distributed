import 'package:distributed.http/src/http_provider.dart';

/// The singleton [HttpProvider] for the current isolate.
///
/// This must be set exactly once via [initializeHttp] before invoking any HTTP
/// related methods.
HttpProvider http;

/// Sets [http] for the current isolate.
///
/// This must be called exactly once before using this library.
void initializeHttp(HttpProvider provider) {
  assert(http == null, 'http is already initialized!');
  http = provider;
}
