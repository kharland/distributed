enum SocketState {
  closed,
  idle,
  awaitingConn,
  awaitingAck,
  sending,
  receiving,
}
