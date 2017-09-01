import 'package:distributed.ipc/src/enum.dart';
import 'package:meta/meta.dart';

/// Modes describing how data should be transferred between a datagram socket.
@immutable
class TransferType extends Enum {
  /// The sender and the receiver both send and receive packets.
  ///
  /// When sending a message, the sender sends a message part and waits for
  /// acknowledgement from the receiver before sending another.  The receiver
  /// receives message parts and sends acknowledgement to the sender.
  ///
  /// This mode works best for decentralized networks that require redundancy.
  static const BATCH = const TransferType._(5, 'batch');

  /// The sender only sends and the receiver only receives.
  ///
  /// When sending a message, the receiver does no give acknowledgement of
  /// receipt.  If a packet is dropped it is lost forever.
  ///
  /// This mode works best for client-server networks where speed matters more
  /// than data-loss.
  static const FAST = const TransferType._(10, 'fast');

  /// Returns the [TransferType] whose value is [value].
  ///
  /// If no matching [TransferType] is found, an [ArgumentError] is raised.
  factory TransferType.fromValue(int value) {
    if (value == FAST.value) {
      return FAST;
    } else {
      throw new UnimplementedError('$value');
    }
  }

  @literal
  const TransferType._(int value, String name) : super(name, value);
}
