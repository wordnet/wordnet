Uncomplicated Firewall
========

Ansible role that installs and configures ufw, AKA [The Uncomplicated Firewall](https://launchpad.net/ufw).

Role Variables
--------------

**ufw_connection_rate_limits**: A list of port and protocol pairs that should be rate limited. The default is empty. According to the ufw man page, "ufw will deny connections if an IP address has attempted to initiate 6 or more connections in the last 30 seconds." *ufw currently only supports rate limits for incoming IPv4 connections.* The following example would limit TCP connections to the SSH port, TCP and UDP connections to the DNS port, and TCP connections to the MySQL port:

    ufw_connection_rate_limits:
      - { port: 22,   protocol: tcp }
      - { port: 53,   protocol: tcp }
      - { port: 53,   protocol: udp }
      - { port: 3306, protocol: tcp }

**ufw_whitelisted_ipv4_addresses**: A list of IPv4 address, port, and protocol tuples that the firewall should allow access to. The default is empty. This is a good way to ensure that certain services can only be reached by approved IP addresses. The following example would grant SSH access to 192.168.0.1 over TCP, and OpenVPN access to 10.0.0.1 over UDP:

    ufw_whitelisted_ipv4_addresses:
      - { address: 192.168.0.1, port: 22,   protocol: tcp }
      - { address: 10.0.0.1,    port: 1194, protocol: udp }

**ufw_whitelisted_ipv6_addresses**: This variable behaves exactly the same as ufw_whitelisted_ipv4_addresses, except it applies to IPv6 addresses. The default is empty. The following example would allow Google's IPv6 address to access the DNS port over UDP, and Facebook's IPv6 address to access the Sphinx port over TCP. Note that it's important to enclose the IPv6 addresses in quotes, otherwise their colons will confuse the parser:

    ufw_whitelisted_ipv6_addresses:
      - { address: "2607:f8b0:4004:802::1001",          port: 53,   protocol: udp }
      - { address: "2a03:2880:2110:df07:face:b00c:0:1", port: 9312, protocol: tcp }

**ufw_whitelisted_ports**: A list of port and protocol pairs that the firewall should allow access to. The default is to open port 22 over TCP. This variable applies to incoming connections from both IPv4 and IPv6 clients. If you wanted to allow access to SSH, DNS, and Nginx, you might do something like this:

    ufw_whitelisted_ports:
      -  { port: 22,  protocol: tcp }
      -  { port: 53,  protocol: udp }
      -  { port: 80,  protocol: tcp }
      -  { port: 443, protocol: tcp }

License
-------

The MIT License (MIT)

Copyright (c) 2014 Joshua Lund

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Author Information
------------------

You can find me on [Twitter](https://twitter.com/joshualund), and on [GitHub](https://github.com/jlund/). I also occasionally blog at [MissingM](http://missingm.co).
