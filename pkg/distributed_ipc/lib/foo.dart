// import 'dart:async';
// import 'package:distributed.ipc/platform/vm.dart';
// import 'package:distributed.ipc/src/protocol/byte_adapter.dart';
// import 'package:distributed.ipc/src/vm/vm_socket.dart';

// Future foo() async {
//   const config = const UdpSocketConfig(
//     transferType: TransferType.FAST,
//     address: '127.0.0.1',
//     port: 8080,
//   );

//   UdpSocket<List<int>> socket = await UdpSocket.bind(config);
//   ByteAdapter byteAdapter = new ByteAdapter(socket, socket.forEach);
//   ConnectionHost connHost;
// }
