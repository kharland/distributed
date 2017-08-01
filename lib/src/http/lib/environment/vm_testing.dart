import 'dart:async';

import 'package:distributed.http/http.dart';
import 'package:distributed.http/src/configuration.dart';
import 'package:distributed.http/src/http_provider.dart';
import 'package:distributed.http/src/testing/http_transformer.dart';
import 'package:distributed.http/src/testing/local_address.dart';
import 'package:distributed.http/src/testing/network_emulator.dart';
import 'package:distributed.http/vm.dart';
import 'package:distributed.monitoring/logging.dart';
import 'package:meta/meta.dart';
import 'package:stream_channel/stream_channel.dart';

void configureHttp() {
  initializeHttp(
      new TestHttpProvider(new Logger('http_provider.test'), 'localhost'));
}

class TestHttpProvider implements HttpProvider {
  final NetworkEmulator _network;
  final String _localHost;

  TestHttpProvider(Logger logger, this._localHost)
      : _network = new NetworkEmulator(<NetworkAddress>[
          new NetworkAddress(_localHost, logger),
        ]);

  @override
  Future<HttpResponse> get(String url) => _send(url, 'GET');

  @override
  Future<HttpResponse> post(String url, {String payload}) =>
      _send(url, 'POST', payload: payload);

  @override
  Future<HttpResponse> delete(String url) => _send(url, 'DELETE');

  @override
  Future<HttpServer> bindHttpServer(String host, int port) async {
    return new TestHttpServer(await bindSocketServer(host, port));
  }

  @override
  Future<SocketServer> bindSocketServer(String host, int port) async {
    return new TestSocketServer(
      new AddressReleaser(host, port, _network),
      _network.listen(host, port),
    );
  }

  @override
  Future<TestSocket> connectSocket(String url) async {
    var uri = Uri.parse(url);
    return _network.connectWithoutSrcPort(_localHost, uri.host, uri.port);
  }

  Future<TestHttpResponse> _send(String url, String method,
      {String payload}) async {
    var remoteUri = Uri.parse(url);
    var responseController = new StreamChannelController<String>();
    var request = new TestHttpRequest(
        method: method,
        uri: remoteUri,
        responder: new TestHttpResponder(responseController.foreign.sink),
        payloadStream: method == 'POST'
            ? new Future<String>.value(payload).asStream()
            : new Stream<String>.empty());

    // Open a socket.dart to send the actual request, then immediately close it.
    await connectSocket(url)
      ..add(new HttpRequestSerializer().serialize(request))
      ..close();

    return new TestHttpResponse(responseController.local.stream);
  }
}

class TestHttpServer extends StreamView<ServerHttpRequest>
    with Closable
    implements HttpServer {
  final TestSocketServer _delegate;

  TestHttpServer._(Stream<ServerHttpRequest> stream, this._delegate)
      : super(stream);

  factory TestHttpServer(TestSocketServer delegate) {
    var controller = new StreamController<ServerHttpRequest>();
    delegate.forEach((Socket socket) {
      socket.transform(new HttpRequestTransformer()).forEach(controller.add);
    }).then((_) {
      controller.close();
    });
    return new TestHttpServer._(controller.stream, delegate);
  }

  @override
  String get address => _delegate.address;

  @override
  int get port => _delegate.port;

  @override
  void close() {
    _delegate.close();
    super.close();
  }

  @override
  String get url => super.url;
}

class TestSocketServer extends StreamView<Socket>
    with Closable
    implements SocketServer {
  final AddressReleaser _releaser;

  TestSocketServer(this._releaser, Stream<Socket> sockets) : super(sockets);

  @override
  String get address => _releaser.host;

  @override
  int get port => _releaser.port;

  @override
  void close() {
    _releaser.release();
    super.close();
  }
}

class TestHttpRequest extends StreamView<String> implements ServerHttpRequest {
  @override
  final String method;

  @override
  final Uri uri;

  final bool isWebSocketRequest;
  final TestHttpResponder _responder;

  TestHttpRequest({
    @required this.method,
    @required this.uri,
    @required TestHttpResponder responder,
    Stream<String> payloadStream,
    this.isWebSocketRequest: false,
  })
      : _responder = responder,
        super((payloadStream ?? new Stream.empty()).asBroadcastStream());

  @override
  TestHttpResponder get response => _responder;
}

class TestHttpResponder extends Closable implements HttpResponder {
  final Sink<String> _sink;

  TestHttpResponder(this._sink);

  @override
  void add(String data) {
    _sink.add(data);
  }

  @override
  void close() {
    _sink.close();
  }
}

class TestHttpResponse extends StreamView<String> implements HttpResponse {
  TestHttpResponse(Stream<String> responseStream) : super(responseStream);
}

class TestSocket extends StreamView<String> with Closable implements Socket {
  final AddressReleaser _releaser;
  final Sink<String> _sink;

  TestSocket(this._releaser, this._sink, Stream<String> stream) : super(stream);

  @override
  int get port => _releaser.port;

  @override
  String get localHost => _releaser.host;

  @override
  String get remoteHost => throw new UnimplementedError();

  @override
  void add(String data) {
    _sink.add(data);
  }

  @override
  void close() {
    _releaser.release();
    super.close();
  }
}

class Closable {
  final _closedCompleter = new Completer<Null>();

  Future get closed => _closedCompleter.future;

  void close() {
    _closedCompleter.complete();
  }
}
