class DaemonRoutes {
  final String daemonUrl;

  DaemonRoutes(this.daemonUrl);

  String ping() => '$daemonUrl/ping';

  String keepAlive(String nodeName) => '$daemonUrl/ping/$nodeName';

  // TODO: Delete
  String node(String nodeName) => '$daemonUrl/node/$nodeName';

  String addNode(String nodeName) => '$daemonUrl/node/$nodeName';

  String removeNode(String nodeName) => '$daemonUrl/node/$nodeName';

  String controlServer(String nodeName) =>
      '$daemonUrl/node/control_server/$nodeName';

  String diagnosticsServer(String nodeName) =>
      '$daemonUrl/node/diagnostics_server/$nodeName';
}

// TODO: delete
const listNodes = '/list/node';
const nodeByName = '/node/:name';
const controlServer = '/node/control_server/:name';
const diagnosticsServer = '/node/diagnostics_server/:name';
const keepAlive = '/ping/:name';
const ping = '/ping';
