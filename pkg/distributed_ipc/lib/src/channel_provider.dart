import 'dart:async';

import 'package:distributed.ipc/ipc.dart';

/// Provides multiplexed channels for IPC.
///
/// The channels can be connected to another process running on either the local
/// host or some remote host.
abstract class ChannelProvider {
  /// Completes when then channel is closed.
  Future get onClose;

  /// Creates a new [Channel].
  Channel channel(String name);

  /// Closes this provider.
  ///
  /// Every [Channel] created from this [ChannelProvider] will close, and
  /// writing to any of these channels will result in an exception.
  ///
  /// Returns a future that completes when this [Channel] is closed.
  Future close();
}