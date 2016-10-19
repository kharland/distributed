import 'package:distributed/interfaces/node.dart';
import 'package:distributed/platform/server/node.dart';

enum DistributedPlatform { Server, Browser }

DistributedPlatform _platform;

void setPlatform(DistributedPlatform platform) {
  if (_platform != null) {
    throw new StateError('The platform is already initialized!');
  }
  _platform = platform;
}

DistributedPlatform get platform => _platform;
