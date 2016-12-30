The distributed_dart Port Mapper Daemon (DPMD)
==

The DPMD is responsible for assigning ports for distributed_dart nodes.

A node fetches the port number of another node through the DPMD at the remote host to initiate a
connection request.

A DPMD must be running at each host where a node is running.  The DPMD can be started manually or
automatically as a result of the Erlang node startup.

By default the DPMD listens on port 4369.