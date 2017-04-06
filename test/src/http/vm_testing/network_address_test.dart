import 'package:distributed.http/src/testing/local_address.dart';
import 'package:distributed.http/src/testing/network_agents.dart';
import 'package:distributed.http/src/testing/network_emulator.dart';
import 'package:distributed.http/vm.dart';
import 'package:distributed.monitoring/logging.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group("$NetworkAddress", () {
    NetworkAddress address;
    setUp(() {
      address = new NetworkAddress('test.host', new Logger('$NetworkAddress'));
    });

    test('attach should bind a NetworkAgent to its address', () {
      var agent = new ListeningAgent(
          new AddressReleaser(address.host, 1, new MockNetworkEmulator()));
      expect(address.agents, isEmpty);
      expect(address.isReserved(agent.port), isFalse);
      address.attach(agent);
      expect(address.agents, contains(agent));
      expect(address.isReserved(agent.port), isTrue);
    });

    test('detach should free a NetworkAgent from its address', () {
      var agent = new ListeningAgent(
          new AddressReleaser(address.host, 1, new MockNetworkEmulator()));
      expect(address.agents, isEmpty);
      expect(address.isReserved(agent.port), isFalse);
      address.attach(agent);
      expect(address.agents, contains(agent));
      expect(address.isReserved(agent.port), isTrue);
      address.detach(agent);
      expect(address.isReserved(agent.port), isFalse);
    });

    group('connect', () {
      test('should fail if no agent is bound', () {
        var listeningAgent = new ListeningAgent(
            new AddressReleaser(address.host, 1, new MockNetworkEmulator()));
        var connectingAgent = new ConnectingAgent(
            new AddressReleaser(address.host, 2, new MockNetworkEmulator()));
        expect(() => address.connect(connectingAgent, listeningAgent.port),
            throwsA(new isInstanceOf<SocketException>()));
      });

      test('should fail if the bound agent is not a listening agent', () {
        var notAListeningAgent = new ConnectingAgent(
            new AddressReleaser(address.host, 1, new MockNetworkEmulator()));
        var connectingAgent = new ConnectingAgent(
            new AddressReleaser(address.host, 2, new MockNetworkEmulator()));
        expect(() => address.connect(connectingAgent, notAListeningAgent.port),
            throwsA(new isInstanceOf<SocketException>()));
      });

      test('should connect one agent to another if another is bound', () {
        var listeningAgent = new ListeningAgent(
            new AddressReleaser(address.host, 1, new MockNetworkEmulator()));
        var connectingAgent = new ConnectingAgent(
            new AddressReleaser(address.host, 2, new MockNetworkEmulator()));
        address.attach(listeningAgent);
        expect(listeningAgent.sockets, emits(new isInstanceOf<Socket>()));
        expect(address.connect(connectingAgent, listeningAgent.port),
            new isInstanceOf<Socket>());
      });
    });
  });
}

class MockNetworkEmulator extends Mock implements NetworkEmulator {}
