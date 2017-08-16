/// Modes describing how data should be transferred between a datagram socket.
enum TransferMode {
  /// The sender and the receiver both send and receive packets.
  ///
  /// When sending a message, the sender sends a message part and waits for
  /// acknowledgement from the receiver before sending another.  The receiver
  /// receives message parts and sends acknowledgement to the sender.
  ///
  /// This mode works best for decentralized networks that require redundancy.
  lockstep,

  /// The sender only sends and the receiver only receives.
  ///
  /// When sending a message, the receiver does no give acknowledgement of
  /// receipt.  If a packet is dropped it is lost forever.
  ///
  /// This mode works best for client-server networks where speed matters more
  /// than data-loss.
  fast
}