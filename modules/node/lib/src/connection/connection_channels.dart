import 'dart:async';
import 'package:stream_channel/stream_channel.dart';

abstract class ConnectionChannels<T> {
  StreamChannel<T> get user;

  StreamChannel<T> get system;

  StreamChannel<T> get error;

  Future close();

  Future get done;
}

abstract class ConnectionChannelsProvider<T> {
  Future<ConnectionChannels<T>> createFromUrl(String url);
}
