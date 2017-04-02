/* Port Daemon Server routes */

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

String toPing(String host) => '$host$ping';

String toKeepAlive(String host, String nodeName) => '$host$_ping/$nodeName';

String toNodeByName(String host, String nodeName) =>
    '$host$_nodeByName/$nodeName';

String toControlServer(String host, String nodeName) =>
    '$host$_controlServer/$nodeName';

String toDiagnosticsServer(String host, String nodeName) =>
    '$host$_diagnosticsServer/$nodeName';
