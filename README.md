HAProxyInstance
===============

While there are already a handfull of HA Proxy abstraction layers on RubyGems, I think we needed one more. Features:

* Powerful and expressive `check_haproxy` command line utility, intended Continuous Delivery scenarios and compatible with Nagios.
    * Efficiently check many remote load balancers
    * Programmatically answer questions like, "Can we survive a rolling restart, 3 at a time?" and "Will restarting myserver01 take the site down?"
* Bring servers in and out of service programmatically.
* Doesn't try to modify configuration files. Use [haproxy-tools](https://github.com/subakva/haproxy-tools), [rhaproxy](https://github.com/jjuliano/rhaproxy), [haproxy_join](https://github.com/joewilliams/haproxy_join), or better yet, [Chef](http://www.opscode.com/chef) for that.
* Doesn't talk to sockets, yet. Use [haproxy-ruby](https://github.com/inkel/haproxy-ruby) for now if you need this.

ProTip
------

HA Proxy's awesome creator Willy Tarrreau loves [big text files](http://haproxy.1wt.eu/download/1.5/doc/configuration.txt) and [big, flat web pages](http://haproxy.1wt.eu/). If smaller, hyperlinked documents are more your style, you should know about the two alternative documentation sources:

* http://code.google.com/p/haproxy-docs/
* http://cbonte.github.com/haproxy-dconv/configuration-1.5.html

