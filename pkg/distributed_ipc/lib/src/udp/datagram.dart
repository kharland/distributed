import 'package:collection/collection.dart';
import 'package:distributed.ipc/src/internal/enum.dart';
import 'package:meta/meta.dart';

@immutable
class DatagramType extends Enum {
  static const ACK = const DatagramType._(0x1, 'Acknowledgement');
  static const RES = const DatagramType._(0x2, 'Resend last message');
  static const DATA = const DatagramType._(0x3, 'Data part');
  static const END = const DatagramType._(0x4, 'End of message parts');
  static const GREET = const DatagramType._(0x5, 'Connection request');
  static const ERROR = const DatagramType._(100, 'Error');

  static final _valueToType = <int, DatagramType>{
    ACK.value: ACK,
    RES.value: RES,
    DATA.value: DATA,
    END.value: END,
    ERROR.value: ERROR,
  };

  /// Returns a [Datagram] whose value is [value].
  static DatagramType fromValue(int value) {
    if (!_valueToType.containsKey(value)) {
      throw new ArgumentError('Invalid datagram value $value');
    }
    return _valueToType[value];
  }

  @literal
  const DatagramType._(int value, String description)
      : super(description, value);
}

@immutable
class DatagramFactory {
  final String _address;
  final int _port;

  @literal
  const DatagramFactory(this._address, this._port);

  Datagram ack() => new Datagram(DatagramType.ACK, _address, _port);

  Datagram end() => new Datagram(DatagramType.END, _address, _port);

  ErrorDatagram error(String msg) => new ErrorDatagram(_address, _port, msg);
}

class Datagram {
  static const _equality = const DatagramEquality();

  final DatagramType type;
  final String address;
  final List<int> data;
  final int port;

  @override
  int get hashCode => _equality.hash(this);

  @override
  String toString() => '$runtimeType ${{
        'type': type,
        'address': address,
        'port': port,
      }}';

  @override
  bool operator ==(other) => _equality.equals(this, other);

  const Datagram(this.type, this.address, this.port, [this.data = const []]);
}

/// A [Datagram] that carries a payload.
@literal
class DataDatagram extends Datagram {
  /// This datagram's position within a sequence of datagrams.
  ///
  /// If this datagram is not part of a sequence, this value is always 1.
  final int position;

  /// The contents of this datagram.
  ///
  /// For now we only support utf-8 encoding.
  final List<int> payload;

  @override
  String toString() => '$runtimeType ${{
    'type': type,
    'address': address,
    'port': port,
    'position': position,
    'payload': payload,
  }}';

  @literal
  const DataDatagram(String address, int port, this.payload, this.position)
      : super(DatagramType.DATA, address, port);
}

/// A [Datagram] used to initiate communication between two nodes.
@immutable
class GreetDatagram extends Datagram {
  /// This datagram's encoding type.
  final int encodingType;

  /// A value describing the transfer algorithm to use.
  final int transferType;

  @literal
  GreetDatagram(
    String address,
    int port, {
    @required this.encodingType,
    @required this.transferType,
  })
      : super(DatagramType.GREET, address, port);
}

/// A [Datagram] used to initiate communication between two nodes.
@immutable
class ErrorDatagram extends Datagram {
  /// This datagram's error message.
  final String message;

  @literal
  ErrorDatagram(String address, int port, this.message)
      : super(DatagramType.ERROR, address, port);
}

/// An equality relation on [Datagram] objects.
@immutable
class DatagramEquality implements Equality<Datagram> {
  static final _listEq = const ListEquality().equals;

  @literal
  const DatagramEquality();

  // FIXME: compare GREET datagram.
  // FIXME: compare ERROR datagram.
  @override
  bool equals(Datagram a, Datagram b) {
    if (a is DataDatagram && b is! DataDatagram ||
        a is! DataDatagram && b is DataDatagram) {
      return false;
    } else if (a is DataDatagram && b is DataDatagram) {
      return _dataEq(a, b);
    } else {
      return _commonEq(a, b);
    }
  }

  bool _commonEq(Datagram a, Datagram b) =>
      a.type == b.type && a.address == b.address && a.port == b.port;

  bool _dataEq(DataDatagram a, DataDatagram b) =>
      _commonEq(a, b) &&
      a.position == b.position &&
      _listEq(a.payload, b.payload);

  @override
  int hash(Datagram p) => p.toString().hashCode;

  @override
  bool isValidKey(Object o) => o is Datagram;
}
