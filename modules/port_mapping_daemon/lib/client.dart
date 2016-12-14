import 'dart:async';
import 'dart:io';

import 'package:distributed.port_mapping_daemon/src/api/api.dart';
import 'package:distributed.port_mapping_daemon/src/daemon_handle.dart';
import 'package:path/path.dart';

export 'package:distributed.port_mapping_daemon/src/daemon_handle.dart';

class DaemonClient {
  static const _defaultTimeout = const Duration(seconds: 1);
  final DaemonSocket _channel;
  final DaemonHandle _handle;

  DaemonClient._(this._channel, this._handle);

  static Future<DaemonClient> connect(DaemonHandle handle) async {
    assert(await isDaemonRunning(handle));
    return new DaemonClient._(
        await DaemonSocket.createFromUrl(handle.url), handle);
  }

  static Future<bool> isDaemonRunning(DaemonHandle handle) async {
    var resultCompleter = new Completer<bool>();
    var channel = await DaemonSocket
        .createFromUrl(handle.url, idleTimeout: _defaultTimeout, onTimeout: () {
      resultCompleter.complete(false);
    });

    try {
      channel.stream.take(1).first.then((_) {
        resultCompleter.complete(true);
      });

      channel.sendRequestInitiation(RequestType.ping, handle.cookie);
      channel.close();
      return resultCompleter.future;
    } on SocketException catch (_) {
      return false;
    }
  }

  static Future<Process> spawnDaemon(DaemonHandle handle) {
    var dart = _findDart();
    if (dart.isEmpty) {
      throw new Exception('Could not find dart.  Set \$DARTVM to the location '
          'of the dart binary and try again.');
    }
    return _spawnDaemon(handle, dart);
  }

  Future<RegistrationResult> registerNode(String name) async {
    var resultCompleter = new Completer<RegistrationResult>();
    _channel.sendRequestInitiation(RequestType.register, _handle.cookie);
    _channel.sendRegistrationRequest(name);
    return resultCompleter.future;
  }

  static String _findDart() {
    var envPath = Platform.environment['PATH'];
    var paths = envPath.split(':').where((path) =>
        path.toLowerCase().contains('dart') &&
        path.endsWith('${Platform.pathSeparator}bin'));

    for (String path in paths) {
      path = absolute(path.replaceAll('~', Platform.environment['HOME']));
      var directory = new Directory(path);
      if (!directory.existsSync()) {
        continue;
      }

      var files = directory.listSync();
      var dartVmBinary = files.firstWhere(
          (FileSystemEntity entity) => entity.path.endsWith('dart'),
          orElse: () => null);

      if (dartVmBinary?.existsSync() == true) {
        return dartVmBinary.path;
      }
    }

    var dartVmPath = Platform.environment['DARTVM'];
    if (dartVmPath?.isNotEmpty == true) {
      return dartVmPath;
    }

    return '';
  }

  static Future<Process> _spawnDaemon(DaemonHandle handle, String dart) async {
    assert(!await isDaemonRunning(handle));

    var daemonProcess = await Process.start(
        dart,
        [
          '-c',
          'daemon_executors.dart',
          '--hostname=${handle.hostname}',
          '--port=${handle.port}',
          '--cookie=${handle.cookie}'
        ],
        mode: ProcessStartMode.DETACHED_WITH_STDIO);
    await daemonProcess.stdout.first;

    if (!await isDaemonRunning(handle)) {
      throw new StateError("Unable to start daemon");
    }

    return daemonProcess;
  }
}