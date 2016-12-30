The distributed_dart Port Mapper Daemon (DPMD)
==

The Daemon is responsible for assigning ports to nodes.

A node fetches the port number of another node through the daemon at the remote host to initiate a
connection request.

A Daemon must be running at each host where a node is running.  

By default the Daemon listens on port 4369.