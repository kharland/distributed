import 'package:distributed/interfaces/node.dart';
import 'package:distributed/platform/server/node.dart';

import 'package:distributed/src/configuration.dart';

export 'package:distributed/interfaces/event.dart';
export 'package:distributed/interfaces/node.dart';
export 'package:distributed/interfaces/peer.dart';

/// Creates a new [Node] identified by [name] and [hostname].
Node createNode(String name, String hostname) =>
    platform == DistributedPlatform.Server
        ? new ServerNode(name, hostname)
        : throw new UnimplementedError();
