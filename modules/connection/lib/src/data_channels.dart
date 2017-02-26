import 'dart:async';

import 'package:distributed.connection/socket.dart';
import 'package:stream_channel/stream_channel.dart';

abstract class DataChannels<T> {
  StreamChannel<T> get user;

  StreamChannel<T> get system;

  StreamChannel<T> get error;

  Future close();

  Future get done;
}

abstract class DataChannelsProvider<T> {
  Future<DataChannels<T>> createFromUrl(String url);

  Future<DataChannels<T>> createFromSocket(Socket socket);
}
