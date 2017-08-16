import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/src/channel_message_codec.dart';
import 'package:distributed.ipc/src/socket.dart';
import 'package:distributed.ipc/src/socket_channel_provider.dart';

/// Listens for connections at [host] on [port].
Future<ChannelProvider> listen(String host, int port) async {
  final serverSocket = await io.ServerSocket.bind(host, port);
  final provider = serverSocket.first.then(_provider);
  serverSocket.close();
  return provider;
}

/// Creates a [ChannelProvider] connected to [url].
Future<ChannelProvider> connect(String host, int port) async {
  return _provider(await io.Socket.connect(host, port));
}

ChannelProvider _provider(io.Socket socket) {
  return new SocketChannelProvider(
    new GenericSocket<String>(
      socket.transform(const Utf8Decoder()).asBroadcastStream(),
      socket as Sink<String>,
    ),
    const ChannelMessageEncoder().convert,
    const ChannelMessageDecoder().convert,
  );
}
