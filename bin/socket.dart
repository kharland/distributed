import 'dart:async';
import 'dart:io';

Future main() async {
  HttpServer server;
  Socket socket;

  try {
    server = await HttpServer.bind('127.0.0.1', 9010);
    socket = await Socket.connect('localhost', 9010);
    print(socket.add);
    print(socket.remoteAddress);
  } finally {
    await socket.close();
    await server.close(force: true);
  }
}
