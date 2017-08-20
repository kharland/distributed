/// Describes the current state of a [DatagramSocket].
enum SocketState {
  /// Indicates the socket is closed and cannot be used.
  closed,

  /// Indicates the socket is not currently sending nor receiving messages.
  idle,

  /// Indicates the socket is waiting to send its next message.
  ///
  /// This state is entered when an END packet is sent while messages are still
  /// in the socket's queue.  When the remote sends an ACK in acknowledgement of
  /// the END packet, the socket will send the next message from the queue and
  /// transition to [sending].
  pending,

  /// Indicates the socket is in the middle of sending a message.
  sending,

  /// Indicates the socket is in the middle of receiving a message.
  receiving,
}
