import 'package:distributed.ipc/src/udp/datagram.dart';
import 'package:meta/meta.dart';

@immutable
class DatagramRewriter {
  static final _dataRewriter = const _DataDatagramRewriter();
  static final _greetRewriter = const _GreetDatagramRewriter();

  @literal
  const DatagramRewriter();

  Datagram rewrite(@checked Datagram dg, {String address, int port}) {
    if (dg.type == DatagramType.DATA) {
      return _dataRewriter.rewrite(dg, address: address, port: port);
    } else if (dg.type == DatagramType.GREET) {
      return _greetRewriter.rewrite(dg, address: address, port: port);
    } else if (dg.type == DatagramType.ERROR) {
      throw new UnimplementedError();
    } else {
      return new Datagram(dg.type, address, port);
    }
  }
}

@immutable
class _DataDatagramRewriter implements DatagramRewriter {
  @literal
  const _DataDatagramRewriter();

  @override
  DataDatagram rewrite(DataDatagram dg, {String address, int port}) {
    return new DataDatagram(
      address ?? dg.address,
      port ?? dg.port,
      dg.payload,
      dg.position,
    );
  }
}

@immutable
class _GreetDatagramRewriter implements DatagramRewriter {
  @literal
  const _GreetDatagramRewriter();

  @override
  GreetDatagram rewrite(GreetDatagram dg, {String address, int port}) {
    return new GreetDatagram(
      address ?? dg.address,
      port ?? dg.port,
      encodingType: dg.encodingType,
      transferType: dg.transferType,
    );
  }
}
