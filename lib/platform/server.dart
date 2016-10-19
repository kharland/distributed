import 'package:distributed/src/configuration.dart';
import 'package:seltzer/platform/server.dart';

void configureDistributed() {
  useSeltzerInTheServer();
  setPlatform(DistributedPlatform.Server);
}
