import 'package:distributed.ipc/src/internal/enum.dart';
import 'package:meta/meta.dart';

/// Modes describing how data should be transferred between a datagram socket.
@immutable
class TransferType extends Enum {
  /// The sender and the receiver both send and receive.
  ///
  /// When sending a message, the sender sends a message part and waits for
  /// acknowledgement from the receiver before sending another.  The receiver
  /// receives message parts and sends acknowledgement to the sender.
  ///
  /// This mode works best for transferring large pieces of data that must
  /// arrive completely at their destination.
  static const RELIABLE = const TransferType._(5, 'reliable');

  /// The sender only sends and the receiver only receives.
  ///
  /// When sending a message, the receiver does no give acknowledgement of
  /// receipt.  If a datagram is dropped it is lost forever.
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
