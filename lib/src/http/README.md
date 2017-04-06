distributed.http
==
This library provides an abstraction of all the HTTP resources used by any service or component in package distributed.
Its primary function is to simplify running tests on a CI server such as Travis, where code might be prohibited from
sending http requests to certain hosts, or from binding to sockets in the local host machine.

It has many limitations, and is only a partial implementation of a full HTTP library.  It intentionally implementations
only the functionality needed to build this library and will continually evolve as this library is developed.