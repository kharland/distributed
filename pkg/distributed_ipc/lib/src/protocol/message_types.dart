/// Describes the type of message sent over a datagram socket.
class MessageType {
  final int value;
  final String description;

  static const ACK = const MessageType._(0x1, 'Acknowledgement');
  static const RES = const MessageType._(0x2, 'Resend last message');
  static const MSG = const MessageType._(0x3, 'Message part');
  static const END = const MessageType._(0x4, 'End of message parts');
  static const DROP = const MessageType._(0x5, 'Drop connection');
  static const CONN = const MessageType._(0x6, 'Open connection');

  static final _valueToType = <int, MessageType>{
    ACK.value: ACK,
    RES.value: RES,
    MSG.value: MSG,
    END.value: END,
    DROP.value: DROP,
    CONN.value: CONN,
  };

  static MessageType fromValue(int value) {
    assert(_valueToType.containsKey(value), 'Invalid value $value');
    return _valueToType[value];
  }

  const MessageType._(this.value, this.description);
}
