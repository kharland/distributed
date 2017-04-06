import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:distributed.http/src/configuration.dart';
import 'package:distributed.http/vm.dart';
import 'package:http/http.dart' as httplib;

void configureHttp() {
  initializeHttp(new ProdHttpProvider());
}

class ProdHttpProvider implements HttpProvider {
  @override
  Future<HttpResponse> get(String url) async => throw new UnimplementedError();

  @override
  Future<HttpResponse> post(String url, {String payload}) async =>
      new ProdHttpResponse(await httplib.post(url, body: payload));

  @override
  Future<HttpResponse> delete(String url) async =>
      throw new UnimplementedError();

  @override
  Future<HttpServer> bindHttpServer(String address, int port) async {
    return new ProdHttpServer(await io.HttpServer.bind(address, port));
  }

  @override
  Future<SocketServer> bindSocketServer(String host, int port) =>
      ProdSocketServer.bind(host, port);

  @override
  Future<ProdSocket> connectSocket(String url) => ProdSocket.connect(url);
}

class ProdHttpServer extends StreamView<HttpRequest> implements HttpServer {
  final io.HttpServer _delegate;

  ProdHttpServer(io.HttpServer delegate)
      : _delegate = delegate,
        super(delegate
            .map((io.HttpRequest request) => new ProdHttpRequest(request)));

  @override
  String get address => _delegate.address.host;

  @override
  void close() {
    _delegate.close(force: true);
  }

  @override
  int get port => _delegate.port;
}

/// A server that listens for Socket requests.
class ProdSocketServer extends StreamView<Socket> implements SocketServer {
  final io.ServerSocket _delegate;

  ProdSocketServer._(this._delegate)
      : super(_delegate.asyncMap(ProdSocket.receive));

  static Future<SocketServer> bind(address, int port) async =>
      new ProdSocketServer._(await io.ServerSocket.bind(address, port));

  @override
  void close() {
    _delegate.close();
  }

  @override
  String get address => _delegate.address.host;

  @override
  int get port => _delegate.port;
}

class ProdHttpResponder implements HttpResponder {
  final io.HttpResponse _delegate;

  ProdHttpResponder(this._delegate);

  @override
  void add(String data) {
    _delegate.write(data);
  }

  @override
  void close() {
    _delegate.close();
  }
}

class ProdHttpRequest extends StreamView<String> implements HttpRequest {
  final io.HttpRequest _delegate;
  final ProdHttpResponder _responder;

  ProdHttpRequest(io.HttpRequest delegate)
      : _delegate = delegate,
        _responder = new ProdHttpResponder(delegate.response),
        super(delegate.transform(new Utf8Decoder()));

  @override
  String get method => _delegate.method;

  @override
  Uri get uri => _delegate.uri;

  @override
  ProdHttpResponder get response => _responder;
}

class ProdHttpResponse extends StreamView<String> implements HttpResponse {
  ProdHttpResponse(httplib.Response response)
      : super(new Future<String>.value(response.body).asStream());
}

class ProdSocket extends StreamView<String> implements Socket {
  final io.Socket _socket;

  ProdSocket._(io.Socket socket)
      : _socket = socket,
        super(socket.transform(new Utf8Decoder()).asBroadcastStream());

  static Future<ProdSocket> connect(String url) async {
    var uri = Uri.parse(url);
    return new ProdSocket._(await io.Socket.connect(uri.host, uri.port));
  }

  static Future<ProdSocket> receive(io.Socket socket) async {
    return new ProdSocket._(socket);
  }

  @override
  void add(String data) {
    _socket.write(data);
  }

  @override
  void close() {
    _socket.close();
  }

  @override
  String get remoteHost => throw new UnimplementedError();

  @override
  String get localHost => _socket.address.host;

  @override
  int get port => _socket.port;
}
