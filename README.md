HAProxyInstance and HAProxyCluster
==================================

> "Can we survive a rolling restart, 2 at a time?"
>
> "Will restarting myserver01 take the site down?"
>
> "How many concurrent connections right now across all load balancers?"

While there are already a handfull of HA Proxy abstraction layers on RubyGems, I think we needed one more. I wanted to be able to answer questions like those above and more, quickly, accurately, and easily.

`HAProxyInstance` provides an ORM for [HA Proxy](http://haproxy.1wt.edu)'s status page.

`HAProxyCluster` provides a simple MapReduce-like framwork on top of `HAProxyInsance`.

`check_haproxy` provides a Nagios- and shell-scripting-friendly interface for `HAProxyCluster`.

Do you need to do rolling restarts of your application servers? This example assumes that `option httpchk` has been enabled for `myapp`.

```bash
#!/bin/sh
servers="server01.example.com server02.example.com server03.example.com"
load_balancers="lb01.example.com lb02.example.com"

for server in $servers ; do
    check_haproxy --eval "wait_until(true){ myapp.servers.map{|s|s.ok?} }" $load_balancers
    scp myapp.war $server:/opt/tomcat/webapps
done
```



Non-Features
------------

* Doesn't try to modify configuration files. Use [haproxy-tools](https://github.com/subakva/haproxy-tools), [rhaproxy](https://github.com/jjuliano/rhaproxy), [haproxy_join](https://github.com/joewilliams/haproxy_join), or better yet, [Chef](http://www.opscode.com/chef) for that.
* Doesn't talk to sockets, yet. Use [haproxy-ruby](https://github.com/inkel/haproxy-ruby) for now if you need this.

ProTip
------

HA Proxy's awesome creator Willy Tarrreau loves [big text files](http://haproxy.1wt.eu/download/1.5/doc/configuration.txt) and [big, flat web pages](http://haproxy.1wt.eu/). If smaller, hyperlinked documents are more your style, you should know about the two alternative documentation sources:

* http://code.google.com/p/haproxy-docs/
* http://cbonte.github.com/haproxy-dconv/configuration-1.5.html

