class DaemonRoutes {
  final String daemonUrl;

  DaemonRoutes(this.daemonUrl);

  String ping() => '$daemonUrl$_ping';

  String keepAlive(String nodeName) => '$daemonUrl$_ping/$nodeName';

  String node(String nodeName) => '$daemonUrl$_nodeByName/$nodeName';

  String controlServer(String nodeName) =>
      '$daemonUrl$_controlServer/$nodeName';

  String diagnosticsServer(String nodeName) =>
      '$daemonUrl$_diagnosticsServer/$nodeName';
}

const _nameParam = ":name";

const _listNodes = '/list/node';
const _nodeByName = '/node';
const _controlServer = '/node/control_server';
const _diagnosticsServer = '/node/diagnostics_server';
const _ping = '/ping';

const listNodes = _listNodes;
const nodeByName = '$_nodeByName/$_nameParam';
const controlServer = '$_controlServer/$_nameParam';
const diagnosticsServer = '$_diagnosticsServer/$_nameParam';
const keepAlive = '$_ping/$_nameParam';
const ping = _ping;
